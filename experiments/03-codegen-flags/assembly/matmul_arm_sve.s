	.arch armv8.2-a+crc+sve
	.file	"matmul.c"
// GNU C17 (Ubuntu 11.4.0-1ubuntu1~22.04.3) version 11.4.0 (aarch64-linux-gnu)
//	compiled by GNU C version 11.4.0, GMP version 6.2.1, MPFR version 4.1.0, MPC version 1.2.1, isl version isl-0.24-GMP

// GGC heuristics: --param ggc-min-expand=100 --param ggc-min-heapsize=131072
// options passed: -march=armv8.2-a+sve -mlittle-endian -mabi=lp64 -O3 -fasynchronous-unwind-tables -fstack-protector-strong -fstack-clash-protection
	.text
	.align	2
	.p2align 4,,11
	.global	matmul
	.type	matmul, %function
matmul:
.LFB0:
	.cfi_startproc
	cntd	x4		// tmp126
// src/matmul.c:8: void matmul(float A[N][N], float B[N][N], float C[N][N]){
	mov	x8, x1	// B, tmp131
	lsl	x4, x4, 9	// tmp125, tmp126,
// src/matmul.c:12:             for(size_t k = 0; k < N; k++){
	cntw	x5		// tmp120
// src/matmul.c:8: void matmul(float A[N][N], float B[N][N], float C[N][N]){
	mov	x7, x2	// ivtmp.40, tmp132
	mov	x3, x0	// ivtmp.41, tmp130
	add	x9, x2, 16384	// _54, ivtmp.40,
// src/matmul.c:13:                 sum += A[i][k] * B[k][j];
	mov	w0, 256	// tmp115,
	mov	w2, 64	// tmp113,
	index	z3.s, #0, w0	// tmp114,, tmp115
	whilelo	p2.s, wzr, w2	// max_mask_8,, tmp113
.L2:
// src/matmul.c:15:             C[i][j] = sum;
	mov	x6, 0	// ivtmp.33,
	.p2align 3,,7
.L6:
// src/matmul.c:11:             float sum = 0.0f;
	movi	v1.2s, #0	// sum
	add	x1, x8, x6	// ivtmp.17, B, ivtmp.33
// src/matmul.c:8: void matmul(float A[N][N], float B[N][N], float C[N][N]){
	mov	x0, 0	// ivtmp_11,
	mov	p0.b, p2.b	// next_mask_9, max_mask_8
	.p2align 3,,7
.L3:
// src/matmul.c:13:                 sum += A[i][k] * B[k][j];
	ld1w	z2.s, p0/z, [x3, x0, lsl 2]	// vect__3.5, next_mask_9, MEM <vector([4,4]) float> [(float *)vectp.4_33 + ivtmp_12 * 4]
// src/matmul.c:13:                 sum += A[i][k] * B[k][j];
	ld1w	z0.s, p0/z, [x1, z3.s, uxtw]	// vect__6.8, next_mask_9, ivtmp.17, tmp114
// src/matmul.c:12:             for(size_t k = 0; k < N; k++){
	add	x0, x0, x5	// ivtmp_11, ivtmp_11, tmp120
// src/matmul.c:13:                 sum += A[i][k] * B[k][j];
	fmul	z0.s, z0.s, z2.s	// vect__7.9, vect__6.8, vect__3.5
	add	x1, x1, x4	// ivtmp.17, ivtmp.17, tmp125
// src/matmul.c:13:                 sum += A[i][k] * B[k][j];
	fadda	s1, p0, s1, z0.s	// sum, next_mask_9, vect__7.9
	whilelo	p0.s, w0, w2	// next_mask_9, ivtmp_11, tmp113
	b.any	.L3	//,
// src/matmul.c:15:             C[i][j] = sum;
	str	s1, [x7, x6]	// sum, MEM[(float *)_46 + ivtmp.33_5 * 1]
// src/matmul.c:10:         for(size_t j = 0; j < N; j++){
	add	x6, x6, 4	// ivtmp.33, ivtmp.33,
	cmp	x6, 256	// ivtmp.33,
	bne	.L6		//,
// src/matmul.c:9:     for(size_t i = 0; i < N; i++){
	add	x7, x7, 256	// ivtmp.40, ivtmp.40,
	add	x3, x3, 256	// ivtmp.41, ivtmp.41,
	cmp	x7, x9	// ivtmp.40, _54
	bne	.L2		//,
// src/matmul.c:18: }
	ret	
	.cfi_endproc
.LFE0:
	.size	matmul, .-matmul
	.ident	"GCC: (Ubuntu 11.4.0-1ubuntu1~22.04.3) 11.4.0"
	.section	.note.GNU-stack,"",@progbits
