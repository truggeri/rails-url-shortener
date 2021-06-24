# Rails Url Shortener

[![Test](https://github.com/truggeri/rails-url-shortener/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/truggeri/rails-url-shortener/actions/workflows/test.yml)
![Coverage Badge](https://img.shields.io/badge/coverage-100%25-brightgreen.svg)

A simple Rails application that is an api based url shortener.
Try it out at [https://short.truggeri.com/](https://short.truggeri.com/) using our [api docs](https://short.truggeri.com/docs) as a guide.

![RoR Badge](https://img.shields.io/badge/-Ruby_On_Rails-b32424?style=flat&labelColor=cc0000&logo=ruby-on-rails&logoColor=white)
![PostgreSQL Badge](https://img.shields.io/badge/-PostgreSQL-426078?style=flat&labelColor=336791&logo=postgresql&logoColor=white)

[![Github Badge](https://img.shields.io/badge/-GitHub-322626?style=flat&labelColor=181717&logo=github&logoColor=white)](https://github.com/truggeri/rails-url-shortener)
[![GitHub Actions Badge](https://img.shields.io/badge/-GitHub_Actions-4b93e6?style=flat&labelColor=2088FF&logo=github-actions&logoColor=white)](https://github.com/truggeri/rails-url-shortener/actions)
[![OpenAPI Badge](https://img.shields.io/badge/-OpenAPI_Spec-8dd152?style=flat&labelColor=85EA2D&logo=swagger&logoColor=white)](./docs/api-spec.yaml)

![Heroku Badge](https://img.shields.io/badge/-Heroku-45197f?style=flat&labelColor=430098&logo=heroku&logoColor=white)
![Docker Badge](https://img.shields.io/badge/-Docker-4b99d4?style=flat&labelColor=2496ED&logo=docker&logoColor=white)

## Requirements and Design

For detailed information on the requirements and design, see [our detailed design documentation](docs/design.md).

## Development

To get started, you'll need to setup dependencies.

### PostgreSQL Database

This app uses [PostgreSQL 13](https://www.postgresql.org/docs/13/) for it's datastore. In order to configure one, provide a database URL via an environment variable.

```bash
export DATABASE_URL=postgres://<username>:<password>@<host>:<port>/rails_url_shortener
```

This database can be setup in any fashion that you choose. Options include [local install](https://www.postgresql.org/download/), [Docker](https://hub.docker.com/_/postgres?tab=description), or as [a web service](https://www.heroku.com/postgres).

### Docker

If you'd like to run using Docker, there is a Dockerfile provided.
To use, build the container first and then run it with your configured database and port.

```bash
docker build -t rails-url-shortener .
docker run --rm -e DATABASE_URL=$DATABASE_URL -p 3000:3000 rails-url-shortener
```

## Future Improvements

Of course, there's always more to do. [Read our documentation](./docs/future_improvements.md) on
upcoming areas of improvement.
