# See LICENSE for license details.

#include "encoding.h"

#if __riscv_xlen == 64
# define LREG ld
# define SREG sd
# define REGBYTES 8
#else
# define LREG lw
# define SREG sw
# define REGBYTES 4
#endif

  .section ".text.init"
  .globl _start
#ifdef __CHERI_PURE_CAPABILITY__
  .option push
  .option nocapmode
#endif
_start:
#ifdef __CHERI_PURE_CAPABILITY__
  li t6, 0x1800
  csrw mstatus, t6
  # W^X for PCC and DDC
  cspecialrw      ct0, ddc, cnull
  li              t1, (1<<1)
  not             t1, t1
  candperm        ct0, ct0, t1
  cspecialrw      cnull, ddc, ct0

  cspecialrw      ct0, pcc, cnull
  li              t1, ((1<<3) | (1<<5))
  not             t1, t1
  candperm        ct0, ct0, t1
  la              t2, zero_regs
  csetoffset      ct0, ct0, t2
#ifdef __riscv_xcheri_mode_dependent_jumps
  jr.cap          ct0
#else
  cjr             ct0
#endif
#endif

zero_regs:
  li  x1, 0
  li  x2, 0
  li  x3, 0
  li  x4, 0
  li  x5, 0
  li  x6, 0
  li  x7, 0
  li  x8, 0
  li  x9, 0
  li  x10,0
  li  x11,0
  li  x12,0
  li  x13,0
  li  x14,0
  li  x15,0
  li  x16,0
  li  x17,0
  li  x18,0
  li  x19,0
  li  x20,0
  li  x21,0
  li  x22,0
  li  x23,0
  li  x24,0
  li  x25,0
  li  x26,0
  li  x27,0
  li  x28,0
  li  x29,0
  li  x30,0
  li  x31,0

  # enable FPU and accelerator if present
  li t0, MSTATUS_FS | MSTATUS_XS
  csrs mstatus, t0

  # make sure XLEN agrees with compilation choice
  li t0, 1
  slli t0, t0, 31
#if __riscv_xlen == 64
  bgez t0, 1f
#else
  bltz t0, 1f
#endif
1:

  # initialize global pointer
.option push
.option norelax
  la gp, __global_pointer$
.option pop

init_bss:
    /* init bss section */
    la  a0, __bss_start
    la  a1, __bss_end
    li  a2, 0x0
    jal fill_block

init_sbss:
    /* init bss section */
    la  a0, __sbss_start
    la  a1, __sbss_end
    li  a2, 0x0
    jal fill_block

    j init_trap

/* Fills memory blocks */
fill_block:
    bgeu  a0, a1, fb_end
    sw    a2, 0(a0)
    addi  a0, a0, 4
    j   fill_block
fb_end:
    ret

init_trap:
#ifdef __riscv_flen
  # initialize FPU if we have one
  la t0, 1f
  csrw mtvec, t0

  fssr    x0
  fmv.s.x f0, x0
  fmv.s.x f1, x0
  fmv.s.x f2, x0
  fmv.s.x f3, x0
  fmv.s.x f4, x0
  fmv.s.x f5, x0
  fmv.s.x f6, x0
  fmv.s.x f7, x0
  fmv.s.x f8, x0
  fmv.s.x f9, x0
  fmv.s.x f10,x0
  fmv.s.x f11,x0
  fmv.s.x f12,x0
  fmv.s.x f13,x0
  fmv.s.x f14,x0
  fmv.s.x f15,x0
  fmv.s.x f16,x0
  fmv.s.x f17,x0
  fmv.s.x f18,x0
  fmv.s.x f19,x0
  fmv.s.x f20,x0
  fmv.s.x f21,x0
  fmv.s.x f22,x0
  fmv.s.x f23,x0
  fmv.s.x f24,x0
  fmv.s.x f25,x0
  fmv.s.x f26,x0
  fmv.s.x f27,x0
  fmv.s.x f28,x0
  fmv.s.x f29,x0
  fmv.s.x f30,x0
  fmv.s.x f31,x0
1:
#endif

  # initialize trap vector$
  la t0, trap_entry
  csrw mtvec, t0

/*
  la  tp, _end + 63
  and tp, tp, -64    # 64-byte align? Why not do this in the linker script!!
  # tp = address of top of the stack (remember it fills in reverse)

  # get core id
  csrr a0, mhartid
  # for now, assume only 1 core
  li a1, 1
1:bgeu a0, a1, 1b

  # give each core 128KB of stack + TLS
#define STKSHIFT 17
  # a0 = 0
  sll a2, a0, STKSHIFT
  # a2 = 0
  add tp, tp, a2
  # tp = start of stack
  add sp, a0, 1
  # sp = 1
  sll sp, sp, STKSHIFT
  # sp = 128KB
*/

  la tp, __stack_top
  la sp, __stack_bot
  sub a0, sp, tp

#ifdef __CHERI_PURE_CAPABILITY__
/*
  cfromptr    csp, ddc, sp # Get DDC
  csetbounds  csp, csp, tp
  cincoffset  csp, csp, tp
*/

  cfromptr    csp, ddc, tp # Get DDC
  csetbounds  csp, csp, a0
  cincoffset  csp, csp, a0

  lw a0, 0(sp)
  lw a0, 0(tp)

  cspecialr       ct0, ddc # Get DDC.
  la              t1, pvAlmightyDataCap
  sc              ct0, 0(t1)

  # Initialise the captable.
  cspecialrw      ct0, pcc, cnull # Get PCC
  la              t1, _start_purecap
  csetoffset      ct0, ct0, t1
  li              t1, 1
  csetflags       ct0, ct0, t1
#ifdef __riscv_xcheri_mode_dependent_jumps
  jalr.cap        cra, ct0
#else
  cjalr           cra, ct0
#endif

  # From now on, DDC is always null.
  cmove           ct0, cnull
  cspecialw       ddc, ct0

  # initialize trap vector
  cspecialr       ct0, pcc
  li              t1, 1
  csetflags       ct0, ct0, t1

  la              t1, trap_entry
  csetoffset      ct0, ct0, t1
  cspecialw       mtcc, ct0

  la              t1, _init
  csetoffset      ct0, ct0, t1
#ifdef __riscv_xcheri_mode_dependent_jumps
  jr.cap          ct0
#else
  cjr             ct0
#endif
  .option pop
#else
  add sp, sp, tp
  j _init
#endif

# Not expected to trap handle here, but it is useful for debugging
# No need to CHERIfym ebreak should be fine
  .align 2
trap_entry:
#ifdef __CHERI_PURE_CAPABILITY__
  csrr a0, mcause
  csrr a1, mepc
  clgc ct0, handle_trap
#ifdef __riscv_xcheri_mode_dependent_jumps
  jr.cap          ct0
#else
  cjr             ct0
#endif
#else
  addi sp, sp, -272

  SREG x1, 1*REGBYTES(sp)
  SREG x2, 2*REGBYTES(sp)
  SREG x3, 3*REGBYTES(sp)
  SREG x4, 4*REGBYTES(sp)
  SREG x5, 5*REGBYTES(sp)
  SREG x6, 6*REGBYTES(sp)
  SREG x7, 7*REGBYTES(sp)
  SREG x8, 8*REGBYTES(sp)
  SREG x9, 9*REGBYTES(sp)
  SREG x10, 10*REGBYTES(sp)
  SREG x11, 11*REGBYTES(sp)
  SREG x12, 12*REGBYTES(sp)
  SREG x13, 13*REGBYTES(sp)
  SREG x14, 14*REGBYTES(sp)
  SREG x15, 15*REGBYTES(sp)
  SREG x16, 16*REGBYTES(sp)
  SREG x17, 17*REGBYTES(sp)
  SREG x18, 18*REGBYTES(sp)
  SREG x19, 19*REGBYTES(sp)
  SREG x20, 20*REGBYTES(sp)
  SREG x21, 21*REGBYTES(sp)
  SREG x22, 22*REGBYTES(sp)
  SREG x23, 23*REGBYTES(sp)
  SREG x24, 24*REGBYTES(sp)
  SREG x25, 25*REGBYTES(sp)
  SREG x26, 26*REGBYTES(sp)
  SREG x27, 27*REGBYTES(sp)
  SREG x28, 28*REGBYTES(sp)
  SREG x29, 29*REGBYTES(sp)
  SREG x30, 30*REGBYTES(sp)
  SREG x31, 31*REGBYTES(sp)

  csrr a0, mcause
  csrr a1, mepc
  mv a2, sp
  jal handle_trap
  csrw mepc, a0

  # Remain in M-mode after eret
  li t0, MSTATUS_MPP
  csrs mstatus, t0

  LREG x1, 1*REGBYTES(sp)
  LREG x2, 2*REGBYTES(sp)
  LREG x3, 3*REGBYTES(sp)
  LREG x4, 4*REGBYTES(sp)
  LREG x5, 5*REGBYTES(sp)
  LREG x6, 6*REGBYTES(sp)
  LREG x7, 7*REGBYTES(sp)
  LREG x8, 8*REGBYTES(sp)
  LREG x9, 9*REGBYTES(sp)
  LREG x10, 10*REGBYTES(sp)
  LREG x11, 11*REGBYTES(sp)
  LREG x12, 12*REGBYTES(sp)
  LREG x13, 13*REGBYTES(sp)
  LREG x14, 14*REGBYTES(sp)
  LREG x15, 15*REGBYTES(sp)
  LREG x16, 16*REGBYTES(sp)
  LREG x17, 17*REGBYTES(sp)
  LREG x18, 18*REGBYTES(sp)
  LREG x19, 19*REGBYTES(sp)
  LREG x20, 20*REGBYTES(sp)
  LREG x21, 21*REGBYTES(sp)
  LREG x22, 22*REGBYTES(sp)
  LREG x23, 23*REGBYTES(sp)
  LREG x24, 24*REGBYTES(sp)
  LREG x25, 25*REGBYTES(sp)
  LREG x26, 26*REGBYTES(sp)
  LREG x27, 27*REGBYTES(sp)
  LREG x28, 28*REGBYTES(sp)
  LREG x29, 29*REGBYTES(sp)
  LREG x30, 30*REGBYTES(sp)
  LREG x31, 31*REGBYTES(sp)

  addi sp, sp, 272
  mret
#endif

#ifdef __CHERI_PURE_CAPABILITY__
.data
.globl pvAlmightyDataCap
.type pvAlmightyDataCap, @object
pvAlmightyDataCap:
  .chericap 0
.size pvAlmightyDataCap, . - pvAlmightyDataCap
#endif

.section ".tdata.begin"
.globl _tdata_begin
_tdata_begin:

.section ".tdata.end"
.globl _tdata_end
_tdata_end:

.section ".tbss.end"
.globl _tbss_end
_tbss_end:
