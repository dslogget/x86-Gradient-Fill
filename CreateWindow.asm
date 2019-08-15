    
    global _init

    extern _debug
    extern _printEAX
    extern _LoadTriangles@24 ;ppVertices, pnVertices, ppMeshes, pnMeshes, screenwidth, screenheight
    extern _ReadNextNumber@8
    extern _CloseFileHandle@0

    %include "WIN32N.INC"
    %include "WIN32FUNCS.INC"



    %define classStyle 0x0020|0x0002|0x0001
    %define wndStyle 0x80000
    
    section .rdata
className db "MyWindowClass",0
settingsfile db "Settings.txt",0

    section .data

windowHeight:    dd 500
windowWidth:     dd 500





hInst dd 0
pVertices   dd 0
nVertices   dd 0
pMeshes     dd 0
nMeshes     dd 0

    section .bss

    section .text

_wndProc@16:
    push ebp
    mov ebp, esp
    push ebx
    push esi
    push edi

    mov eax, dword 0


    mov ebx, dword [ebp + 12]

    xor ebx, dword WM_CREATE
    jz case1
    xor ebx, dword WM_CREATE^WM_COMMAND
    jz case2
    xor ebx, dword WM_COMMAND^WM_DESTROY
    jz case3
    xor ebx, dword WM_DESTROY^WM_PAINT
    jz case4
    jmp dft
case1:
    push dword [windowHeight]
    push dword [windowWidth]
    push nMeshes
    push pMeshes
    push nVertices
    push pVertices
    call _LoadTriangles@24 ;ppVertices, pnVertices, ppMeshes, pnMeshes, screenwidth, screenheight
    jmp break
case2:
    jmp break
case3:
    push dword 0
    call _PostQuitMessage@4
    mov eax, dword 0
    jmp break
case4:
    sub esp, 148
    mov esi, esp

    push dword esi
    lea ebx, [ebp + 8]
    push dword [ebx]
    call _BeginPaint@8


    cmp eax, 0
    jne skip
    call _GetLastError@0
    call _printEAX
    call _debug
skip:

    ;push dword BLACK_BRUSH
    ;call _GetStockObject@4
    ;push dword eax
    ;push dword [esi]
    ;call _SelectObject@8

    ;push dword 720-27
    ;push dword 10
    ;push dword 0
    ;push dword 0
    ;push dword [esi]
    ;call _Rectangle@20


    ;Draw Gradient Triangle
    
    push edi
    mov edi, dword [nVertices]
    mov eax, dword edi
    ;call _printEAX

    mov edi, dword [nMeshes]

    mov eax, dword edi
    ;call _printEAX

    mov edi, dword [pMeshes]
    mov eax, dword [edi]
    ;call _printEAX


    pop edi

    push dword GRADIENT_FILL_TRIANGLE
    push dword [nMeshes]
    push dword [pMeshes]
    push dword [nVertices]
    push dword [pVertices]
    push dword [esi]
    call _GdiGradientFill@24

endp:
    push dword esi
    push dword [ebx]
    call _EndPaint@8
    
    add esp, 148
    jmp break
dft:
    lea eax, [ebp + 20]
    push dword [eax]
    sub eax, 4
    push dword [eax]
    sub eax, 4
    push dword [eax]
    sub eax, 4
    push dword [eax]
    call _DefWindowProcA@16
    jmp pexit
break:
    mov eax, dword 0
pexit:
    pop edi
    pop esi
    pop ebx
    mov esp, ebp
    pop ebp
    ret 16




_init:
    push ebp
    mov ebp, esp
    push ebx


    push dword 0
    push esp
    push settingsfile
    call _ReadNextNumber@8
    mov [windowWidth], dword eax

    push esp
    push settingsfile
    call _ReadNextNumber@8
    mov [windowHeight], dword eax
    add esp, 4
    call _CloseFileHandle@0
    

    push dword 0
    call _GetModuleHandleA@4
    mov [hInst], eax

    sub esp, 40
    mov ebx, esp
        mov [ebx + 00], dword classStyle
        mov [ebx + 04], dword _wndProc@16
        mov [ebx + 08], dword 0
        mov [ebx + 12], dword 0
        mov eax, dword [hInst]
        mov [ebx + 16], eax ;hInst
        mov [ebx + 20], dword 0

        push dword 32512
        push dword 0
        call _LoadCursorA@8
        ;call load cursor
        mov [ebx + 24], eax
        mov [ebx + 28], dword 1
        mov [ebx + 32], dword 0
        mov [ebx + 36], dword className
    
    push ebx
    call _RegisterClassA@4
    
    cmp eax, dword 0
    je exit

    push dword 0
    push dword [hInst] ;hInst
    push dword 0
    push dword 0
    push dword [windowHeight]
    push dword [windowWidth]
    push dword 0x80000000
    push dword 0x80000000
    push wndStyle
    push className
    push className
    push dword 0
    call _CreateWindowExA@48
    
    mov edx, eax

    cmp edx, dword 0
    je exit

    push 1
    push edx
    call _ShowWindow@8


    sub esp, dword 24
    lea ebx, [esp]
lp:
    push dword 0
    push dword 0
    push dword 0
    push ebx
    call _GetMessageA@16
    cmp eax, dword 0
    je exit

    push ebx
    call _TranslateMessage@4
    push ebx
    call _DispatchMessageA@4
    jmp lp 
exit:

    add esp, 64
    pop ebx
    mov esp, ebp
    pop ebp


    ret
