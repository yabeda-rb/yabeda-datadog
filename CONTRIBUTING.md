# Contributing

1. Fork the repo.

1. Run `./bin/setup`.

1. Run the tests. We only take pull requests with passing tests, and it's great to know that you have a clean slate: `rake spec`.

1. Make sure your editor has [rubocop gem](https://github.com/rubocop-hq/rubocop) integration or using rubocop as CLI tool and you are not violating code style rules.

1. Add a test for your change. Only refactoring and documentation changes require no new tests. If you are adding functionality or fixing a bug, we need a test!

1. Make the test pass.

1. Write a [good commit message][commit].

1. Push to your fork and submit a pull request.

Others will give constructive feedback.  This is a time for discussion and improvements, and making the necessary changes will be required before we can merge the contribution.

## Start Application in Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

You can run a Datadog agent in a docker container with the following command:

    $ bin/dev

Beware that the agent will collect metrics (a lot) from docker itself and your OS and  all launched docker containers. You have to provide `DD_API_KEY` in `.datadog-agent.env` file. You can put additional environment variable for Datadog agent container into this file

Example of `.datadog-agent.env` file:

```shell
# required
DD_API_KEY=<your Datadog API key>
DD_DOGSTATSD_NON_LOCAL_TRAFFIC=true
# optinal
DD_HOSTNAME=my-development-computer
```

As a real usage example you can run:

    $ YABEDA_DATADOG_API_KEY=<your Datadog API key> YABEDA_DATADOG_APP_KEY=<your Datadog App key> ruby examples/script.rb

To install this gem onto your local machine, run:

    $ bundle exec rake install

To release a new version, update the version number in `version.rb`, and then run:

    $ bundle exec rake release

Which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

[commit]: http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html
