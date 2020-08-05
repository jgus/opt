#!/bin/bash -e

function cleanup()
{
    pkill -P $$
}
trap cleanup EXIT

scream -i virbr1 -o pulse &
screampid=$!
looking-glass-client -a yes
kill ${screampid}
