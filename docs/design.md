# Design

This document outlines the design of this application including decisions that were made and why.

## Requirements

From our original requirements specification,

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

## Product Design

The following section details design decisions based on each product requirement.

### Create Short URLs

Creating short URLs can be done via POST to the root. The only required parameter is `full_url` as empty
`short_urls` get an auto generated code. Much more detail on this will be detailed later.

```bash
$ curl -D - -X POST --url "/" --data "full_url=https://anytown.usa"
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"created_at":"2021-06-22T14:46:35Z","full_url":"https://anytown.usa","short_url":"Sa37mxEZilg-"}
```

### Custom Slugs

Custom slugs can also be created by providing a `short_url` parameter to the create route.

```bash
$ curl -D - -X POST --url "/" --data "full_url=https://anytown.usa" --data "short_url=any"
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"created_at":"2021-06-22T14:48:12Z","full_url":"https://anytown.usa","short_url":"any","token":"nsdo.sg89sdn.sdfnk2"}
```

There are a few restrictions to what `short_url`s are valid. Only alpha numeric and `-`, `_` and `+` characters
are allowed. Any uppercase letters are converted to lower case. The reason for this, which breaks down to
security, is outlined in further detail below.

The response includes a token which can be used to expire this short. The token does not expire.

### Expire URLs

Expiring URLs is done through a DELETE HTTP request to the short url to be deleted. An Authorization header is
required which includes the bearer token that was given when the short was created. This token will be verified
and only a matching token will be allowed to remove the requested short ensuring only the creator can expire
a short.

```bash
$ curl -D - -X DELETE --url "/any" --header "Authorization: bearer nsdo.sg89sdn.sdfnk2"
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{}
```

### Get Redirected

This is the heart of the project. To go from a short url to a full url, simply perform a GET to the short url.

```bash
$ curl -D - -X GET --url "/any"
HTTP/1.1 302 Found
Location: https://anytown.usa
Content-Type: text/html; charset=utf-8
```

There are a few key considerations with this functionality.

1. This action should always be fast.
2. We should prevent security concerns when possible.
3. This design should scale reasonably well.

#### Speed

The first point can be achieved with a few techniques. Translations from short url to full url are done by a SQL
query that should be covered by an index. This means the `short_url` field needs to be indexed. If we need
further optimization, an in-memory cache could be used to enhance speed of "hot" slugs, but for now we will only
be relying on the PostgreSQL cache. Any non-local cache (memcached, Redis) _might_ be faster, but because they
are across the network, it is possible that such a solution offers no additional performance while adding a
decent amount of complexity.

#### Security

The second point has two pieces. The first is not allowing injection or poorly formed URLs by reducing the
character set that is allowed. We only allow alphanumeric characters (`A-Z`, `a-z` and `0-9`) as well as
`-`, `_` and `+` to get at least 64 character options. This avoids issues with
[script injecting](https://en.wikipedia.org/wiki/Code_injection) and
[homographic attacks](https://en.wikipedia.org/wiki/IDN_homograph_attack).

We also need to consider takeover attacks where an attacker takes a `short_url` that is similar to another
short one in order to trick unsuspecting users (ex: `example` and `Example`). We can achieve this by only
allowing custom slugs to be lower case. The reason not to down case incoming slugs is that it would both increase
our computation time, doing the down case on every request, and it would reduce our available characters by 26.

Another approach would be to do the lookup by a `short_url` as given, and if it misses in the database, try
again after down casing. This would work and maintain our full character set, but it would violate our first
consideration - keep this route fast. In order to maintain speed, we should also avoid running multiple SQL queries to determine the `full_url`. This is done by not allowing users to enter custom slugs with upper case letters so a down case is not necessary as a second query.

#### Scale

The final consideration is how this design will scale. The product requirements give no bound to the scale of
the application. This means the design must strike a balance between speed of development, complexity of the
solution and potential future scaling.

Based on 65 possible characters and a default of six characters for a random short, there are
75.4 billion possible shorts.

```math
65^6 = 75,418,890,625
```

This provides the balance between available options and our choice of data store, PostgreSQL.

While the read may be fast, we should also consider the speed of the create. If we only randomly generate
a code and then check to ensure it's not taken, we will slow down dramatically as the number of shorts grow.
Said another way, the naive approach to code generation is `O(n)` for `n` existing shorts.
An ideal solution would be able to generate a random that's in order `O(1)`. This is an optimization that
we will aim to develop in the future.

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
The token is signed using HS256, so it cannot be tampered with or faked.
