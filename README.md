U2 Proyecto Ventas e Inventario en Ensamblador

Materia: Lenguajes de Interfaz

Unidad: 2

1. Integrantes del Equipo

Ángel David Quiñónez Figueroa

[Añadir nombre de otro integrante, si aplica]

[Añadir nombre de otro integrante, si aplica]

2. Instrucciones de Compilación y Ejecución

Este proyecto fue desarrollado en ensamblador MASM x86 de 32 bits, haciendo uso de la biblioteca Irvine32. Para ejecutarlo en Visual Studio, sigue estos pasos:

Abre Visual Studio y crea un nuevo "Proyecto vacío" (C++).

Haz clic derecho en el proyecto en el Explorador de soluciones -> Dependencias de compilación -> Personalizaciones de compilación y marca la casilla MASM.

Agrega el archivo fuente codigo.asm a la carpeta de Archivos de origen.

Haz clic derecho en el proyecto -> Propiedades:

Ve a Vinculador (Linker) -> General -> Directorios de bibliotecas adicionales: Agrega la ruta de tu carpeta de Irvine (ej. C:\Irvine).

Ve a Vinculador (Linker) -> Entrada -> Dependencias adicionales: Escribe irvine32.lib;.

Ve a Microsoft Macro Assembler -> General -> Include Paths: Agrega la ruta de tu carpeta de Irvine.

Compila y ejecuta el programa presionando Ctrl + F5.

3. Informe Breve

Negocio elegido: Tienda de electrónica.

Regla adicional del negocio: Descuento por mayoreo. Si el cliente compra 3 o más unidades de un mismo producto en una sola exhibición, el sistema aplica automáticamente un 10% de descuento sobre el importe base.

Organización de datos en memoria: El inventario se estructuró mediante un arreglo contiguo de tamaño fijo (MAX_PRODUCTOS = 10). Cada registro utiliza un STRUCT personalizado de 42 bytes (código, nombre, precio y existencia). Para las búsquedas y validaciones, se navega por este bloque de memoria utilizando el registro apuntador ESI y sumando el tamaño de la estructura para avanzar iterativamente.

Formato del archivo de inventario: Se optó por un archivo binario de volcado directo (inventario.dat). Se utilizaron las funciones de la API de Windows (WriteToFile y ReadFromFile) con su respectivo handle para volcar la memoria RAM directamente al disco. Esta decisión se investigó y tomó por su alta eficiencia, ya que evita realizar procesos de "parseo" de texto al cargar los datos.

Decisiones investigadas (Manejo Numérico): Para cumplir la restricción de no usar funciones automáticas (ReadDec/WriteDec) y evitar la imprecisión del punto flotante, los precios capturados se convierten matemáticamente a centavos enteros (multiplicando por 10 o 100 usando MUL y procesando el código ASCII). Para mostrarlos en formato XX.XX MXN, se emplea la instrucción aritmética DIV entre 100; el cociente representa los pesos y el residuo los centavos, convirtiéndolos nuevamente a ASCII mediante la suma de 30h.

4. Tabla de Pruebas

| Prueba | Entrada | Resultado Esperado | Resultado Obtenido |
| Alta válida | Código: DSP-002, Nombre: DISPLAY PORT, Precio: 70.99, Cantidad: 20 | Producto registrado correctamente, disminuye el espacio disponible. | Conforme a lo esperado. |
| Alta duplicada | Intentar registrar nuevamente DSP-002 | Rechazo del sistema con mensaje de error sin sobrescribir memoria. | Error: Codigo ya existe. |
| Alta formato inválido | Código: abc-123 (minúsculas) | Rechazo por no cumplir el patrón estricto LLL-DDD. | Error: El codigo debe ser LLL-DDD (ej. ABC-123). |
| Búsqueda | Opción 2, Código: DSP-002 | Muestra en pantalla el nombre, precio formateado y existencias. | Conforme a lo esperado. |
| Entrada válida | Opción 3, Código: DSP-002, Cantidad a recibir: 10 | La existencia del producto se actualiza sumando las unidades (Total: 30). | Conforme a lo esperado. |
| Entrada excesiva | Opción 3, Código: DSP-002, Cantidad a recibir: 90 | Rechazo de la operación por superar el límite del inventario (100). | Error: La existencia superaria las 100 unidades. |
| Venta con descuento | Opción 4, Código: DSP-002, Cantidad a vender: 3 | Resta existencias, aplica -10% al ser >= 3 unidades y muestra el total a pagar. | Conforme a lo esperado (-10% aplicado). |
| Venta rechazada | Opción 4, Código: DSP-002, Cantidad a vender: 50 | Rechazo por no tener suficientes unidades en el inventario actual. | Error: Existencias insuficientes. |
| Mostrar resumen | Opción 5 | Imprime el valor monetario total del almacén y los ingresos generados en la sesión. | Conforme a lo esperado. |
