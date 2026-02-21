#!/bin/sh


# Create cov_out directory and make it writable for everyone to avoid permission issues in docker
# Use -f to ignore errors if it's already there and owned by someone else,
# but if we can't chmod it, we might have issues.
# Better yet, try to remove it if it's empty or just ignore the error if it already has right permissions.
# mkdir -p ./cov_out || true
# chmod 777 ./cov_out || true

docker run --rm -it \
  -v ./in-ftp-fandango/:/home/ubuntu/experiments/seeds/ \
  -v ./cov_out/:/home/ubuntu/experiments/cov_out/ \
  -e COV_OUT_DIR=/home/ubuntu/experiments/cov_out/ \
  -e GCOVR_FILTER='.*Source/Release/SomeFile\.c$' \
  lightftp-fan-seeds:latest \
  /bin/bash -lc 'exec-seeds.sh /home/ubuntu/experiments/seeds'



#  -e GCOVR_FILTER='.*Source/Release/SomeFile\.c$' \
