; DLLCpp
; 
; Biblioteka zawierajaca funkcje zwiazane z projektem konwersji i
; obliczen wrazen odwrotnej notacji polskiej
; 
; Autor: Konrad Skrzypczyk
; Przedmiot: Jezyki Assemblera
; Rok akademicki: 2020/21
; Implementacja: MASM (x64)
; Pliki: LibAsm.def, LibAsm.asm
; 
; =================== CHANELOG =================== 
;
; v0.1:
; - Dodanie i implementacja nowej procedury: ConvertToRPN proc stdcall data: ptr byte
;
; v0.11:
; - Dodanie definicji nowej procedury: CalcRPN proc rpn: ptr byte
; - Ujednolicenie procedury ConvertToRPN z wersja C++
;
; v0.2:
; - Usuniecie makr: .IF .IFELSE .ENDIF

; v0.21:
; - 'Rebranding' kodu z MASM x86 na MASM x64
;
; v0.22:
; - ConvertToRPN -> dodanie wsparcia dla liczb ujemnych
;
; v0.3:
; - Poprawa znalezionych bledow (zwracanie z procedury ConvertToRPN, brakujace spacje)
; - Ujednolicenie procedury CalcRPN z wersja C++
; - Implementacja procedury CalcRPN
;
; v0.4:
; - CalcRPN - usuniecie niepotrzenych zmiennych lokalnych
; - Ujednolicenie jezyka komentarzy
;
; v0.5:
; - Dodanie informacji i modyfikowanych flagach i rejestrach
; 
; v0.5:
; - CalcRPN poprawa bledow zwiazanych ze obsluga stosu
; - Dodanie makr PushXMM i PopXMM
;
; v0.51:
; - ConvertToRPN - naprawnie bledu zwiazanego z priorytetem operatorow
; 
; v0.6:
; - ConvertToRPN - optymalizacja kodu (usuniecie zmiennej wasNum)
;
; v0.7:
; - ConvertToRPN - dodanie wsparcia dla brakujacych znakow * przed nawiasami
; - ConvertToRPN - naprawienie bledow zwiazanych z obsluga liczb ujemnych
;
; v0.8:
; - ConvertToRPN - naprawa bledu zwiazana z znakiem NULL
;
;*/

.data
	DN01 real8 0.1											;deklaracja 0.1
	DN1 real8 1.0											;deklaracja 1.0

.const
	EN48 equ 48												;deklaracja stalej 48
	EN10 equ 10												;deklaracja stalej 10

.code

	;Procedura konwertuje pobrane wyrazenie matematyczne na odwrotna notacje polska
	;Nie sprawdza parametrow wejsciowych. Musi byc zakonczone znakiem NULL.
	;Obsluguje liczby ujemne, -(, X(YYY) np. 125(3-5) -> 125*(3-5)
	;@param RCX: ptr byte pobrany ciag znakow z pliku
	;@param RDX: ptr byte buffor zapisu wyniku (zadeklarowany przed wywolaniem procedury)
	;@param R8: seperatora dziesietnego
	;@return 1 w przypadku braku bledow, 0 w razie napotkania bledu
	;@warning modyfikowane flagi: PL, ZR, AC, PE, CY
	;@warning modyfikowane rejestry: RBX, RCX, RDX, R8, R9, R10, R11
	;@warning wyrazenie nie moze posiadac spacji
	ConvertToRPN proc
		
		LOCAL currSignPriority: byte								;zmienna przechowujac priorytet pobranego operatora
		LOCAL numOperatorStack: DWORD								;zmienna przechowujaca ilosc operatorow wlozonych na stos
		LOCAL currSign: byte										;zmienna przechowujaca pobrany znak z DATA
		LOCAL popSign: byte											;zmienna przechowujaca pobrany operator ze stosu
		
		push rbp													;kopia rejestru RBP
		push rsi													;kopia rejestru RSI
		push rdi													;kopia rejestru RDI
		
		mov rsi, rcx												;wczytanie wskaznik na DATA (RCX)
		mov rdi, rdx												;wczytanie wskaznika na RESULT (RDX)
		xor rax, rax												;RAX = 0
		mov numOperatorStack, eax									;NUM_OPERATOR_STACK = 0
		
		mov al, byte ptr [rsi]										;zaladowanie 1 znaku do AL
		cmp al, '('													;sprawdzenie czy 1 znak to nawias (potrzebne aby nie wyjsc poza zakres)
			jne @CheckFirstMinus										;jesli nie, skok @CheckFirstMinus
			push rax												;odlozenie nawiasu na stos
			inc numOperatorStack									;inkrementacja ilosci elementow na stosie
		jmp @LoopInput												;skok do @LoopInput
		@CheckFirstMinus:											;@CheckFirstMinus
		cmp	al, '-'													;sprawdzenie czy 1 znak to minus
			jne @ReadyToLoop											;jesli nie, skok @ReadyToLoop
		mov [rdi], al												;RDI << '-'
		inc rdi														;RDI++
		inc rsi														;RSI++, przytowanie do pobrania nastepnego znaku
		mov al, [rsi]												;AL <- zaladowanie kolejenego znaku z zrodla
		cmp al, '('												;sprawdzenie czy wystepuje sytuacja -(
			jne @ReadyToLoop										;jesli nie, skok do @ReadyToLoop
		mov al, '1'												;zaladowanie 1 do AL
		mov [rdi], al											;RDI << 1
		inc rdi													;RDI++, przejscie do nastepnego wolnego miejsca
		mov al, ' '												;ladujemy spacje do AL
		mov [rdi], al											;RDI << ' '
		inc rdi													;RDI++, przejscie do nastepnego wolnego miejsca
		push '*'												;wlozenie * na stos
		push '('												;wlozenie ( na stos
		inc numOperatorStack									;inkrementacja NUM_OPERATOR_STACK
		inc numOperatorStack									;inkrementacja NUM_OPERATOR_STACK
		inc rsi													;RSI++, zaladowanie nastepnego znaku na wejscie

		@ReadyToLoop:												;@FirstNotMinus
		dec rsi														;indeks DATA[-1]

		@LoopInput:													;@LoopInput
			inc rsi													;inkrementacja RSI - nastepny znak
			mov rax, [rsi]											;wczytanie znaku do akumulatora (AL -> znak)
			mov currSign, al										;wczytanie pobranego znaku do CURR_SIGN
			cmp al, 0												;sprawdzenie czy wczytano znak '\0'
				je @LoopBreak											;tak, wyjscie z petli
			cmp al, '0'												;sprawdzenie czy pobrany znak >= '0' (czy pobrano cyfre)
				jb @FalseLoadNum										;znak < '0' czyli wczytano inny znak - skok do @FalseLoadNum
			cmp al, '9'												;tak, znak >= '0' - sprawdzenie czy znak <= '9'								
				jbe @LoadNum											;tak, wczytano cyfre - skok do @LoadNum
			@FalseLoadNum:											;@FalseLoadNum
			cmp al, '+'												;nie, sprawdzenie czy pobrany znak to '+'
				je @LoadAdd												;tak, skok do @LoadAdd
			cmp al, '-'												;nie, sprawdzenie czy pobrany znak to '-'
				je @LoadSub												;tak, skok do @LoadSub
			cmp al, '*'												;nie, sprawdzenie czy pobrany znak to '*'
				je @LoadMull											;tak, - skok do @LoadMull
			cmp al, '/'												;nie, sprawdzenie czy pobrany znak to '/'
				je @LoadDiv												;tak, skok do @LoadDiv
			cmp al, '('												;nie, sprawdzenie czy pobrany znak to '('
				je @LoadOpeningParenthesis								;tak, skok do @LoadOpeningParenthesis
			cmp al, ')'												;nie, sprawdzenie czy pobrany znak to ')'
				je @LoadClosedParenthesis								;tak, skok do @LoadClosedParenthesis
			jmp @Err												;skok do @Err
			
			@LoadNum:												;@LoadNum
			mov [rdi], rax											;RDI <- dodanie cyfry do wyniku
			inc rdi													;inkrementacja RDI (wskaznika)
			inc rsi													;inkrementacja RSI w celu sprawdzenia nastepnego znaku
			mov rax, [rsi]											;wczytanie znaku z RSI do RAX
			cmp al, 0												;sprawdzenie czy nastepny znak to '\0'
				je @LoopBreak											;tak, skok do @LoopBreak
			cmp al, r8b												;sprawdzenie czy wczytano separator .
				je @LoadNum												;tak, wczytano seperator -> skok do @LoadNum
			cmp al, '0'												;sprawdzenie czy nastepny znak to cyfra
				je @LoadNum												;wczytano 0 -> skok do @LoadNum
				jb @LoadNumBreak										;< '0', nie wczytano cyfry - skok do @LoadNumBreak
			cmp al, '9'												;upewnienie sie czy cyfra jest <= '9'								
			jbe @LoadNum											;tak, wczytano cyfre - skok do @LoadNum
			
			@LoadNumBreak:										;@LoadNumBreak	
			dec rsi												;dekrementacja RSI, (nowy obieg petli od razu go inkrementuje)
			mov al, " "											;wczytanie spacji do AL
			mov [rdi], al										;wypisanie wczytanej spacji do rezultatu
			inc rdi												;inkrementacja wskaznika RDI na nastepne wolne miejsce
			jmp @LoopInput										;pobranie nastepnego znaku -> skok do @LoopInput

			@LoadSub:											;@LoadSub
			xor r11, r11										;wyzerowanie r10 poniewaz bedziemy korzystac ino z r10b
			mov r9, rsi											;wczytanie do r8 RSI, aby nie zepsuc wskaznika
			mov r10, rsi											;identycznie dla r9 <- RSI
			dec r9												;zmniejszamy r8 aby otrzymac poprzedni znak
			inc r10												;zwiekszamy r9 aby otrzymac nastepny znak
			mov r11, [r9]										;wczytujemy wartosc znaku spod r8 do r10
			cmp r11b, '('										;sprawdzenie czy wystepuje sytuacja -(
				jne @LoadSubOperator								;jesli nie, skok do @LoadSubOperator
			mov [rdi], al										;RDI << '-'
			inc rdi												;RDI++, przejscie do nastepnego wolnego miejsca
			mov r11, [r10]										;wczytanie znaku spod r9 do r10
			cmp r11b, '('										;sprawdzenie czy wystapila sytuacja (-(
				jne @LoopInput										;jesli nie, skok do @LoopInput
																;jesli tak, to mamy sytuacje (-(
			mov al, '1'											;wczytanie do AL 1
			mov [rdi], al										;wyprowadzenie 1 do wyniku RDI << 1
			inc rdi												;inkrementacja RDI
			mov al, ' '											;zaladowanie do AL spacji
			mov [rdi], al										;RDI << AL
			inc rdi												;RDI++, ustawienie RDI na wolny bajt
			push '*'											;wlozenie * na stos
			push '('											;wlozenie ( na stos
			inc numOperatorStack								;inkrementacja NUM_OPERATOR_STACK
			inc numOperatorStack								;inkrementacja NUM_OPERATOR_STACK
			inc rsi												;RSI++, przejscie do nastepnego znaku aby ominac (
			jmp @LoopInput										;skok do @LoopInput

			@LoadSubOperator:									;@LoadSubOperator:
			@LoadAdd:											;@LoadAdd
			mov currSignPriority, '1'							;ustawienie priorytetu '1' do CURR_SIGN_PRIORITY
			jmp @CheckStackPriority								;skok do @CheckStackPriority
			
			@LoadMull:											;@LoadMull
			@LoadDiv:											;@LoadDiv
			mov currSignPriority, '2'							;ustawienie priorytetu '2' do CURR_SIGN_PRIORITY
				
			@CheckStackPriority:								;@CheckStackPriority
			mov ecx, numOperatorStack							;RCX <- NUM_OPERATOR_STACK
			cmp ecx, 0											;sprawdzenie, czy na stosie sa jakies operatory
			jz @StackLoopBreak										;brak operatorow, skok do @StackLoopBreak
				@StackLoop:										;@StackLoop
					xor rbx, rbx								;wyzerowanie RBX
					pop rbx										;pobiernie operatora z stosu
					mov popSign, bl								;zapisanie pobranego operatora do POP_SIGN
					push rcx									;wrzucenie licznika petli na stos
					xor rcx, rcx								;RCX <- 0
					mov cl, bl									;wpisanie do RCX parametru fun. CheckSignPriority
					call CheckSignPriority						;sprawdzenie priorytetu operatora na stosie
					pop rcx										;przywrocenie licznika petli
					cmp al, currSignPriority					;porowanie priorytetow operatorow
						jb @LP										;obecny pierytet jest wiekszy niz ten na stosie skok do @LP
																	;priorytet jest mniejszy lub rowny
																	;
						mov [rdi], rbx								;RDI <- EBX (ostatni pobrany operator)
						inc rdi										;inkrementacja wskaznika RDI
						mov rbx, " "								;RBX = " "
						mov [rdi], rbx								;RDI <- wpisanie spacji
						inc rdi										;inkrementacja wskaznika RDI
						dec numOperatorStack						;dekrementacj NUM_OPERATOR_STACK
						jmp @GP										;skok do @GP
					@LP:										;@LP - priorytet mniejszy
						push rbx									;zwrocenie operatora na stos
						jmp @StackLoopBreak							;skok do @StackLoopBreak
					@GP:										;@GP
					dec ecx										;dekrementacja licznika petli @StackLoop
					cmp ecx, 0									;sprawdzenie czy licznik == 0
				jne @StackLoop									;jesli tak to skok do @StackLoop
				
				@StackLoopBreak:								;@StackLoopBreak
				xor rax, rax									;RAX <- 0
				mov al, currSign								;wczytanie do AL wartosci zmiennej CURR_SIGN
				push rax										;wrzucenie operatora na stos
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadOpeningParenthesis:							;@LoadOpeningParenthesis	
				xor r10, r10									;wyzerowanie r9
				mov r9, rsi										;r8 <- RSI aby operowac na kopii
				dec r9											;dekrementacja r8 w celu pozyskania poprzedniego znaku
				mov r10, [r9]									;wczytaniu do r9 znaku spod adresu r8
				cmp r10b, ')'									;porowanie czy poprzedni znak to (
					jne @LOP@CheckBeforeNum							;jesli nie, skok do @LOP@CheckBeforeNum	
				push '*'										;jesli tak, to mamy ")(" - wlozenie na stos * 
				inc numOperatorStack							;inkrementacja ilosci elementow na stosie
				jmp @LOP@PushOpeningBracket						;skok do LOP@PushOpeningBracket
				
				@LOP@CheckBeforeNum:							;@LOP@CheckBeforeNum
				cmp r10b, '0'									;sprawdzenie czy znak < '0;
					jb @LOP@PushOpeningBracket						;jesli tak, skok do @LOP@PushOpeningBracket
				cmp r10b, '9'									;sprawdzenie czy znak > '9'								
					ja @LOP@PushOpeningBracket						;tak, skok do @LOP@PushOpeningBracket
				push '*'										;nie, mamy sytuacje typu X(YYY), wlozenie * na stos
				inc numOperatorStack							;inkrementacja ilosci elementow na stosie

				@LOP@PushOpeningBracket:						;@LOP@PushOpeningBracket
				push rax										;dodanie znaku ( na stos
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadClosedParenthesis:								;@LoadClosedParenthesis
				xor rdx, rdx									;RDX <- 0
				mov ecx, numOperatorStack						;RCX <- NUM_OPERATOR_STACK - wprowadzenie licznika petli @LoopStack
				@@LoopStack:									;@@LoopStack
					xor rbx, rbx								;RBX <- 0
					pop rbx										;pobranie operatora z stosu
					mov popSign, bl								;zapisanie pobranego operatpra do POP_SIGN
					cmp bl, '('									;sprawdzenie czy pobrany operator to (
						je @@LoopStackBreak							;tak, skok do @@LoopStackBreak
						mov [rdi], rbx							;nie, wyprowadzenie pobranego operatora do RDI
						inc rdi									;inkrementacja RDI (wskaznika)
						mov rbx, " "							;RBX <- " "
						mov [rdi], rbx							;RESUTL <- spacja
						inc rdi									;inkrementacja RDI (wskaznika)
						dec numOperatorStack					;dekrementacja NUM_OPERATOR_STACK
						jmp @@LS								;skok do @@LS
					@@LoopStackBreak:							;@@LoopStackBreak
						dec numOperatorStack					;dekrementacja NUM_OPERATOR_STACK
						jmp @LoopInput							;skok do @LoopInput - wczytanie nowgo znaku
					@@LS:										;@@LS
					dec ecx										;dekrementacja licznika petli
					cmp ecx, 0									;sprawdzenie czy sa jeszcze jakies znaki na stosie
				jne @@LoopStack									;tak, skok do @@LoopStack
			jmp @LoopInput										;nie, skok do @LoopInput

		
		@LoopBreak:												;@LoopBreak
		
		mov cl, " "												;zaladowanie spacji do CL
		mov [rdi], cl											;RDI <- dodanie spacji
		inc rdi													;inkrementacja wskaznika RDI

																;COMM:: wyprowadzenie do lancucha wynikowego pozostalych znakow na stosie 
		
		mov ecx, numOperatorStack								;zaladowanie licznika petli (NUM_OPERATOR_STACK)
		cmp ecx, 0												;sprawdzenie czy sa jakies operatory na stosie
			je @End													;jesli  tak to skok do @End
		@LoopStackClear:										;@LoopStackClear
			pop rbx												;pobranie operatora z stosu
			mov popSign, bl										;zapisanie pobranego operatora do POP_SIGN
			mov [rdi], rbx										;RDI << wyprowadzenie operatora do wyniku
			inc rdi												;inkrementacja RDI (wskaznika)
			mov rbx, " "										;zaladowanie spacji do EBX
			mov [rdi], rbx										;RDI << dodanie spacja
			inc rdi												;inkrementacja RDI (wskaznika)
			dec ecx												;dekrementacja licznika petli
			cmp ecx, 0											;sprawdzenie czy sa jeszcze jakies znaki na stosie
		jne @LoopStackClear										;tak, skok do nowego obiegu petli
																;nie, przejscie dalej
		@End:
		xor rax, rax											;RAX << 0 znak NULL
		mov [rdi], rax											;RDI << '\0'
		mov rax, 1												;RAX << brak bledow, TRUE
		
		
		pop rdi													;przywrocenie RDI
		pop rsi													;przywrocenie RSI
		pop rbp													;przywrocenie RBP

		ret														;return RAX

		@Err:													;@Err
		mov rax, 0												;RAX << wystapil blad, FALSE

		pop rdi													;przywrocenie RDI
		pop rsi													;przywrocenie RSI
		pop rbp													;przywrocenie RBP

		ret														;return RAX

	ConvertToRPN endp

	;Procedura sprawdza priorytet operatora matematycznego
	;@param CL: byte operator matematyczny
	;@return zwraca piorytet znaku -> '0', '1', '2'
	;@warning modyfikowane flagi: ZR, PE.
	CheckSignPriority proc
		
		xor rax, rax							;wyzerowanie RAX
		mov al, cl								;AL <- CL (SIGN)
		cmp al, '+'								;sprawdzenie czy pobrano +
			je @LoadPrirorty1						;tak, skok do @LoadPrirorty1
		cmp al, '-'								;sprawdzenie czy pobrano -
			je @LoadPrirorty1						;tak, skok do @LoadPrirorty1
		cmp al, '*'								;sprawdzenie czy pobrano *
			je @LoadPrirorty2						;tak, skok do @LoadPrirorty2
		cmp al, '/'								;sprawdzenie czy pobrano /
			je @LoadPrirorty2						;tak, skok do @LoadPrirorty2
		mov al, '0'								;ustawienie piorytetu 0 do AL
		ret										;return RAX (AL)
		@LoadPrirorty1:							;@LoadPrirorty1
		mov al, '1'								;ustawienie piorytetu 1 AL
		ret										;return RAX (AL)
		@LoadPrirorty2:							;@LoadPrirorty2
		mov al, '2'								;ustawienie piorytetu 2 AL
		ret										;return RAX (AL)

	CheckSignPriority endp

	;Makro wstawiajace wartosc rejestru XMM na stos
	;@param _XMM: rejestr XMM0-7
	PushXMM macro _XMM
		sub rsp, 16
		movdqu XMMWORD PTR [rsp], _XMM
	endm

	;Makro pobierajace wartosc rejestru XMM na stos
	;@param _XMM: rejestr XMM0-7
	PopXMM macro _XMM
		movdqu _XMM, XMMWORD PTR [rsp]
		add rsp, 16	
	endm

	;Procedura oblicza wartosc wyrazenia ONP, ktore moze skladac sie z cyfr, +, -, *, /, . i spacji
	;Nie sprawdza poprawnosci parametrow wejsciowych. Kazda liczba i znak musi byc oddzielony spacja.
	;@param RCX: <ptr byte> wyrazenie ONP, ktore musi byc zakonczone spacja (liczby ujemne) i znakiem NULL
	;@param RDX: seperatora dziesietnego
	;@return XMM0: <real8> zwraca wynik wyrazenia ONP. W przypadku bledu zwraca 0
	;@warning modyfikowane flagi: OV, PL, ZR, AC, PE, CY
	;@warning modyfikowane rejestry: RAX, RBX, RCX, RDX, R8, R9, XMM0-7
	CalcRPN proc

		LOCAL currSign: BYTE										;znak wczytywanej liczby
		LOCAL exponentSize: DWORD									;rozmiar cechy liczby

		push rbp													;kopia rejestru RBP
		push rsi													;kopia rejestru RSI
		push rdi													;kopia rejestru RDI

		xor rax, rax												;wyzerowanie RAX
		mov exponentSize, eax										;EXPONENT_SIZE <- EAX, wyzerowanie rozmiaru cechy liczby
		movsd xmm6, DN01											;XMM6 <- 0.1
		xorpd xmm7, xmm7											;XMM7 <- 0

		mov rsi, rcx												;zaladowanie RPN do ESI

		mov al, '+'													;AL <- '+'
		mov currSign, al											;przyjecie ze pierwsza liczba jest dodatnia

		dec rsi														;indeks RPN[-1]

		CalcRPN@LOOP:												;CalcRPN@LOOP
			inc rsi													;inkrementacja indeksu tablicy RPN
			mov bl, byte ptr [rsi]									; ### DEBUG ###
			cmp byte ptr [rsi], 0									;sprawdzenie czy wczytano znak '\0'
				je CalcRPN@LOOPBreak									;tak, wyjscie z petli
			cmp byte ptr [rsi], '0'									;sprawdzenie czy pobrany znak to cyfra
				jae CalcRPN@LoadNum										;tak, skok do CalcRPN@LoadNum
			cmp byte ptr [rsi], ' '									;sprawdzenie czy pobrany znak to spacja
				je CalcRPN@LOOP											;tak, skok do CalcRPN@LOOP
			cmp byte ptr [rsi], '-'									;sprawdzenie czy pobrany znak to '-'
				jne CalcRPN@OperatorNext								;nie, skok do CalcRPN@OperatorNext
				cmp byte ptr [rsi+1], " "								;sprawdzenie czy wczytano '-' jako operator (czy nastepny znak jest spacja)
					je CalcRPN@LoadSub										;tak, skok do CalcRPN@LoadSubOperator
				mov currSign, '-'										;CURR_SIGN = '-'
				jmp CalcRPN@LOOP										;skok do CalcRPN@LOOP
			CalcRPN@OperatorNext:									;CalcRPN@OperatorNex
			cmp byte ptr [rsi], '+'									;sprawdzenie czy pobrany znak to '+'
				je CalcRPN@LoadAdd										;tak, skok do CalcRPN@LoadAdd
			cmp byte ptr [rsi], '*'									;sprawdzenie czy pobrany znak to '*'
				je CalcRPN@LoadMull										;tak, - skok do CalcRPN@LoadMull
			cmp byte ptr [rsi], '/'									;sprawdzenie czy pobrany znak to '/'
				je CalcRPN@LoadDiv										;tak, skok do CalcRPN@LoadDiv
			xorps xmm0, xmm0										;jesli nie to wyzerowanie XMM0 w celu zwrocenia bledu funkcji
			PushXMM xmm0											;wlozenie wartosci XMM0 na stos
			jmp CalcRPN@LOOPBreak									;skok do CalcRPN@LOOPBreak

			CalcRPN@LoadNum:										;CalcRPN@LoadNum
																	;COMM::wczytanie cechy liczby
				xor rbx, rbx										;RBX <- 0 - przechowywac bedzie ceche liczby
				mov rcx, 1											;mnoznik - RCX <- 1

				CalcRPN@LoadExponentNum:							;CalcRPN@LoadExponentNum
					xor rax, rax									;RAX <- 0
					mov al, byte ptr [rsi]							;wkladam znak cyfry do AL
					push rax										;wkladam cyfre na stos
					inc exponentSize									;inkrementacja EXPONENT_SIZE
					inc rsi											;inkrementacja indexu RPN [RSI]
					cmp byte ptr [rsi], r8b							;sprawdzenie czy wczytano seperator
						je CalcRPN@ExponentToDecimal					;tak, skok do CalcRPN@ExponentToDecimal
					cmp byte ptr [rsi], " "							;sprawdznie czy wczytano cala liczbe tzn.spacje
						je CalcRPN@ExponentToDecimal					;tak, to skok do CalcRPN@ExponentToDecimal
				jne	CalcRPN@LoadExponentNum							;nie, to wczytaj nastepna cyfre lub seperator

				CalcRPN@ExponentToDecimal:							;CalcRPN@ExponentToDecimal
					pop rax											;pobieram znaku cyfry ze stosu
					sub al, EN48									;zamiana ASCII na cyfre (AL - '0')
					mul rcx											;przemnozenie przez mnoznik
					add rbx, rax									;dodanie wyniku do rejestru RBX
																	;mnoznik * 10
					mov rax, rcx									;
					mov rdx, EN10									;
					mul rdx											;
					mov rcx, rax									;

					dec exponentSize								;zmniejszenie ilosci cyfr na stosie
					cmp exponentSize, 0								;sprawdzenie czy przetworzono wszystkie cyfry
				jne CalcRPN@ExponentToDecimal							;jesli nie to skok do CalcRPN@ExponentToDecimal

																	;RBX posiada wartosci cechy liczby
				xorpd xmm1, xmm1 									;XMM1 <- 0
				cvtsi2sd xmm1, rbx									;XMM1 <- RBX __ EXPONENT

				cmp byte ptr [rsi], " "								;sprawdznie czy wczytano cala liczbe tzn.spacje
					je CalcRPN@NumReady									;tak, to skok do CalcRPN@NumReady
																	
																	;XMM0
																	;XMM1 - WYNIK (CECHA+MANTYSA)
																	;XMM2 - MNOZNIK
																	;XMM3 - CYFRA * MNOZNIK
																	;XMM4 - pop XMM (TMP_1)
																	;XMM5 - pop XMM (TMP_2)
																	;XMM6 - 0.1
																	;XMM7 - 0.0

				movsd xmm2, xmm6									;XMM2 <- 0.1

				inc rsi												;inkrementacja licznika RPN [RSI]

				CalcRPN@LoadMantissaNum:
					xor r9, r9										;R9 <- 0
					mov r9b, byte ptr [rsi]							;R9B <- znak cyfry
					sub r9b, EN48									;R9B <- konwersja z ASCII na cyfre (R8B - '0')
					cvtsi2sd  xmm3, r9								;XMM3 <- zsaladowanie cyfry z R9B
					mulsd xmm3, xmm2								;XMM3 <- CYFRA * MNOZNIK
					addsd xmm1, xmm3								;dodanie uzyskanej wartosci do XMM1
					mulsd xmm2,	xmm6								;XMM2 <- MNOZNIK * 0.1
					inc rsi											;inkrementacja licznika RPN [RSI]
					cmp byte ptr [rsi], " "							;sprawdznie czy wczytano cala liczbe tzn.spacje
						je CalcRPN@NumReady								;tak, to skok do CalcRPN@WholeNum
				jne CalcRPN@LoadMantissaNum							;nie, to wczytaj nastepna cyfre

				CalcRPN@NumReady:									;CalcRPN@NumReady

																	;uwzglednienie czy dodatnia czy ujemna
				cmp currSign, '-'									;sprawdzenie czy CURR_SIGN == '-'
					jne PositiveNum										;jesli nie to skok do PositiveNum
				 													;jesli tak to:
				xorpd xmm5, xmm5										;XMM5 <- 0
				subsd xmm5, xmm1										;XMM5 - XMM1
				movsd xmm1, xmm5										;XMM1 <- XMM5
				
				PositiveNum:										;PositiveNum
				PushXMM xmm1										;odlozenie wyniku na stos

																	;COM::czyszcenie pod nastepna liczbe
				xor rax, rax										;RAX <- 0
				mov exponentSize, eax								;zeruje rozmiar cechy
				mov al, '+'											;AL <- '+'
				mov currSign, al									;CURR_SING = '+', przyjmuje ze nastepna liczba bedzie dodatnia

			jmp CalcRPN@LOOP									;skok do CalcRPN@LOOP

			CalcRPN@LoadSub:										;CalcRPN@LoadSub
				PopXMM	xmm4										;pobranie ze stosu liczby do XMM4
				PopXMM	xmm5										;pobranie ze stosu liczby do XMM5
				subsd xmm5, xmm4									;XMM5 <- XMM5 - XMM4
				PushXMM xmm5										;wrzucenie wyniku na stos
				jmp CalcRPN@LOOP									;skok do CalcRPN@LOOP
			CalcRPN@LoadAdd:										;CalcRPN@LoadAdd
				PopXMM	xmm4										;pobranie ze stosu liczby do XMM4
				PopXMM	xmm5										;pobranie ze stosu liczby do XMM5
				addsd xmm5, xmm4									;XMM5 <- XMM5 + XMM4
				PushXMM xmm5										;wrzucenie wyniku na stos
				jmp CalcRPN@LOOP									;skok do CalcRPN@LOOP
			CalcRPN@LoadMull:										;CalcRPN@LoadMull
				PopXMM	xmm4										;pobranie ze stosu liczby do XMM4
				PopXMM	xmm5										;pobranie ze stosu liczby do XMM5
				mulsd xmm5, xmm4									;XMM5 <- XMM5 * XMM4
				PushXMM xmm5										;wrzucenie wyniku na stos
				jmp CalcRPN@LOOP									;skok do CalcRPN@LOOP
			CalcRPN@LoadDiv:										;CalcRPN@LoadDiv
				PopXMM	xmm4										;pobranie ze stosu liczby do XMM4
				PopXMM	xmm5										;pobranie ze stosu liczby do XMM5
				divsd xmm5, xmm4									;XMM5 <- XMM5 / XMM4
				PushXMM xmm5										;wrzucenie wyniku na stos

		jmp CalcRPN@LOOP											;skok do CalcRPN@LOOP - wczytanie nastepnego znaku RPN

		CalcRPN@LOOPBreak:											;CalcRPN@LOOPBreak

		PopXMM xmm0												; pobranie wyniku koncowego ze stosu

		pop rdi													;przywrocenie RDI
		pop rsi													;przywrocenie RSI
		pop rbp													;przywrocenie RBP

		ret														;return XMM0

	CalcRPN endp

end