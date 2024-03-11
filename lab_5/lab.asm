.686
.model flat
.XMM

public _objetosc_cysterny, _compute, _compute2
extern _GetUserNameA@8 : PROC
extern _MulDiv@12 : PROC

.data
destination dw 50 dup (0DEADh)

.code
;----------------------------------------------------------------------------------
_objetosc_cysterny PROC
; double objetosc_cysterny(double l, double d);

	push ebp
	mov ebp, esp
	; l = [ebp+8], d = [ebp+16]


	fld qword ptr [ebp+8]
	fld qword ptr [ebp+16]
	; st(0) = d, st(1) = l
	fsub st(1), st(0)
	; st(0) = d, st(1) = l - d = h

	push 2
	fild dword ptr [esp]
	add esp, 4
	; st(0) = 2, st(1) = d, st(2) = h
	fdiv
	; st(0) = d/2 = r, st(1) = h

	fld1
	; st(0) = 1, st(1) = r, st(2) = h
	fmul st(0), st(1)
	fmul st(0), st(1)
	fmul st(0), st(1)
	; st(0) = r^3, st(1) = r, st(2) = h
	fldpi
	fmul
	; st(0) = pi*r^3, st(1) = r, st(2) = h

	push 4
	fild dword ptr [esp]
	push 3
	fild dword ptr [esp]
	add esp, 8

	fdiv
	; st(0) = 4/3, st(1) = pi*r^3, st(2) = r, st(3) = h
	fmul
	; st(0) = 4/3*pi*r^3 = v1, st(1) = r, st(2) = h
	fld st(1)
	fmulp st(2), st(0)
	; st(0) = v1, st(1) = r^2, st(2) = h
	fldpi
	fmulp st(2), st(0)
	; st(0) = v1, st(1) = pi*r^2, st(2) = h
	fld st(2)
	fmulp st(2), st(0)
	; st(0) = v1, st(1) = v2, st(2) = h
	fadd
	; st(0) = v1 + v2 = v, st(1) = h

	pop ebp
	ret
_objetosc_cysterny ENDP
;----------------------------------------------------------------------------------
_compute PROC
	push ebp
	mov ebp, esp

	mov eax, [ebp+8]
	mov ebx, [ebp+12]
	mov edi, [ebp+16]

	and eax, 7FFFFFh
	shl eax, 23
	add ebx, eax

	mov [edi], ebx

	pop ebp
	ret
_compute ENDP

_compute2 PROC
	push ebp
	mov ebp, esp

	finit

	fild dword ptr [ebp+8]
	fmul st(0), st(0)
	fldpi
	fmulp

	pop ebp
	ret
_compute2 ENDP


END
