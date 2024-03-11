.686
.model flat
extern _ExitProcess@4	: PROC
extern __write			: PROC
extern __read			: PROC
extern _puts			: PROC

;---------------------------------------------------------------------------------
.data
	; deklaracja tablicy 12-bajtowej do przechowywania tworzonych cyfr
	znaki db 12 dup (?)		; do wyswietlania

	; deklaracja tablicy do przechowywania wprowadzanych cyfr (w obszarze danych)
	obszar db 12 dup (?)	; do wczytywania
	
	dziesiec dd 10 ; mno¿nik
	dekoder db '0123456789ABCDEF'
	dekoder_13 db '0123456789ABC'
	dekoder_20 db '0123456789ABCDEFGHIJ'
;---------------------------------------------------------------------------------
.code
;---------------------------------------------------------------------------------
wczytaj_do_EAX_hex PROC
	; wczytywanie liczby szesnastkowej z klawiatury – liczba po
	; konwersji na postaæ binarn¹ zostaje wpisana do rejestru EAX
	; po wprowadzeniu ostatniej cyfry nale¿y nacisn¹æ klawisz Enter
	push ebx
	push ecx
	push edx
	push esi
	push edi
	push ebp

	; rezerwacja 12 bajtów na stosie przeznaczonych na tymczasowe
	; przechowanie cyfr szesnastkowych wyœwietlanej liczby
	sub esp, 12			; rezerwacja poprzez zmniejszenie ESP
	mov esi, esp		; adres zarezerwowanego obszaru pamiêci

	push dword PTR 10	; max iloœæ znaków wczytyw. liczby
	push esi			; adres obszaru pamiêci
	push dword PTR 0	; numer urz¹dzenia (0 dla klawiatury)
	call __read			; odczytywanie znaków z klawiatury
	add esp, 12			; usuniêcie parametrów ze stosu

	mov eax, 0			; dotychczas uzyskany wynik
pocz_konw:
	mov dl, [esi]		; pobranie kolejnego bajtu
	inc esi				; inkrementacja indeksu
	cmp dl, 10			; sprawdzenie czy naciœniêto Enter
	je gotowe			; skok do koñca podprogramu

; sprawdzenie czy wprowadzony znak jest cyfr¹ 0, 1, 2 , ..., 9
	cmp dl, '0'
	jb pocz_konw		; inny znak jest ignorowany
	cmp dl, '9'
	ja sprawdzaj_dalej
	sub dl, '0'			; zamiana kodu ASCII na wartoœæ cyfry
dopisz:
	shl eax, 4			; przesuniêcie logiczne w lewo o 4 bity
	or al, dl			; dopisanie utworzonego kodu 4-bitowego
						; na 4 ostatnie bity rejestru EAX
	jmp pocz_konw		; skok na pocz¹tek pêtli konwersji
	
; sprawdzenie czy wprowadzony znak jest cyfr¹ A, B, ..., F
sprawdzaj_dalej:
	cmp dl, 'A'
	jb pocz_konw		; inny znak jest ignorowany
	cmp dl, 'F'
	ja sprawdzaj_dalej2
	sub dl, 'A' - 10	; wyznaczenie kodu binarnego
	jmp dopisz
; sprawdzenie czy wprowadzony znak jest cyfr¹ a, b, ..., f
sprawdzaj_dalej2:
	cmp dl, 'a'
	jb pocz_konw		; inny znak jest ignorowany
	cmp dl, 'f'
	ja pocz_konw		; inny znak jest ignorowany
	sub dl, 'a' - 10
	jmp dopisz
gotowe:
	; zwolnienie zarezerwowanego obszaru pamiêci
	add esp, 12

	pop ebp
	pop edi
	pop esi
	pop edx
	pop ecx
	pop ebx

	ret
wczytaj_do_EAX_hex ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_hex PROC
	; wyœwietlanie zawartoœci rejestru EAX
	; w postaci liczby szesnastkowej
	pusha	; przechowanie rejestrów
	; rezerwacja 12 bajtów na stosie (poprzez zmniejszenie
	; rejestru ESP) przeznaczonych na tymczasowe przechowanie
	; cyfr szesnastkowych wyœwietlanej liczby
	sub esp, 12
	mov edi, esp ; adres zarezerwowanego obszaru pamiêci
	
	; przygotowanie konwersji
	mov ecx, 8 ; liczba obiegów pêtli konwersji (32 / 4)
	mov esi, 1 ; indeks pocz¹tkowy u¿ywany przy zapisie cyfr

	mov byte PTR [edi][0], ' '	; *zadanie_3_5


ptl3hex:
	; przesuniêcie cykliczne (obrót) rejestru EAX o 4 bity w lewo
	; w szczególnoœci, w pierwszym obiegu pêtli bity nr 31 - 28
	; rejestru EAX zostan¹ przesuniête na pozycje 3 - 0
	rol eax, 4
	; wyodrêbnienie 4 najm³odszych bitów i odczytanie z tablicy
	; 'dekoder' odpowiadaj¹cej im cyfry w zapisie szesnastkowym
	mov ebx, eax			; kopiowanie EAX do EBX
	and ebx, 0000000FH		; zerowanie bitów 31 - 4 rej.EBX

; zadanie_3_5 START	
	or ebx, ebx
	jnz nie_zero
	cmp byte PTR [edi][esi - 1], ' '	; sprawdzenie czy poprzednia cyfra to spacja (zero nieznacz¹ce)
	jnz nie_zero
	mov dl, ' '							; jeœli tak, to obecne zero te¿ jest nieznacz¹ce
	jmp wpisz_znak

nie_zero:
	mov dl, dekoder[ebx]	; pobranie cyfry z tablicy
; zadanie_3_5 END

wpisz_znak:
	; wpisanie cyfry do obszaru roboczego
	mov [edi][esi], dl
	inc esi
	loop ptl3hex			; sterowanie pêtl¹

	; wpisanie znaku nowego wiersza przed i po cyfrach
	mov byte PTR [edi][0], 10
	mov byte PTR [edi][9], 10

	; wyœwietlenie przygotowanych cyfr
	push 10					; 8 cyfr + 2 znaki nowego wiersza
	push edi				; adres obszaru roboczego
	push 1					; nr urz¹dzenia (tu: ekran)
	call __write			; wyœwietlenie

	; usuniêcie ze stosu 24 bajtów, w tym 12 bajtów zapisanych
	; przez 3 rozkazy push przed rozkazem call
	; i 12 bajtów zarezerwowanych na pocz¹tku podprogramu
	add esp, 24

	popa	; odtworzenie rejestrów
	ret		; powrót z podprogramu
wyswietl_EAX_hex ENDP
;---------------------------------------------------------------------------------
wczytaj_do_EAX PROC	; zadanie 3.2
	push ebx
	push ecx
	push edx

	; max iloœæ znaków wczytywanej liczby
	push dword PTR 12
	push dword PTR OFFSET obszar	; adres obszaru pamiêci
	push dword PTR 0				; numer urz¹dzenia (0 dla klawiatury)
	call __read						; odczytywanie znaków z klawiatury 
	add esp, 12						; usuniêcie parametrów ze stosu

	; bie¿¹ca wartoœæ przekszta³canej liczby przechowywana jest w rejestrze EAX
	; przyjmujemy 0 jako wartoœæ pocz¹tkow¹
	mov eax, 0
	mov ebx, OFFSET obszar	; adres obszaru ze znakami

pobieraj_znaki:
	mov cl, [ebx]	; pobranie kolejnej cyfry w kodzie ASCII
	inc ebx			; zwiêkszenie indeksu
	cmp cl, 10		; sprawdzenie czy naciœniêto Enter
	je byl_enter	; skok, gdy naciœniêto Enter

	sub cl, 30H		; zamiana kodu ASCII na wartoœæ cyfry
	movzx ecx, cl	; przechowanie wartoœci cyfry w rejestrze ECX
	; mno¿enie wczeœniej obliczonej wartoœci razy 10
	mul dziesiec	; mul dword PTR dziesiec
	add eax, ecx		; dodanie ostatnio odczytanej cyfry
	jmp pobieraj_znaki						; skok na pocz¹tek pêtli

byl_enter: ; wartoœæ binarna wprowadzonej liczby znajduje siê teraz w rejestrze EAX
	
	pop edx
	pop ecx
	pop ebx
	ret
wczytaj_do_EAX ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX PROC
	pusha

	mov esi, 10		; indeks w tablicy 'znaki'
	mov ebx, 10		; dzielnik równy 10
konwersja:
	mov edx, 0		; zerowanie starszej czêœci dzielnej
	div ebx			; dzielenie przez 10, reszta w EDX,
	; iloraz w EAX
	add dl, 30H		; zamiana reszty z dzielenia na kod
	; ASCII
	mov znaki [esi], dl		; zapisanie cyfry w kodzie ASCII
	dec esi					; zmniejszenie indeksu
	cmp eax, 0				; sprawdzenie czy iloraz = 0
	jne konwersja			; skok, gdy iloraz niezerowy
; wype³nienie pozosta³ych bajtów spacjami i wpisanie znaków nowego wiersza
wypeln:
	or esi, esi
	jz wyswietl						; skok, gdy ESI = 0
	mov byte PTR znaki [esi], 20H	; kod spacji
	dec esi							; zmniejszenie indeksu
	jmp wypeln
wyswietl:
	mov byte PTR znaki [0], 0AH		; kod nowego wiersza
	mov byte PTR znaki [11], 0AH	; kod nowego wiersza
	; wyœwietlenie cyfr na ekranie
	push dword PTR 12				; liczba wyœwietlanych znaków
	push dword PTR OFFSET znaki		; adres wyœw. obszaru
	push dword PTR 1				; numer urz¹dzenia (ekran ma numer 1)
	call __write					; wyœwietlenie liczby na ekranie
	add esp, 12						; usuniêcie parametrów ze stosu

	popa
	ret

wyswietl_EAX ENDP
;---------------------------------------------------------------------------------
zadanie_3_1 PROC
; program, który wyœwietlia na ekranie 50 pocz¹tkowych elementów ci¹gu liczb: 1, 2, 4, 7, 11, 16, 22, ...
	pusha

	mov ecx, 0		; dodawana liczba
	mov eax, 1		; liczba do wyœwietlenia
wyswietl_nastepny_element_ciagu:
	add eax, ecx
	call wyswietl_EAX

	inc ecx
	cmp ecx, 50		; sprawdzenie czy wyœwietlono 50 elementów
	jne wyswietl_nastepny_element_ciagu

	popa
	ret
zadanie_3_1 ENDP
;---------------------------------------------------------------------------------
zadanie_3_3 PROC
; program, który wczutje z klawiatury liczbê dziesiêtn¹ mniejsz¹ od 60000 i wyœwietla na ekranie kwadrat tej liczby
	pusha

	call wczytaj_do_EAX
	mul eax
	call wyswietl_EAX

	popa
	ret
zadanie_3_3 ENDP
;---------------------------------------------------------------------------------
zadanie_3_4 PROC
; program, który wczytuje liczbê dziesiêtn¹ z klawiatury i wyœwietla na ekranie jej reprezentacjê w systemie szesnastkowym
	pusha

	call wczytaj_do_EAX
	call wyswietl_EAX_hex

	popa
	ret
zadanie_3_4 ENDP
;---------------------------------------------------------------------------------
zadanie_3_6 PROC
; program, który wczytuje liczbê szesnastkow¹ z klawiatury i wyœwietla na ekranie jej reprezentacjê w systemie dziesiêtnym
	pusha

	call wczytaj_do_EAX_hex
	call wyswietl_EAX

	popa
	ret
zadanie_3_6 ENDP
;---------------------------------------------------------------------------------
wczytaj_liczbe_64 PROC

	push ebx
	push ecx
	push edi

	; rezerwacja pamieci do wczytywania
	sub esp, 24		; 2^64 - 1
	mov edi, esp	; adres obszaru 

	; max iloœæ znaków wczytywanej liczby
	push dword ptr 22				; 2^64 - 1
	push edi			; adres obszaru pamiêci
	push dword ptr 0				; numer urz¹dzenia (0 dla klawiatury)
	call __read			; odczytywanie znaków z klawiatury 
	add esp, 12			; usuniêcie parametrów ze stosu

	mov eax, 0		; m³odsze 32 bity
	mov ebx, 0		; starsze 32 bity (tymczasowo)

pobieraj_znaki:
	mov cl, [edi]	; pobranie kolejnej cyfry w kodzie ASCII
	inc edi			; zwiêkszenie indeksu
	cmp cl, 10		; sprawdzenie czy naciœniêto Enter
	je byl_enter	; skok, gdy naciœniêto Enter

	sub cl, 30H			; zamiana kodu ASCII na wartoœæ cyfry
	movzx ecx, cl		; przechowanie wartoœci cyfry w rejestrze ECX
	; mno¿enie wczeœniej obliczonej wartoœci razy 10
	mul dziesiec		; mul dword PTR dziesiec
	add eax, ecx		; dodanie ostatnio odczytanej cyfry
	; EDX przechowuje bity, które nie zmieœci³y siê w rejestrze EAX
	; EBX przecowuje starsze 32 bity
	push eax
	push edx
	
	mov eax, ebx
	or eax, eax
	jz brak_starszych_bitow	
	mul dziesiec
brak_starszych_bitow:	
	
	pop edx
	
	add eax, edx
	mov ebx, eax

	pop eax

	jmp pobieraj_znaki		; skok na pocz¹tek pêtli

byl_enter: ; wartoœæ binarna wprowadzonej liczby znajduje siê teraz w rejestrze EAX

	mov edx, ebx
	
	add esp, 24		; zwolnienie zarezerwowanego obszaru pamiêci
	pop edi
	pop ecx
	pop ebx
	ret

wczytaj_liczbe_64 ENDP
;---------------------------------------------------------------------------------
wyswietl_liczbe_64 PROC
	pusha

	sub esp, 24
	lea ebp, [esp + 20]		; adres koñca obszaru roboczego
	
	mov esi, edx	; starsza czêœæ - w1
	mov edi, eax	; m³odsza czêœæ - w0

pobierz_kolejna_cyfre:
	mov edx, 0
	mov eax, esi
	div dziesiec	; EAX - v1, EDX - r1
	mov esi, eax	; v1
	mov eax, edi	; w0
	div dziesiec	; EAX - v0, EDX - r0
	mov edi, eax

	add dl, 30H
	mov [ebp], dl
	dec ebp

	push esi
	or esi, edi
	pop esi
	jnz pobierz_kolejna_cyfre

	
	inc ebp
	lea ebx, [esp + 21]
	sub ebx, ebp

	mov dl, 10
	mov [ebp + ebx], dl
	inc ebx

	push ebx
	push ebp				; adres obszaru roboczego
	push 1					; nr urz¹dzenia (tu: ekran)
	call __write			; wyœwietlenie
	add esp, 12				; usuniêcie parametrów ze stosu


	; mov dl, 0
	; mov [ebp + ebx], dl
	; push ebp
	; call _puts
	; add esp, 4


	add esp, 24
	popa
	ret

wyswietl_liczbe_64 ENDP
;---------------------------------------------------------------------------------
wczytaj_EAX_U2_b13 PROC

	push ebx
	push edx
	push esi
	push ebp

	sub esp, 12				; rezerwacja na stosie
	mov ebp, esp			; obszar do wczytywania

	push 12
	push ebp
	push 0
	call __read
	add esp ,12
	
	mov eax, 0				; wynik
	mov ebx, 13				; podstawa
	mov esi, 0

wczytaj_kolejna_cyfre_13:
	cmp byte ptr [ebp][esi], 0Ah		; sprawdzenie czy naciœniêto Enter
	je gotowe_13	; skok do koñca podprogramu

	mul ebx		; EDX:EAX = EAX * EBX

	mov dl, [ebp][esi]
	inc esi

	; sprawdzenie czy wprowadzony znak jest cyfr¹ 0, 1, 2 , ..., 9
	cmp dl, '0'
	jb wczytaj_kolejna_cyfre_13		; inny znak jest ignorowany
	cmp dl, '9'
	ja sprawdzaj_dalej_13
	sub dl, '0'			; zamiana kodu ASCII na wartoœæ cyfry

dopisz_13:
	movzx edx, dl
	add eax, edx	
	jmp wczytaj_kolejna_cyfre_13		; skok na pocz¹tek pêtli konwersji

sprawdzaj_dalej_13:
	cmp dl, 'A'
	jb wczytaj_kolejna_cyfre_13		; inny znak jest ignorowany
	cmp dl, 'C'
	ja sprawdzaj_dalej2_13
	sub dl, 'A' - 10	; wyznaczenie kodu binarnego
	jmp dopisz_13
; sprawdzenie czy wprowadzony znak jest cyfr¹ a, b, ..., f
sprawdzaj_dalej2_13:
	cmp dl, 'a'
	jb wczytaj_kolejna_cyfre_13		; inny znak jest ignorowany
	cmp dl, 'c'
	ja wczytaj_kolejna_cyfre_13		; inny znak jest ignorowany
	sub dl, 'a' - 10
	jmp dopisz_13

	ja wczytaj_kolejna_cyfre_13

gotowe_13:

	cmp byte ptr [ebp], '-'
jne koniec_13
	neg eax

koniec_13:
	add esp, 12

	pop ebp
	pop esi
	pop edx
	pop ebx

	ret

wczytaj_EAX_U2_b13 ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_U2_b13 PROC
	pusha

	sub esp, 12				; rezerwacja na stosie
	mov ebp, esp			; obszar do wyswietlania
	mov esi, 11				; indeks w tablicy
	mov byte ptr [ebp], 0Ah			; znak nowego wiersza

	;mov eax, 7FFFFFFFh	; 100...000
	mov ebx, 13			; podstawa
	
	mov cl, '+'

	rol eax, 1			; CF = 1, jeœli najstarszy bit = 1
	ror eax, 1
	jnc liczba_dodatnia

	; konwersja z U2
	neg eax			; = NOT A, inc A
	mov cl, '-'

liczba_dodatnia:
	
	xor edx, edx
	div ebx		; EDX - ostatnia cyfra
	
	mov dl, dekoder_13[edx]
	mov [ebp][esi], dl
	dec esi

	or eax, eax
	jnz liczba_dodatnia

	mov [ebp][esi], cl	; znak liczby

wypelnij_spacjami_13:
	dec esi
	or esi, esi
	jz przejdz_do_wyswietlania_13
	
	mov byte ptr [ebp][esi], ' '	
	jmp wypelnij_spacjami_13
	

przejdz_do_wyswietlania_13:

	push 12
	push ebp
	push 1
	call __write
	add esp ,12

	add esp, 12		; zarezerwowana pamiêæ (warn)

	popa
	ret
wyswietl_EAX_U2_b13 ENDP
;---------------------------------------------------------------------------------
wczytaj_do_EAX_20 PROC
	
	push ebx
	push edx
	push esi
	push ebp

	sub esp, 12				; rezerwacja na stosie
	mov ebp, esp			; obszar do wczytywania

	push 12
	push ebp
	push 0
	call __read
	add esp ,12

	mov eax, 0				; wynik
	mov ebx, 20				; podstawa
	mov esi, 0

wczytaj_kolejna_cyfre_20:
	cmp byte ptr [ebp][esi], 0Ah		; sprawdzenie czy naciœniêto Enter
	je gotowe_20						; skok do koñca podprogramu

	mul ebx		; EDX:EAX = EAX * EBX

	mov dl, [ebp][esi]
	inc esi

	; sprawdzenie czy wprowadzony znak jest cyfr¹ 0, 1, 2 , ..., 9
	cmp dl, '0'
	jb wczytaj_kolejna_cyfre_20		; inny znak jest ignorowany
	cmp dl, '9'
	ja sprawdzaj_dalej_20
	sub dl, '0'			; zamiana kodu ASCII na wartoœæ cyfry

dopisz_20:
	movzx edx, dl
	add eax, edx	
	jmp wczytaj_kolejna_cyfre_20		; skok na pocz¹tek pêtli konwersji

sprawdzaj_dalej_20:
	cmp dl, 'A'
	jb wczytaj_kolejna_cyfre_20			; inny znak jest ignorowany
	cmp dl, 'J'
	ja sprawdzaj_dalej2_20
	sub dl, 'A' - 10	; wyznaczenie kodu binarnego
	jmp dopisz_20
; sprawdzenie czy wprowadzony znak jest cyfr¹ a, b, ..., f
sprawdzaj_dalej2_20:
	cmp dl, 'a'
	jb wczytaj_kolejna_cyfre_20		; inny znak jest ignorowany
	cmp dl, 'j'
	ja wczytaj_kolejna_cyfre_20		; inny znak jest ignorowany
	sub dl, 'a' - 10
	jmp dopisz_20

	ja wczytaj_kolejna_cyfre_20

gotowe_20:

	add esp, 12

	pop ebp
	pop esi
	pop edx
	pop ebx

	ret

wczytaj_do_EAX_20 ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_bez_spacji PROC
	pusha

	sub esp, 12				; rezerwacja na stosie
	mov ebp, esp			; obszar do wyswietlania

	mov esi, 10		; indeks w tablicy 'znaki'
	mov ebx, 10		; dzielnik równy 10
konwersja_bez_spacji:
	mov edx, 0		; zerowanie starszej czêœci dzielnej
	div ebx			; dzielenie przez 10, reszta w EDX,
	; iloraz w EAX
	add dl, 30H		; zamiana reszty z dzielenia na kod
	; ASCII
	mov [ebp][esi], dl		; zapisanie cyfry w kodzie ASCII
	dec esi					; zmniejszenie indeksu
	cmp eax, 0				; sprawdzenie czy iloraz = 0
	jne konwersja_bez_spacji			; skok, gdy iloraz niezerowy
	
	inc esi
	add ebp, esi

	mov ebx, 12
	sub ebx, esi

	; wyœwietlenie cyfr na ekranie
	push ebx						; liczba wyœwietlanych znaków
	push ebp		; adres wyœw. obszaru
	push 1							; numer urz¹dzenia (ekran ma numer 1)
	call __write					; wyœwietlenie liczby na ekranie
	add esp, 12						; usuniêcie parametrów ze stosu

	add esp, 12
	popa

	ret

wyswietl_EAX_bez_spacji ENDP
;---------------------------------------------------------------------------------
wypisz_ilorax_EAX_EBX PROC
	pusha	

	xor edx, edx
	div ebx		; EAX - wynik, EDX - reszta

	call wyswietl_EAX_bez_spacji

	or edx, edx
	jz koniec_wypisz_ilorax_EAX_EBX

	
	push edx

	mov al, ','
	movzx eax, al
	push eax
	mov ebp, esp

	push 1
	push ebp
	push 1
	call __write
	add esp, 16

	pop edx
	mov ecx, 3	; 3 cyfry po przecinku
	xor eax, eax
wypisz_po_przecinku:	

	mov eax, edx	; reszta z dzielenia
	mul dziesiec
	
	div ebx			; EAX - cyfra po przecinku

	call wyswietl_EAX_bez_spacji

	or edx, edx
	jz koniec_wypisz_ilorax_EAX_EBX
	
	loop wypisz_po_przecinku
	
koniec_wypisz_ilorax_EAX_EBX:

	popa
	ret

wypisz_ilorax_EAX_EBX ENDP
;---------------------------------------------------------------------------------
wczytaj_2_liczby_wypisz_iloraz PROC

	call wczytaj_do_EAX_20
	mov ebx, eax
	call wczytaj_do_EAX_20
	xchg eax, ebx
	call wypisz_ilorax_EAX_EBX

wczytaj_2_liczby_wypisz_iloraz ENDP
;---------------------------------------------------------------------------------
wczytaj_do_EAX_12 PROC
	
	push ebx
	push ecx
	push edx
	push esi
	push ebp

	sub esp, 12				; rezerwacja na stosie
	mov ebp, esp			; obszar do wczytywania

	push 12
	push ebp
	push 0
	call __read
	add esp ,12

	mov eax, 0				; wynik
	mov ebx, 12				; podstawa
	mov esi, 0

wczytaj_kolejna_cyfre_12:
	cmp byte ptr [ebp][esi], 0Ah		; sprawdzenie czy naciœniêto Enter
	je gotowe_12						; skok do koñca podprogramu

	mul ebx		; EDX:EAX = EAX * EBX

	mov dl, [ebp][esi]
	inc esi

	; sprawdzenie czy wprowadzony znak jest cyfr¹ 0, 1, 2 , ..., 9
	cmp dl, '0'
	jb wczytaj_kolejna_cyfre_12		; inny znak jest ignorowany
	cmp dl, '9'
	ja sprawdzaj_dalej_12
	sub dl, '0'			; zamiana kodu ASCII na wartoœæ cyfry

dopisz_12:
	movzx edx, dl
	add eax, edx	
	jmp wczytaj_kolejna_cyfre_12		; skok na pocz¹tek pêtli konwersji

sprawdzaj_dalej_12:
	cmp dl, 'A'
	jb nie_jest_liczba_12		; skoñcz dzia³anie
	cmp dl, 'B'
	ja sprawdzaj_dalej2_12
	sub dl, 'A' - 10	; wyznaczenie kodu binarnego
	jmp dopisz_12
; sprawdzenie czy wprowadzony znak jest cyfr¹ a, b, ..., f
sprawdzaj_dalej2_12:
	cmp dl, 'a'
	jb nie_jest_liczba_12		; skoñcz dzia³anie
	cmp dl, 'b'
	ja nie_jest_liczba_12		; skoñcz dzia³anie
	sub dl, 'a' - 10
	jmp dopisz_12

	ja wczytaj_kolejna_cyfre_12

gotowe_12:

	add esp, 12

	pop ebp
	pop esi
	pop edx
	pop ecx
	pop ebx

	ret

nie_jest_liczba_12:
	xor eax, eax
	jmp gotowe_12

wczytaj_do_EAX_12 ENDP
;---------------------------------------------------------------------------------
wyswietl_EAX_12_bez_spacji PROC
	pusha

	sub esp, 12				; rezerwacja na stosie
	mov ebp, esp			; obszar do wyswietlania
	mov esi, 11				; indeks w tablicy

	mov ebx, 12				; podstawa

petla_wyswietl_12:	
	xor edx, edx
	div ebx					; EDX - ostatnia cyfra
	
	mov dl, dekoder_13[edx]	; warn (dekoder_12)
	mov [ebp][esi], dl
	dec esi

	or eax, eax
	jnz petla_wyswietl_12

przejdz_do_wyswietlania_12:

	add ebp, esi			; adres pocz¹tku
	inc ebp
	mov ebx, 11
	sub ebx, esi			; liczba wyœwietlanych znaków

	push ebx
	push ebp
	push 1
	call __write
	add esp ,12

	add esp, 12				; zwolnienie zarezerwowanego obszaru pamiêci

	popa
	ret
wyswietl_EAX_12_bez_spacji ENDP
;---------------------------------------------------------------------------------
wczytaj_dwie_liczby_12_wypisz_ciag PROC
	pusha

	add esp, 4
	mov ebp, esp

	mov word ptr [ebp], ' ,'


	call wczytaj_do_EAX_12

	or eax, eax
	jz wyjatek_nie_jest_liczba_12
	
	mov ecx, eax

	call wczytaj_do_EAX_12
	or eax, eax
	jz wyjatek_nie_jest_liczba_12
	
	; EAX = 'p', ECX = 'n'
	mov ebx, 0

nastepny_element_ciagu_12:
	ror ebx, 1
	rol ebx, 1
	jc eax_minus_ebx
	add eax, ebx
	call wyswietl_EAX_12_bez_spacji
	sub eax, ebx
	jmp koniec_ciag_12

eax_minus_ebx:
	sub eax, ebx
	call wyswietl_EAX_12_bez_spacji
	add eax, ebx

koniec_ciag_12:
	inc ebx

	cmp ecx, 1
	jz koniec_ciag_12_2

	push eax
	push ecx
	; wyœwietlenie ', '
	push 2		; liczba znaków
	push ebp	; adres obszaru
	push 1		; nr urz¹dzenia (ekran ma numer 1)
	call __write
	add esp, 12	; usuniêcie parametrów ze stosu
	pop ecx
	pop eax

koniec_ciag_12_2:	

	loop nastepny_element_ciagu_12

wyjatek_nie_jest_liczba_12:

	add esp, 4
	popa
	ret
wczytaj_dwie_liczby_12_wypisz_ciag ENDP
;---------------------------------------------------------------------------------
END
