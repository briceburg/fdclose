#!/usr/bin/env bats

#
# 00 - test dependencies
#

load helpers

setup() {
  cd $REPO_ROOT
}

@test "makefile compiles $NAMESPACE" {
  rm -rf $REPO_ROOT/bin/$NAMESPACE
  make
  [ -e $REPO_ROOT/bin/$NAMESPACE ]
}

@test "makefile installs $NAMESPACE" {
  make DESTDIR=$TMPDIR install
  [ -e $TMPDIR/usr/local/bin/$NAMESPACE ]
}

@test "makefile uninstalls $NAMESPACE" {
  make DESTDIR=$TMPDIR uninstall
  [ ! -e $TMPDIR/usr/local/bin/$NAMESPACE ]
}

@test "makefile cleans up" {
  make clean
  [ ! -e $REPO_ROOT/dist ]
}
