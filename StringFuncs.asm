    global _uitoa@8
    global _strlen@4
    global _atoui@4

    extern _debug
    extern _printEAX
    extern _printCRLF

    %include "WIN32FUNCS.INC"

    extern h_stdout

    section .rdata
DEC_LUT dd 1000000000,100000000,10000000,1000000,100000,10000,1000,100,10,1,0


    section .text

_atoui@4: ;param1: arrayptr; return num
    push ebp
    mov ebp, esp
    push ebx
    push esi

  ;push dword [ebp + 8]
  ;call _strlen@4
  ;push dword 0
  ;mov edx, esp

  ;push dword 0                               ; lpReserved = null
  ;push dword edx                              ; lpNumberOfCharsWritten = pointer to "other"
  ;push dword eax                              ; nNumberOfCharsToWrite = length of "msg"
  ;push dword [ebp + 8]                              ; lpBuffer = pointer to "msg"
  ;push dword [h_stdout]                       ; hConsoleOutput = console handle from GetStdHandle
  ;call _WriteConsoleA@20                      ; Write string
  ;call _printCRLF
  ;add esp, 4

    mov ebx, dword 0
    mov eax, dword 0
    mov ecx, dword [ebp + 8]
    mov esi, dword 10

atoui_lp:
    mov bl, byte [ecx]
atoui_if1:
    cmp bl, byte 0
    jne atoui_elseif1_1
    jmp atoui_exit
atoui_elseif1_1:
    cmp bl, '0'
    jae atoui_elseif1_2
    add ecx, 1
    jmp atoui_lp
atoui_elseif1_2:
    cmp bl, '9'
    jbe atoui_endif1
    add ecx, 1
    jmp atoui_lp
atoui_endif1:
    
    mul esi
    sub ebx, dword '0'
    add eax, ebx
    add ecx, 1
    jmp atoui_lp

atoui_exit:
    ;call _printEAX

    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret 4


_uitoa@8: ;param1: buf ;param2:int ;return length
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov ebx, [ebp + 8]  ;buf ptr
    mov ecx, [ebp + 12] ;int
    mov eax, dword 0
    mov edi, dword DEC_LUT

uitoa_while1:
    mov esi, [edi]
    cmp esi, dword 0
    je uitoa_wend1
    

    mov edx, dword 0

uitoa_while2:
        cmp ecx, esi
        jb uitoa_wend2

        sub ecx, esi
        inc edx
        jmp uitoa_while2
uitoa_wend2:
    cmp eax, dword 0
    jne uitoa_if
    cmp edx, dword 0
    je uitoa_endif
uitoa_if:
    add edx, dword '0'
    mov byte [ebx], dl
    inc ebx
    inc eax
uitoa_endif:
    add edi, 4
    jmp uitoa_while1
uitoa_wend1:
    mov byte [ebx], byte 0

    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret 8


_strlen@4: ;param1: byte ptr
    push ebp
    mov ebp, esp
    push ebx
    
    mov eax, dword 0 ;toRet = 0
    mov ebx, [ebp + 8] ;retrieve param

strlen_while:
    cmp byte [ebx], byte 0
    je strlen_endw

    inc eax
    inc ebx
    jmp strlen_while
strlen_endw:

    pop ebx
    mov esp, ebp
    pop ebp
    ret 4