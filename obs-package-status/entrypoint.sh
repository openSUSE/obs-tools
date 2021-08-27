#!/bin/bash

while true; do
  (exec $@)
  sleep $((OBS_TOOLS_RUN_EVERY*60))
done
