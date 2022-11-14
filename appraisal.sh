#!/usr/bin/env bash
set -euo pipefail

bundle exec appraisal rspec "$@"
