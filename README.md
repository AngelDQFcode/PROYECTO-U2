#U2 Proyecto Ventas e Inventario en Ensamblador#

Materia: Lenguajes de Interfaz
Unidad: 2

1. Integrantes del Equipo

Ángel David Quiñónez Figueroa

Edith Alessandra Gomez Sanchez

Sahory Estrada Trejo

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

Formato del archivo de inventario: Se optó por un archivo binario de volcado directo (inventario.dat). Se utilizaron las funciones de la API de Windows (WriteToFile y ReadFromFile) con su respectivo handle para volcar la memoria RAM directamente al disco. Esta decisión se tomó por su alta eficiencia, ya que evita realizar procesos de "parseo" de texto al cargar los datos.

Decisiones investigadas y Fuentes consultadas:
Para cumplir la restricción de no usar funciones automáticas (ReadDec/WriteDec) y evitar la imprecisión del coprocesador matemático, se investigó cómo procesar cadenas numéricas manualmente. Los precios capturados se convierten a centavos enteros procesando el código ASCII (restando 30h) y multiplicando por 10 o 100 usando la instrucción MUL. Para imprimirlos en formato moneda, se emplea DIV entre 100 para aislar pesos (cociente) y centavos (residuo).

Fuentes consultadas:

Irvine, K. R. (2014). Assembly Language for x86 Processors (7ma ed.). Pearson. (Consulta sobre manejo de la pila con PUSHAD/POPAD, operaciones de archivos y conversiones ASCII).

Documentación oficial de Intel: Intel 64 and IA-32 Architectures Software Developer's Manual. (Consulta técnica sobre el comportamiento de las banderas y registros en las instrucciones DIV y MUL).

4. Tabla de Pruebas

Las pruebas de ejecución, entradas, resultados esperados y obtenidos se encuentran documentados detalladamente en el archivo adjunto.

📄 Haz clic aquí para abrir y visualizar las pruebas: PRUEBAS DE LA EJECUCÍON.pdf
