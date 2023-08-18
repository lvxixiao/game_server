#!/bin/sh
export ROOT=$(cd `dirname $0`; pwd)
export SKYNETROOT="$ROOT/lib/skynet"
echo $ROOT
echo $SKYNETROOT

$SKYNETROOT/skynet $ROOT/config