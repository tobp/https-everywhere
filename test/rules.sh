#!/bin/bash -ex
#
# Test that all rulesets modified after a certain date have sufficient test
# coverage, according to the ruleset checker.
#

# Get to the repo root directory, even when we're symlinked as a hook.
if [ -n "$GIT_DIR" ]
then
    # $GIT_DIR is set, so we're running as a hook.
    cd $GIT_DIR
else
    # Git command exists? Cool, let's CD to the right place.
    git rev-parse && cd "$(git rev-parse --show-toplevel)"
fi

source utils/mktemp.sh

TMP="$(mktemp)"
trap 'rm "$TMP"' EXIT
if ! [ -d https-everywhere-checker ] ; then
  echo "Submodule https-everywhere-checker is missing. Run"
  echo "./install-dev-dependencies.sh"
  exit 1
fi
if [ $# -gt 0 ] ; then
  exec python2.7 https-everywhere-checker/src/https_everywhere_checker/check_rules.py \
    https-everywhere-checker/coverage.checker.config "$@"
fi
if ! python2.7 https-everywhere-checker/src/https_everywhere_checker/check_rules.py \
      https-everywhere-checker/coverage.checker.config; then
  echo "Ruleset test coverage was insufficient."
  echo ""
  echo "Under the new ruleset testing rules (February 2015), any modified ruleset"
  echo "must have sufficient test coverage. You can often improve test coverage by"
  echo "adding <test url='...' /> tags, or by restructuring the rule to avoid"
  echo "wildcard <target> tags. See these documents:"
  echo "https://github.com/EFForg/https-everywhere/blob/master/ruleset-testing.md"
  echo "https://github.com/EFForg/https-everywhere/blob/master/ruleset-style.md"
  exit 1
else
  exit 0
fi
