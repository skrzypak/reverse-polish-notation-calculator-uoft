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
; v0.3:
; - Fix bugs
; - Change of return proc type: CalcRPN(const char* rpn) from long double to float
; - float CalcRPN(const char* rpn) - implementation 
;
;*/

.data
	DN01 real4 0.1
	DN1 real4 1.0
	RESULT real4 0.0
	TMP_R4 real4 0.0

.const
	EN48 equ 48												;deklaracja sta³ej 48
	EN10 equ 10												;deklaracja sta³ej 10

.code

	;Procedura konwertuje pobrane wyra¿enie matematyczne na odwrotn¹ notacjê polsk¹
	;@param RCX: ptr byte pobrany ci¹g znaków z pliku
	;@param RDX: ptr byte buffor zapisu wyniku (zadeklarowany przed wywo³aniem procedury)
	;@warning modyfikowane flagi: OF, CF, SF, ZF, AF i PF.
	;@warning modyfikowane rejestry: RBX, RCX, RDX
	;@warning wyra¿enie nie mo¿e posiadaæ spacji
	;TODO:: wykorzystaæ rejestry R8-R15
	ConvertToRPN proc
		
		LOCAL wasNum: byte											;zmienna wykorzystywana do dodawania spacji
		LOCAL currSignPriority: byte								;zmienna przechowuj¹c priorytet pobranego operatora
		LOCAL numOperatorStack: DWORD								;zmienna przechowuj¹ca iloœæ operatorów w³o¿onych na stos
		LOCAL currSign: byte										;zmienna przechowuj¹ca pobrany znak z DATA
		LOCAL popSign: byte											;zmienna przechowuj¹ca pobrany operator ze stosu

		push rbp													;kopia rejestru RBP
		push rsi													;kopia rejestru RSI
		push rdi													;kopia rejestru RDI

		mov rsi, rcx												;wczytanie wskaŸnik na DATA (RCX)
		mov rdi, rdx												;wczytanie wskaŸnika na RESULT (RDX)
		xor rax, rax												;RAX = 0
		mov numOperatorStack, eax									;NUM_OPERATOR_STACK = 0
		mov al, '0'													;AL = 0
		mov wasNum, al												;WAS_NUM = 0

		cmp byte ptr [rsi], '-'										;sprawdzam, czy pierwszy znak jest '-'
			mov al, byte ptr [rsi]										;jeœli tak, to AL <- '-'
			je @LoadNum													;i skok do @LoadNum

		dec rsi														;indeks DATA[-1]

		@LoopInput:													;@LoopInput

			inc rsi													;inkrementacja RSI - nastêpny znak
			mov rax, [rsi]											;wczytanie znaku do akumulatora (AL -> znak)
			mov currSign, al										;wczytanie pobranego znaku do CURR_SIGN
			
			cmp al, 0												;sprawdzenie czy wczytano znak '\0'
				je @LoopBreak											;tak, wyjœcie z pêtli

																		;nie, sprawdzenie czy pobrano cyfrê

			cmp al, '0'												;sprawdzenie czy pobrany znak >= '0'
				je @LoadNum												;znak == '0' - skok do @LoadNum
				jb @FalseLoadNum										;znak < '0' czyli wczytnao inny znak - skok do @FalseLoadNum
			cmp al, '9'												;tak, znak >= '0' - sprawdzenie czy znak <= '9'								
				jbe @LoadNum											;tak, wczytano cyfrê - skok do @LoadNum
				ja @Err													;nie, wczytano inny znak - skok do @Err

			@FalseLoadNum:											;@FalseLoadNum

			cmp al, '.'												;sprawdzenie czy wczytano seperator
				je @LoadSeperator										;tak, wczytano seperator - skok do @LoadSeperator

			xor rbx, rbx										;wyzerowanie rejestru RBX
			mov bl, wasNum										;wczytanie wartoœci WAS_NUM do BL
			cmp bl, '1'											;sprawdzenie czy do RESULT nale¿y dodaæ spacjê
				jne @NotAddSpace									;nie, skok do @NotAddSpace
																	;tak
				mov rbx, " "											;RBX <- " "
				mov [rdi], rbx											;RESULT <- dodanie spacji
				inc rdi													;zwiêkszenie indeksu RESULT
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
			jmp @LoopInput										;skok do @LoopInput - pobranie nastêpnego znaku

			@LoadNum:											;@LoadNum
			@LoadSeperator:										;@LoadSeperator
			mov [rdi], rax										;RESULT <- dodanie cyfry do wyniku
			inc rdi												;zwiêkszenie indeksu RESULT
			mov bl, '1'											;wczytanie '1' do BL
			mov wasNum, bl										;zapisanie do WAS_NUM, ¿e wczytano znak zwi¹zany z liczb¹
			jmp @LoopInput										;skok do @LoopInput - pobranie nastêpnego znaku

			@LoadSub:											;@LoadSub
			@LoadAdd:											;@LoadAdd
			mov currSignPriority, '1'							;ustawienie priorytetu '1' do CURR_SIGN_PRIORITY
			jmp @CheckStackPriority								;skok do @CheckStackPriority
			
			@LoadMull:											;@LoadMull
			@LoadDiv:											;@LoadDiv
			mov currSignPriority, '2'							;ustawienie priorytetu '2' do CURR_SIGN_PRIORITY
				
			@CheckStackPriority:								;@CheckStackPriority
			mov ecx, numOperatorStack							;RCX <- NUM_OPERATOR_STACK
			cmp ecx, 0											;sprawdzenie, czy na stosie s¹ jakieœ operatory
			jz @StackLoopBreak										;brak operatorów, skok do @StackLoopBreak
				@StackLoop:										;@StackLoop
					xor rbx, rbx								;wyzerowanie RBX
					pop rbx										;pobiernie operatora z stosu
					mov popSign, bl								;zapisanie pobranego operatora do POP_SIGN
																;ASM x86
					;push rbx									;zwrócenie operator na stos
																;<!-- ASM x86 ->
																;ASM x64
					push rcx									;wrzucenie licznika pêtli na stos
					xor rcx, rcx								;RCX <- 0
					mov cl, bl									;wpisanie do RCX parametru fun. CheckSignPriority
																;<!-- ASM x64 ->
					call CheckSignPriority						;sprawdzenie priorytetu operatora na stosie
																;ASM x64
					pop rcx										;przywrócenie licznika pêtli
																;<!-- ASM x64 ->
					cmp al, currSignPriority					;porówanie priorytetów operatorów
						jbe @LP										;pierytet jest mniejszy skok do @LP
																	;priorytet jest wiêkszy	
																	;
						mov [rdi], rbx								;RESULT <- EBX (ostatni pobrany operator)
						inc rdi										;inkrementacja indeksu RESULT
						mov rbx, " "								;RBX = " "
						mov [rdi], rbx								;RESULT <- wpisanie spacji
						inc rdi										;inkrementacja indeksu RESULT
						dec numOperatorStack						;dekrementacj NUM_OPERATOR_STACK
						jmp @GP										;skok do @GP
					@LP:										;@LP - priorytet mniejszy
						push rbx									;zwrócenie operatora na stos
						jmp @StackLoopBreak							;skok do @StackLoopBreak
					@GP:										;@GP
					dec ecx										;dekrementacja licznika pêtli @StackLoop
					cmp ecx, 0									;sprawdzenie czy licznik == 0
				jne @StackLoop									;jeœli tak to skok do @StackLoop
				
				@StackLoopBreak:								;@StackLoopBreak
				xor rax, rax									;RAX <- 0
				mov al, currSign								;wczytanie do AL wartoœci zmiennej CURR_SIGN
				push rax										;wrzucenie operatora na stos
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadOpeningParenthesis:							;@LoadOpeningParenthesis	
				push rax										;dodanie znaku ( na stos
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				inc rsi											;sprawdzenie czy przypadkiem nastêpna liczb jest ujemna
				cmp byte ptr [rsi], '-'							;
					jne @LOP_NOT_MINUS							;nie, to skok do @LOP_NOT_MINUS
																;jeœli tak to...
					xor rax, rax								;RAX <- 0
					mov al, byte ptr [rsi]						;AL <- '-'
				jmp @LoadNum									;tak, skok do @LoadNum
				@LOP_NOT_MINUS:									;@LOP_NOT_MINUS
					dec rsi										;dekrementacja RSI
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadClosedParenthesis:								;@LoadClosedParenthesis
				xor rdx, rdx									;RDX <- 0
				mov ecx, numOperatorStack						;RCX <- NUM_OPERATOR_STACK - wprowadzenie licznika pêtli @LoopStack
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
					dec ecx										;dekrementacja licznika pêtli
					cmp ecx, 0									;sprawdzenie czy s¹ jeszcze jakieœ znaki na stosie
				jne @@LoopStack									;tak, skok do @@LoopStack
			jmp @LoopInput										;nie, skok do @LoopInput

		
		@LoopBreak:												;@LoopBreak
		
		mov cl, " "												;za³adowanie spacji do CL
		mov [rdi], cl											;RESUTL <- dodanie spacji
		inc rdi													;inkrementacja indeksu RESULT

																;COMM:: wyprowadzenie do ³ancucha wynikowego pozosta³ych znaków na stosie 
		
		mov ecx, numOperatorStack								;za³adowanie licznika pêtli (NUM_OPERATOR_STACK)
		cmp ecx, 0												;sprawdzenie czy s¹ jakieœ operatory na stosie
			je @End													;jeœli  tak to skok do @End
		@LoopStackClear:										;@LoopStackClear
			pop rbx												;pobranie operatora z stosu
			mov popSign, bl										;zapisanie pobranego operatora do POP_SIGN
			mov [rdi], rbx										;RESULT << wyprowadzenie operatora do wyniku
			inc rdi												;inkrementacja indeksu RESULT
			mov rbx, " "										;za³adowanie spacji do EBX
			mov [rdi], rbx										;RESUTL << dodanie spacja
			inc rdi												;inkrementacja indeksu RESULT
			dec ecx												;dekrementacja licznika pêtli
			cmp ecx, 0											;sprawdzenie czy s¹ jeszcze jakieœ znaki na stosie
		jne @LoopStackClear										;tak, skok do nowego obiegu pêtli
																;nie, przejœcie dalej
		@End:
		mov rdi, 0												;RESULT << '\0'
		xor rax, rax											;RAX <- 0
		mov rax, 1												;RAX <- brak b³êdów, TRUE
		
		@Err:													;@Err
		mov rax, 0												;RAX <- wyst¹pi³ b³¹d, FALSE

		pop rdi													;przywrócenie RDI
		pop rsi													;przywrócenie RSI
		pop rbp													;przywrócenie RBP

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

	;Procedura konwertuje pobrane wyra¿enie matematyczne na odwrotn¹ notacjê polsk¹
	;@param RCX: ptr byte wyra¿enie onp
	;@return zwraca wynik wyra¿enia onp <float>
	;@warning modyfikowane flagi: <uzupe³niæ>
	;@warning modyfikowane rejestry: RAX, RBX, RCX, RDX, R8, XMM0-7
	;TODO::wykorzystaæ rejestry R9-R15
	CalcRPN proc

		LOCAL currSign: BYTE										;znak wczytywanej liczby
		LOCAL exponentSize: DWORD									;rozmiar cechy liczby

		push rsi													;kopia RSI

		xor rax, rax												;wyzerowanie RAX
		mov exponentSize, eax										;zerujê rozmiar cechy
		movss xmm6, DN01											;XMM6 <- 0.1
		xorps xmm7, xmm7											;XMM7 <- 0

		mov rsi, rcx												;za³adowanie RPN do ESI

		mov al, '+'													;AL <- '+'
		mov currSign, al											;przyjmuje ¿e pierwsza liczba jest dodatnia

		dec rsi														;indeks RPN[-1]

		CalcRPN@LOOP:												;CalcRPN@LOOP
			inc rsi													;inkrementacja indeksu tablicy RPN
			cmp byte ptr [rsi], 0									;sprawdzenie czy wczytano znak '\0'
				je CalcRPN@LOOPBreak									;tak, wyjœcie z pêtli
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
				xor rbx, rbx										;RBX <- 0 - przechowywaæ bêdzie cechê liczby
				mov rcx, 1											;mno¿nik - RCX <- 1

				CalcRPN@LoadExponentNum:							;CalcRPN@LoadExponentNum
					xor rax, rax									;RAX <- 0
					mov al, byte ptr [rsi]							;wk³adam znak cyfry do AL
					push rax										;wk³adam cyfre na stos
					inc exponentSize									;inkrementacja EXPONENT_SIZE
					inc rsi											;inkrementacja indexu RPN [RSI]
					cmp byte ptr [rsi], '.'							;sprawdzenie czy wczytano seperator
						je CalcRPN@ExponentToDecimal					;tak, skok do CalcRPN@ExponentToDecimal
					cmp byte ptr [rsi], " "							;sprawdznie czy wczytano ca³¹ liczbê tzn.spacjê
						je CalcRPN@ExponentToDecimal					;tak, to skok do CalcRPN@ExponentToDecimal
				jne	CalcRPN@LoadExponentNum							;nie, to wczytaj nastêpn¹ cyfrê lub seperator

				CalcRPN@ExponentToDecimal:
					pop rax											;pobieram znaku cyfry ze stosu
					sub al, EN48									;zamiana ASCII na cyfrê (AL - '0')
					mul rcx											;przemno¿enie przez mno¿nik
					add rbx, rax									;dodanie wyniku do rejestru RBX
																	;mnoznik * 10
					mov rax, rcx									;
					mov rdx, EN10									;
					mul rdx											;
					mov rcx, rax									;

					dec exponentSize
					cmp exponentSize, 0
				jne CalcRPN@ExponentToDecimal

																	;RBX posiada wartoœci cechy liczby
				xorps xmm1, xmm1 									;XMM1 <- 0
				cvtsi2ss xmm1, rbx									;XMM1 <- RBX __ EXPONENT

				cmp byte ptr [rsi], " "								;sprawdznie czy wczytano ca³¹ liczbê tzn.spacjê
					je CalcRPN@NumReady									;tak, to skok do CalcRPN@NumReady
																	
																	;XMM0
																	;XMM1 - WYNIK (CECHA+MANTYSA)
																	;XMM2 - MNO¯NIK
																	;XMM3 - CYFRA * MNO¯NIK
																	;XMM4 - pop XMM (TMP_1)
																	;XMM5 - pop XMM (TMP_2)
																	;XMM6 - 0.1
																	;XMM7 - 0.0

				movss xmm2, xmm6									;XMM2 <- 0.1

				inc rsi												;inkrementacja licznika RPN [RSI]

				CalcRPN@LoadMantissaNum:
					xor r8, r8										;R8 <- 0
					mov r8b, byte ptr [rsi]							;R8B <- znak cyfry
					sub r8b, EN48									;R8B <- wartoœæ cyfry (R8B - '0')
					cvtsi2ss  xmm3, r8								;XMM3 <- za³adowanie cyfry z R8B
					mulps xmm3, xmm2								;XMM3 <- CYFRA * MNO¯NIK
					addss xmm1, xmm3								;dodanie uzyskanej wartoœci do XMM1
					mulss xmm2,	xmm6								;XMM2 <- MNO¯NIK * 0.1
					inc rsi											;inkrementacja licznika RPN [RSI]
					cmp byte ptr [rsi], " "							;sprawdznie czy wczytano ca³¹ liczbê tzn.spacjê
						je CalcRPN@NumReady								;tak, to skok do CalcRPN@WholeNum
				jne CalcRPN@LoadMantissaNum							;nie, to wczytaj nastêpn¹ cyfrê

				CalcRPN@NumReady:									;CalcRPN@NumReady

																	;uwzglêdnienie czy dodatnia czy ujemna
				cmp currSign, '-'									;sprawdzenie czy CURR_SIGN == '-'
					jne PositiveNum										;jeœli nie to skok do PositiveNum
				 													;jeœli tak to:
				xorps xmm5, xmm5										;XMM5 <- 0
				subss xmm5, xmm1										;XMM5 - XMM1
				movss xmm1, xmm5										;XMM1 <- XMM5
				PositiveNum:										;PositiveNum
				movups TMP_R4, xmm1									;TMP_R4 <- XMM1
				fld TMP_R4											;od³o¿enie wyniku na stos (TMP_R4)

																	;COM::czyszcenie pod nastêpn¹ liczbê
				xor rax, rax										;RAX <- 0
				mov exponentSize, eax								;zeruje rozmiar cechy
				mov al, '+'											;AL <- '+'
				mov currSign, al									;CURR_SING = '+', przyjmujê ¿e nastêpna liczba bêdzie dodatnia

			jmp CalcRPN@LOOP									;skok do CalcRPN@LOOP

			CalcRPN@LoadSub:										;CalcRPN@LoadSub
			cmp byte ptr [rsi+1], " "								;sprawdzenie czy wczytano '-' jako operator
				je CalcRPN@LoadSubOperator								;tak, skok do CalcRPN@LoadSubOperator
			mov currSign, '-'										;nie, CURR_SIGN = '-'
			jmp CalcRPN@LOOP										;skok do CalcRPN@LOOP

			CalcRPN@LoadSubOperator:								;CalcRPN@LoadSubOperator
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm4, TMP_R4									;za³adowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm5, TMP_R4									;za³adowanie liczby do XMM5
				subss xmm5, xmm4									;XMM5 <- XMM% - XMM4
				movups TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadAdd:										;CalcRPN@LoadAdd
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm4, TMP_R4									;za³adowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm5, TMP_R4									;za³adowanie liczby do XMM5
				addss xmm5, xmm4									;XMM5 <- XMM% + XMM4
				movups TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadMull:										;CalcRPN@LoadMull
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm4, TMP_R4									;za³adowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm5, TMP_R4									;za³adowanie liczby do XMM5
				mulss xmm5, xmm4									;XMM5 <- XMM% * XMM4
				movups TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadDiv:										;CalcRPN@LoadDiv
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm4, TMP_R4									;za³adowanie liczby do XMM4
				fstp TMP_R4											;pobranie ze stosu do TNP_R4
				movups xmm5, TMP_R4									;za³adowanie liczby do XMM5
				divss xmm5, xmm4									;XMM5 <- XMM% / XMM4
				movups TMP_R4, xmm5									;TMP_R4 <- XMM5
				fld TMP_R4											;wrzucenie na stos TNP_R4
				jmp CalcRPN@LOOP
			CalcRPN@LoadSpace:										;CalcRPN@LoadSpace

		jmp CalcRPN@LOOP											;skok do CalcRPN@LOOP - wczytanie nastêpnego znaku RPN

		CalcRPN@LOOPBreak:											;CalcRPN@LOOPBreak
		CalcRPN@Err:												;CalcRPN@Err

		fstp RESULT													;pobranie koñcowego wyniku ze stosu
		movss xmm0, RESULT											;zwrócenie wyniku

		pop RSI														;przywrócenie RSI

		ret															;return RAX

	CalcRPN endp

end