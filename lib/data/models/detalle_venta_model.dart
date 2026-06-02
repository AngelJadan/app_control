class DetalleVentaModel {
  final int? id;
  final int? ventaId;
  final int productoId;
  final String? nombreProducto; // Opcional para mostrar en UI de reportes
  final int cantidad;
  final double precioUnitario;

  DetalleVentaModel({
    this.id,
    this.ventaId,
    required this.productoId,
    this.nombreProducto,
    required this.cantidad,
    required this.precioUnitario,
  });

  Map<String, dynamic> toMap(int idVenta) => {
    'venta_id': idVenta,
    'producto_id': productoId,
    'cantidad': cantidad,
    'precio_unitario': precioUnitario,
  };

  factory DetalleVentaModel.fromMap(Map<String, dynamic> map) =>
      DetalleVentaModel(
        id: map['id'],
        ventaId: map['venta_id'],
        productoId: map['producto_id'],
        nombreProducto:
            map['nombre_producto'], // Se llena mediante un JOIN en la consulta
        cantidad: map['cantidad'],
        precioUnitario: map['precio_unitario'],
      );
}
