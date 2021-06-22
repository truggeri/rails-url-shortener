# Rails Url Shortener

A simple Rails application that acts as an api based url shortener.

![RoR Badge](https://img.shields.io/badge/-Ruby_On_Rails-b32424?style=flat&labelColor=cc0000&logo=ruby-on-rails&logoColor=white)
![PostgreSQL Badge](https://img.shields.io/badge/-PostgreSQL-426078?style=flat&labelColor=336791&logo=postgresql&logoColor=white)
[![Heroku Badge](https://img.shields.io/badge/-GitHub-322626?style=flat&labelColor=181717&logo=github&logoColor=white)](https://github.com/truggeri/rails-url-shortener)
[![GitHub Actions Badge](https://img.shields.io/badge/-GitHub_Actions-4b93e6?style=flat&labelColor=2088FF&logo=github-actions&logoColor=white)](https://github.com/truggeri/rails-url-shortener/actions)
[![OpenAPI Badge](https://img.shields.io/badge/-OpenAPI_Spec-8dd152?style=flat&labelColor=85EA2D&logo=swagger&logoColor=white)](./docs/api-spec.yaml)

## Application Requirements

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

For more detailed information, see [our detailed design documentation](docs/design.md).

## Development

To get started, you'll need the following dependencies setup.

### PostgreSQL Database

This app uses [PostgreSQL 13](https://www.postgresql.org/docs/13/) for it's datastore. In order to configure one, provide a database URL via an environment variable.

```bash
export DATABASE_URL=postgres://<username>:<password>@<host>:<port>/rails_url_shortener
```

This database can be setup in any fashion that you choose. Options include [local install](https://www.postgresql.org/download/), [Docker](https://hub.docker.com/_/postgres?tab=description), or as [a web service](https://www.heroku.com/postgres).
