#!/bin/bash

while true; do
  exec "$@"
  sleep $RUN_EVERY
done
