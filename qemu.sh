#!/bin/sh
set -e
. ./iso.sh

qemu-system-$(./target-triplet-to-arch.sh $HOST) -cdrom ruos.iso -boot order=d -drive file=myos_storage,format=raw
