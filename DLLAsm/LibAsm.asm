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
; v0.2:
;
;*/

.686p
.model flat, stdcall

.const
	ASCII equ 48
	SPACE equ " "

.code

	;Procedura konwertuje pobrane wyra�enie matematyczne na odwrotn� notacj� polsk�
	;@param data: ptr byte pobrany ci�g znak�w z pliku
	;@param result: ptr byte buffor zapisu wyniku
	ConvertToRPN proc data: ptr byte, result: ptr byte
		
		LOCAL currentSign: byte										;zmienna przechowuj�ca pobrany znak
		LOCAL wasNum: byte											;zmienna wykorzystywana do dodawania spacji
		LOCAL currentSignPriority: byte								;zmienna przechowuj�c prirytet pobranego znaku
		LOCAL numOperatorOnStack: DWORD								;zmienna przechowuj�ca ilo�� znak�w w�o�onych na stos
		LOCAL popSign: byte											;zmienna przechowuj�ca pobrany znak ze stosu

		push ebx													;kopia rejestru ebx
		push esi													;kopia rejestru esi
		push edi													;kopia rejestru edi

		mov esi, data												;wczytanie wyra�enia wej�ciowego do EDI
		mov edi, result												;wczytanie wska�nika rezultatu
		xor eax, eax												;wyzerowanie rejestru akumulatora EAX
		xor ebx, ebx												;wyzerowanie rejestru og�lnego EBX
		mov numOperatorOnStack, eax									;wyzerowanie zmiennej stack_size

		dec esi														;chwilowo �a�cuch indeks -1

		@Loop:														;p�tla przechodz�ca po wszystkich znakach [ESI]
			inc esi													;przej�cie donowego znaku wyr. matematycznego
			mov eax, [esi]											;wczytanie znaku do akumulatora

			mov currentSign, al										;zapisanie wczytanego znaku do zmiennej

			.IF currentSign >= "0"									;sprawdzenie czy wczytany znak to cyfra
																	;
				.IF currentSign <= "9"								;'	
					mov [edi], eax									;je�li tak, zapisanie cyfry na wyj�cie
					inc edi											;przej�cie do nast�j kom�rki �a�cucha wynikowego
					mov bl, '1'										;wczytanie 1 (true) do BL
					mov wasNum, bl									;zapisanie, �e wczytano znak zwi�zany z liczb�
				.ENDIF												;
			
			.ELSEIF currentSign == "."								;sprawdzenie czy wczytano seperator dziesi�tny
				mov [edi], eax										;je�li tak, zapisanie kropki na wyj�cie
				inc edi												;przej�cie do nast�j kom�rki �a�cucha wynikowego
				mov bl, '1'											;wczytanie 1 (true) do BL
				mov wasNum, bl										;zapisanie, �e wczytano znak zwi�zany z liczb�
			
			.ELSE													;wczytano inny znak

				.IF wasNum == '1'									;sprawdzenie czy nale�y do wyniku doda� spacj�
					mov ebx, " "									;wczytanie do EBX znaku spacji
					mov [edi], ebx									;dodanie spacji do rezultatu
					inc edi											;przej�cie do nast�j kom�rki �a�cucha wynikowego
					mov bl, '0'										;wczytanie 0 (false) do BL
					mov wasNum, bl									;ustawienie zmiennej WAS_NUM na false
				.ENDIF												;

				.IF	currentSign == ' '								;sprawdzenie czy wczytano spacj�
					jmp @@BREAK										;skok do sprawdzenia nast�pnych warunk�w p�tli

				.ELSEIF currentSign == "+"							;sprawdzenie czy wczytano sum�
					mov currentSignPriority, '1'					;ustawienie priorytetu '1'
					jmp @GoSignAhead								;skok do @GoSignAhead
				.ELSEIF currentSign == "-"							;sprawdzenie czy wczytano r�nic�
					mov currentSignPriority, '1'					;ustawienie priorytetu '1'
					jmp @GoSignAhead								;skok do @GoSignAhead
				.ELSEIF currentSign == "*"							;sprawdzenie czy wczytano iloczyn
					mov currentSignPriority, '2'					;ustawienie priorytetu '2'
					jmp @GoSignAhead								;skok do @GoSignAhead
				.ELSEIF currentSign == "/"							;sprawdzenie czy wczytano iloraz
					mov currentSignPriority, '2'					;ustawienie priorytetu '2'
					@GoSignAhead:									;etykieta @GoSignAhead
					mov ecx, numOperatorOnStack						;wprowadzenie licznika p�tli
					cmp ecx, 0										;przyr�wanie rozmiaru stosu do zera
					jz @StackLoopBreak								;je�li stos jest pusty to przeskakujemy dalej
					@Stack_loop:									;p�tla analizowania znak�w ze stosu
						xor ebx, ebx								;wyzerowanie rejestru ebx
						pop ebx										;pobiernie ostatniego operatora z stosu
						mov popSign, bl								;zapisanie pobranego operatora do popSign
						push ebx									;zwr�cenie popSign
						call CheckSignPriority						;sprawdzenie priorytetu operatora
						.IF  currentSignPriority < al				;por�wanie priorytet�w operator�
																	;priorytet jest wi�kszy			
							mov [edi], ebx							;znak wyprowadzamy do rezultatu
							inc edi									;przej�cie do nast�j kom�rki �a�cucha wynikowego
							mov ebx, SPACE							;za�adowanie spacji
							mov [edi], ebx							;dodanie spacji do rezultatu
							inc edi									;przej�cie do nast�j kom�rki �a�cucha wynikowego
							dec numOperatorOnStack					;ekrementacja rozmiaru stosu
						.ELSE										;priorytet mniejszy	
							xor eax, eax
							push ebx								;zwracam operator na stos
							jmp @StackLoopBreak						;wychodzenie z p�tli
						.ENDIF

						dec ecx										;dekrementacja licznika
						cmp ecx, 0									;czy przetworzono wszystkie znaki
					jne @Stack_loop									;skok do nowego obiegu p�tli

					@StackLoopBreak:
					xor eax, eax									;wyzerowanie akumulatora
					mov al, currentSign								;pobranie analizowanego znaku do EAX
					push eax										;wrzucenie operatora currentSign na stos
					inc numOperatorOnStack							;inkrementacja stosu
				.ELSEIF currentSign == "("							;sprawdzenie czy wczytano nawias otw.
					push eax										;dodanie znaku ( na stos
					inc numOperatorOnStack							;stack_size + 1
				.ELSEIF currentSign == ")"							;sprawdzenie czy wczytano nawias zam.
					xor edx, edx									;wyzerowanie rejestru edx
					mov ecx, numOperatorOnStack						;wprowadzenie licznika p�tli
					@Stack_loop_:
						xor ebx, ebx								;wyzerowanie rejestru edx
						pop ebx										;pobranie operatora z stosu
						mov popSign, bl								;zapisanie pobranego znaku ze stosu do popSign
						.IF popSign != "("							;sprawdzenie czy pobrano nawias (
							mov [edi], ebx							;nie, to wyprowadzenie na wyj�cie
							inc edi									;przej�cie do nast�j kom�rki �a�cucha wynikowego
							mov ebx, SPACE							;za�adowanie spacji
							mov [edi], ebx							;dodanie spacji do rezultatu
							inc edi									;przej�cie do nast�j kom�rki �a�cucha wynikowego
							dec numOperatorOnStack					;dekrementacja stosu z operaotrami
						.ELSE										;tak, to sko�czenie p�tli
							dec numOperatorOnStack					;dekrementacja stosu z operatorami
							jmp @Stack_loop_break_					;ouszczenie p�tli
						.ENDIF

						dec ecx										;dekrementacja licznika p�tli
						cmp ecx, 0									;sprawdzenie czy s� jeszcze jakie� nieprzetworzone znkai
					jne @Stack_loop_								;tak, skok do nowego obieku p�tli
					@Stack_loop_break_:								;nie, przej�cie dalej
				.ELSE												;nie wczytano �adnego znanego znkau
																	;sygnalizacja b��du
				.ENDIF

			.ENDIF													;

			@@BREAK:
			cmp byte ptr [esi], 0									;sprawdzenie, czy ostatni znak [ESI] to '\0'
			jne @Loop												;rozpocz�cie nowego przebiegu p�tli

		;Wyprowadzenie do �ancucha wynikowego pozosta�ych znak�w na stosie 
		mov ecx, numOperatorOnStack									;za�adowanie licznika p�tli (numOperatorOnStack)
		@Clear_stack_loop:
			pop ebx													;pobranie operatora z stosu
			mov popSign, bl											;zapisanie pobranego znaku ze stosu do popSign
			mov [edi], ebx											;wyprowadzenie znaku do rezultatu
			inc edi													;przej�cie do nast�j kom�rki �a�cucha wynikowego
			mov ebx, SPACE											;za�adowanie spacji
			mov [edi], ebx											;dodanie spacji do rezultatu
			inc edi													;przej�cie do nast�j kom�rki �a�cucha wynikowego
			dec ecx													;dekrementacja licznika p�tli
			cmp ecx, 0												;sprawdzenie czy s� jeszcze jakie� nieprzetworzone znkai
		jne @Clear_stack_loop										;tak, skok do nowego obiegu p�tli
																	;nie, przej�cie dalej
		
		pop edi														;przywr�cenie rejestru edi
		pop esi														;przywr�cenie rejestru esi
		pop ebx														;przywr�cenie rejestru ebx

		xor eax, eax												;wyzerowanie akumulatora

		ret


	ConvertToRPN endp

	;Procedura sprawdza priorytet operatora matematycznego
	;@param sign: byte operator matematyczny
	;@return zwraca piorytet znaku '0', '1', '2'
	CheckSignPriority proc sign: byte
		
		xor eax, eax												;wyzerowanie rejestur eax

		.IF sign == '+'												;sprawdzenie czy to +
			mov al, '1'												;ustawienie piorytetu 1
		.ELSEIF sign == '-'											;sprawdzenie czy to -
			mov al, '1'												;ustawienie piorytetu 1
		.ELSEIF sign == "*"											;sprawdzenie czy to *
			mov al, '2'												;ustawienie piorytetu 2
		.ELSEIF sign == "/"											;sprawdzenie czy to /
			mov al, '2'												;ustawienie piorytetu 2
		.ELSE														;sprawdzanu jest inny znak
			mov al, '0'												;ustawienie piorytetu 0
		.ENDIF

		ret															;powr�t z procedury, wynik w EAX

	CheckSignPriority endp

end