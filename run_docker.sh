#!/bin/bash -e

docker build -t test/iso .

docker run --init --rm -it \
    -v .:/iso \
    -w /iso \
    -e TERM=xterm \
    test/iso
