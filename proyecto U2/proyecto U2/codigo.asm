INCLUDE Irvine32.inc

; =================================================================
; 1. ESTRUCTURAS Y DATOS
; =================================================================
Producto STRUCT
    codigo      BYTE 8 DUP(0)    ; 3 letras, guion, 3 dígitos, nulo
    nombre      BYTE 26 DUP(0)   ; 25 caracteres + nulo
    precio      DWORD 0          ; Precio en centavos enteros
    existencia  DWORD 0          ; Unidades (0 a 100)
Producto ENDS

.data
MAX_PRODUCTOS = 10
inventario Producto MAX_PRODUCTOS DUP(<>)
numProductos DWORD 0
ingresosSesion DWORD 0

; Manejo de archivos
archivoNom    BYTE "inventario.dat", 0
handleArchivo DWORD ?

; Textos del Menú
menuTitulo BYTE "=== TIENDA DE ELECTRONICA ===", 13, 10, 0
menu1      BYTE "1. Registrar producto", 13, 10, 0
menu2      BYTE "2. Buscar / Mostrar inventario", 13, 10, 0
menu3      BYTE "3. Recibir mercancia", 13, 10, 0
menu4      BYTE "4. Vender", 13, 10, 0
menu5      BYTE "5. Mostrar resumen", 13, 10, 0
menu6      BYTE "6. Salir y Guardar", 13, 10, 0
promptOpc  BYTE "Elige una opcion: ", 0

; Mensajes de captura y resultados
msgCod     BYTE "Ingrese codigo (ABC-123): ", 0
msgNom     BYTE "Ingrese nombre: ", 0
msgPrec    BYTE "Ingrese precio (ej. 15.50): ", 0
msgExist   BYTE "Ingrese cantidad: ", 0
msgCantRec BYTE "Cantidad a recibir: ", 0
msgCantVen BYTE "Cantidad a vender: ", 0
msgMx      BYTE " MXN", 13, 10, 0
msgSepar   BYTE "-------------------------", 13, 10, 0
msgTotal   BYTE "Total inventario: ", 0
msgIng     BYTE "Ingresos de sesion: ", 0
msgRegla   BYTE "¡Descuento 10% aplicado por mayoreo (>=3)!", 13, 10, 0
msgPrecTxt BYTE " - Precio: $", 0
msgExisTxt BYTE " - Existencia: ", 0
msgVentaOk BYTE "Venta exitosa. Total a pagar: $", 0
msgGuard   BYTE "Inventario guardado exitosamente. ¡Adios!", 13, 10, 0

; Mensajes de error
errLleno   BYTE "Error: Inventario lleno.", 13, 10, 0
errCod     BYTE "Error: El codigo debe ser LLL-DDD (ej. ABC-123).", 13, 10, 0
errDuplic  BYTE "Error: Codigo ya existe.", 13, 10, 0
errFormato BYTE "Error: Formato numerico invalido.", 13, 10, 0
errNoEncon BYTE "Error: Producto no encontrado.", 13, 10, 0
errExcede  BYTE "Error: La existencia superaria las 100 unidades.", 13, 10, 0
errNoExist BYTE "Error: Existencias insuficientes.", 13, 10, 0

bufferEntrada BYTE 50 DUP(0)

.code
; =================================================================
; 2. CICLO PRINCIPAL
; =================================================================
main PROC
    call CargarArchivo           ; Recuperar catálogo al iniciar

CicloMenu:
    call Crlf
    mov edx, OFFSET menuTitulo
    call WriteString
    mov edx, OFFSET menu1
    call WriteString
    mov edx, OFFSET menu2
    call WriteString
    mov edx, OFFSET menu3
    call WriteString
    mov edx, OFFSET menu4
    call WriteString
    mov edx, OFFSET menu5
    call WriteString
    mov edx, OFFSET menu6
    call WriteString
    
    mov edx, OFFSET promptOpc
    call WriteString

    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    
    cmp eax, 1
    jne OpcionInvalida

    mov al, bufferEntrada[0]
    cmp al, '1'
    je OpcRegistrar
    cmp al, '2'
    je OpcBuscar
    cmp al, '3'
    je OpcRecibir
    cmp al, '4'
    je OpcVender
    cmp al, '5'
    je OpcResumen
    cmp al, '6'
    je OpcSalir

OpcionInvalida:
    jmp CicloMenu

OpcRegistrar:
    call RegistrarProducto
    jmp CicloMenu
OpcBuscar:
    call BuscarInventario
    jmp CicloMenu
OpcRecibir:
    call RecibirMercancia
    jmp CicloMenu
OpcVender:
    call VenderProducto
    jmp CicloMenu
OpcResumen:
    call MostrarResumen
    jmp CicloMenu
OpcSalir:
    call GuardarArchivo
    exit
main ENDP

; =================================================================
; 3. CONVERSIONES NUMÉRICAS Y UTILIDADES (SIN ReadDec / WriteDec)
; =================================================================

; -----------------------------------------------------------------
; CadenaACentavos: Texto a Entero (Maneja decimales)
; -----------------------------------------------------------------
CadenaACentavos PROC
    push ebx
    push ecx
    push esi
    mov esi, edx
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
CicloConv:
    mov cl, [esi]
    cmp cl, 0
    je FinConv
    cmp cl, '.'
    je DetectoPto
    cmp cl, '0'
    jb ErrConv
    cmp cl, '9'
    ja ErrConv
    sub cl, 30h
    push edx
    mov edx, 10
    mul edx
    pop edx
    add eax, ecx
    cmp ebx, 0
    je SigDig
    inc ebx
    cmp ebx, 3
    ja ErrConv
SigDig:
    inc esi
    jmp CicloConv
DetectoPto:
    cmp ebx, 0
    jne ErrConv
    mov ebx, 1
    inc esi
    jmp CicloConv
FinConv:
    cmp ebx, 0
    je Faltan2
    cmp ebx, 2
    je Falta1
    jmp ExitoConv
Faltan2:
    mov ebx, 100
    mul ebx
    jmp ExitoConv
Falta1:
    mov ebx, 10
    mul ebx
ExitoConv:
    clc
    jmp Terminar
ErrConv:
    stc
Terminar:
    pop esi
    pop ecx
    pop ebx
    ret
CadenaACentavos ENDP

; -----------------------------------------------------------------
; CentavosACadena: Imprime importe EAX con formato XX.XX MXN
; -----------------------------------------------------------------
CentavosACadena PROC
    pushad
    mov ecx, 100
    xor edx, edx
    div ecx
    push edx             ; Guardar centavos (32 bits)
    
    mov ebx, 10
    xor ecx, ecx         ; Limpiar ECX completo para usarlo de contador
CicloPesos:
    xor edx, edx
    div ebx
    add dl, 30h
    push edx             ; Guardar dígito
    inc ecx
    test eax, eax
    jnz CicloPesos
ImprimePesos:
    pop eax              ; Extraer dígito
    call WriteChar
    loop ImprimePesos
    
    mov al, '.'
    call WriteChar
    
    pop eax              ; Recuperar centavos (32 bits)
    cmp eax, 10
    jae ImprimeCentsDosDigitos
    
    ; --- CASO: Centavos de 0 a 9 ---
    push eax
    mov al, '0'
    call WriteChar       ; Imprime el '0' inicial (ej. .05 o .00)
    pop eax
    add al, 30h          ; Convierte el dígito a ASCII
    call WriteChar       ; Imprime el dígito
    jmp FinCents

    ; --- CASO: Centavos de 10 a 99 ---
ImprimeCentsDosDigitos:
    mov ebx, 10
    xor edx, edx
    div ebx
    add al, 30h
    add dl, 30h
    call WriteChar       ; Imprime decenas
    mov al, dl
    call WriteChar       ; Imprime unidades
    
FinCents:
    mov edx, OFFSET msgMx
    call WriteString
    popad
    ret
CentavosACadena ENDP

; -----------------------------------------------------------------
; ImprimirEntero: Imprime el valor de EAX como cadena simple
; -----------------------------------------------------------------
ImprimirEntero PROC
    pushad
    mov ecx, 10
    xor edi, edi
CicloDivE:
    xor edx, edx
    div ecx
    add dl, 30h
    push edx             ; Guardar dígito (32 bits en lugar de 16)
    inc edi
    test eax, eax
    jnz CicloDivE
ImprimeDig:
    pop eax              ; Extraer dígito (32 bits)
    call WriteChar
    dec edi
    jnz ImprimeDig
    popad
    ret
ImprimirEntero ENDP

; -----------------------------------------------------------------
; BuscarPorCodigoHelper: Compara bufferEntrada con inventario
; Salidas: ESI = Puntero al producto. CF=0 si encontró, CF=1 si no.
; -----------------------------------------------------------------
BuscarPorCodigoHelper PROC
    mov esi, OFFSET inventario
    mov ecx, numProductos
    test ecx, ecx
    jz NoEncontradoH
CicloBusqueda:
    push ecx
    push esi
    mov ebx, OFFSET bufferEntrada
    mov ecx, 7
ComparaStr:
    mov al, [ebx]
    mov ah, [esi]
    cmp al, ah
    jne SiguienteProdH
    inc ebx
    inc esi
    loop ComparaStr
    pop esi             ; Encontrado: restaurar ESI al inicio del struct
    pop ecx
    clc                 ; CF=0 (Éxito)
    ret
SiguienteProdH:
    pop esi
    pop ecx
    add esi, TYPE Producto
    loop CicloBusqueda
NoEncontradoH:
    stc                 ; CF=1 (Fallo)
    ret
BuscarPorCodigoHelper ENDP

; =================================================================
; 4. PROCEDIMIENTOS DEL NEGOCIO (OPCIONES DEL MENÚ)
; =================================================================

RegistrarProducto PROC
    pushad
    mov eax, numProductos
    cmp eax, MAX_PRODUCTOS
    jae ErrorLleno
    
    mov edx, OFFSET msgCod
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    cmp eax, 7
    jne FormatoCodInvalido
    
    mov ecx, 3
    mov esi, OFFSET bufferEntrada
ValLetras:
    mov al, [esi]
    cmp al, 'A'
    jb FormatoCodInvalido
    cmp al, 'Z'
    ja FormatoCodInvalido
    inc esi
    loop ValLetras
    
    mov al, [esi]
    cmp al, '-'
    jne FormatoCodInvalido
    inc esi
    
    mov ecx, 3
ValDigitos:
    mov al, [esi]
    cmp al, '0'
    jb FormatoCodInvalido
    cmp al, '9'
    ja FormatoCodInvalido
    inc esi
    loop ValDigitos

    call BuscarPorCodigoHelper
    jnc CodDuplicado ; Si CF=0 (lo encontró), es duplicado

GuardarNuevo:
    mov eax, numProductos
    mov ebx, TYPE Producto
    mul ebx
    mov esi, OFFSET inventario
    add esi, eax
    
    push esi
    mov ebx, OFFSET bufferEntrada
    mov ecx, 8
CopiarCod:
    mov al, [ebx]
    mov [esi], al
    inc ebx
    inc esi
    loop CopiarCod
    pop esi
    
    mov edx, OFFSET msgNom
    call WriteString
    push esi
    add esi, 8
    mov edx, esi
    mov ecx, 26
    call ReadString
    pop esi
    
    mov edx, OFFSET msgPrec
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    mov edx, OFFSET bufferEntrada
    call CadenaACentavos
    jc ErrorFormato
    mov (Producto PTR [esi]).precio, eax
    
    mov edx, OFFSET msgExist
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    mov edx, OFFSET bufferEntrada
    call CadenaACentavos
    jc ErrorFormato
    cmp eax, 10000       ; Límite de 100 (convertido en centavos es 10000)
    ja ErrorFormato
    
    mov ebx, 100
    xor edx, edx
    div ebx
    mov (Producto PTR [esi]).existencia, eax
    inc numProductos
    jmp FinRegistro

ErrorLleno:
    mov edx, OFFSET errLleno
    call WriteString
    jmp FinRegistro
FormatoCodInvalido:
    mov edx, OFFSET errCod
    call WriteString
    jmp FinRegistro
CodDuplicado:
    mov edx, OFFSET errDuplic
    call WriteString
    jmp FinRegistro
ErrorFormato:
    mov edx, OFFSET errFormato
    call WriteString
FinRegistro:
    popad
    ret
RegistrarProducto ENDP

BuscarInventario PROC
    pushad
    mov eax, numProductos
    test eax, eax
    jz FinBuscar
    
    mov edx, OFFSET msgCod
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    
    call BuscarPorCodigoHelper
    jc ErrorNoEncontradoB
    
    ; Imprimir datos si se encontró (ESI apunta al producto)
    mov edx, OFFSET msgSepar
    call WriteString
    lea edx, (Producto PTR [esi]).codigo
    call WriteString
    call Crlf
    lea edx, (Producto PTR [esi]).nombre
    call WriteString
    mov edx, OFFSET msgPrecTxt
    call WriteString
    mov eax, (Producto PTR [esi]).precio
    call CentavosACadena
    mov edx, OFFSET msgExisTxt
    call WriteString
    mov eax, (Producto PTR [esi]).existencia
    call ImprimirEntero
    call Crlf
    jmp FinBuscar

ErrorNoEncontradoB:
    mov edx, OFFSET errNoEncon
    call WriteString
FinBuscar:
    popad
    ret
BuscarInventario ENDP

RecibirMercancia PROC
    pushad
    mov edx, OFFSET msgCod
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    
    call BuscarPorCodigoHelper
    jc ErrorNoEncontradoR
    
    mov edx, OFFSET msgCantRec
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    mov edx, OFFSET bufferEntrada
    call CadenaACentavos
    jc ErrorFormatoR
    
    mov ebx, 100
    xor edx, edx
    div ebx              ; EAX = unidades a sumar
    
    mov ebx, (Producto PTR [esi]).existencia
    add ebx, eax
    cmp ebx, 100
    ja ErrorExcede
    mov (Producto PTR [esi]).existencia, ebx ; Guardar nuevo total
    jmp FinRecibir

ErrorExcede:
    mov edx, OFFSET errExcede
    call WriteString
    jmp FinRecibir
ErrorNoEncontradoR:
    mov edx, OFFSET errNoEncon
    call WriteString
    jmp FinRecibir
ErrorFormatoR:
    mov edx, OFFSET errFormato
    call WriteString
FinRecibir:
    popad
    ret
RecibirMercancia ENDP

VenderProducto PROC
    pushad
    mov edx, OFFSET msgCod
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    
    call BuscarPorCodigoHelper
    jc ErrorNoEncontradoV
    
    mov edx, OFFSET msgCantVen
    call WriteString
    mov edx, OFFSET bufferEntrada
    mov ecx, SIZEOF bufferEntrada
    call ReadString
    mov edx, OFFSET bufferEntrada
    call CadenaACentavos
    jc ErrorFormatoV
    
    mov ecx, 100
    xor edx, edx
    div ecx              ; EAX = cantidad solicitada
    
    mov ebx, (Producto PTR [esi]).existencia
    cmp eax, ebx
    ja ErrorNoExistV     ; Si pide más de lo que hay, saltar
    
    sub ebx, eax
    mov (Producto PTR [esi]).existencia, ebx
    
    mov ebx, eax         ; EBX = cantidad
    mov eax, (Producto PTR [esi]).precio
    mul ebx              ; EAX = Importe total
    
    cmp ebx, 3           ; Regla negocio: 3 o más artículos = descuento
    jb SinDescuento
    push eax
    mov edx, OFFSET msgRegla
    call WriteString
    pop eax
    mov ecx, 10
    push eax
    xor edx, edx
    div ecx              ; Calculamos el 10%
    mov ebx, eax
    pop eax
    sub eax, ebx         ; Descontamos el 10%

SinDescuento:
    add ingresosSesion, eax
    mov edx, OFFSET msgVentaOk
    call WriteString
    call CentavosACadena
    jmp FinVenta

ErrorNoExistV:
    mov edx, OFFSET errNoExist
    call WriteString
    jmp FinVenta
ErrorNoEncontradoV:
    mov edx, OFFSET errNoEncon
    call WriteString
    jmp FinVenta
ErrorFormatoV:
    mov edx, OFFSET errFormato
    call WriteString
FinVenta:
    popad
    ret
VenderProducto ENDP

MostrarResumen PROC
    pushad
    call Crlf
    mov edx, OFFSET msgSepar
    call WriteString
    mov esi, OFFSET inventario
    mov ecx, numProductos
    xor ebx, ebx
    test ecx, ecx
    jz MostrarIngresos
CicloResumen:
    mov eax, (Producto PTR [esi]).precio
    mov edi, (Producto PTR [esi]).existencia
    mul edi
    add ebx, eax
    add esi, TYPE Producto
    loop CicloResumen
MostrarIngresos:
    mov edx, OFFSET msgTotal
    call WriteString
    mov eax, ebx
    call CentavosACadena
    mov edx, OFFSET msgIng
    call WriteString
    mov eax, ingresosSesion
    call CentavosACadena
    popad
    ret
MostrarResumen ENDP

; =================================================================
; 5. MANEJO DE ARCHIVOS EN DISCO
; =================================================================

GuardarArchivo PROC
    pushad
    mov edx, OFFSET archivoNom
    call CreateOutputFile
    cmp eax, INVALID_HANDLE_VALUE
    je FinGuardar
    mov handleArchivo, eax
    
    mov eax, handleArchivo
    mov edx, OFFSET numProductos
    mov ecx, 4
    call WriteToFile
    
    mov eax, handleArchivo
    mov edx, OFFSET inventario
    mov ecx, SIZEOF inventario
    call WriteToFile
    
    mov eax, handleArchivo
    call CloseFile
    
    mov edx, OFFSET msgGuard
    call WriteString
FinGuardar:
    popad
    ret
GuardarArchivo ENDP

CargarArchivo PROC
    pushad
    mov edx, OFFSET archivoNom
    call OpenInputFile
    cmp eax, INVALID_HANDLE_VALUE
    je FinCargar     ; Si no existe, inicia vacío (normal en primer uso)
    mov handleArchivo, eax
    
    mov eax, handleArchivo
    mov edx, OFFSET numProductos
    mov ecx, 4
    call ReadFromFile
    
    mov eax, handleArchivo
    mov edx, OFFSET inventario
    mov ecx, SIZEOF inventario
    call ReadFromFile
    
    mov eax, handleArchivo
    call CloseFile
FinCargar:
    popad
    ret
CargarArchivo ENDP

END main