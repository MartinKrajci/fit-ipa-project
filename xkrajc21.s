;Student login: xkrajc21

[BITS 64]
DEFAULT REL 

	GLOBAL _DllMainCRTStartup
	EXPORT _DllMainCRTStartup

	GLOBAL ipa_interpolation
	EXPORT ipa_interpolation

	extern xlogin00_other_f
	extern printcube
	extern getpixel


section .data

message_end:



section .text
_DllMainCRTStartup:
	push rbp
	mov rbp, rsp
	

	mov rax,1
	mov rsp, rbp
	pop rbp
	ret 
	
ipa_interpolation:
	push rbp
	mov rbp, rsp

	; Preparing constants, calling other functions 
	mov r10, qword __float64__(1.0)
	movq xmm13, r10

	mov r10, __float64__(255.0)
	movq xmm4, r10						; 255

	movq xmm10, xmm2					; tailleZ
	movq r11, xmm2

	movapd xmm12, xmm1					; y
	movlhps xmm12, xmm0					;|     ?    |     ?    |     x    |     y    |
	roundpd xmm14, xmm12, 0x0			;|     ?    |     ?    |   intx   |   inty   |
	subpd xmm12, xmm14					;|     ?    |     ?    |    dx    |    dy    |
	movapd xmm11, xmm12
	movapd xmm15, xmm14
	movlhps xmm13, xmm13				;|     ?    |     ?    |     1    |     1    |
	addpd xmm15, xmm13					;|     ?    |     ?    |  intx+1  |  inty+1  |

	sub rsp, 0x20
	mov rcx, r9
	movhlps xmm5, xmm14
	cvtsd2si rdx, xmm5
	movq xmm6, xmm14
	cvtsd2si r8, xmm6
	call getpixel
	and rax, 0xFF
	cvtsi2sd xmm0, rax

	mov rcx, r9
	movhlps xmm5, xmm15
	cvtsd2si rdx, xmm5
	movq xmm6, xmm14
	cvtsd2si r8, xmm6
	call getpixel
	and rax, 0xFF
	cvtsi2sd xmm1, rax

	mov rcx, r9
	movhlps xmm5, xmm14
	cvtsd2si rdx, xmm5
	movq xmm6, xmm15
	cvtsd2si r8, xmm6
	call getpixel
	and rax, 0xFF
	cvtsi2sd xmm2, rax

	mov rcx, r9
	movhlps xmm5, xmm15
	cvtsd2si rdx, xmm5
	movq xmm6, xmm15
	cvtsd2si r8, xmm6
	call getpixel
	and rax, 0xFF
	cvtsi2sd xmm3, rax
	add rsp, 0x20

	; Searching for minimum
	movlhps xmm0, xmm1
	movlhps xmm2, xmm3

	vperm2f128 ymm0, ymm0, ymm2, 0x20	;| pxColor4 | pxColor3 | pxColor2 | pxColor1 |
	vmovapd ymm2, ymm0

	movlhps xmm10, xmm10
	vperm2f128 ymm10, ymm10, ymm10, 0x20;|  tailleZ |  tailleZ |  tailleZ |  tailleZ |

	movlhps xmm4, xmm4
	vperm2f128 ymm4, ymm4, ymm4, 0x20	;|    255   |    255   |    255   |    255   |

	vdivpd ymm10, ymm4
	vmulpd ymm2, ymm10

	vperm2f128 ymm5, ymm2, ymm5, 0x31
	minpd xmm5, xmm2					;|     ?    |     ?    |   MIN2   |   MIN1   |
	movhlps xmm6, xmm5
	minpd xmm6, xmm5					;|     ?    |     ?    |     ?    |    MIN   |

	; If condition
	movapd xmm7, xmm6
	mov rax, __float64__(0.5)
	movq xmm8, rax
	addpd xmm7,	xmm8					;|     ?    |     ?    |     ?    |  MIN+0.5 |
	movlhps xmm7, xmm7
	vperm2f128 ymm7, ymm7, ymm7, 0x20	;|  MIN+0.5 |  MIN+0.5 |  MIN+0.5 |  MIN+0.5 |
	vminpd ymm8, ymm7, ymm2
	vxorpd ymm8, ymm2
	vptest ymm8, ymm8
	jz interpolation

	mulpd xmm6, xmm1
	movq xmm0, xmm6						;if -> height
	jmp end

	; Else
interpolation:
	subpd xmm13, xmm12					;|     ?    |     ?    |   1-dx   |   1-dy   |
	movhlps xmm12, xmm13				;|     ?    |     ?    |    dx    |   1-dx   |
	vperm2f128 ymm12, ymm12, ymm12, 0x20;|    dx    |   1-dx   |    dx    |   1-dx   |
	vmulpd ymm12, ymm0					;|   c4*dx  |  c3*1-dx |   c2*dx  |  c1*1-dx |
	vshufpd ymm10, ymm12, ymm10, 0xF	;|     ?    |    c4    |     ?    |    c2    |
	vaddpd ymm12, ymm10
	vperm2f128 ymm14, ymm12, ymm12, 0x1
	movlhps xmm12, xmm14				;|     ?    |     ?    |    c43   |    c21   |
	movlhps xmm13, xmm11				;|     ?    |     ?    |    dy    |   1-dy   |
	mulpd xmm12, xmm13
	movhlps xmm13, xmm12
	addpd xmm13, xmm12
	movq xmm0, xmm13					;else -> height

end:
	movq xmm1, r10
	movq xmm2, r11
	mulsd xmm0, xmm2
	divsd xmm0, xmm1
	mov rsp, rbp
	pop rbp
ret 0

