;-----------------------------------------------
; Fundamentos de arquitectura de computadoras
; Uso de la consola para entrada/salida
; PHREDA
;-----------------------------------------------

format PE
entry main

section '.text' code readable executable

salida:
        push    n
        push    _str
        call    [gets]
        add     esp, 4
        push    0
        call    [exit]
        ret
                
;<<<<<<<<<<<<< BOOT
main:
        push    _p
        call    [printf]
        add     esp, 4

        push    n1
        push    _dec
        call    [scanf]
        add     esp, 8

        push    _p
        call    [printf]
        add     esp, 4

        push    n2
        push    _dec
        call    [scanf]
        add     esp, 8

        jmp salida
                

section '.data' data readable writeable

n1            dd ?
n2            dd ?

_p		db "n:",0
_dec	db "%d",0


section '.idata' data import readable

include "macro\import32.inc"

library msvcrt, "MSVCRT.DLL"

import msvcrt,\
       printf ,'printf',\
       scanf  ,'scanf',\
	   gets  ,'gets',\
	   puts  ,'puts',\
       exit   ,'exit'

