# Guía de Uso - App Control de Inventario

## 🚀 Inicio Rápido

### Para compilar la aplicación:

```bash
cd ~/app_control
flutter pub get
flutter run
```

## 📋 Características

### 1. **Nueva Venta** (Pestaña Izquierda)

- Selecciona productos del catálogo izquierdo
- Cada clic agrega una unidad al carrito
- Ingresa nombre del cliente (obligatorio)
- Selecciona forma de pago
- Añade observaciones (opcional)
- El stock se actualiza automáticamente

**Formas de Pago disponibles:**

- Efectivo
- Transferencia
- Depósito
- En factura
- Cortesía

### 2. **Inventario** (Pestaña Central)

- **Crear Producto**: Botón verde en la esquina superior derecha
  - Nombre (obligatorio)
  - Precio (obligatorio)
  - Cantidad Inicial (obligatorio)
  - Descripción (opcional)

- **Aumentar Stock**: Icono de caja azul
  - Especifica cuántas unidades agregar

- **Editar Producto**: Icono de lápiz naranja
  - Modifica nombre, precio o descripción
  - El stock se mantiene igual

- **Eliminar**: Icono de basura roja
  - No permite eliminar si hay ventas asociadas
  - Requiere confirmación

**Indicadores:**

- Stock verde: >= 10 unidades
- Stock rojo: < 10 unidades

### 3. **Reportes** (Pestaña Derecha)

- **Filtro de Fechas**: Selecciona rango de fechas
- **Botón Buscar**: Carga reportes del período

**Información Mostrada:**

- Resumen con totales:
  - Total de ventas realizadas
  - Ingresos totales
  - Productos vendidos
- Tabla con todas las ventas del período
- Botón "Ver Detalle" para ampliar información

## 💾 Base de Datos

La aplicación usa SQLite local. Los datos se guardan en:

- **Windows/Linux**: `~/.local/share/sistema_inventario.db`
- **Android**: Base de datos del app

No requiere internet ni servidor externo.

## 🔑 Características de Seguridad

- **Foreign Keys**: Protege la integridad de datos
- **Validaciones**: Verifica stock antes de vender
- **Confirmaciones**: Pide confirmación antes de eliminar

## ⚠️ Consideraciones

- Si un producto tiene ventas registradas, no puede eliminarse
- El stock debe ser positivo para vender
- Las fechas de reportes incluyen el día completo (00:00 a 23:59)

## 📊 Ejemplo de Uso Completo

1. **Crear Productos**:
   - Ir a Inventario
   - Click en "Nuevo Producto"
   - Llenar formulario y guardar

2. **Realizar Venta**:
   - Ir a Nueva Venta
   - Hacer clic en productos del catálogo
   - Llenar datos del cliente
   - Click en "Procesar y Guardar Venta"

3. **Consultar Reportes**:
   - Ir a Reportes
   - Seleccionar rango de fechas
   - Click en "Buscar"
   - Ver detalle de ventas

## 🛠️ Troubleshooting

**Problema**: No aparecen productos en ventas
**Solución**: Primero crea productos en Inventario

**Problema**: No puedo aumentar stock más de X unidades
**Solución**: Es una limitación de SQLite integer, considera reducir cantidades

**Problema**: La base de datos no se encuentra
**Solución**: Ejecuta la app, se creará automáticamente

## 📞 Soporte

Para reportar problemas o sugerencias, verifica:

- Que Flutter está actualizado: `flutter upgrade`
- Las dependencias: `flutter pub get`
- No hay archivos dañados en `/lib`
