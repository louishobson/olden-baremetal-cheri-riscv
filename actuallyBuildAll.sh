#!/bin/bash

SDKROOT=/home/louis/Documents/CHERI/cheribuild/output/sdk
export PATH=$SDKROOT/bin:$PATH
export SYSROOT=$SDKROOT/baremetal/baremetal-riscv64-purecap/riscv64-unknown-elf
export LIBRARY_PATH=$SDKROOT/baremetal-riscv64-purecap/riscv64-unknown-elf/lib:$LIBRARY_PATH

# voronoi and mst twidle pointer bits, so are broken for CHERI

BENCHMARKS="tsp treeadd treeadd_frag power perimeter health em3d bisort bh"

if [[ -z "$1" ]]; then
	for benchmark in $BENCHMARKS ; do
		make GFE_TARGET=P3 TOOLCHAIN=LLVM CHERI=1 RUNS=1 SYSROOT_DIR=$SYSROOT -C $benchmark clean all || { echo "$benchmark failed!"; exit 1; }
	done
elif [[ "$1" == "clean" ]]; then
	for benchmark in $BENCHMARKS ; do
		make GFE_TARGET=P3 TOOLCHAIN=LLVM CHERI=1 RUNS=1 SYSROOT_DIR=$SYSROOT -C $benchmark clean
	done
else
	make GFE_TARGET=P3 TOOLCHAIN=LLVM CHERI=1 RUNS=1 SYSROOT_DIR=$SYSROOT -C $1 clean all
fi
