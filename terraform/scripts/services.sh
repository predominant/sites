#!/bin/sh

hab svc load \
  grahamweldon/site-grahamweldon \
  --strategy at-once

hab svc load \
  grahamweldon/site-nekodiabetes \
  --strategy at-once

hab svc load \
  grahamweldon/site-loadbalancer \
  --strategy at-once \
  --bind grahamweldon:site-grahamweldon.default \
  --bind nekodiabetes:site-nekodiabetes.default

hab svc load \
  grahamweldon/site-rtmp \
  --strategy at-once

hab svc load \
  core/minio \
  --strategy at-once

# hab svc load \
#   grahamweldon/site-elasticsearch \
#   --strategy at-once