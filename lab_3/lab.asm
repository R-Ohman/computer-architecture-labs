.686
.model flat
extern _ExitProcess@4	: PROC
extern __write			: PROC
extern __read			: PROC
extern _MessageBoxA@16	: PROC
public _main
;---------------------------------------------------------------------------------
.data
	osiem dd 8	; mno�nik
	tekst dw 'a', 'r', 'c', 'h', 'i', 't', 'e', 'k', 't', 'u', 'r', 'a', 0
	buffer db 20 dup (?)
	tekst_pocz db 10, 'Podaj tekst ', 10
	koniec_t db ?
	bufor db 80 dup (0)
	nowa_linia db 10
	byla_spacja db ?
	ile_znakow dd ?
;---------------------------------------------------------------------------------
.code
_main PROC
	
	mov ecx, (OFFSET koniec_t - OFFSET tekst_pocz)
	push ecx
	push OFFSET tekst_pocz
	push 1
	call __write
	add esp, 12

	push 80
	push OFFSET bufor
	push 0
	call __read
	add esp, 12
	mov ile_znakow, eax

_1:	mov byla_spacja, 1
	mov ecx, eax
	mov ebx, 0

petla:
	mov dl, bufor[ebx]
	cmp byla_spacja, 1
	jne czy_spacja

sprawdzaj:
	cmp dl, 'a'
_2:	jb czy_spacja
	cmp dl, 'z'
	ja dalej
	sub dl, 20h
	mov bufor[ebx], dl

czy_spacja:
	mov byla_spacja, 0
	cmp dl, ' '
_3:	jne dalej
	mov byla_spacja, 1

dalej:
	inc ebx
	loop petla

	push ile_znakow
	push OFFSET bufor
	push 1
	call __write
	add esp, 12

	push 0
	call _ExitProcess@4

_main ENDP
;---------------------------------------------------------------------------------
wczytaj_do_EAX_8 PROC
	push ebx
	push ecx
	push edx
	push ebp

	sub esp, 12			; rezerwujemy pami�� do wczytania liczby
	mov ebp, esp	

	push 12		
	push ebp	
	push 0			; klawiatura
	call __read		
	add esp, 12		; usuni�cie parametr�w ze stosu

	mov eax, 0		; bie��ca warto�� przekszta�canej liczby
	mov esi, 0		; indeks w obszarze pami�ci (EBP)
	
pobieraj_znaki:
	mov cl, [ebp][esi]	; pobranie cyfry w kodzie ASCII
	inc esi				; zwi�kszenie indeksu
	cmp cl, 10			; sprawdzenie czy naci�ni�to Enter
	je byl_enter		; skok, gdy naci�ni�to Enter

	sub cl, 30H			; zamiana kodu ASCII na warto�� cyfry
	movzx ecx, cl		; przechowanie warto�ci cyfry w rejestrze ECX
	; mno�enie wcze�niej obliczonej warto�ci razy 8
	mul osiem
	add eax, ecx		; dodanie ostatnio odczytanej cyfry
	jmp pobieraj_znaki						; skok na pocz�tek p�tli

byl_enter: ; warto�� binarna wprowadzonej liczby znajduje si� teraz w rejestrze EAX
	
	add esp, 12		; zwolnienie pami�ci
	pop ebp
	pop edx
	pop ecx
	pop ebx
	ret
wczytaj_do_EAX_8 ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_10 PROC
	pusha

	sub esp, 12		; rezrwacja pami�ci
	mov ebp, esp	; adres obszaru pami�ci

	mov esi, 10		; indeks w tablicy (EBP)
	mov ebx, 10		; dzielnik r�wny 8

konwersja:
	mov edx, 0		; zerowanie starszej cz�ci dzielnej
	div ebx			; dzielenie przez 10, reszta w EDX,
	add dl, 30H		; zamiana reszty z dzielenia na kod
	mov [ebp][esi], dl		; zapisanie cyfry w kodzie ASCII
	dec esi					; zmniejszenie indeksu
	cmp eax, 0				; sprawdzenie czy iloraz = 0
	jne konwersja			; skok, gdy iloraz niezerowy
wyswietl:

	mov byte PTR [ebp][11], 0AH		; kod nowego wiersza
	mov byte PTR [ebp][esi], '='

	; pomijamy niewype�nione miejsca w obszarze pami�ci
	add ebp, esi

	; obliczamy liczb� liczba wy�wietlanych znak�w
	mov ebx, 12
	sub ebx, esi

	push ebx						
	push ebp						; adres wy�w. obszaru
	push 1							; numer urz�dzenia (ekran ma numer 1)
	call __write					; wy�wietlenie liczby na ekranie
	add esp, 12						; usuni�cie parametr�w ze stosu

	add esp, 12		; zwolnienie zareserwowanej pami�ci
	popa
	ret

wyswietl_EAX_10 ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_8 PROC
	pusha

	sub esp, 12		; rezrwacja pami�ci
	mov ebp, esp	; adres obszaru pami�ci

	mov esi, 10		; indeks w tablicy (EBP)
	mov ebx, 8		; dzielnik r�wny 8

konwersja:
	mov edx, 0		; zerowanie starszej cz�ci dzielnej
	div ebx			; dzielenie przez 10, reszta w EDX,
	; iloraz w EAX
	add dl, 30H		; zamiana reszty z dzielenia na kod

	mov [ebp][esi], dl		; zapisanie cyfry w kodzie ASCII
	dec esi					; zmniejszenie indeksu
	cmp eax, 0				; sprawdzenie czy iloraz = 0
	jne konwersja			; skok, gdy iloraz niezerowy

wyswietl:

	mov byte PTR [ebp][11], 0AH		; kod nowego wiersza
	mov byte PTR [ebp][esi], '='

	; pomijamy niewype�nione miejsca w obszarze pami�ci
	add ebp, esi

	; obliczamy liczb� liczba wy�wietlanych znak�w
	mov ebx, 12
	sub ebx, esi

	push ebx						
	push ebp						; adres wy�w. obszaru
	push 1							; numer urz�dzenia (ekran ma numer 1)
	call __write					; wy�wietlenie liczby na ekranie
	add esp, 12						; usuni�cie parametr�w ze stosu

	add esp, 12		; zwolnienie zareserwowanej pami�ci
	popa
	ret

wyswietl_EAX_8 ENDP
END