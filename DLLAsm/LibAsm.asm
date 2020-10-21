;DLLAsm
;
; Source code to library used in reverse polish notation calculator project
;
; Author: Konrad Skrzypczyk
; Subject: Assembly languages
; Academic year: 2020/21
; Implementation: MASM
;
; =================== CHANELOG ===================
;
; v0.1:
; Adding and implementing new method void ConvertToRPN(const char* data, char* result);
;
; v0.11:
; - Adding new function definiton: long double __cdecl CalcRPN(const char* rpn) 
; - Remove macro: .IF .IFELSE .ENDIF
; 
; v0.2:
; - 'Rebranding' code to x64
;
; v0.21:
; - ConvertToRPN -> support negative number
;
;*/

.const
	N48 equ 48												;deklaracja sta�ej 48

.code

	;Procedura konwertuje pobrane wyra�enie matematyczne na odwrotn� notacj� polsk�
	;@param RCX: ptr byte pobrany ci�g znak�w z pliku
	;@param RDX: ptr byte buffor zapisu wyniku
	;@warning modyfikowane flagi: OF, CF, SF, ZF, AF i PF.
	;@warning modyfikowane rejestry: RBX, RCX, RDX
	;@warning wyra�enie nie mo�e posiada� spacji
	ConvertToRPN proc
		
		LOCAL wasNum: byte											;zmienna wykorzystywana do dodawania spacji
		LOCAL currSignPriority: byte								;zmienna przechowuj�c priorytet pobranego operatora
		LOCAL numOperatorStack: DWORD								;zmienna przechowuj�ca ilo�� operator�w w�o�onych na stos
		LOCAL currSign: byte										;zmienna przechowuj�ca pobrany znak z DATA
		LOCAL popSign: byte											;zmienna przechowuj�ca pobrany operator ze stosu

		push rbp													;kopia rejestru RBP
		push rsi													;kopia rejestru RSI
		push rdi													;kopia rejestru RDI

		mov rsi, rcx												;wczytanie wska�nik na DATA (RCX)
		mov rdi, rdx												;wczytanie wska�nika na RESULT (RDX)
		xor rax, rax												;RAX = 0
		mov numOperatorStack, eax									;NUM_OPERATOR_STACK = 0
		mov al, '0'													;AL = 0
		mov wasNum, al												;WAS_NUM = 0
																	
																	;TODO: usuwanie spacji z RSI

		cmp byte ptr [rsi], '-'										;sprawdzam, czy pierwszy znak jest '-'
			mov al, byte ptr [rsi]										;je�li tak, to AL <- '-'
			je @LoadNum													;i skok do @LoadNum

		dec rsi														;indeks DATA[-1]

		@LoopInput:													;@LoopInput

			inc rsi													;inkrementacja RSI - nast�pny znak
			mov rax, [rsi]											;wczytanie znaku do akumulatora (AL -> znak)
			mov currSign, al										;wczytanie pobranego znaku do CURR_SIGN
			
			cmp al, 0												;sprawdzenie czy wczytano znak '\0'
				je @LoopBreak											;tak, wyj�cie z p�tli

																		;nie, sprawdzenie czy pobrano cyfr�

			cmp al, '0'												;sprawdzenie czy pobrany znak >= '0'
				je @LoadNum												;znak == '0' - skok do @LoadNum
				jb @FalseLoadNum										;znak < '0' czyli wczytnao inny znak - skok do @FalseLoadNum
			cmp al, '9'												;tak, znak >= '0' - sprawdzenie czy znak <= '9'								
				jbe @LoadNum											;tak, wczytano cyfr� - skok do @LoadNum
				ja @Err													;nie, wczytano inny znak - skok do @Err

			@FalseLoadNum:											;@FalseLoadNum

			cmp al, '.'												;sprawdzenie czy wczytano seperator
				je @LoadSeperator										;tak, wczytano seperator - skok do @LoadSeperator

			xor rbx, rbx										;wyzerowanie rejestru RBX
			mov bl, wasNum										;wczytanie warto�ci WAS_NUM do BL
			cmp bl, '1'											;sprawdzenie czy do RESULT nale�y doda� spacj�
				jne @NotAddSpace									;nie, skok do @NotAddSpace
																	;tak
				mov rbx, " "											;RBX <- " "
				mov [rdi], rbx											;RESULT <- dodanie spacji
				inc rdi													;zwi�kszenie indeksu RESULT
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
			jmp @LoopInput										;skok do @LoopInput - pobranie nast�pnego znaku

			@LoadNum:											;@LoadNum
			@LoadSeperator:										;@LoadSeperator
			mov [rdi], rax										;RESULT <- dodanie cyfry do wyniku
			inc rdi												;zwi�kszenie indeksu RESULT
			mov bl, '1'											;wczytanie '1' do BL
			mov wasNum, bl										;zapisanie do WAS_NUM, �e wczytano znak zwi�zany z liczb�
			jmp @LoopInput										;skok do @LoopInput - pobranie nast�pnego znaku

			@LoadSub:											;@LoadSub
			@LoadAdd:											;@LoadAdd
			mov currSignPriority, '1'							;ustawienie priorytetu '1' do CURR_SIGN_PRIORITY
			jmp @CheckStackPriority								;skok do @CheckStackPriority
			
			@LoadMull:											;@LoadMull
			@LoadDiv:											;@LoadDiv
			mov currSignPriority, '2'							;ustawienie priorytetu '2' do CURR_SIGN_PRIORITY
				
			@CheckStackPriority:								;@CheckStackPriority
			mov ecx, numOperatorStack							;RCX <- NUM_OPERATOR_STACK
			cmp ecx, 0											;sprawdzenie, czy na stosie s� jakie� operatory
			jz @StackLoopBreak										;brak operator�w, skok do @StackLoopBreak
				@StackLoop:										;@StackLoop
					xor rbx, rbx								;wyzerowanie RBX
					pop rbx										;pobiernie operatora z stosu
					mov popSign, bl								;zapisanie pobranego operatora do POP_SIGN
																;ASM x86
					;push rbx									;zwr�cenie operator na stos
																;<!-- ASM x86 ->
																;ASM x64
					push rcx									;wrzucenie licznika p�tli na stos
					xor rcx, rcx								;RCX <- 0
					mov cl, bl									;wpisanie do RCX parametru fun. CheckSignPriority
																;<!-- ASM x64 ->
					call CheckSignPriority						;sprawdzenie priorytetu operatora na stosie
																;ASM x64
					pop rcx										;przywr�cenie licznika p�tli
																;<!-- ASM x64 ->
					cmp al, currSignPriority					;por�wanie priorytet�w operator�w
						jbe @LP										;pierytet jest mniejszy skok do @LP
																	;priorytet jest wi�kszy	
																	;
						mov [rdi], rbx								;RESULT <- EBX (ostatni pobrany operator)
						inc rdi										;inkrementacja indeksu RESULT
						mov rbx, " "								;RBX = " "
						mov [rdi], rbx								;RESULT <- wpisanie spacji
						inc rdi										;inkrementacja indeksu RESULT
						dec numOperatorStack						;dekrementacj NUM_OPERATOR_STACK
						jmp @GP										;skok do @GP
					@LP:										;@LP - priorytet mniejszy
						push rbx									;zwr�cenie operatora na stos
						jmp @StackLoopBreak							;skok do @StackLoopBreak
					@GP:										;@GP
					dec ecx										;dekrementacja licznika p�tli @StackLoop
					cmp ecx, 0									;sprawdzenie czy licznik == 0
				jne @StackLoop									;je�li tak to skok do @StackLoop
				
				@StackLoopBreak:								;@StackLoopBreak
				xor rax, rax									;RAX <- 0
				mov al, currSign								;wczytanie do AL warto�ci zmiennej CURR_SIGN
				push rax										;wrzucenie operatora na stos
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadOpeningParenthesis:							;@LoadOpeningParenthesis	
				push rax										;dodanie znaku ( na stos
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				inc rsi											;sprawdzenie czy przypadkiem nast�pna liczb jest ujemna
				cmp byte ptr [rsi], '-'							;
					jne @LOP_NOT_MINUS							;nie, to skok do @LOP_NOT_MINUS
																;je�li tak to...
					xor rax, rax								;RAX <- 0
					mov al, byte ptr [rsi]						;AL <- '-'
				jmp @LoadNum									;tak, skok do @LoadNum
				@LOP_NOT_MINUS:									;@LOP_NOT_MINUS
					dec rsi										;dekrementacja RSI
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadClosedParenthesis:								;@LoadClosedParenthesis
				xor rdx, rdx									;RDX <- 0
				mov ecx, numOperatorStack						;RCX <- NUM_OPERATOR_STACK - wprowadzenie licznika p�tli @LoopStack
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
					dec ecx										;dekrementacja licznika p�tli
					cmp ecx, 0									;sprawdzenie czy s� jeszcze jakie� znaki na stosie
				jne @@LoopStack									;tak, skok do @@LoopStack
			jmp @LoopInput										;nie, skok do @LoopInput

		
		@LoopBreak:												;@LoopBreak
		
		mov cl, " "												;za�adowanie spacji do CL
		mov [rdi], cl											;RESUTL <- dodanie spacji
		inc rdi													;inkrementacja indeksu RESULT

																;COMM:: wyprowadzenie do �ancucha wynikowego pozosta�ych znak�w na stosie 
		
		mov ecx, numOperatorStack								;za�adowanie licznika p�tli (NUM_OPERATOR_STACK
		@LoopStackClear:										;@LoopStackClear
			pop rbx												;pobranie operatora z stosu
			mov popSign, bl										;zapisanie pobranego operatora do POP_SIGN
			mov [rdi], rbx										;RESULT << wyprowadzenie operatora do wyniku
			inc rdi												;inkrementacja indeksu RESULT
			mov rbx, " "										;za�adowanie spacji do EBX
			mov [rdi], rbx										;RESUTL << dodanie spacja
			inc rdi												;inkrementacja indeksu RESULT
			dec ecx												;dekrementacja licznika p�tli
			cmp ecx, 0											;sprawdzenie czy s� jeszcze jakie� znaki na stosie
		jne @LoopStackClear										;tak, skok do nowego obiegu p�tli
																;nie, przej�cie dalej
		
		mov rdi, 0												;RESULT << '\0'
		xor rax, rax											;RAX <- 0
		mov rax, 1												;RAX <- brak b��d�w, TRUE
		
		@Err:													;@Err
		mov rax, 0												;RAX <- wyst�pi� b��d, FALSE

		pop rdi													;przywr�cenie RDI
		pop rsi													;przywr�cenie RSI
		pop rbp													;przywr�cenie RBP

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

	;Procedura konwertuje pobrane wyra�enie matematyczne na odwrotn� notacj� polsk�
	;@param RCX: ptr byte wyra�enie onp
	;@return zwraca wynik wyra�enia onp <QWORD>
	;@warning modyfikowane flagi: <uzupe�ni�>
	;@warning modyfikowane rejestry: <uzupe�ni�>
	CalcRPN proc

		LOCAL currSign: BYTE										;znak wczytywanej liczby
		LOCAL feature: QWORD										;cecha liczby
		LOCAL mantissa: QWORD										;mantysa liczby
		LOCAL featureSize: DWORD									;rozmiar cechy liczby
		LOCAL numOfRaxStack: DWORD									;ilo�� 'rejestr�w' RAX na stosie

		LOCAL curr: BYTE											;### DEBUG ###

		push rbp													;kopia rejestru RBP
		push rsi													;kopia rejestru RSI
		push rdi													;kopia rejestru RDI

		xor rax, rax												;wyzerowanie RAX
		mov feature, rax											;zeruje cech� (FEATURE)
		mov mantissa, rax											;zeruj� mantys� (MANTISSA)
		mov featureSize, eax										;zeruj� rozmiar cechy
		mov numOfRaxStack, eax										;zeruj� ilo�� rejestr�w RAX na stosie

		mov rsi, rcx												;za�adowanie RPN do ESI

		mov al, '+'													;AL <- '+'
		mov currSign, al											;przyjmuje �e pierwsza liczba jest dodatnia

		dec rsi														;indeks RPN[-1]

		CalcRPN@LOOP:												;CalcRPN@LOOP
			inc rsi													;inkrementacja indeksu tablicy RPN

			mov bl, byte ptr [rsi]									; ### DEBUG ###
			mov curr, bl											; ### DEBUG ###

			cmp byte ptr [rsi], 0									;sprawdzenie czy wczytano znak '\0'
				je CalcRPN@LOOPBreak									;tak, wyj�cie z p�tli
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
				xor rcx, rcx										;RCX <- 0
				mov rcx, 1											;mno�nik - RCX <- 1

																	;TODO: wyzerowanie rejestru XXX

				CalcRPN@LoadFeatureNum:								;CalcRPN@LoadFeatureNum
					xor rax, rax									;RAX <- 0
					mov al, byte ptr [rsi]							;wk�adam znak cyfry do AL

					mov bl, byte ptr [rsi]							; ### DEBUG ###
					mov curr, bl									; ### DEBUG ###

					push rax										;wk�adam cyfre na stos
					inc featureSize									;inkrementacja FEATURE_SIZE
					inc rsi											;inkrementacja indexu RPN [RSI]
					cmp byte ptr [rsi], '.'							;sprawdzenie czy wczytano seperator
						je CalcRPN@FeatureToDecimal						;tak, skok do CalcRPN@FeatureToDecimal
					cmp byte ptr [rsi], " "							;sprawdznie czy wczytano ca�� liczb� tzn.spacj�
						je CalcRPN@FeatureToDecimal						;tak, to skok do CalcRPN@FeatureToDecimal
				jne	CalcRPN@LoadFeatureNum							;nie, to wczytaj nast�pn� cyfr� lub seperator

				CalcRPN@FeatureToDecimal:
					pop rbx											;pobieram znaku cyfry ze stosu
					mov curr, bl									; ### DEBUG ###

					;TODO
					;
					;
																	;zamiana ASCII na cyfr� (BL - '0')
																	;przemno�enie przez mno�nik
																	;dodanie wyniku do rejestru XXX
																	;mnoznik * 10

					dec featureSize
					cmp featureSize, 0
				jne CalcRPN@FeatureToDecimal

				cmp byte ptr [rsi], " "							;sprawdznie czy wczytano ca�� liczb� tzn.spacj�
					je CalcRPN@NumReady								;tak, to skok do CalcRPN@NumReady

																	;TODO: mno�nika <- 0.1

				CalcRPN@LoadMantissaNum:

					inc rsi											;inkrementacja licznika RPN [RSI]

					mov bl, byte ptr [rsi]							; ### DEBUG ###
					mov curr, bl									; ### DEBUG ###

					;TODO
					;
					;

																	;zamiana ASCII na cyfr� (BL - '0')
																	;przemno�enie przez mno�nik
																	;dodanie wyniku do rejestru XXX
																	;mnoznik * 0.1

					cmp byte ptr [rsi], " "							;sprawdznie czy wczytano ca�� liczb� tzn.spacj�
						je CalcRPN@NumReady								;tak, to skok do CalcRPN@WholeNum
				jne CalcRPN@LoadMantissaNum							;nie, to wczytaj nast�pn� cyfr�

				CalcRPN@NumReady:									;CalcRPN@NumReady:

																	;TODO::od�o�enie liczby na stos

																	;COM::czyszcenie pod nast�pn� liczb�
				xor rax, rax										;RAX <- 0
				mov featureSize, eax								;zeruje rozmiar cechy
				mov numOfRaxStack, eax								;zeruje ilo�� rejestr�w RAX na stosie
				mov feature, rax									;zeruje FEATURE
				mov mantissa, rax									;zeruje MANTISSA
				mov al, '+'											; AL <- '+'
				mov currSign, al									;CURR_SING = '+', przyjmuj� �e nast�pna liczba b�dzie dodatnia

			jmp CalcRPN@LOOP									;skok do CalcRPN@LOOP

			CalcRPN@LoadSub:										;CalcRPN@LoadSub
			cmp byte ptr [rsi+1], " "								;sprawdzenie czy wczytano '-' jako operator
				je CalcRPN@LoadSubOperator								;tak, skok do CalcRPN@LoadSubOperator
			mov currSign, '-'										;nie, CURR_SIGN = '-'
			jmp CalcRPN@LOOP										;skok do CalcRPN@LOOP

																	;;TODO::pobranie ze stosu i wykonanie oblicze�
			CalcRPN@LoadSubOperator:								;CalcRPN@LoadSubOperator
			CalcRPN@LoadSpace:										;CalcRPN@LoadSpace
			CalcRPN@LoadAdd:										;CalcRPN@LoadAdd
			CalcRPN@LoadMull:										;CalcRPN@LoadMull
			CalcRPN@LoadDiv:										;CalcRPN@LoadDiv

		jmp CalcRPN@LOOP											;skok do CalcRPN@LOOP - wczytanie nast�pnego znaku RPN

		CalcRPN@LOOPBreak:											;CalcRPN@LOOPBreak
		CalcRPN@Err:												;CalcRPN@Err

		xor rax, rax												;RAX <- 0

		pop rdi														;przywr�cenie RDI
		pop rsi														;przywr�cenie RSI
		pop rbp														;przywr�cenie RBP

		ret															;return RAX

	CalcRPN endp

end