#!/usr/bin/env bats

#
# 10 - basic application behavior and test prerequisites
#

load app

@test "app exists and is executable" {
  [ -x $APP ]
}
