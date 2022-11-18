format PE GUI 4.0
entry inicio

include 'Win32a.inc'

ventana_1	equ		1
salir_btn	equ		1000

section '.data' data readable writeable

Ist             dd 0
pWnd            dd 0
hdc             dd 0
rectanguloSeleccionado  dd 0    ; bandera de rectangulo: (0) no seleccionado, (1) seleccionado
circuloSeleccionado     dd 0    ; bandera de circulo: (0) no seleccionado, (1) seleccionado
trianguloSeleccionado   dd 0    ; bandera de triangulo: (0) no seleccionado, (1) seleccionado
idFiguraActual          dd 0    ; identificador de la figura a mover: (0) aun no hay figuras en el lienzo, (1) rectangulo, (2) circulo, (3) triangulo
puntosTriangulo         dd 0, 0, 0, 0, 0, 0

velocidad       equ 16
lLienzo         equ 180   ; limite izquierdo de lienzo
tLienzo         equ 25    ; limite superior de lienzo
rLienzo         equ 602   ; limite derecho de lienzo
bLienzo         equ 353   ; limite inferior de lienzo
alturaFigura    equ 50
anchoRectangulo equ 70

lienzo              RECT lLienzo, tLienzo, rLienzo, bLienzo
baseRectangulo      RECT 355, 164, 426, 214                      ; base para dibujar el rectangulo
baseCirculo         RECT 366, 164, 416, 214                      ; base para dibujar el circulo
baseTriangulo       RECT 366, 164, 416, 214                      ; base para dibujar el triangulo
baseFiguraActual    RECT 0, 0, 0, 0                              ; base de la figura a mover
 
section '.code' code readable executable

inicio:
	invoke GetModuleHandle,0
	mov [Ist],eax
	invoke DialogBoxParam,eax,ventana_1,0,DlgProc,0 
fin:
	invoke ExitProcess,0

proc DlgProc,hWnd,uMsg,wParam,lParam
	push edi esi ebx
	
    cmp [idFiguraActual], 0
    jne eContinuar
    invoke GetDC, [pWnd]
	mov [hdc], eax
 	stdcall dibujarLienzo

eContinuar:    
	mov eax,[uMsg]
	cmp	eax,WM_COMMAND
	je	jCOMMAND
	cmp	eax,WM_INITDIALOG
	je	jINITDIALOG
	cmp	eax,WM_CLOSE
	je	jCLOSE
	xor eax,eax
	jmp finish

jINITDIALOG:
	mov eax,[hWnd]
	mov [pWnd],eax
	
	mov eax,1
	jmp finish
	
jCOMMAND:
	mov eax,[wParam]
	cmp	eax,salir_btn
	je	salir
	
	cmp eax, 1005
	je seleccionarRectangulo
	
	cmp eax, 1006
	je seleccionarCirculo
	
	cmp eax, 1007
	je seleccionarTriangulo
	
	cmp [idFiguraActual], 0
	je terminar
	
	cmp eax, 1001
	je eMoverArriba
	
	cmp eax, 1002
	je eMoverIzquierda
	
	cmp eax, 1003
	je eMoverAbajo
	
	cmp eax, 1004
	je eMoverDerecha

terminar:
	xor eax,eax
	jmp finish
	
salir:
	invoke SendMessage,[hWnd],WM_CLOSE,0,0
	mov eax,1
	jmp finish
	
eMoverArriba:
    stdcall moverArriba
    stdcall actualizar
    mov eax, 1
    jmp finish
    
eMoverIzquierda:
    stdcall moverIzquierda
    stdcall actualizar
    mov eax, 1
    jmp finish
    
eMoverAbajo:
    stdcall moverAbajo
    stdcall actualizar
    mov eax, 1
    jmp finish
    
eMoverDerecha:
    stdcall moverDerecha
    stdcall actualizar
    mov eax, 1
    jmp finish
	
seleccionarRectangulo:
    mov [rectanguloSeleccionado], 1
    mov [idFiguraActual], 1
    mov [circuloSeleccionado], 0
    mov [trianguloSeleccionado], 0
    mov eax, [baseRectangulo.left]
    mov [baseFiguraActual.left], eax
    mov eax, [baseRectangulo.top]
    mov [baseFiguraActual.top], eax
    mov eax, [baseRectangulo.right]
    mov [baseFiguraActual.right], eax
    mov eax, [baseRectangulo.bottom]
    mov [baseFiguraActual.bottom], eax
    stdcall dibujarFiguras
    mov eax, 1
    jmp finish

seleccionarCirculo:
    mov [circuloSeleccionado], 1
    mov [idFiguraActual], 2
    mov [rectanguloSeleccionado], 0
    mov [trianguloSeleccionado], 0
    mov eax, [baseCirculo.left]
    mov [baseFiguraActual.left], eax
    mov eax, [baseCirculo.top]
    mov [baseFiguraActual.top], eax
    mov eax, [baseCirculo.right]
    mov [baseFiguraActual.right], eax
    mov eax, [baseCirculo.bottom]
    mov [baseFiguraActual.bottom], eax
    stdcall dibujarFiguras
    mov eax, 1
    jmp finish
    
seleccionarTriangulo:
    mov [trianguloSeleccionado], 1
    mov [idFiguraActual], 3
    mov [rectanguloSeleccionado], 0
    mov [circuloSeleccionado], 0
    mov eax, [baseTriangulo.left]
    mov [baseFiguraActual.left], eax
    mov eax, [baseTriangulo.top]
    mov [baseFiguraActual.top], eax
    mov eax, [baseTriangulo.right]
    mov [baseFiguraActual.right], eax
    mov eax, [baseTriangulo.bottom]
    mov [baseFiguraActual.bottom], eax
    stdcall dibujarFiguras
    mov eax, 1
    jmp finish
	
jCLOSE:	
	invoke EndDialog,[hWnd],0
	mov eax,1
	
finish:
	pop ebx esi edi
	ret
endp

proc dibujarFiguras
    invoke GetDC, [pWnd]
	mov [hdc], eax
	
	invoke RedrawWindow, [pWnd], lienzo, NULL, RDW_ERASE or RDW_INVALIDATE
	invoke RedrawWindow, [pWnd], lienzo, NULL, RDW_ERASENOW
	
    stdcall dibujarLienzo
    
    cmp [rectanguloSeleccionado], 0
    je continuarCirculo
    
    stdcall dibujarRectangulo
    
continuarCirculo:
    cmp [circuloSeleccionado], 0
    je continuarTriangulo
    
    stdcall dibujarCirculo
    
continuarTriangulo:
    cmp [trianguloSeleccionado], 0
    je continuar
    
    stdcall dibujarTriangulo
    
continuar:
    
    ret
endp

proc dibujarLienzo
	invoke Rectangle, [hdc], [lienzo.left], [lienzo.top], [lienzo.right], [lienzo.bottom]
    ret
endp

proc dibujarRectangulo
    push eax
    invoke CreateSolidBrush, 000000FFh
    invoke SelectObject, [hdc], eax
    invoke Rectangle, [hdc], [baseRectangulo.left], [baseRectangulo.top], [baseRectangulo.right], [baseRectangulo.bottom]
    invoke DeleteObject, eax
    pop  eax
    ret
endp

proc dibujarCirculo
    push eax
    invoke CreateSolidBrush, 0000FFFFh
    invoke SelectObject, [hdc], eax
    invoke Ellipse, [hdc], [baseCirculo.left], [baseCirculo.top], [baseCirculo.right], [baseCirculo.bottom]
    invoke DeleteObject, eax
    pop  eax
    ret
endp

proc dibujarTriangulo
    push eax ebx ecx edx
    mov eax, [baseTriangulo.left]
    mov ebx, eax
    mov [puntosTriangulo], eax
    mov eax, [baseTriangulo.bottom]
    mov edx, eax
    mov [puntosTriangulo + 4], eax
    mov eax, [baseTriangulo.right]
    mov [puntosTriangulo + 8], eax
    mov [puntosTriangulo + 12], edx
    sub eax, ebx
    mov ecx, 2
    mov edx, 0
    div ecx
    add eax, ebx
    mov [puntosTriangulo + 16], eax
    mov eax, [baseTriangulo.top]
    mov [puntosTriangulo + 20], eax
    invoke CreateSolidBrush, 00008000h
    invoke SelectObject, [hdc], eax
    invoke Polygon, [hdc], puntosTriangulo, 3
    invoke DeleteObject, eax
    pop  edx ecx ebx eax
    ret
endp

proc actualizar
    push eax
    cmp [idFiguraActual], 1
    jne eActualizarCirculo
    mov eax, [baseFiguraActual.left]
    mov [baseRectangulo.left], eax
    mov eax, [baseFiguraActual.top]
    mov [baseRectangulo.top], eax
    mov eax, [baseFiguraActual.right]
    mov [baseRectangulo.right], eax
    mov eax, [baseFiguraActual.bottom]
    mov [baseRectangulo.bottom], eax
    jmp eTerminarActualizar
eActualizarCirculo:
    cmp [idFiguraActual], 2
    jne eActualizarTriangulo
    mov eax, [baseFiguraActual.left]
    mov [baseCirculo.left], eax
    mov eax, [baseFiguraActual.top]
    mov [baseCirculo.top], eax
    mov eax, [baseFiguraActual.right]
    mov [baseCirculo.right], eax
    mov eax, [baseFiguraActual.bottom]
    mov [baseCirculo.bottom], eax
    jmp eTerminarActualizar
eActualizarTriangulo:
    cmp [idFiguraActual], 3
    jne eTerminarActualizar
    mov eax, [baseFiguraActual.left]
    mov [baseTriangulo.left], eax
    mov eax, [baseFiguraActual.top]
    mov [baseTriangulo.top], eax
    mov eax, [baseFiguraActual.right]
    mov [baseTriangulo.right], eax
    mov eax, [baseFiguraActual.bottom]
    mov [baseTriangulo.bottom], eax
eTerminarActualizar:
    stdcall dibujarFiguras
    pop  eax
    ret
endp

proc moverArriba
    push eax
    sub [baseFiguraActual.top], velocidad
    sub [baseFiguraActual.bottom], velocidad
    cmp [baseFiguraActual.top], tLienzo
    jae terminarMA 
    
    mov [baseFiguraActual.top], tLienzo
    mov [baseFiguraActual.bottom], tLienzo
    add [baseFiguraActual.bottom], alturaFigura
    
terminarMA:
    pop eax
    ret
endp

proc moverIzquierda
    push eax
    sub [baseFiguraActual.left], velocidad
    sub [baseFiguraActual.right], velocidad
    cmp [baseFiguraActual.left], lLienzo
    jae terminarMI
    
    mov [baseFiguraActual.left], lLienzo
    mov [baseFiguraActual.right], lLienzo
    
    cmp [idFiguraActual], 1
    jne otrasFigurasMI
    
    add [baseFiguraActual.right], anchoRectangulo
    jmp terminarMI
    
otrasFigurasMI:
    add [baseFiguraActual.right], alturaFigura
    
terminarMI:
    pop eax
    ret
endp

proc moverAbajo
    push eax
    add [baseFiguraActual.bottom], velocidad
    add [baseFiguraActual.top], velocidad
    cmp [baseFiguraActual.bottom], bLienzo
    jbe terminarMB
    
    mov [baseFiguraActual.bottom], bLienzo
    mov [baseFiguraActual.top], bLienzo
    sub [baseFiguraActual.top], alturaFigura
    
    cmp [idFiguraActual], 3
    jne terminarMB
    sub [baseFiguraActual.top], 1
    sub [baseFiguraActual.bottom], 1
    
terminarMB:
    pop eax
    ret
endp

proc moverDerecha
    push eax
    add [baseFiguraActual.right], velocidad
    add [baseFiguraActual.left], velocidad
    cmp [baseFiguraActual.right], rLienzo
    jbe terminarMD
    
    mov [baseFiguraActual.right], rLienzo
    mov [baseFiguraActual.left], rLienzo
    
    cmp [idFiguraActual], 1
    jne otrasFiguras
    
    sub [baseFiguraActual.left], anchoRectangulo
    
    jmp terminarMD 

otrasFiguras:
    sub [baseFiguraActual.left], alturaFigura

    cmp [idFiguraActual], 3
    jne terminarMD
    sub [baseFiguraActual.right], 1
    sub [baseFiguraActual.left], 1
     
terminarMD:
    pop eax
    ret
endp

section '.idata' import data readable writeable
;  ;importamos solo los procedimientos basicos para abrir una ventana
;  library kernel, 'KERNEL32.DLL',\
;	  user,   'USER32.DLL'
;
;  import  kernel,\
;	  GetModuleHandle,'GetModuleHandleA',\
;	  ExitProcess,	  'ExitProcess'
;
;  import  user,\
;	  DialogBoxParam, 'DialogBoxParamA',\
;	  EndDialog,	  'EndDialog',\
;	  SendMessage,	  'SendMessageA'
  ;otra forma para importar los procedimientos importando archivos INC
  library kernel32,'KERNEL32.DLL',user32,'USER32.DLL',gdi32,'GDI32.DLL'
  include 'api\kernel32.inc'
  include 'api\user32.inc'
  include 'api\gdi32.inc'

section '.rsrc' resource from 'proyecto.res' data readable
