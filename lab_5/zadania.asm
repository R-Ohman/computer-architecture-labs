.686
.model flat
.XMM

public _nowy_exp, _srednia_harm, _sumuj_tablice_SSE, _int2float, _pm_jeden, _dodawanie_SSE
public _progowanie_sredniej_kroczacej, _single_neuron


.data
	jedenki dd 1.0, 1.0, 1.0, 1.0

	ALIGN 16
	tabl_A dd 1.0, 2.0, 3.0, 4.0
	tabl_B dd 2.0, 3.0, 4.0, 5.0
	; liczba db 1
	tabl_C dd 3.0, 4.0, 5.0, 6.0

.code
;----------------------------------------------------------------------------------
_single_neuron PROC
; float single_neuron(float* x, double* w, unsigned int n);
	push ebp
	mov ebp, esp
	; *x = [ebp+8], *w = [ebp+12], n = [ebp+16]
	mov esi, [ebp+8]		; esi = x (wartoœci)
	mov edi, [ebp+12]		; edi = w (wagi)
	mov ecx, [ebp+16]		; ecx = n

	fld qword ptr [edi]		; st(0) = w0 = suma
	add edi, 8

dodaj:
	fld dword ptr [esi]		; st(0) = x[i], st(1) = suma
	fld qword ptr [edi]		; st(0) = w[i], st(1) = x[i], st(2) = suma
	add esi, 4
	add edi, 8

	fmulp					; st(0) = w[i] * x[i], st(1) = suma
	faddp					; st(0) = suma + w[i] * x[i]
	loop dodaj

	fchs					; ^x -> ^(-x)
	sub esp, 4
	fstp dword ptr [esp]	; empty
	call _nowy_exp			; st(0) = exp(-suma)
	add esp, 4

	fld1					; st(0) = 1, st(1) = exp(-suma)
	fadd st(1), st(0)		; st(0) = 1, st(1) = 1 + exp(-suma)
	fxch
	fdivp					; st(0) = st(1)/st(0) = 1/(1 + exp(-suma))

	pop ebp
	ret
_single_neuron ENDP
;----------------------------------------------------------------------------------
_progowanie_sredniej_kroczacej PROC
; float progowanie_sredniej_kroczacej(float* tablica, unsigned int k, unsigned int m);
; koñczy dzia³anie, jeœli bezwzglêdna róznica < 0.6, zwraca wartoœæ ostatniej œredniej
	push ebp
	mov ebp, esp

	; *tablica = [ebp+8], k = [ebp+12], m = [ebp+16]
	mov esi, [ebp+8]		; esi = tablica
	mov ecx, [ebp+12]		; ecx = k
	xor edx, edx			; edx = 0

	push 6
	fild dword ptr [esp]	; st(0) = 6
	add esp, 4

	push 10
	fild dword ptr [esp]	; st(0) = 10, st(1) = 6
	add esp, 4

	fdivp					; st(0) = st(1)/st(0) = 0.6

	fldz					; st(0) = 0 (stara œrednia), st(1) = 0.6
	fild dword ptr [ebp+16]	; st(0) = m, st(1) = 0, st(2) = 0.6

szukaj_roznice:

	push ecx
	mov ecx, [ebp+16]	; ecx = m

	fldz					; st(0) = 0, st(1) = m, st(2) = stara œrednia, st(3) = 0.6
	licz_srednia:
		fld dword ptr [esi]		; st(0) = tablica[i], st(1) = œrednia, st(2) = m, st(3) = x
		add esi, 4
		faddp st(1), st(0)		; st(0) = st(0) + st(1) = suma + tablica[i], st(1) = m, st(2) = x

		loop licz_srednia

	pop ecx
	fdiv st(0), st(1)		; st(0) = st(0) / st(1) = suma / m, st(1) = m, st(2) = x, st(3) = 0.6
	
	or edx, edx			; sprawdzenie, czy to pierwsza œrednia
	jz pierwsza
	
	fsub st(2), st(0)			; st(2) = st(2) - st(0) = stara œrednia - nowa œrednia
	; st(2) = | st(2) |
	fxch st(2)
	fabs
	; st(0) = | ró¿nica |, st(1) = m, st(2) = nowa œrednia, st(3) = 0.6
	fcomi st(0), st(3)				; porównanie z 0.6
	; jump if st(0) < 0.6
	jb mniejsze
	fxch
	fstp st(1)	; del st(0)
	jmp koniec

pierwsza:
	fstp st(2)		; st(0) = m, st(1) = œrednia, st(2) = 0.6
koniec:
	inc edx					; edx - licznik œrednich
	
	dec ecx
	jnz szukaj_roznice

mniejsze:
	fxch st(2)		; st(0) = ostatnia œrednia, st(1) = m, st(2) = roznica, st(3) = 0.6
	fstp st(1)
	fstp st(1)
	fstp st(1)		; st(0) = ostatnia œrednia

	pop ebp
	ret

_progowanie_sredniej_kroczacej ENDP
;----------------------------------------------------------------------------------
_dodawanie_SSE PROC
; void dodawanie_SSE(float * a);
	push ebp
	mov ebp, esp
	mov eax, [ebp+8]
	
	movaps xmm2, tabl_A
	movaps xmm3, tabl_B
	movaps xmm4, tabl_C
	
	addps xmm2, xmm3
	addps xmm2, xmm4
	
	movups [eax], xmm2

	pop ebp
	ret
_dodawanie_SSE ENDP
;----------------------------------------------------------------------------------
_pm_jeden PROC
; void pm_jeden (float * tabl);
	push ebp
	mov ebp, esp
	push esi

	mov esi, [ebp+8]	; esi = tabl
	movups xmm5, [esi]


	addsubps xmm5, jedenki

	movups [esi], xmm5

	pop esi
	pop ebp
	ret
_pm_jeden ENDP
;----------------------------------------------------------------------------------
_int2float PROC
; void int2float (int * calkowite, float * zmienno_przec);
	push ebp
	mov ebp, esp
	push esi
	push edi

	mov esi, [ebp+8]	; esi = calkowite
	mov edi, [ebp+12]	; edi = zmienno_przec

	cvtpi2ps xmm5, qword PTR [esi]
	movups [edi], xmm5

	pop edi
	pop esi
	pop ebp
	ret
_int2float ENDP
;----------------------------------------------------------------------------------
_sumuj_tablice_SSE PROC
; void sumuj_tablice_SSE(char*, char*, char*);
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi

	mov esi, [ebp+8]	; esi = tablica1
	mov edi, [ebp+12]	; edi = tablica2
	mov ebx, [ebp+16]	; ebx = tablica wynikowa

	movups xmm5, [esi]
	movups xmm6, [edi]

	paddsb xmm5, xmm6

	movups [ebx], xmm5

	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
_sumuj_tablice_SSE ENDP
;----------------------------------------------------------------------------------
_nowy_exp PROC
; float nowy_exp(float x);
	push ebp
	mov ebp, esp

	fld1					; st(0) = 1
	fld dword ptr [ebp+8]	; st(0) = x, st(1) = 0
	fld1
	fld1					
	fld1					; st(0) = 1 (dzielna), st(1) = 1 (dzielnik), st(2) = i (mno¿nik), st(3) = x (mno¿nik), st(4) = 1 (resultat sumy)

	mov ecx, 19

addition:
	; inkrementacja dzielnej: x => x * x
	fmul st(0), st(3)			; st(0) = st(0) * st(2) = x^n
	fld st(2)
	fmulp st(2), st(0)			; st(1) = 1 * 2 * ... * st(2)
	
	fld st(0)					; st(0) = x^n = st(1) = dzielna, st(2) = dzielnik
	fdiv st(0), st(2)			; st(0) = st(0) / st(2) = dzielna / dzielnik
	faddp st(5), st(0)			; st(0) = dzielna, st(1) = dzielnik, st(2) = i, st(3) = x, st(4) = result

	; inkremetna dzielnika: i => i + 1
	fld1
	faddp st(3), st(0)
	loop addition

	fld st(4)

	pop ebp
	ret
_nowy_exp ENDP
;----------------------------------------------------------------------------------
_srednia_harm PROC
; float srednia_harm(float* tablica, unsigned int n);
	push ebp
	mov ebp, esp
	push edi
	; *tablica = [ebp+8], n = [ebp+12]
	mov edi, [ebp + 8]	; edi = tablica
	mov ecx, [ebp+12]	; ecx = n

	fild dword ptr [ebp+12]		; st(0) = n
	fldz						; st(0) = 0, st(1) = n
addition:
	fld1
	fld dword ptr [edi+4*ecx-4]	; st(0) = tablica[ecx-1], st(1) = 1, st(2) = sum
	fdivp						; st(1)	= st(1)/st(0) => delete st(0)
	; st(0) = 1/tablica[ecx-1], st(1) = sum
	faddp						; st(0) = sum + 1/tablica[ecx-1]

	loop addition
	
	; st(0) = sum, st(1) = n
	fdivp						; st(0) = st(1)/st(0) = n / sum

	pop edi
	pop ebp
	ret
_srednia_harm ENDP
;----------------------------------------------------------------------------------
END