;/** DLLAsm
;*
;* Source code to library used in reverse polish notation calculator project
;*
;* Author: Konrad Skrzypczyk
;* Subject: Assembly languages
;* Academic year: 2020/21
;* Implementation: MASM
;*
;* =================== CHANELOG ===================
;*
;* v0.1:
;*
;*
;*/

.686p
.model flat, stdcall

.data
	buffInput db "12.125 + a.15 * (b * c + d / e)", 0	; 12 a b c * d e / + * +
	buffResult db 256 DUP (0)

.code

	ConvertToRPN proc stdcall data: ptr byte

		mov esi, offset buffInput
		mov eax, 'a'
		mov [esi], eax

		ret

	ConvertToRPN endp

end