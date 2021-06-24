# Future Improvements

The following are ideas for how the product could be enhanced in the future.

## Additional User Management

If user accounts were desired in the future, one solution would be to "roll our own" user management.
This is okay for a small scale project as one can own their own code.
There are also lots of helper libraries such as [Devise](https://github.com/heartcombo/devise).

Another option, depending on the business requirements, are to use an external service to manage users. Such
options include [Auth0](https://auth0.com/) and [Aws Cognito](https://aws.amazon.com/cognito/). These solutions
are great because they offer features that would be extremely difficult to implement on our own such as
external identity providers (Google, Facebook, Apple, etc.), multi-factor authentication and security updates.
Of course, not every organization will be comfortable exporting this functionality to an external partner.
A working example of such a setup with Auth0 can be seen in
[this branch](https://github.com/truggeri/rails-url-shortener/tree/auth0-exp).

## Analytics

It would be useful if we could see the number of uses of each short. This can be a tricky to implement
if scale is considered. I would _not_ recommend keeping a counter on the `shorts` table itself because this would
involve a write for every access, though it would work as a small scale implementation.

A longer term solution would be an asynchronous action that would take the short URL and create an event in a
scalable manner. This could start out with something like [Sidekiq](https://github.com/mperham/sidekiq) or
[Aws SQS](https://aws.amazon.com/sqs/) acting as the async barrier and a write to
another PostgreSQL table or Redis cache. A more long term solution would be to an event stream such as
[Kafka](https://kafka.apache.org/), [Aws Kinesis](https://aws.amazon.com/kinesis/) or
[Google Cloud Pub/Sub](https://cloud.google.com/pubsub) to take in an event stream of activity
and then a service on the consuming side to store these records, perhaps to a data store
([MongoDB](https://www.mongodb.com/), etc.) or a
[data lake](https://aws.amazon.com/big-data/datalakes-and-analytics/what-is-a-data-lake/)
(using [S3](https://aws.amazon.com/s3/)).

## Short URL Recovery

Short URLs currently live forever or until their creator destroys them.
We could set an arbitrary lifespan for shorts such that they will be recovered for the pool of available urls.
This could be only a time limit (ex: six or 12 months), or take into account the last time the short was used.

I would recommend doing this as an asynchronous process though a worker such as
[Sidekiq](https://github.com/mperham/sidekiq). A cron job could be setup to run periodically that looks for
matching recoverable shorts and recovers them. This would also mean a mechanism for recovery, such as a table
of available slugs that are pulled from when a new short is created.

## Speed/Scale Improvements

There are a few ideas that would enhance the speed or scale of the app.

### Distribution

The current mechanism used for generating new slugs may slow down if the system becomes widely distributed across
computation nodes. This is because it relies on getting the last integer id of the shorts table.
In a widely distributed system, this may cause a large number of locks and stale data as the number
of nodes increased. A more centralized source of truth or better distributed generation algorithm could be used
to mitigate this type of problem. Because the system is not widely distributed yet, this increased complexity
is not currently worth the effort it would take to implement.
