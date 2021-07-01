# Design

This document outlines the design of this application including decisions that were made and why.

## Requirements

From the original requirements specification,

> **Product Requirements**:
>
> 1. Clients should be able to create a shortened URL from a longer URL.
> 2. Clients should be able to specify a custom slug.
> 3. Clients should be able to expire / delete previous URLs.
> 4. Users should be able to open the URL and get redirected.
>
> **Project Requirements**:
>
> 1. The project should include an automated test suite.
> 2. The project should include a README file with instructions for running the web service and its tests. You should also use the README to provide context on choices made during development.
> 3. The project should be packaged as a zip file or submitted via a hosted git platform (Github, Gitlab, etc).
>
> **Additional Requirements**:
>
> 1. Calculate a cost for each slug, where consonants cost $1, vowels $2 and any repeated character costs $1 extra.
> a. ex: goly -> $5, oely -> $6, gole -> $6
> 2. Add a suggestion service that given a valid hostname (characters only) suggests a slug that has minimal cost.
> a. ex: goldbelly -> gldb ($4), google -> golg ($6), hi -> hihh ($7)

## Product Design

The following section details design decisions based on each product requirement.

### Create Short URLs

Creating short URLs can be done via a POST to the root url. The only required body parameter is `full_url`. `short_urls` can be provided, but if omitted an auto generated slug is used.
Much more detail on this process is [detailed below](#custom-slugs).

```bash
$ curl --dump-header - --requestPOST --url "/" --data "full_url=https://anytown.usa"
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"created_at":"2021-06-22T14:46:35Z","full_url":"https://anytown.usa","short_url":"Sa37mx"}
```

### Custom Slugs

Custom slugs can also be created by providing a `short_url` parameter to the create route.

```bash
$ curl --dump-header - --request POST --url "/" --data "full_url=https://anytown.usa" --data "short_url=any"
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"created_at":"2021-06-22T14:48:12Z","full_url":"https://anytown.usa","short_url":"any","token":"nsdo.sg89sdn.sdfnk2"}
```

There are a few restrictions to what `short_url`s are valid.

* The `short_url` must be between 4 and 100 characters in length.
* Only alpha numeric and `-_` characters are allowed.
* Any uppercase letters are converted to lower case. The reason for this, which breaks down to
security, is outlined in further [detail below](#security).

The response includes a [jwt token](https://en.wikipedia.org/wiki/JSON_Web_Token) which can be
used to expire this short. This is [detailed below](#user-management).

### Expire URLs

Expiring URLs is done through a DELETE request to the short url itself An Authorization header is
required which includes the bearer token that was given when the short was created. This token will be verified
and only a matching token will be allowed to remove the requested short ensuring only the creator can expire
a short. These tokens never expire.

```bash
$ curl --dump-header - --request DELETE --url "/any" --header "Authorization: bearer nsdo.sg89sdn.sdfnk2"
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
```

### Get Redirected

This is the heart of the project. To go from a short url to a full url,
simply perform a GET request to the short url.

```bash
$ curl --dump-header - --request GET --url "/any"
HTTP/1.1 302 Found
Location: https://anytown.usa
Content-Type: text/html; charset=utf-8
```

There are a few key considerations with this functionality.

1. Speed - This action should always be fast.
2. Security - We should prevent security concerns when possible.
3. Scale - This design should scale reasonably well.

#### Speed

The first point is achieved with a few techniques. Translations from short url to full url are done by a SQL
query that is covered by an index. This means the
[`short_url` field is indexed](https://github.com/truggeri/rails-url-shortener/blob/a7454fb2ab59019972cb9c28477bb1ebb2fa7b63/db/migrate/20210622000232_create_shorts.rb#L10).
If we need
further optimization, an in-memory cache could be used to enhance speed of "hot" slugs, but for now we will only
be relying on the PostgreSQL cache. Any non-local cache (memcached, Redis) _might_ be faster, but because they
are across the network, it is possible that such a solution offers no additional performance while adding a
decent amount of complexity and cost.

#### Security

The second point has two pieces. The first is not allowing injection or poorly formed URLs by reducing the
character set that is allowed. We only allow alphanumeric characters (`A-Z`, `a-z` and `0-9`) as well as
`-` and `_` to get at least 64 character options. This avoids issues with
[script injecting](https://en.wikipedia.org/wiki/Code_injection) and
[homographic attacks](https://en.wikipedia.org/wiki/IDN_homograph_attack).

We also need to consider takeover attacks where an attacker takes a `short_url` that is similar to another
short one in order to trick unsuspecting users (ex: `example` and `Example`). We can achieve this by only
allowing custom slugs to be lower case. The reason not to down case incoming slugs is that it would both increase
our computation time, doing the down case on every request, and it would reduce our available characters by 26.

Another approach would be to do the lookup by a `short_url` as given, and if it misses in the database, try
again after down casing. This would work and maintain our full character set, but it would violate our first
consideration - keep this route fast. In order to maintain speed, we should also avoid running multiple SQL queries to determine the `full_url`. This leads to our final solution which is to
[down case all custom slugs](https://github.com/truggeri/rails-url-shortener/blob/a7454fb2ab59019972cb9c28477bb1ebb2fa7b63/app/controllers/shorts_controller.rb#L19)
before saving them to the database.

#### Scale

The final consideration is how this design will scale. The product requirements give no bound to the scale of
the application. This means the design must strike a balance between speed of development, complexity of the
solution and potential future scaling.

Based on 64 possible characters and a default of six characters for a random short, there are
69 billion possible shorts. If we ever need more, we can add another digit.

```math
64^6 = 68,719,476,736
```

This provides the balance between available options and our choice of data store, PostgreSQL.

While the read may be fast, we should also consider the speed of the create. If we only randomly generate
a code and then check to ensure it's not taken, we will slow down dramatically as the number of shorts grow.
Said another way, the naive approach to code generation is `O(n)` for `n` existing shorts.
An ideal solution would be able to generate a random that's in order `O(1)`.
This is an optimization that is [detailed below](#auto-generated-slugs).

## Project Design

This section outlines aspects of the application design that relate to the project requirements.

### Test Suite

[![GitHub Actions Badge](https://img.shields.io/badge/-GitHub_Actions-4b93e6?style=flat&labelColor=2088FF&logo=github-actions&logoColor=white)](https://github.com/truggeri/rails-url-shortener/actions)

The testing suite and linting are run as part of
[continuous integration](https://en.wikipedia.org/wiki/Continuous_integration)
[using GitHub Actions](https://github.com/truggeri/rails-url-shortener/actions).

The test suite can also be run locally.

```bash
bundle exec rspec spec/
```

And linting can also be done locally.

```bash
bundle exec rubocop -D
```

### README File

This project includes a [root README file](../README.md) which references this document as well as others.

### Source Code Hosting

[![Heroku Badge](https://img.shields.io/badge/-GitHub-322626?style=flat&labelColor=181717&logo=github&logoColor=white)](https://github.com/truggeri/rails-url-shortener)

This project is hosted using [GitHub](https://github.com/) at [https://github.com/truggeri/rails-url-shortener](https://github.com/truggeri/rails-url-shortener).

## Additional Requirements

A later pairing session brought about the following additions.

### Cost Calculation

The cost calculation is done as a [before-validation action on the `Short` model](https://github.com/truggeri/rails-url-shortener/blob/6d94c5c421e59b95427749c15f62b4de91d0f8b8/app/models/short.rb#L34).
It iterates over each character and tallies a cost per character.
A slight modification was made to allow for digits and `-_` characters at a cost of $3 each. Reoccurrences are
handled by a hash for quick access. This cost is then saved to the model to avoid recalculation.

### Suggestion Service

There is a [suggestion service](https://github.com/truggeri/rails-url-shortener/blob/main/app/lib/suggestion.rb)
that takes in a hostname (such as `google`) and outputs a suggestion at minimal cost.
This works by breaking the hostname into possible characters (consonants and vowels), then iterating in order of

* Unused consonants ($1 each)
* Unused vowels ($2 each)
* Used consonants ($2 each)
* Used vowels ($3 each)

A random selection is done for each used character to provide unique suggestions. A randomization _could_ be done
on all characters after the generation too.

## Future Improvements

To see areas for improvement, [read our documentation](./future_improvements.md).

## Notes

The following are additional design notes.

### User Management

There are currently no restrictions on creating shorts. This means that anyone from the public internet can
create shorts and remove their own shorts. This is an intentional design choice. DDoS or spamming should be
handled by the network defense layer (such as [Cloudflare](https://www.cloudflare.com)),
not this application itself.

The expiration of a short is restricted by a [Json Web Token (jwt)](https://jwt.io/introduction)
which is provided at creation. This ensures that only the creator has the authority to remove their short.
The token is signed using HS256, so it cannot be tampered with or faked and all the information it contains
is safe for public viewing so there is no need to encrypt it with
[Json Web Encryption (jwe)](https://en.wikipedia.org/wiki/JSON_Web_Encryption).

### Auto Generated Slugs

A [recent change](https://github.com/truggeri/rails-url-shortener/commit/fd2b7d22bd1a9287171194c39d6aab5bdde7eefb)
was made in the mechanism for generating a slug. The original implementation created a random
string using Base64. This would work fine when the total space of available slugs is sparse,
but as the number of available slugs became small, the number of random draws to get a valid slug would increase.

The [new mechanism](https://github.com/truggeri/rails-url-shortener/blob/main/app/lib/slug.rb) will create
a code in `O(1)` time, even as the available space of slugs decreases. It uses
a base 64 conversion of the next available integer id.
This creates a code that is likely to be available unless it was already taken by a custom slug.
The process is also no slower than a random Base64 encoded string generation would be.
