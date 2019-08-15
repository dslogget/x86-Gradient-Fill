    extern _debug
    extern _printEAX
    extern h_stdout
    extern _atoui@4
    extern _atoi@4
    extern _printCRLF
    extern windowHeight
    extern windowWidth

    global _ReadNextNumber@4
    global _LoadTriangles@24 ;ppVertices, pnVertices, ppMeshes, pnMeshes, screenwidth, screenheight
    global _ReadFloat@4
    global _CloseFileHandle@0
    
    %include "WIN32N.INC"
    %include "WIN32FUNCS.INC"
    %define buflen 30


    section .rdata
filename    db "./test.txt", 0
fl0_5 dd 0.5
max_col_intensity dw 0xFF00

    section .data
h_file      dd 0

    section .text



_ReadFloat@4: ;filepath
    push ebp
    mov ebp, esp
    

    push dword [ebp + 8]
    call _ReadNextNumber@4

    push eax
    fild dword [esp]
    pop eax

    push dword [ebp + 8]
    call _ReadNextNumber@4

    cmp eax, dword 0
    je ReadFloat_exit

    push eax

    ;get bits needed to shift
    fldlg2
    fild dword [esp]
    fyl2x 
    fadd dword [fl0_5]
    frndint
    push dword 0
    fistp dword [esp]
    pop ecx  


    push edi
    mov edi, dword 10
    mov eax, dword 10
    cmp ecx, 0
    je ReadFloat_lp_end
ReadFloat_lp_start:
    loop ReadFloat_lp
    jmp ReadFloat_lp_end
ReadFloat_lp:
    mul edi
    jmp ReadFloat_lp_start
ReadFloat_lp_end:
    pop edi

    fild dword [esp]
    push eax
    fidiv dword [esp]
    fadd
    add esp, 4
ReadFloat_exit:
    mov esp, ebp
    pop ebp
    ret 4


_ReadNextNumber@4: ;filepath
    push ebp
    mov ebp, esp
    push esi
    sub esp, 8 ;numreached, numBytesRead
    sub esp, buflen ;buffer
    mov [ebp -4*1 - 4], dword 0

ReadNextNumber_if1:
    cmp dword [h_file], 0
    jne ReadNextNumber_else1

    push dword 0
    push dword 0
    push dword OPEN_ALWAYS
    push dword 0
    push dword FILE_SHARE_READ
    push dword GENERIC_READ
    push dword [ebp + 8];
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
    lea eax, [ebp -4*1 - 8]
    push dword eax
    push dword 1
    lea eax, [ebp -4*1 - 8 - buflen + esi]
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
    cmp [ebp -4*1 - 8], dword 0
    ja ReadNextNumber_endif2
ReadNextNumber_ret:

    cmp [ebp -4*1 - 4], dword 0
    jne ReadNextNumber_next
    mov eax, dword -1
    jmp ReadNextNumber_exit
ReadNextNumber_next:

    lea eax, [ebp -4*1 - 8 - buflen + esi]
    mov byte [eax], 0
    lea eax, [ebp -4*1 - 8 - buflen]
    push dword eax
    call _atoi@4
    jmp ReadNextNumber_exit
ReadNextNumber_endif2: 

lea eax, [ebp -4*1 - 8 - buflen + esi]
ReadNextNumber_if3:
    cmp byte [eax], '0'
    jb ReadNextNumber_elseif3_1
    cmp byte [eax], '9'
    ja ReadNextNumber_elseif3_1
    mov [ebp -4*1 - 4], dword 1
    jmp ReadNextNumber_endif3
ReadNextNumber_elseif3_1:
    cmp [ebp -4*1 - 4], dword 0
    jne ReadNextNumber_ret
ReadNextNumber_endif3:
    
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
    ret 4





_LoadTriangles@24: ;ppVertices, pnVertices, ppMeshes, pnMeshes, screenwidth, screenheight
    push ebp
    mov ebp, esp
    push edi
    sub esp, 4

    call _GetProcessHeap@0
    mov dword [ebp -4*1 - 4], dword eax

    push filename
    call _ReadNextNumber@4

    mov ecx, dword [ebp + 12]
    mov [ecx], dword eax

    mov edi, 16
    mul edi
    push eax
    push dword 0
    push dword [ebp -4*1 - 4]
    call _HeapAlloc@12


    mov ecx, dword [ebp + 8]
    mov [ecx], dword eax



    push filename
    call _ReadNextNumber@4

    mov ecx, dword [ebp + 20]
    mov [ecx], dword eax

    mov edi, 12
    mul edi
    push eax
    push dword 0
    push dword [ebp -4*1 - 4]
    call _HeapAlloc@12

    mov ecx, dword [ebp + 16]
    mov [ecx], dword eax

    ; Start populating vertices
    mov edi, dword [ebp + 12]
    mov ecx, dword [edi]
    mov eax, dword [ebp + 8]
    mov edi, dword [eax]

    sub dword [ebp + 8 + 5*4], 30
    
    LoadTriangles_loop1:
    push ecx
    ;x
        push filename
        call _ReadFloat@4
        push dword [ebp + 8 + 4*4]
        fimul dword [esp]
        fistp dword [edi]

        add edi, 4
        add esp, 4

    ;y
        push filename
        call _ReadFloat@4
        push dword [ebp + 8 + 5*4]
        fimul dword [esp]
        fistp dword [edi]
        ;sub dword [edi], 25

        add edi, 4
        add esp, 4

    ;R
        push filename
        call _ReadFloat@4
        fimul word [max_col_intensity]
        fistp word [edi]

        add edi, 2

    ;G
        push filename
        call _ReadFloat@4
        fimul word [max_col_intensity]
        fistp word [edi]

        add edi, 2
    ;B
        push filename
        call _ReadFloat@4
        fimul word [max_col_intensity]
        fistp word [edi]

        add edi, 2
    ;A
        push filename
        call _ReadFloat@4
        fimul word [max_col_intensity]
        fistp word [edi]

        add edi, 2

    pop ecx
    sub ecx, 1
    jnz LoadTriangles_loop1

    ; Start populating meshes
    mov edi, dword [ebp + 20]
    mov ecx, dword [edi]
    mov eax, dword [ebp + 16]
    mov edi, dword [eax]

    
    LoadTriangles_loop2:
    push ecx
        push filename
        call _ReadNextNumber@4
        mov dword [edi], eax
        add edi, 4
        push filename
        call _ReadNextNumber@4
        mov dword [edi], eax
        add edi, 4
        push filename
        call _ReadNextNumber@4
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


_CloseFileHandle@0:
    push dword [h_file]
    call _CloseHandle@4
    mov [h_file], dword 0
    ret

