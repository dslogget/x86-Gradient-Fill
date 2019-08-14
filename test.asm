    global _start
    global _debug
    global _printEAX
    global _printCRLF

    global h_stdout


    %include "WIN32N.INC"
    %include "WIN32FUNCS.INC"


    extern _ReadNextNumber@0
    extern _atoui@4
    extern _init
    extern _uitoa@8
    extern _strlen@4

    extern _LoadTriangles@16 ;ppVertices, pnVertices, ppMeshes, pnMeshes


    section .rdata

debug_str db "Here",10,13
debug_str_len equ $-debug_str

tstbfr db "123",0

    section .bss
buf        resb 128
buflen  equ $-buf

    section .data
h_stdout    dd 0
h_stdin     dd 0
h_stderr    dd 0

pVertices   dd 0
nVertices   dd 0
pMeshes     dd 0
nMeshes     dd 0

    section .text

_printEAX:
    push ebp
    mov ebp, esp
    push eax
    push ecx
    push edx
    push ebx
    push dword 0


    push dword eax
    push dword buf
    call _uitoa@8

    lea edx, [ebp - 4]
    push dword  0                               ; lpReserved = null
    push dword edx                              ; lpNumberOfCharsWritten = pointer to "other"
    push dword eax                              ; nNumberOfCharsToWrite = length of "msg"
    push dword buf                              ; lpBuffer = pointer to "msg"
    push dword [h_stdout]                       ; hConsoleOutput = console handle from GetStdHandle
    call _WriteConsoleA@20                      ; Write string
    call _printCRLF

    add esp, 4
    pop ebx
    pop edx
    pop ecx
    pop eax
    mov esp, ebp
    pop ebp
    ret

_printCRLF:
    push ebp
    mov ebp, esp
    push eax
    push ecx
    push edx
    push ebx
    push dword 0


    mov [buf], byte 10
    mov [buf + 1], byte 13

    lea edx, [ebp - 4]
    push dword  0                               ; lpReserved = null
    push dword edx                              ; lpNumberOfCharsWritten = pointer to "other"
    push dword 2                              ; nNumberOfCharsToWrite = length of "msg"
    push dword buf                              ; lpBuffer = pointer to "msg"
    push dword [h_stdout]                       ; hConsoleOutput = console handle from GetStdHandle
    call _WriteConsoleA@20                      ; Write string

    add esp, 4
    pop ebx
    pop edx
    pop ecx
    pop eax
    mov esp, ebp
    pop ebp
    ret 

_debug:
    push ebp
    mov ebp, esp
    push eax
    push ecx
    push edx
    push ebx

    push dword 0
    mov eax, esp

    push dword  0                               ; lpReserved = null
    push dword eax                              ; lpNumberOfCharsWritten = pointer to "other"
    push dword debug_str_len                              ; nNumberOfCharsToWrite = length of "msg"
    push dword debug_str                              ; lpBuffer = pointer to "msg"
    push dword [h_stdout]                       ; hConsoleOutput = console handle from GetStdHandle
    call _WriteConsoleA@20

    add esp, 4

    pop ebx
    pop edx
    pop ecx
    pop eax
    mov esp, ebp
    pop ebp
    ret

_start:
    push 0
    call _SetLastError@4

    and esp, -4
    mov ebp, esp
    sub esp, 4
    mov [ebp], dword 0



    push buflen
    push dword 0
    push buf
    call _memset
    add esp, 12
    
    
    call _initHandles



    ;mov eax, dword [nVertices]
    ;call _printEAX
    ;call _printCRLF
    ;mov eax, dword [nMeshes]
    ;call _printEAX
    ;call _printCRLF
    

    push dword [h_stdin]
    call _FlushConsoleInputBuffer@4

    ;push tstbfr
    ;call _atoui@4

    ;add eax, 1

    ;call _printEAX


    ;;lea edx, [ebp + 4]
    ;;push dword 0
    ;;push dword edx
    ;;push dword buflen
    ;;push dword buf
    ;;push dword [h_stdin]
    ;;call _ReadConsoleA@20

    ;;lea eax, [buf - 2]
    ;;add eax, [ebp + 4]
    ;;mov [eax], byte 0

    ;;push dword buf
    ;;call _strlen
    ;;add esp, 4

    call _init

    ;call _GetLastError@0

    ;push dword eax
    ;push dword buf
    ;call _uitoa@8

    ;lea edx, [ebp + 4]
    ;push dword  0                               ; lpReserved = null
    ;push dword edx                              ; lpNumberOfCharsWritten = pointer to "other"
    ;push dword eax                              ; nNumberOfCharsToWrite = length of "msg"
    ;push dword buf                              ; lpBuffer = pointer to "msg"
    ;push dword [h_stdout]                       ; hConsoleOutput = console handle from GetStdHandle
    ;call _WriteConsoleA@20                      ; Write string

    push    0                                   ; exit code = 0
    call _ExitProcess@4
stop: 
    jmp stop



_initHandles:
    push ebp
    mov ebp, esp

    push dword -12
    call _GetStdHandle@4
    mov dword [h_stderr], eax

    push dword -11     
    call _GetStdHandle@4              
    mov dword [h_stdout], eax

    push dword -10
    call _GetStdHandle@4
    mov dword [h_stdin], eax
    
    mov esp, ebp
    pop ebp
    ret

_memset: ;param1: ptr ;param2: byte val ;param3 num of bytes
    push ebp
    mov ebp, esp

    mov eax, dword [ebp + 8]
    mov edx, dword [ebp + 12]
    mov ecx, dword [ebp + 16]

memset_while:
    cmp ecx, 0
    je memset_wend
    mov byte [eax], dl
    inc eax
    dec ecx
    jmp memset_while
memset_wend:
    mov eax, dword 0

    mov esp, ebp
    pop ebp
    ret

