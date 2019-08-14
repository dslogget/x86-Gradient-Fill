    extern _debug
    extern _printEAX
    extern h_stdout
    extern _atoui@4
    extern _printCRLF

    global _ReadNextNumber@0
    global _LoadTriangles@16 ;ppVertices, pnVertices, ppMeshes, pnMeshes
    
    %include "WIN32N.INC"
    %include "WIN32FUNCS.INC"
    %define buflen 30


    section .rdata
filename    db "./test.txt", 0

    section .data
h_file      dd 0

    section .text


_ReadNextNumber@0:
    push ebp
    mov ebp, esp
    push esi
    sub esp, 8 ;numreached, numBytesRead
    sub esp, buflen ;buffer
    

    mov [ebp - 4], dword 0

ReadNextNumber_if1:
    cmp dword [h_file], 0
    jne ReadNextNumber_else1

    push dword 0
    push dword 0
    push dword OPEN_ALWAYS
    push dword 0
    push dword FILE_SHARE_READ
    push dword GENERIC_READ
    push dword filename
    call _CreateFileA@28
    mov dword [h_file], eax
    jmp ReadNextNumber_endif1
ReadNextNumber_else1:
    mov eax, dword [h_file]
ReadNextNumber_endif1:

    cmp eax, 0
    jne ReadNextNumber_skip
    call _GetLastError@0
    call _printEAX
    call _debug
    jmp ReadNextNumber_exit
ReadNextNumber_skip:


    mov esi, dword 0
ReadNextNumber_lp:
    push dword 0
    lea eax, [ebp - 8]
    push dword eax
    push dword 1
    lea eax, [ebp - 8 - buflen + esi]
    push dword eax
    push dword [h_file]
    call _ReadFile@20

    cmp eax, 0
    jne ReadNextNumber_skip2
    call _GetLastError@0
    call _printEAX
    call _debug
    jmp ReadNextNumber_exit
ReadNextNumber_skip2:


ReadNextNumber_if2:
    cmp [ebp - 8], dword 0
    ja ReadNextNumber_endif2
ReadNextNumber_ret:

    cmp [ebp - 4], dword 0
    jne ReadNextNumber_next
    mov eax, dword -1
    jmp ReadNextNumber_exit
ReadNextNumber_next:

    lea eax, [ebp - 8 - buflen + esi]
    mov byte [eax], 0
    lea eax, [ebp - 8 - buflen]
    push dword eax
    call _atoui@4
    jmp ReadNextNumber_exit
ReadNextNumber_endif2: 

lea eax, [ebp - 8 - buflen + esi]
ReadNextNumber_if3:
    cmp byte [eax], '0'
    jb ReadNextNumber_elseif3_1
    cmp byte [eax], '9'
    ja ReadNextNumber_elseif3_1
    mov [ebp - 4], dword 1
    jmp ReadNextNumber_endif3
ReadNextNumber_elseif3_1:
    cmp [ebp - 4], dword 0
    jne ReadNextNumber_ret
ReadNextNumber_endif3:

    ;push dword  0                               ; lpReserved = null
    ;lea eax, [ebp - 8]
    ;push dword eax                             ; lpNumberOfCharsWritten = pointer to "other"
    ;push dword 1                              ; nNumberOfCharsToWrite = length of "msg"
    ;lea eax, [ebp - 32 + esi]
    ;push dword eax                              ; lpBuffer = pointer to "msg"
    ;push dword [h_stdout]                       ; hConsoleOutput = console handle from GetStdHandle
    ;call _WriteConsoleA@20                      ; Write string
    
    
    add esi, 1


    cmp esi, dword (buflen - 1)
    jae ReadNextNumber_ret 
    jmp ReadNextNumber_lp


ReadNextNumber_exit:
    add esp, 8 ;file, heap
    add esp, buflen
    pop esi
    mov esp, ebp
    pop ebp
    ret 





_LoadTriangles@16: ;ppVertices, pnVertices, ppMeshes, pnMeshes
    push ebp
    mov ebp, esp
    push edi
    sub esp, 4

    call _GetProcessHeap@0
    mov dword [ebp - 4], dword eax

    call _ReadNextNumber@0
    mov ecx, dword [ebp + 12]
    mov [ecx], dword eax

    mov edi, 16
    mul edi
    push eax
    push dword 0
    push dword [ebp - 4]
    call _HeapAlloc@12


    mov ecx, dword [ebp + 8]
    mov [ecx], dword eax




    call _ReadNextNumber@0
    mov ecx, dword [ebp + 20]
    mov [ecx], dword eax

    mov edi, 12
    mul edi
    push eax
    push dword 0
    push dword [ebp - 4]
    call _HeapAlloc@12

    mov ecx, dword [ebp + 16]
    mov [ecx], dword eax

    ; Start populating vertices
    mov edi, dword [ebp + 12]
    mov ecx, dword [edi]
    mov eax, dword [ebp + 8]
    mov edi, dword [eax]

    
    LoadTriangles_loop1:
    push ecx
        call _ReadNextNumber@0
        mov dword [edi], eax
        add edi, 4
        call _ReadNextNumber@0
        mov dword [edi], eax
        add edi, 4
        call _ReadNextNumber@0
        mov word [edi], ax
        add edi, 2
        call _ReadNextNumber@0
        mov word [edi], ax
        add edi, 2
        call _ReadNextNumber@0
        mov word [edi], ax
        add edi, 2
        call _ReadNextNumber@0
        mov word [edi], ax
        add edi, 2
        ;call _printEAX
        ;call _printCRLF
    pop ecx
    loop LoadTriangles_loop1

    ; Start populating meshes
    mov edi, dword [ebp + 20]
    mov ecx, dword [edi]
    mov eax, dword [ebp + 16]
    mov edi, dword [eax]

    
    LoadTriangles_loop2:
    push ecx
        call _ReadNextNumber@0
        mov dword [edi], eax
        add edi, 4
        call _ReadNextNumber@0
        mov dword [edi], eax
        add edi, 4
        call _ReadNextNumber@0
        mov dword [edi], eax
        add edi, 4
    pop ecx
    loop LoadTriangles_loop2

    

LoadTriangles_exit:
    add esp, 4
    pop edi
    mov esp, ebp
    pop ebp
    ret 16




