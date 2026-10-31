#U2 Proyecto Ventas e Inventario en Ensamblador#

Materia: Lenguajes de Interfaz
Unidad: 2

1. Integrantes del Equipo

Ángel David Quiñónez Figueroa

Edith Alessandra Gomez Sanchez

Sahory Estrada Trejo

# U2 Proyecto: Ventas e Inventario en Ensamblador

**Integrantes del Equipo:**
* Ángel David Quiñónez Figueroa

## 1. Negocio Elegido y Regla Adicional
* **Negocio:** Tienda de Electrónica.
* **Regla Adicional:** Descuento por mayoreo. Si el cliente compra 3 o más unidades de un mismo producto, se aplica un 10% de descuento al importe total de esa venta. Esto se resuelve matemáticamente en el código dividiendo el total en centavos entre 10 y restándolo del importe original, descartando fracciones automáticamente.

## 2. Organización de Datos en Memoria
Se utilizó un arreglo contiguo en memoria para almacenar hasta 10 productos (`MAX_PRODUCTOS = 10`). Cada producto está definido por una estructura (`STRUCT`) de 42 bytes en total:
* **Código:** 8 bytes (7 caracteres + nulo)
* **Nombre:** 26 bytes (25 caracteres + nulo)
* **Precio:** 4 bytes (`DWORD` en centavos)
* **Existencia:** 4 bytes (`DWORD`)

Para los recorridos, se utiliza el registro `ESI` como apuntador. En cada ciclo de búsqueda o impresión, se le suma el tamaño de la estructura (`TYPE Producto`) a `ESI` para saltar exactamente al inicio del siguiente registro en la memoria RAM.

## 3. Formato del Archivo y Decisiones
* **Archivo:** `inventario.dat`
* **Formato:** Volcado binario directo.
* **Justificación de decisiones:** En lugar de convertir los valores numéricos a cadenas de texto (parseo) para guardarlos, se utiliza la función `WriteToFile` de Irvine32 para transferir el bloque completo de la estructura directamente de la RAM al disco duro. Esto es más eficiente, evita desbordamientos por conversiones y permite que la función `ReadFromFile` recargue el catálogo exacto al iniciar la siguiente sesión sin necesidad de procesar los datos de nuevo.

## 4. Tabla de Pruebas

| Prueba / Entrada | Resultado Esperado | Resultado Obtenido |
| :--- | :--- | :--- |
| **Alta válida** (USB-001, $250.50, 50 u) | El sistema registra el producto sin errores. | Éxito. Producto registrado en memoria. |
| **Alta duplicada** (USB-001) | Rechaza el registro por código existente. | Éxito. Muestra `Error: Codigo ya existe`. |
| **Búsqueda válida** (USB-001) | Muestra los datos correctos ingresados. | Éxito. Muestra precio y existencia exactos. |
| **Entrada válida** (+30 a USB-001) | Suma unidades (total 80) sin superar 100. | Éxito. Unidades actualizadas a 80. |
| **Entrada excesiva** (+50 a USB-001) | Rechaza porque 80+50 supera las 100 unidades. | Éxito. Muestra `Error: La existencia superaria las 100 unidades`. |
| **Venta aceptada** (4 u. de USB-001) | Aplica el descuento del 10% por llevar >= 3 y descuenta existencias. | Éxito. Descuenta 4 unidades y muestra mensaje de regla aplicada. |
| **Venta rechazada** (90 u. de USB-001) | Rechaza la venta porque el inventario actual es menor a 90. | Éxito. Muestra `Error: Existencias insuficientes`. |
| **Guardado y Carga** (Opción 6 y reinicio) | Al cerrar y abrir el programa, el catálogo y las modificaciones persisten. | Éxito. El archivo `inventario.dat` recupera los datos íntegros al reiniciar. |

## Evidencias de Ejecución

Haz clic en el siguiente enlace para visualizar las capturas de pantalla de todas las pruebas realizadas en la consola:

[📄 PRUEBAS DE LA EJECUCÍON.pdf](PRUEBAS%20DE%20LA%20EJECUC%C3%8DON.pdf)

