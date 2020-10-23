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
;*/

.data
	DN01 real8 0.1											;deklaracja 0.1
	DN1 real8 1.0											;deklaracja 1.0
	TMP_R4 real8 0.0										;zmienna tymczasowa pod REAL8

.const
	EN48 equ 48												;deklaracja stalej 48
	EN10 equ 10												;deklaracja stalej 10

.code

	;Procedura konwertuje pobrane wyrazenie matematyczne na odwrotna notacje polska
	;Nie sprawdza parametrow wejsciowych
	;@param RCX: ptr byte pobrany ciag znakow z pliku
	;@param RDX: ptr byte buffor zapisu wyniku (zadeklarowany przed wywolaniem procedury)
	;@warning modyfikowane flagi: OF, CF, SF, ZF, AF i PF.
	;@warning modyfikowane rejestry: RBX, RCX, RDX
	;@warning wyrazenie nie moze posiadac spacji
	;@warning::wolne rejestry R8-R15
	ConvertToRPN proc
		
		LOCAL wasNum: byte											;zmienna wykorzystywana do dodawania spacji
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
		mov al, '0'													;AL = 0
		mov wasNum, al												;WAS_NUM = 0

		cmp byte ptr [rsi], '-'										;sprawdzam, czy pierwszy znak jest '-'
			mov al, byte ptr [rsi]										;jesli tak, to AL <- '-'
			je @LoadNum													;i skok do @LoadNum

		dec rsi														;indeks DATA[-1]

		@LoopInput:													;@LoopInput

			inc rsi													;inkrementacja RSI - nastepny znak
			mov rax, [rsi]											;wczytanie znaku do akumulatora (AL -> znak)
			mov currSign, al										;wczytanie pobranego znaku do CURR_SIGN
			
			cmp al, 0												;sprawdzenie czy wczytano znak '\0'
				je @LoopBreak											;tak, wyjscie z petli

																		;nie, sprawdzenie czy pobrano cyfre

			cmp al, '0'												;sprawdzenie czy pobrany znak >= '0'
				je @LoadNum												;znak == '0' - skok do @LoadNum
				jb @FalseLoadNum										;znak < '0' czyli wczytnao inny znak - skok do @FalseLoadNum
			cmp al, '9'												;tak, znak >= '0' - sprawdzenie czy znak <= '9'								
				jbe @LoadNum											;tak, wczytano cyfre - skok do @LoadNum
				ja @Err													;nie, wczytano inny znak - skok do @Err

			@FalseLoadNum:											;@FalseLoadNum

			cmp al, '.'												;sprawdzenie czy wczytano seperator
				je @LoadSeperator										;tak, wczytano seperator - skok do @LoadSeperator

			xor rbx, rbx										;wyzerowanie rejestru RBX
			mov bl, wasNum										;wczytanie wartosci WAS_NUM do BL
			cmp bl, '1'											;sprawdzenie czy do RESULT nalezy dodac spacje
				jne @NotAddSpace									;nie, skok do @NotAddSpace
																	;tak
				mov rbx, " "											;RBX <- " "
				mov [rdi], rbx											;RESULT <- dodanie spacji
				inc rdi													;zwiekszenie indeksu RESULT
				mov bl, '0'												;wczytanie '0' do BL
				mov wasNum, bl											;ustawienie zmiennej WAS_NUM na false ('0')											;

			@NotAddSpace:										;@NotAddSpace

				cmp al, ' '										;sprawdzenie czy pobrany znak to spacja
					je @LoadSpace									;tak, skok do @LoadSpace
				cmp al, '+'										;nie, sprawdzenie czy pobrany znak to '+'
					je @LoadAdd										;tak, skok do @LoadAdd
				cmp al, '-'										;nie, sprawdzenie czy pobrany znak to '-'
					je @LoadSub										;tak, skok do @LoadSub
				cmp al, '*'										;nie, sprawdzenie czy pobrany znak to '*'
					je @LoadMull									;tak, - skok do @LoadMull
				cmp al, '/'										;nie, sprawdzenie czy pobrany znak to '/'
					je @LoadDiv										;tak, skok do @LoadDiv
				cmp al, '('										;nie, sprawdzenie czy pobrany znak to '('
					je @LoadOpeningParenthesis						;tak, skok do @LoadOpeningParenthesis
				cmp al, ')'										;nie, sprawdzenie czy pobrany znak to ')'
					je @LoadClosedParenthesis						;tak, skok do @LoadClosedParenthesis

			@LoadSpace:											;@LoadSpace
			jmp @LoopInput										;skok do @LoopInput - pobranie nastepnego znaku

			@LoadNum:											;@LoadNum
			@LoadSeperator:										;@LoadSeperator
			mov [rdi], rax										;RESULT <- dodanie cyfry do wyniku
			inc rdi												;zwiekszenie indeksu RESULT
			mov bl, '1'											;wczytanie '1' do BL
			mov wasNum, bl										;zapisanie do WAS_NUM, ze wczytano znak zwiazany z liczba
			jmp @LoopInput										;skok do @LoopInput - pobranie nastepnego znaku

			@LoadSub:											;@LoadSub
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
																;ASM x86
					;push rbx									;zwrocenie operator na stos
																;<!-- ASM x86 ->
																;ASM x64
					push rcx									;wrzucenie licznika petli na stos
					xor rcx, rcx								;RCX <- 0
					mov cl, bl									;wpisanie do RCX parametru fun. CheckSignPriority
																;<!-- ASM x64 ->
					call CheckSignPriority						;sprawdzenie priorytetu operatora na stosie
																;ASM x64
					pop rcx										;przywrocenie licznika petli
																;<!-- ASM x64 ->
					cmp al, currSignPriority					;porowanie priorytetow operatorow
						jbe @LP										;pierytet jest mniejszy skok do @LP
																	;priorytet jest wiekszy	
																	;
						mov [rdi], rbx								;RESULT <- EBX (ostatni pobrany operator)
						inc rdi										;inkrementacja indeksu RESULT
						mov rbx, " "								;RBX = " "
						mov [rdi], rbx								;RESULT <- wpisanie spacji
						inc rdi										;inkrementacja indeksu RESULT
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
				push rax										;dodanie znaku ( na stos
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				inc rsi											;sprawdzenie czy przypadkiem nastepna liczb jest ujemna
				cmp byte ptr [rsi], '-'							;
					jne @LOP_NOT_MINUS							;nie, to skok do @LOP_NOT_MINUS
																;jesli tak to...
					xor rax, rax								;RAX <- 0
					mov al, byte ptr [rsi]						;AL <- '-'
				jmp @LoadNum									;tak, skok do @LoadNum
				@LOP_NOT_MINUS:									;@LOP_NOT_MINUS
					dec rsi										;dekrementacja RSI
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
						mov [rdi], rbx							;nie, RESULT <- RBX (pobrany operator z  stosu)
						inc rdi									;inkrementacja indeksu RESULT
						mov rbx, " "							;RBX <- " "
						mov [rdi], rbx							;RESUTL <- spacja
						inc rdi									;inkrementacja indeksu RESULT
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
		mov [rdi], cl											;RESUTL <- dodanie spacji
		inc rdi													;inkrementacja indeksu RESULT

																;COMM:: wyprowadzenie do lancucha wynikowego pozostalych znakow na stosie 
		
		mov ecx, numOperatorStack								;zaladowanie licznika petli (NUM_OPERATOR_STACK)
		cmp ecx, 0												;sprawdzenie czy sa jakies operatory na stosie
			je @End													;jesli  tak to skok do @End
		@LoopStackClear:										;@LoopStackClear
			pop rbx												;pobranie operatora z stosu
			mov popSign, bl										;zapisanie pobranego operatora do POP_SIGN
			mov [rdi], rbx										;RESULT << wyprowadzenie operatora do wyniku
			inc rdi												;inkrementacja indeksu RESULT
			mov rbx, " "										;zaladowanie spacji do EBX
			mov [rdi], rbx										;RESUTL << dodanie spacja
			inc rdi												;inkrementacja indeksu RESULT
			dec ecx												;dekrementacja licznika petli
			cmp ecx, 0											;sprawdzenie czy sa jeszcze jakies znaki na stosie
		jne @LoopStackClear										;tak, skok do nowego obiegu petli
																;nie, przejscie dalej
		@End:
		mov rdi, 0												;RESULT << '\0'
		xor rax, rax											;RAX <- 0
		mov rax, 1												;RAX <- brak bledow, TRUE
		
		@Err:													;@Err
		mov rax, 0												;RAX <- wystapil blad, FALSE

		pop rdi													;przywrocenie RDI
		pop rsi													;przywrocenie RSI
		pop rbp													;przywrocenie RBP

		ret														;return RAX

	ConvertToRPN endp

	;Procedura sprawdza priorytet operatora matematycznego
	;@param CL: byte operator matematyczny
	;@return zwraca piorytet znaku -> '0', '1', '2'
	;@warning modyfikowane flagi: OF, CF, SF, ZF, AF i PF.
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
		@LoadPrirorty1: 
		mov al, '1'								;ustawienie piorytetu 1 AL
		ret										;return RAX (AL)
		@LoadPrirorty2: 
		mov al, '2'								;ustawienie piorytetu 2 AL
		ret										;return RAX (AL)

	CheckSignPriority endp

	;Procedura oblicza wartosc wyrazenia ONP
	;Nie sprawdza parametrow wejsciowych. Kazda liczba i znak musi byc oddzielony spacja.
	;@param RCX: <ptr byte> wyrazenie ONP
	;@return XMM0: <real8> zwraca wynik wyrazenia ONP, w razie bledu zwraca 0
	;@warning modyfikowane flagi: <uzupelnic>
	;@warning modyfikowane rejestry: RAX, RBX, RCX, RDX, R8, XMM0-7
	;@warning::wolne rejestry R9-R15
	CalcRPN proc

		LOCAL currSign: BYTE										;znak wczytywanej liczby
		LOCAL exponentSize: DWORD									;rozmiar cechy liczby

		push rsi													;kopia RSI

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
			cmp byte ptr [rsi], 0									;sprawdzenie czy wczytano znak '\0'
				je CalcRPN@LOOPBreak									;tak, wyjscie z petli
			cmp byte ptr [rsi], '0'									;sprawdzenie czy pobrany znak to cyfra
				jae CalcRPN@LoadNum										;tak, skok do CalcRPN@LoadNum
			cmp byte ptr [rsi], '+'									;nie, sprawdzenie czy pobrany znak to '+'
				je CalcRPN@LoadAdd										;tak, skok do CalcRPN@LoadAdd
			cmp byte ptr [rsi], '-'									;nie, sprawdzenie czy pobrany znak to '-'
				je CalcRPN@LoadSub										;tak, skok do CalcRPN@LoadSub
			cmp byte ptr [rsi], '*'									;nie, sprawdzenie czy pobrany znak to '*'
				je CalcRPN@LoadMull										;tak, - skok do CalcRPN@LoadMull
			cmp byte ptr [rsi], '/'									;nie, sprawdzenie czy pobrany znak to '/'
				je CalcRPN@LoadDiv										;tak, skok do CalcRPN@LoadDiv
			cmp byte ptr [rsi], ' '									;sprawdzenie czy pobrany znak to spacja
				je CalcRPN@LoadSpace									;tak, skok do CalcRPN@LoadSpace
			jmp CalcRPN@Err

			CalcRPN@LoadNum:
																	;COMM::wczytanie cechy liczby
				xor rbx, rbx										;RBX <- 0 - przechowywac bedzie ceche liczby
				mov rcx, 1											;mnoznik - RCX <- 1

				CalcRPN@LoadExponentNum:							;CalcRPN@LoadExponentNum
					xor rax, rax									;RAX <- 0
					mov al, byte ptr [rsi]							;wkladam znak cyfry do AL
					push rax										;wkladam cyfre na stos
					inc exponentSize									;inkrementacja EXPONENT_SIZE
					inc rsi											;inkrementacja indexu RPN [RSI]
					cmp byte ptr [rsi], '.'							;sprawdzenie czy wczytano seperator
						je CalcRPN@ExponentToDecimal					;tak, skok do CalcRPN@ExponentToDecimal
					cmp byte ptr [rsi], " "							;sprawdznie czy wczytano cala liczbe tzn.spacje
						je CalcRPN@ExponentToDecimal					;tak, to skok do CalcRPN@ExponentToDecimal
				jne	CalcRPN@LoadExponentNum							;nie, to wczytaj nastepna cyfre lub seperator

				CalcRPN@ExponentToDecimal:
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
				jne CalcRPN@ExponentToDecimal

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
					xor r8, r8										;R8 <- 0
					mov r8b, byte ptr [rsi]							;R8B <- znak cyfry
					sub r8b, EN48									;R8B <- konwersja z ASCII na cyfre (R8B - '0')
					cvtsi2sd  xmm3, r8								;XMM3 <- zsaladowanie cyfry z R8B
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
				movupd TMP_R4, xmm1									;TMP_R4 <- XMM1
				fld TMP_R4											;odlozenie wyniku na stos (TMP_R4)

																	;COM::czyszcenie pod nastepna liczbe
				xor rax, rax										;RAX <- 0
				mov exponentSize, eax								;zeruje rozmiar cechy
				mov al, '+'											;AL <- '+'
				mov currSign, al									;CURR_SING = '+', przyjmuje ze nastepna liczba bedzie dodatnia

			jmp CalcRPN@LOOP									;skok do CalcRPN@LOOP

			CalcRPN@LoadSub:										;CalcRPN@LoadSub
			cmp byte ptr [rsi+1], " "								;sprawdzenie czy wczytano '-' jako operator
				je CalcRPN@LoadSubOperator								;tak, skok do CalcRPN@LoadSubOperator
			mov currSign, '-'										;nie, CURR_SIGN = '-'
			jmp CalcRPN@LOOP										;skok do CalcRPN@LOOP

			CalcRPN@LoadSubOperator:								;CalcRPN@LoadSubOperator
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm4, TMP_R4									;zaladowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm5, TMP_R4									;zaladowanie liczby do XMM5
				subsd xmm5, xmm4									;XMM5 <- XMM% - XMM4
				movupd TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadAdd:										;CalcRPN@LoadAdd
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm4, TMP_R4									;zaladowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm5, TMP_R4									;zaladowanie liczby do XMM5
				addsd xmm5, xmm4									;XMM5 <- XMM% + XMM4
				movupd TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadMull:										;CalcRPN@LoadMull
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm4, TMP_R4									;zaladowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm5, TMP_R4									;zaladowanie liczby do XMM5
				mulsd xmm5, xmm4									;XMM5 <- XMM% * XMM4
				movupd TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadDiv:										;CalcRPN@LoadDiv
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm4, TMP_R4									;zaladowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movupd xmm5, TMP_R4									;zaladowanie liczby do XMM5
				divsd xmm5, xmm4									;XMM5 <- XMM% / XMM4
				movupd TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadSpace:										;CalcRPN@LoadSpace

		jmp CalcRPN@LOOP											;skok do CalcRPN@LOOP - wczytanie nastepnego znaku RPN

		CalcRPN@LOOPBreak:											;CalcRPN@LOOPBreak

		fstp TMP_R4													;pobranie koncowego wyniku ze stosu
		movsd xmm0, TMP_R4											;zwrocenie wyniku

		pop RSI														;przywrocenie RSI

		ret															;return XMM0

		CalcRPN@Err:												;CalcRPN@Err
		xorpd xmm0, xmm0											;XMM0 <- 0
		ret															;return RAX

	CalcRPN endp

end