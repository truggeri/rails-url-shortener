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

ToDo

### Custom Slugs

ToDo

### Expire URLs

ToDo

### Get Redirected

This is the heart of the project. There are a few key considerations with this functionality.

1. This action should always be fast.
2. We should prevent security concerns when possible.

The first point can be achieved with a few techniques. Translations from short url to full url are done by a SQL
query that should be covered by an index. This means the `short_url` field needs to be indexed. If we need
further optimization, an in-memory cache could be used to enhance speed of "hot" slugs, but for now we will only
be relying on the PostgreSQL cache.

The second point has two pieces. The first is not allowing injection or poorly formed URLs by reducing the
character set that is allowed. We only allow alphanumeric characters (`A-Z`, `a-z` and `0-9`) as well as
`-` and `_` to get to an even 64 characters. This avoids issues with script injecting and homographic attacks.

We also need to consider takeover attacks where an attacker takes a `short_url` that is similar to another
short one in order to trick unsuspecting users (ex: `example` and `Example`). We can achieve this by only
allowing custom slugs to be lower case. The reason not to down case incoming slugs is that it would both increase
our computation time, doing the actual down case, and it would reduce our available characters by 26.

Another approach would be to do the lookup by a `short_url` as given, and if it misses in the database, try
again after down casing. This would work and maintain our full character set, but it would violate our first
consideration - keep this route fast. In order to maintain speed, we should also avoid running multiple SQL queries to determine the `full_url`. This is done by not allowing users to enter custom slugs with upper case letters so a down case is not necessary as a second query.

## Project Design

This section outlines aspects of the application design that relate to the project requirements.

### Test Suite

[![GitHub Actions Badge](https://img.shields.io/badge/-GitHub_Actions-4b93e6?style=flat&labelColor=2088FF&logo=github-actions&logoColor=white)](https://github.com/truggeri/rails-url-shortener/actions)

The testing suite is run as part of continuous integration using GitHub Actions.

To run the test suite locally,

```bash
bundle exec rspec spec/
```

### README File

This project includes a [root README file](../README.md) which references this document as well as others.

### Source Code Hosting

[![Heroku Badge](https://img.shields.io/badge/-GitHub-322626?style=flat&labelColor=181717&logo=github&logoColor=white)](https://github.com/truggeri/rails-url-shortener)

This project is hosted using [GitHub](https://github.com/) at [https://github.com/truggeri/rails-url-shortener](https://github.com/truggeri/rails-url-shortener).
