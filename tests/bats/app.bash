#!/usr/bin/env bash

# source helpers if not loaded
[ $HELPERS_LOADED ] || . "$BATS_TEST_DIRNAME/helpers.bash"

APP="$TMPDIR/usr/local/bin/fclose"
SKIP_NETWORK_TEST=${SKIP_NETWORK_TEST:-false}

#
# runtime fns
#

# make/app(){
#   (
#     cd "$REPO_ROOT"
#     make DESTDIR="$TMPDIR" install
#   )
#   [ -x "$APP" ] || die "failed installing application binary"
# }
#
#
# [ -e "$APP" ] || make/app &>/dev/null
