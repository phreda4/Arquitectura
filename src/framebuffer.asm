;-------------------------------------
; Fundamentos de arquitectura de computadoras
; Inteface Basica con Windows
; PHREDA - FASTA 2025
;-------------------------------------
format PE GUI 4.0
entry start

;XRES equ 640
;YRES equ 480
;XRES equ 800 ;YRES equ 600
XRES equ 1024 
YRES equ 768
;XRES equ 1280 ;YRES equ 800

include 'include\win32a.inc'

section '.code' code readable executable

start:
        invoke  GetModuleHandle,0
        mov     [hinstance],eax
        invoke  LoadIcon,0,IDI_APPLICATION
        mov     [wc.hIcon],eax
        mov     [wc.style],0
        mov     [wc.lpfnWndProc],WindowProc
        mov     [wc.cbClsExtra],0
        mov     [wc.cbWndExtra],0
        mov     eax,[hinstance]
        mov     [wc.hInstance],eax
        mov     [wc.hbrBackground],0
        mov     dword [wc.lpszMenuName],0
        mov     dword [wc.lpszClassName],_class
        invoke  RegisterClass,wc
        mov [dwExStyle],WS_EX_APPWINDOW
        mov [dwStyle],WS_VISIBLE+WS_CAPTION+WS_SYSMENU
        invoke ShowCursor,0
        xor eax,eax
        mov [rec.left],eax
        mov [rec.top],eax
        mov [rec.right],XRES
        mov [rec.bottom],YRES
        invoke AdjustWindowRect,rec,[dwStyle],0
        mov eax,[rec.left]
        sub [rec.right],eax
        mov eax,[rec.top]
        sub [rec.bottom],eax
        xor eax,eax
        mov [rec.left],eax
        mov [rec.top],eax
        invoke  CreateWindowEx,[dwExStyle],_class,_title,[dwStyle],0,0,[rec.right],[rec.bottom],0,0,[hinstance],0
        mov     [hwnd],eax
        invoke GetDC,[hwnd]
        mov [hDC],eax
        mov [bmi.biSize],sizeof.BITMAPINFOHEADER
        mov [bmi.biWidth],XRES
        mov [bmi.biHeight],-YRES
        mov [bmi.biPlanes],1
        mov [bmi.biBitCount],32
        mov [bmi.biCompression],BI_RGB
        invoke ShowWindow,[hwnd],SW_NORMAL
        invoke UpdateWindow,[hwnd]

;---------- INICIO
restart:
;;        call test1
;        call test2
;        call test3
        jmp SYSEND

;*******************************************
;--- ejemplo 1 llena la pantalla
;*******************************************
test1:
        xor ebx,ebx
loopi:
;        inc edx
        mov [SYSFRAME+ebx*4],edx
        add ebx,1
        cmp ebx,640*480
        jl loopi
        add edx,1
        call SYSREDRAW
        call SYSUPDATE
        cmp [SYSKEY],1
        jne test1

        ret
;*******************************************
;---ejemplo 2 uso de mouse
;*******************************************
test2:
        call SYSCLS
loop2:


        mov eax, [SYSXYM]
        mov ebx,eax
        shr ebx,16
        and eax,$ffff

        mov ecx,[x1]
        mov edx,[y1]

        mov [x1],eax
        mov [y1],ebx
        call LINEA

        call SYSREDRAW
        call SYSUPDATE
        cmp [SYSKEY],1
        jne loop2
        ret

;*******************************************
;--- ejemplo 3 caracteres y lineas
;*******************************************
test3:
        call SYSCLS

        mov eax,10
        mov ebx,10
        call setxy

        mov eax,65
.l1:    push eax
        call emit
        pop eax
        add eax,1
        cmp eax,128
        jne .l1


        mov eax, [SYSXYM]
        mov ebx,eax
        shr ebx,16
        and eax,$ffff

        mov ecx,100
        mov edx,100
        call LINEA

        call SYSREDRAW
        call SYSUPDATE
        cmp [SYSKEY],1
        jne test3

        ret

;*******************************************
setxy:  ; eax=x,ebx=y----edi;dir
        imul ebx,ebx,XRES
        add eax,ebx
        lea edi,[SYSFRAME+eax*4]
        ret

;*******************************************
emit:   ; eax=char
        imul eax,eax,12
        lea esi,[rom8x12+eax]
        mov ebx,0
cadalin:
        movzx eax,byte [esi+ebx]
        mov ecx,$80
cadapix:
        test eax,ecx
        je no
        mov edx,$ff00
        mov [edi],edx
no:     shr ecx,1
        add edi,4
        cmp ecx,0
        jne cadapix

        add ebx,1
        add edi,(XRES-8)*4
        cmp ebx,12
        jne cadalin
        sub edi,((XRES*12)*4)-8*4
        ret

;*******************************************
LINEA:  ; eax=x1 ebx=y1 ecx=x2 edx=y2
        cmp ebx,edx
        je horizontal
        jg .noswap
        xchg eax,ecx
        xchg ebx,edx
.noswap:
        shl eax,16
        shl ecx,16
        sub eax,ecx
        push ebx
        push edx
        sub ebx,edx
        add ebx,1
        cdq
        idiv ebx
        mov esi,eax
        add ecx,$7fff
        pop ebx
        pop edx
.lineas:
        mov eax,ecx
        add eax,esi
        push ebx
        push eax
        shr ecx,16
        shr eax,16
        call horizontal
        pop ecx
        pop ebx
        add ebx,1
        cmp ebx,edx
        jle .lineas
        ret

horizontal:  ; eax=x1 ebx=y1 ecx=x2
        cmp ecx,eax
        jg .m
        xchg ecx,eax
.m:
        sub ecx,eax
        jnz .n
        add ecx,1
.n:
        imul ebx,ebx,XRES
        add eax,ebx
        lea edi,[SYSFRAME+eax*4]
.l:
        mov dword [edi],$ff00
        add edi,4
        sub ecx,1
        jnz .l
        ret


;*******************************************
;*******************************************
;*******************************************
;*******************************************
; OS inteface
;===============================================
align 16
SYSUPDATE: ; ( -- )
        push eax ebx edx ecx
        mov [SYSKEY],0
        invoke  PeekMessage,msg,0,0,0,PM_NOREMOVE
        or      eax,eax
        jz      .noEvent
        invoke  GetMessage,msg,0,0,0
        or      eax,eax
        jz      .endApp
        invoke  TranslateMessage,msg
        invoke  DispatchMessage,msg
.noEvent:
        pop ecx edx ebx eax
        ret
.endApp:
        pop ecx edx ebx eax
;===============================================
align 16
SYSEND: ; ( -- )
        invoke ReleaseDC,[hwnd],[hDC]
        invoke DestroyWindow,[hwnd]
        invoke ExitProcess,0
        ret
;===============================================
align 16
SYSREDRAW: ; ( -- )
        pusha
        invoke SetDIBitsToDevice,[hDC],0,0,XRES,YRES,0,0,0,YRES,SYSFRAME,bmi,0
        popa
        ret
;===============================================
align 16
SYSCLS:         ; ( -- )
        pusha
        mov eax,[SYSPAPER]
        lea edi,[SYSFRAME]
        mov ecx,XRES*YRES
        rep stosd
        popa
        ret
;===============================================
SYSMSEC: ;  ( -- eax=msec
        lea esi,[esi-4]
        mov [esi], eax
        invoke GetTickCount
        ret
;===============================================
SYSTIME: ;  ( -- ecx=s ebx=m eax=h )
        invoke GetLocalTime,SysTime
        movzx eax,word [SysTime.wHour]
        movzx ebx,word [SysTime.wMinute]
        movzx ecx,word [SysTime.wSecond]
        ret
;===============================================
SYSDATE: ;  ( -- eax=y ebx=m ecx=d )
        invoke GetLocalTime,SysTime
        movzx eax,word [SysTime.wYear]
        movzx ebx,word [SysTime.wMonth]
        movzx ecx,word [SysTime.wDay]
        ret
;===============================================
SYSLOAD: ; edi='from eax="filename"
        invoke CreateFile,eax,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_FLAG_SEQUENTIAL_SCAN,0
        mov [hdir],eax
        or eax,eax
        jz .end
.again:
        invoke ReadFile,[hdir],edi,$fffff,cntr,0
        mov eax,[cntr]
        add edi,eax
        or eax,eax
        jnz .again
        invoke CloseHandle,[hdir]
        mov eax,edi
.end:
        ret

;===============================================
SYSSAVE: ; edx='from ecx=cnt eax="filename" --
        push edx ecx
        invoke CreateFile,eax,GENERIC_WRITE,0,0,CREATE_ALWAYS,FILE_FLAG_SEQUENTIAL_SCAN,0
        mov [hdir],eax
        pop ecx edx
        or eax,eax
        jz .saveend
        invoke WriteFile,[hdir],edx,ecx,cntr,0
        cmp [cntr],ecx
        je .saveend
        or eax,eax
        jz .saveend
        invoke CloseHandle,[hdir]
.saveend:
        ret

;--------------------------------------
proc WindowProc hwnd,wmsg,wparam,lparam
        mov     eax,[wmsg]
        cmp     eax,WM_MOUSEMOVE
        je      wmmousemove
        cmp     eax,WM_LBUTTONUP
        je      wmmouseev
        cmp     eax,WM_MBUTTONUP
        je      wmmouseev
        cmp     eax,WM_RBUTTONUP
        je      wmmouseev
        cmp     eax,WM_LBUTTONDOWN
        je      wmmouseev
        cmp     eax,WM_MBUTTONDOWN
        je      wmmouseev
        cmp     eax,WM_RBUTTONDOWN
        je      wmmouseev
        cmp     eax,WM_KEYUP
        je      wmkeyup
        cmp     eax,WM_KEYDOWN
        je      wmkeydown
		cmp		eax,WM_CLOSE
		je		SYSEND
		cmp		eax,WM_DESTROY
		je		SYSEND		
  defwindowproc:
        invoke  DefWindowProc,[hwnd],[wmsg],[wparam],[lparam]
        ret
  wmmousemove:
        mov eax,[lparam]
        mov [SYSXYM],eax
        xor eax,eax
        ret
  wmmouseev:
        mov eax,[wparam]
        mov [SYSBM],eax
        xor eax,eax
        ret
  wmkeyup:
        mov eax,[lparam]
        shr eax,16
        and eax,$7f
        or eax,$80
        mov [SYSKEY],eax
        xor eax,eax
        ret
  wmkeydown:                    ; cmp [wparam],VK_ESCAPE ; je wmdestroy
        mov eax,[lparam]
        shr eax,16
        and eax,$7f
        mov [SYSKEY],eax
        xor eax,eax
        ret
endp
;----------------------------------------------
section '.idata' import data readable

library kernel,'KERNEL32.DLL', user,'USER32.DLL', gdi,'GDI32.DLL'
import kernel,\
         GetModuleHandle,'GetModuleHandleA', CreateFile,'CreateFileA',\
         ReadFile,'ReadFile',  WriteFile,'WriteFile',\
         CloseHandle,'CloseHandle', GetTickCount,'GetTickCount',\
         ExitProcess,'ExitProcess', GetLocalTime,'GetLocalTime',\
         SetCurrentDirectory,'SetCurrentDirectoryA', FindFirstFile,'FindFirstFileA',\
         FindNextFile,'FindNextFileA',  FindClose,'FindClose'

import user,\
         RegisterClass,'RegisterClassA', CreateWindowEx,'CreateWindowExA',\
         DestroyWindow,'DestroyWindow', DefWindowProc,'DefWindowProcA',\
         GetMessage,'GetMessageA', PeekMessage,'PeekMessageA',\
         TranslateMessage,'TranslateMessage', DispatchMessage,'DispatchMessageA',\
         LoadCursor,'LoadCursorA', LoadIcon,'LoadIconA',\
         SetCursor,'SetCursor', MessageBox,'MessageBoxA',\
         PostQuitMessage,'PostQuitMessage', WaitMessage,'WaitMessage'    ,\
         ShowWindow,'ShowWindow', UpdateWindow,'UpdateWindow',\
         ChangeDisplaySettings,'ChangeDisplaySettingsA', GetDC,'GetDC',\
         ReleaseDC,'ReleaseDC', AdjustWindowRect,'AdjustWindowRect',\
         ShowCursor,'ShowCursor'

import gdi,\
        SetDIBitsToDevice,'SetDIBitsToDevice'

section '.data' data readable writeable

        hinstance       dd 0
        hwnd            dd 0
        wc              WNDCLASS ;EX?
        msg             MSG
        hDC             dd 0
        dwExStyle       dd 0
        dwStyle         dd 0
        rec             RECT
        bmi             BITMAPINFOHEADER
        SysTime         SYSTEMTIME
        hdir            dd 0
        afile           dd 0
        cntr            dd 0
        _title          db 'asm',0
        _class          db 'asm',0

include "fonti.inc"

align 4
        SYSXYM  dd 0
        SYSBM   dd 0
        SYSKEY  dd 0
        SYSPAPER dd 0

        x1 dd 0
        y1 dd 0

align 16 ; CUADRO DE VIDEO (FrameBuffer)
        SYSFRAME        rd XRES*YRES
