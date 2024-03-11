.686
.model flat

public _Sum

.code
;-------------------------------------------------------------------------------
_Sum PROC
; int Sum(int count, ...);
	push ebp
	mov ebp, esp
	
	mov ecx, [ebp + 8]	; ECX = count
	xor eax, eax		; EAX = 0 = sum 

	jecxz koniec

add_next_number:
	add eax, [ebp + 4 * ecx + 8]
	loop add_next_number

koniec:
	pop ebp
	ret
_Sum ENDP
;-------------------------------------------------------------------------------
END
