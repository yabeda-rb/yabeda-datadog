# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Fixed

- Compatibility with dogstatd v5

## 0.3.5 - 2019-05-22

### Fixed

 - Relaxed anyway_config dependency constraint as there is no breaking changes in anyway_config 2.0. [@palkan]

## 0.3.4 - 2019-03-12

### Fixed

 - Problem with Gemfile.lock introduced in 0.3.3. [@dmshvetsov]

## 0.3.3 - 2019-03-12

### Fixed

 - Counters displayed with decimal values in Datadog dashboards. [@dmshvetsov], [#18](https://github.com/yabeda-rb/yabeda-datadog/pull/18)

## 0.3.2 - 2019-02-14

### Fixed

 - Convert unit names from plural form to singular as Datadog accepts only singular names. [@dmshvetsov], [#16](https://github.com/yabeda-rb/yabeda-datadog/pull/16)

## 0.3.1 - 2019-01-17

### Fixed

 - Relaxed Ruby version constraint. [@palkan], [#14](https://github.com/yabeda-rb/yabeda-datadog/pull/14)

## 0.3.0 - 2019-01-11

First known version by [@dmshvetsov] and [@Neyaz].

[@palkan]: https://github.com/palkan "Vladimir Dementyev"
[@dmshvetsov]: https://github.com/dmshvetsov "Dmitry Shvetsov"
[@Neyaz]: https://github.com/Neyaz "Nikolay Malinin"
