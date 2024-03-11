.686
.model flat
extern _ExitProcess@4	: PROC
extern __write			: PROC
extern __read			: PROC
extern _MessageBoxA@16	: PROC
public _main
;---------------------------------------------------------------------------------
.data
	osiem dd 8	; mno¿nik
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

	sub esp, 12			; rezerwujemy pamiêæ do wczytania liczby
	mov ebp, esp	

	push 12		
	push ebp	
	push 0			; klawiatura
	call __read		
	add esp, 12		; usuniêcie parametrów ze stosu

	mov eax, 0		; bie¿¹ca wartoœæ przekszta³canej liczby
	mov esi, 0		; indeks w obszarze pamiêci (EBP)
	
pobieraj_znaki:
	mov cl, [ebp][esi]	; pobranie cyfry w kodzie ASCII
	inc esi				; zwiêkszenie indeksu
	cmp cl, 10			; sprawdzenie czy naciœniêto Enter
	je byl_enter		; skok, gdy naciœniêto Enter

	sub cl, 30H			; zamiana kodu ASCII na wartoœæ cyfry
	movzx ecx, cl		; przechowanie wartoœci cyfry w rejestrze ECX
	; mno¿enie wczeœniej obliczonej wartoœci razy 8
	mul osiem
	add eax, ecx		; dodanie ostatnio odczytanej cyfry
	jmp pobieraj_znaki						; skok na pocz¹tek pêtli

byl_enter: ; wartoœæ binarna wprowadzonej liczby znajduje siê teraz w rejestrze EAX
	
	add esp, 12		; zwolnienie pamiêci
	pop ebp
	pop edx
	pop ecx
	pop ebx
	ret
wczytaj_do_EAX_8 ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_10 PROC
	pusha

	sub esp, 12		; rezrwacja pamiêci
	mov ebp, esp	; adres obszaru pamiêci

	mov esi, 10		; indeks w tablicy (EBP)
	mov ebx, 10		; dzielnik równy 8

konwersja:
	mov edx, 0		; zerowanie starszej czêœci dzielnej
	div ebx			; dzielenie przez 10, reszta w EDX,
	add dl, 30H		; zamiana reszty z dzielenia na kod
	mov [ebp][esi], dl		; zapisanie cyfry w kodzie ASCII
	dec esi					; zmniejszenie indeksu
	cmp eax, 0				; sprawdzenie czy iloraz = 0
	jne konwersja			; skok, gdy iloraz niezerowy
wyswietl:

	mov byte PTR [ebp][11], 0AH		; kod nowego wiersza
	mov byte PTR [ebp][esi], '='

	; pomijamy niewype³nione miejsca w obszarze pamiêci
	add ebp, esi

	; obliczamy liczbê liczba wyœwietlanych znaków
	mov ebx, 12
	sub ebx, esi

	push ebx						
	push ebp						; adres wyœw. obszaru
	push 1							; numer urz¹dzenia (ekran ma numer 1)
	call __write					; wyœwietlenie liczby na ekranie
	add esp, 12						; usuniêcie parametrów ze stosu

	add esp, 12		; zwolnienie zareserwowanej pamiêci
	popa
	ret

wyswietl_EAX_10 ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_8 PROC
	pusha

	sub esp, 12		; rezrwacja pamiêci
	mov ebp, esp	; adres obszaru pamiêci

	mov esi, 10		; indeks w tablicy (EBP)
	mov ebx, 8		; dzielnik równy 8

konwersja:
	mov edx, 0		; zerowanie starszej czêœci dzielnej
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

	; pomijamy niewype³nione miejsca w obszarze pamiêci
	add ebp, esi

	; obliczamy liczbê liczba wyœwietlanych znaków
	mov ebx, 12
	sub ebx, esi

	push ebx						
	push ebp						; adres wyœw. obszaru
	push 1							; numer urz¹dzenia (ekran ma numer 1)
	call __write					; wyœwietlenie liczby na ekranie
	add esp, 12						; usuniêcie parametrów ze stosu

	add esp, 12		; zwolnienie zareserwowanej pamiêci
	popa
	ret

wyswietl_EAX_8 ENDP
END