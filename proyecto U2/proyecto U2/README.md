# U2 Proyecto Ventas e Inventario en Ensamblador

**Materia:** Lenguajes de Interfaz
**Unidad:** 2

## 1. Integrantes del Equipo

* Estrada Trejo Sahory 
* Gomez Sanchez Edith Alessandra 
* Quiñónez Figueroa Ángel David

## 2. Instrucciones de Compilación y Ejecución

Este proyecto fue desarrollado en ensamblador MASM x86 de 32 bits, haciendo uso de la biblioteca **Irvine32**. Para ejecutarlo en Visual Studio, sigue estos pasos:

1. Abre Visual Studio y crea un nuevo "Proyecto vacío" (C++).
2. Haz clic derecho en el proyecto en el Explorador de soluciones -> **Dependencias de compilación** -> **Personalizaciones de compilación** y marca la casilla **MASM**.
3. Agrega el archivo fuente `codigo.asm` a la carpeta de Archivos de origen.
4. Haz clic derecho en el proyecto -> **Propiedades**:
   * Ve a **Vinculador (Linker)** -> **General** -> **Directorios de bibliotecas adicionales**: Agrega la ruta de tu carpeta de Irvine (ej. `C:\Irvine`).
   * Ve a **Vinculador (Linker)** -> **Entrada** -> **Dependencias adicionales**: Escribe `irvine32.lib;`.
   * Ve a **Microsoft Macro Assembler** -> **General** -> **Include Paths**: Agrega la ruta de tu carpeta de Irvine.
5. Compila y ejecuta el programa presionando `Ctrl + F5`.

## 3. Informe Breve

* **Negocio elegido:** Tienda de electrónica.
* **Regla adicional del negocio:** Descuento por mayoreo. Si el cliente compra 3 o más unidades de un mismo producto en una sola exhibición, el sistema aplica automáticamente un 10% de descuento sobre el importe base.
* **Organización de datos en memoria:** El inventario se estructuró mediante un arreglo contiguo de tamaño fijo (`MAX_PRODUCTOS = 10`). Cada registro utiliza un `STRUCT` personalizado de 42 bytes (código, nombre, precio y existencia). Para las búsquedas y validaciones, se navega por este bloque de memoria utilizando el registro apuntador `ESI` y sumando el tamaño de la estructura para avanzar iterativamente.
* **Formato del archivo de inventario:** Se optó por un **archivo binario de volcado directo** (`inventario.dat`). Se utilizaron las funciones de la API