	.file	"matmul.c"
# GNU C17 (Ubuntu 11.4.0-1ubuntu1~22.04.3) version 11.4.0 (x86_64-linux-gnu)
#	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

# GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
# options passed: -msse2 -mno-avx -mno-avx2 -mno-avx512f -mtune=generic -march=x86-64 -O3 -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection -fcf-protection
	.text
	.p2align 4
	.globl	matmul
	.type	matmul, @function
matmul:
.LFB0:
	.cfi_startproc
	endbr64	
	pushq	%rbx	#
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
# src/matmul.c:8: void matmul(float A[N][N], float B[N][N], float C[N][N]){
	movq	%rdi, %r11	# tmp107, A
	movq	%rdx, %r10	# tmp109, C
# src/matmul.c:11:             float sum = 0.0f;
	xorl	%r9d, %r9d	# ivtmp.30
	pxor	%xmm2, %xmm2	# sum
	leaq	16384(%rsi), %rbx	#, ivtmp.20
	leaq	16640(%rsi), %rdi	#, _54
.L2:
	leaq	(%r10,%r9), %rsi	#, ivtmp.18
	movq	%rbx, %rcx	# ivtmp.20, ivtmp.20
	leaq	(%r11,%r9), %r8	#, ivtmp.9
	.p2align 4,,10
	.p2align 3
.L6:
	movq	%r8, %rdx	# ivtmp.9, ivtmp.9
	leaq	-16384(%rcx), %rax	#, ivtmp.10
	movaps	%xmm2, %xmm1	# sum, sum
	.p2align 4,,10
	.p2align 3
.L3:
# src/matmul.c:13:                 sum += A[i][k] * B[k][j];
	movss	(%rdx), %xmm0	# MEM[(float *)_31], MEM[(float *)_31]
	mulss	(%rax), %xmm0	# MEM[(float *)_30], tmp101
# src/matmul.c:12:             for(size_t k = 0; k < N; k++){
	addq	$256, %rax	#, ivtmp.10
	addq	$4, %rdx	#, ivtmp.9
# src/matmul.c:13:                 sum += A[i][k] * B[k][j];
	addss	%xmm0, %xmm1	# tmp101, sum
# src/matmul.c:12:             for(size_t k = 0; k < N; k++){
	cmpq	%rax, %rcx	# ivtmp.10, ivtmp.20
	jne	.L3	#,
# src/matmul.c:10:         for(size_t j = 0; j < N; j++){
	addq	$4, %rcx	#, ivtmp.20
# src/matmul.c:15:             C[i][j] = sum;
	movss	%xmm1, (%rsi)	# sum, MEM[(float *)_8]
# src/matmul.c:10:         for(size_t j = 0; j < N; j++){
	addq	$4, %rsi	#, ivtmp.18
	cmpq	%rdi, %rcx	# _54, ivtmp.20
	jne	.L6	#,
# src/matmul.c:9:     for(size_t i = 0; i < N; i++){
	addq	$256, %r9	#, ivtmp.30
	cmpq	$16384, %r9	#, ivtmp.30
	jne	.L2	#,
# src/matmul.c:18: }
	popq	%rbx	#
	.cfi_def_cfa_offset 8
	ret	
	.cfi_endproc
.LFE0:
	.size	matmul, .-matmul
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
