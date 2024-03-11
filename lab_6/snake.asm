; Program gwiazdki.asm
; Wy�wietlanie znak�w * w takt przerwa� zegarowych
; Uruchomienie w trybie rzeczywistym procesora x86
; lub na maszynie wirtualnej
; zako�czenie programu po naci�ni�ciu klawisza 'x'
; asemblacja (MASM 4.0): masm gwiazdki.asm,,,;
; konsolidacja (LINK 3.60): link gwiazdki.obj;
.386
rozkazy SEGMENT use16

ASSUME CS:rozkazy
;============================================================
; procedura obs�ugi przerwania zegarowego
obsluga_zegara PROC
	; przechowanie u�ywanych rejestr�w
	push ax
	push bx
	push cx
	push es

	; wpisanie adresu pami�ci ekranu do rejestru ES - pami��
	; ekranu dla trybu tekstowego zaczyna si� od adresu B8000H,
	; jednak do rejestru ES wpisujemy warto�� B800H,
	; bo w trakcie obliczenia adresu procesor ka�dorazowo mno�y
	; zawarto�� rejestru ES przez 16
	mov ax, 0B800h				; adres pami�ci ekranu
	mov es, ax
	; zmienna 'licznik' zawiera adres bie��cy w pami�ci ekranu
	mov bx, cs:licznik

	cmp cs:kierunek, -2
	jne nie_lewo
	sub cs:x, 1	
	mov cl, '<'
	jmp wyswietl
nie_lewo:
	cmp cs:kierunek, 2
	jne nie_prawo
	add cs:x, 1
	mov cl, '>'
	jmp wyswietl
nie_prawo:
	cmp cs:kierunek, 160
	jne nie_dol
	add cs:y, 1
	mov cl, '|'
	jmp wyswietl
nie_dol:
	; gora
	sub cs:y, 1
	mov cl, '^'
wyswietl:

	mov ax, 0B800h				; adres pami�ci ekranu
	mov es, ax
	
	push bx
	mov bx, 160+66				; pozycja do wypisywania x
	mov al, cs:x
	call wyswietl_AL

	mov bx, 160+74				; pozycja do wypisywania y
	mov al, cs:y
	call wyswietl_AL
	pop bx
	
	; przes�anie do pami�ci ekranu kodu ASCII wy�wietlanego znaku
	; i kodu koloru: bia�y na czarnym tle (do nast�pnego bajtu)
	mov byte PTR es:[bx], cl			; kod ASCII
	mov byte PTR es:[bx+1], 00001110B	; czarne t�o, ��ty znak
	; zmiana adresu ekranu (pozycja g�owy w�a)
	add bx, cs:kierunek

wysw_dalej:
	;zapisanie adresu bie��cego do zmiennej 'licznik'
	mov cs:licznik,bx

koniec_obslugi:
	; odtworzenie rejestr�w
	pop es
	pop bx
	pop cx
	pop ax

	; skok do oryginalnej procedury obs�ugi przerwania zegarowego
	jmp dword PTR cs:wektor8
	
	; dane programu ze wzgl�du na specyfik� obs�ugi przerwa�
	; umieszczone s� w segmencie kodu
	licznik dw 320				; wy�wietlanie pocz�wszy od 2. wiersza
	wektor8 dd ?
	kierunek dw	2				; lewo (-2) / prawo (+2) / d� (+160) / g�ra (-160)
	x db 0
	y db 2

obsluga_zegara ENDP
;============================================================
obsluga_klawiatury PROC
	; przechowanie u�ywanych rejestr�w
	push ax
	push bx
	push es

	in al, 60H					; odczytanie kodu klawisza	
	mov bx, cs:kierunek

	cmp al, 72
	jne sprawdzaj_lewo
	mov bx, -160

sprawdzaj_lewo:
	cmp al, 75
	jne	sprawdzaj_prawo
	mov bx, -2

sprawdzaj_prawo:
	cmp al, 77
	jne sprawdzaj_dol
	mov bx, 2

sprawdzaj_dol:
	cmp al, 80
	jne nie_strzalka
	mov bx, 160

nie_strzalka:
	mov cs:kierunek, bx

	pop es
	pop bx
	pop ax

	; skok do oryginalnej procedury obs�ugi przerwania zegarowego
	jmp dword PTR cs:wektor9

	; dane programu ze wzgl�du na specyfik� obs�ugi przerwa�
	; umieszczone s� w segmencie kodu
	wektor9 dd ?

obsluga_klawiatury ENDP
;============================================================
; podprogram 'wyswietl_AL' wy�wietla zawarto�� rejestru AL
; w postaci liczby dziesi�tnej bez znaku
wyswietl_AL PROC
	; wy�wietlanie zawarto�ci rejestru AL na ekranie wg adresu
	; podanego w ES:BX
	; stosowany jest bezpo�redni zapis do pami�ci ekranu
	; przechowanie rejestr�w
	push ax
	push cx
	push dx
	
	mov cl, 10			; dzielnik
	mov ah, 0			; zerowanie starszej cz�ci dzielnej
	
	; dzielenie liczby w AX przez liczb� w CL, iloraz w AL,
	; reszta w AH (tu: dzielenie przez 10)
	div cl
	add ah, 30H			; zamiana na kod ASCII
	mov es:[bx+4], ah	; cyfra jedno�ci
	
	mov ah, 0
	div cl				; drugie dzielenie przez 10
	
	add ah, 30H			; zamiana na kod ASCII
	mov es:[bx+2], ah	; cyfra dziesi�tek
	
	add al, 30H			; zamiana na kod ASCII
	mov es:[bx+0], al	; cyfra setek
	
	; wpisanie kodu koloru (intensywny bia�y) do pami�ci ekranu
	mov al, 00001111B
	mov es:[bx+1],al
	mov es:[bx+3],al
	mov es:[bx+5],al
	
	; odtworzenie rejestr�w
	pop dx
	pop cx
	pop ax
	ret					; wyj�cie z podprogramu

wyswietl_AL ENDP
;============================================================
; program g��wny - instalacja i deinstalacja procedury
; obs�ugi przerwa�
; ustalenie strony nr 0 dla trybu tekstowego
zacznij:
	mov al, 0
	mov ah, 5
	int 10

	mov ax, 0
	mov ds,ax							; zerowanie rejestru DS

	; odczytanie zawarto�ci wektora nr 8 i zapisanie go
	; w zmiennej 'wektor8' (wektor nr 8 zajmuje w pami�ci 4 bajty
	; pocz�wszy od adresu fizycznego 8 * 4 = 32)
	mov eax,ds:[32]						; adres fizyczny 0*16 + 32 = 32
	mov cs:wektor8, eax

	; wpisanie do wektora nr 8 adresu procedury 'obsluga_klawiatury'
	mov ax, SEG obsluga_zegara			; cz�� segmentowa adresu
	mov bx, OFFSET obsluga_zegara		; offset adresu
	cli									; zablokowanie przerwa�

	; zapisanie adresu procedury do wektora nr 8
	mov ds:[32], bx						; OFFSET
	mov ds:[34], ax						; cz. segmentowa
	sti									;odblokowanie przerwa�

	; odczytanie zawarto�ci wektora nr 9 i zapisanie go
	; w zmiennej 'wektor9' (wektor nr 9 zajmuje w pami�ci 4 bajty
	; pocz�wszy od adresu fizycznego 9 * 4 = 36)
	mov eax,ds:[36]						; adres fizyczny 0*16 + 36 = 36
	mov cs:wektor9, eax

	; wpisanie do wektora nr 9 adresu procedury 'obsluga_klawiatury'
	mov ax, SEG obsluga_klawiatury			; cz�� segmentowa adresu
	mov bx, OFFSET obsluga_klawiatury		; offset adresu
	cli									; zablokowanie przerwa�

	; zapisanie adresu procedury do wektora nr 9
	mov ds:[36], bx						; OFFSET
	mov ds:[38], ax						; cz. segmentowa
	sti									; odblokowanie przerwa�

	; oczekiwanie na naci�ni�cie klawisza 'x'
aktywne_oczekiwanie:
	
	; sprawdzenie x i y
	cmp cs:x, 79 
	ja koniec_gry

	cmp cs:y, 24
	ja koniec_gry
	
	jmp aktywne_oczekiwanie				; skok, gdy inny znak

koniec_gry:	
	; deinstalacja procedury obs�ugi przerwania zegarowego
	; odtworzenie oryginalnej zawarto�ci wektora nr 8
	mov eax, cs:wektor8
	cli
	mov ds:[32], eax					; przes�anie warto�ci oryginalnej do wektora 8 w tablicy wektor�w przerwa�
	sti

	; deinstalacja procedury obs�ugi przerwania zegarowego
	; odtworzenie oryginalnej zawarto�ci wektora nr 9
	mov eax, cs:wektor9
	cli
	mov ds:[36], eax					; przes�anie warto�ci oryginalnej do wektora 9 w tablicy wektor�w przerwa�
	sti
	
	; zako�czenie programu
	mov al, 0
	mov ah, 4CH
	int 21H

rozkazy ENDS

nasz_stos SEGMENT stack
	db 128 dup (?)
nasz_stos ENDS

END zacznij
