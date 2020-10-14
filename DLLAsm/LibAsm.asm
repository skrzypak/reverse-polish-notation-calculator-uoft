.486
.model flat, stdcall

.code

TestMethod proc x: DWORD, y: DWORD

	xor eax, eax
	mov eax, x
	mov ecx, y
	add eax, ecx
	ret

TestMethod endp

end