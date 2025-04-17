#!/bin/bash

SDKROOT=/home/louis/Documents/CHERI/cheribuild/output/sdk
export PATH=$SDKROOT/bin:$PATH
export SYSROOT=$SDKROOT/baremetal/baremetal-riscv64-purecap/riscv64-unknown-elf
export LIBRARY_PATH=$SDKROOT/baremetal-riscv64-purecap/riscv64-unknown-elf/lib:$LIBRARY_PATH

if [[ -z "$1" ]]; then
	for benchmark in tsp ; do
    		make GFE_TARGET=P3 TOOLCHAIN=LLVM CHERI=1 RUNS=1000 SYSROOT_DIR=$SYSROOT -C $benchmark clean all || { echo "$benchmark failed!"; exit 1; }
	done
else
	make GFE_TARGET=P3 TOOLCHAIN=LLVM CHERI=1 RUNS=1000 SYSROOT_DIR=$SYSROOT -C $1 clean all
fi
