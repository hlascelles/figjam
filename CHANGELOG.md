## 2.2.1 (2025-07-17)

- Add require in engine helper [#225](https://github.com/hlascelles/figjam/pull/225)

## 2.2.0 (2025-07-16)

- Add Rails Engine helper [#224](https://github.com/hlascelles/figjam/pull/224)

## 2.1.0 (2025-07-15)

- Raise exception if config path is invalid [#223](https://github.com/hlascelles/figjam/pull/223)

## 2.0.1 (2025-06-03)

- Adding trusted publishing [#216](https://github.com/hlascelles/figjam/pull/216)

## 2.0.0 (2025-04-12)

BREAKING CHANGE:
- Enforce uppercase ENV keys [#184](https://github.com/hlascelles/figjam/pull/184)

## 1.6.2 (2024-09-10)

- Reduce override log level to info [#160](https://github.com/hlascelles/figjam/pull/160)

## 1.6.1 (2024-04-28)

- Add ruby 3.3 tests [#117](https://github.com/hlascelles/figjam/pull/117)
- Remove ruby 2.7 and Rails 5 tests, add ruby 3.x tests and upgrade rubocop to 1.42.0 [#100](https://github.com/hlascelles/figjam/pull/100)
- Apply quality fixes [#9](https://github.com/hlascelles/figjam/pull/9)

## 1.6.0 (2022-12-20)

- Support Psych 4.X+ to correctly handle YAML aliases [#16](https://github.com/hlascelles/figjam/pull/16)

## 1.5.0 (2022-11-30)

- Ensure that Figjam.adapter is set to Figjam::Rails::Application before the figjam Railtie is loaded [#7](https://github.com/hlascelles/figjam/pull/7)
- Allow silencing of non-string configuration warnings [#8](https://github.com/hlascelles/figjam/pull/8)

## 1.4.0 (2022-11-14)

- Add rubocop, fasterer, reek and Appraisal [#1](https://github.com/hlascelles/figjam/pull/1)

## 1.3.0 (2022-11-10)

- Aliased main module Figaro to Figjam to allow easier migration. 

## 1.2.0 (2022-11-10)

- First release. A hard fork of Figaro (with thanks to Steve Richert!). Retained latest published
  version for drop-in compatibility, but no functional changes.
