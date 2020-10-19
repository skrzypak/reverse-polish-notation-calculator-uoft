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
; - Remove PUSH, POP
;
; v0.
;
;*/

.686p
.model flat, stdcall

.code

	;Procedura konwertuje pobrane wyra�enie matematyczne na odwrotn� notacj� polsk�
	;@param data: ptr byte pobrany ci�g znak�w z pliku
	;@param result: ptr byte buffor zapisu wyniku
	;@warning modyfikowane flagi: <uzupe�ni�>
	ConvertToRPN proc data: ptr byte, result: ptr byte
		
		LOCAL wasNum: byte											;zmienna wykorzystywana do dodawania spacji
		LOCAL currSignPriority: byte								;zmienna przechowuj�c priorytet pobranego operatora
		LOCAL numOperatorStack: DWORD								;zmienna przechowuj�ca ilo�� operator�w w�o�onych na stos
		LOCAL currSign: byte										;zmienna przechowuj�ca pobrany znak z DATA
		LOCAL popSign: byte											;zmienna przechowuj�ca pobrany operator ze stosu

																	;kopia rejestru EBX
		sub esp, 4													;
		mov [esp], ebx												;
																	;kopia rejestru ESI
		sub esp, 4													;
		mov [esp], esi												;
																	;kopia rejestru EDI
		sub esp, 4													;
		mov [esp], edi												;

		mov esi, data												;wczytanie wska�nik na DATA
		mov edi, result												;wczytanie wska�nika na RESULT
		xor eax, eax												;EAX = 0
		mov numOperatorStack, eax									;numOperatorStack = 0
		mov al, '0'
		mov wasNum, al

		dec esi														;indeks DATA[-1]

		@LoopInput:													;@LoopInput

			inc esi													;inkrementacja ESI - nast�pny znak
			mov eax, [esi]											;wczytanie znaku do akumulatora (AL -> znak)
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

			xor ebx, ebx										;wyzerowanie rejestru EBX
			mov bl, wasNum										;wczytanie warto�ci WAS_NUM do BL
			cmp bl, '1'											;sprawdzenie czy do RESULT nale�y doda� spacj�
				jne @NotAddSpace									;nie, skok do @NotAddSpace
																	;tak
				mov ebx, " "											;EBX <- " "
				mov [edi], ebx											;RESULT <- dodanie spacji
				inc edi													;zwi�kszenie indeksu RESULT
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
			mov [edi], eax										;RESULT <- dodanie cyfry do wyniku
			inc edi												;zwi�kszenie indeksu RESULT
			mov bl, '1'											;wczytanie '1' do BL
			mov wasNum, bl										;zapisanie do WAS_NUM, �e wczytano znak zwi�zany z liczb�
			jmp @LoopInput										;skok do @LoopInput - pobranie nast�pnego znaku

			@LoadAdd:											;@LoadAdd
			@LoadSub:											;@LoadSub
			mov currSignPriority, '1'							;ustawienie priorytetu '1' do CURR_SIGN_PRIORITY
			jmp @CheckStackPriority								;skok do @CheckStackPriority
			
			@LoadMull:											;@LoadMull
			@LoadDiv:											;@LoadDiv
			mov currSignPriority, '2'							;ustawienie priorytetu '2' do CURR_SIGN_PRIORITY
				
			@CheckStackPriority:								;@CheckStackPriority
			mov ecx, numOperatorStack							;ECX <- NUM_OPERATOR_STACK
			cmp ecx, 0											;sprawdzenie, czy na stosie s� jakie� operatory
			jz @StackLoopBreak										;brak operator�w, skok do @StackLoopBreak
				@StackLoop:										;@StackLoop
					xor ebx, ebx								;wyzerowanie EBX
																;### DEBUG ### 
																;pobiernie operatora z stosu
					mov ebx, [esp]								;
					add esp, 4									;
					mov popSign, bl								;zapisanie pobranego operatora do POP_SIGN
																;zwr�cenie operator na stos
					sub esp, 4									;
					mov [esp], ebx								;
					call CheckSignPriority						;sprawdzenie priorytetu operatora na stosie
					
					cmp al, currSignPriority					;por�wanie priorytet�w operator�w
						jbe @LP										;pierytet jest mniejszy skok do @LP
																	;priorytet jest wi�kszy	
																	;
						mov [edi], ebx								;RESULT <- EBX (ostatni pobrany operator)
						inc edi										;inkrementacja indeksu RESULT
						mov ebx, " "								;EBX = " "
						mov [edi], ebx								;RESULT <- wpisanie spacji
						inc edi										;inkrementacja indeksu RESULT
						dec numOperatorStack						;dekrementacj NUM_OPERATOR_STACK
						jmp @GP										;skok do @GP
					@LP:										;@LP - priorytet mniejszy
																	;zwr�cenie operatora na stos
						sub esp, 4									;
						mov [esp], ebx								;
						jmp @StackLoopBreak							;skok do @StackLoopBreak
					@GP:										;@GP
					dec ecx										;dekrementacja licznika p�tli @StackLoop
					cmp ecx, 0									;sprawdzenie czy licznik == 0
				jne @StackLoop									;je�li tak to skok do @StackLoop
				
				@StackLoopBreak:								;@StackLoopBreak
				
				xor eax, eax									;EAX <- 0
				mov al, currSign								;wczytanie do AL warto�ci zmiennej CURR_SIGN
																;wrzucenie operatora na stos
				sub esp, 4										;
				mov [esp], eax									;
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadOpeningParenthesis:							;@LoadOpeningParenthesis	
																;dodanie znaku ( na stos
				sub esp, 4										;
				mov [esp], eax									;
				inc numOperatorStack							;inkrementacja NUM_OPERATOR_STACK
				jmp @LoopInput									;skok do @LoopInput
			
			@LoadClosedParenthesis:								;@LoadClosedParenthesis

				xor edx, edx									;EDX <- 0
				mov ecx, numOperatorStack						;ECX <- NUM_OPERATOR_STACK - wprowadzenie licznika p�tli @LoopStack
				@@LoopStack:									;@@LoopStack
					xor ebx, ebx								;EBX <- 0
																;pobranie operatora z stosu
					mov ebx, [esp]								;
					add esp, 4									;
					mov popSign, bl								;zapisanie pobranego operatpra do POP_SIGN
					cmp bl, '('									;sprawdzenie czy pobrany operator to (
						je @@LoopStackBreak							;tak, skok do @@LoopStackBreak
						mov [edi], ebx							;nie, RESULT <- EBX (pobrany operator z  stosu)
						inc edi									;inkrementacja indeksu RESULT
						mov ebx, " "							;EBX <- " "
						mov [edi], ebx							;RESUTL <- spacja
						inc edi									;inkrementacja indeksu RESULT
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
		mov [edi], cl											;RESUTL <- dodanie spacji
		inc edi													;inkrementacja indeksu RESULT

																;COMM:: wyprowadzenie do �ancucha wynikowego pozosta�ych znak�w na stosie 
		
		mov ecx, numOperatorStack								;za�adowanie licznika p�tli (NUM_OPERATOR_STACK
		@LoopStackClear:										;@LoopStackClear
																;pobranie operatora z stosu
			mov ebx, [esp]										;
			add esp, 4											;
			mov popSign, bl										;zapisanie pobranego operatora do POP_SIGN
			mov [edi], ebx										;RESULT << wyprowadzenie operatora do wyniku
			inc edi												;inkrementacja indeksu RESULT
			mov ebx, " "										;za�adowanie spacji do EBX
			mov [edi], ebx										;RESUTL << dodanie spacja
			inc edi												;inkrementacja indeksu RESULT
			dec ecx												;dekrementacja licznika p�tli
			cmp ecx, 0											;sprawdzenie czy s� jeszcze jakie� znaki na stosie
		jne @LoopStackClear										;tak, skok do nowego obiegu p�tli
																;nie, przej�cie dalej
		
		mov edi, 0												;RESULT << '\0'
		xor eax, eax											;EAX <- 0
		mov eax, 1												;EAX <- brak b��d�w, TRUE
		
		@Err:													;@Err
		mov eax, 0												;EAX <- wyst�pi� b��d, FALSE

																;przywr�cenie EDI
		mov edi, [esp]											;
		add esp, 4												;
																;przywr�cenie ESI
		mov esi, [esp]											;
		add esp, 4												;
																;przywr�cenie EBX
		mov ebx, [esp]											;
		add esp, 4												;

		ret														;return EAX

	ConvertToRPN endp

	;Procedura sprawdza priorytet operatora matematycznego
	;@param sign: byte operator matematyczny
	;@return zwraca piorytet znaku -> '0', '1', '2'
	CheckSignPriority proc sign: byte
		
		xor eax, eax							;wyzerowanie EAX
		mov al, sign							;AL <- SIGN
		cmp al, '+'								;sprawdzenie czy pobrano +
			je @LoadPrirorty1						;tak, skok do @LoadPrirorty1
		cmp al, '-'								;sprawdzenie czy pobrano -
			je @LoadPrirorty1						;tak, skok do @LoadPrirorty1
		cmp al, '*'								;sprawdzenie czy pobrano *
			je @LoadPrirorty2						;tak, skok do @LoadPrirorty2
		cmp al, '/'								;sprawdzenie czy pobrano /
			je @LoadPrirorty2						;tak, skok do @LoadPrirorty2
		mov al, '0'								;ustawienie piorytetu 0 do AL
		ret										;return EAX (AL)
		@LoadPrirorty1: 
		mov al, '1'								;ustawienie piorytetu 1 AL
		ret										;return EAX (AL)
		@LoadPrirorty2: 
		mov al, '2'								;ustawienie piorytetu 2 AL
		ret										;return EAX (AL)

	CheckSignPriority endp

	;Procedura konwertuje pobrane wyra�enie matematyczne na odwrotn� notacj� polsk�
	;@param rpn: ptr byte wyra�enie onp
	;@return zwraca wynik wyra�enia onp
	CalcRPN proc rpn: ptr byte
		
													;kopia rejestru ESI
		sub esp, 4
		mov [esp], esi

		xor eax, eax								;wyzerowanie EAX
		mov esi, rpn								;za�adowanie RPN do ESI

		dec esi										;indeks RPN[-1]

		@LOOP:										;@LOOP
			inc esi									;inkrementacja indeksu tablicy RPN
			cmp byte ptr [esi], 0					;sprawdzenie czy wczytano znak '\0'
				je @LOOPBreak							;tak, wyj�cie z p�tli

			; TODO:

		jmp @Loop									;skok do @Loop - wczytanie nast�pnego znaku RPN

		@LOOPBreak:									;@LOOPBreak

													;przywr�cenie kopii ESI
		mov esi, [esp]								;
		add esp, 4									;
		
		xor eax, eax								;EAX <- 0
		ret											;return EAX

	CalcRPN endp

end