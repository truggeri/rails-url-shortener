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

ToDo

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
