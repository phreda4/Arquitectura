;-----------------------------------------------
; Fundamentos de arquitectura de computadoras
; Uso de la consola para entrada/salida
; PHREDA
;-----------------------------------------------

format PE
entry main

section '.text' code readable executable

log:
        pusha
        push    edx
        push    edx
        push    ecx
        push    ecx
        push    ebx
        push    ebx
        push    eax
        push    eax
        push    _eax1
        call    [printf]
        add     esp, 4*9
        popa
        ret

salida:
        push    num1
        push    _str
        call    [scanf]
        add     esp, 8
        push    0
        call    [exit]
        ret

rutina:
        mov eax,33
        mov ebx,123
        mov ecx,9
        mov edx,10
        ret

main:
        push    _prompt
        call    [printf]
		;pop eax
        add     esp, 4

        push    num1
        push    _dec
        call    [scanf]
        add     esp, 8


;        call rutina
;        call log
;        add eax,1
;        call log
        jmp salida

section '.data' data readable writeable

eaxcopia dd 0
num1            dd ?
num2            dd ?

_prompt db "Ingrese un numero:",0
_str   db "%s",0
_dec  db "%d",0
_eax1  db "EAX = %d $%x "
_ebx1  db "EBX = %d $%x "
_ecx1  db "ECX = %d $%x "
_edx1  db "EDX = %d $%x ",10,0

buffer rb 1024 

str2    db "Hola",0


section '.idata' data import readable

include "macro\import32.inc"

library msvcrt, "MSVCRT.DLL"

import msvcrt,\
       printf ,'printf',\
       scanf  ,'scanf',\
       exit   ,'exit'

