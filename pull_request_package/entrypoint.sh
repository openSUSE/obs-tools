#!/bin/bash

while true; do
  ./runner.rb -f config/config.yml
  sleep $RUN_EVERY
done
