import 'detalle_venta_model.dart';

class VentaModel {
  final int? id;
  final DateTime fecha;
  final double total;
  final String? observacion;
  final String nombreCliente;
  final String
  formaPago; // Efectivo, Transferencia, Deposito, En factura, Cortesia
  final List<DetalleVentaModel> productos;

  VentaModel({
    this.id,
    required this.fecha,
    required this.total,
    this.observacion,
    required this.nombreCliente,
    required this.formaPago,
    required this.productos,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fecha': fecha.toIso8601String(),
    'total': total,
    'observacion': observacion,
    'nombre_cliente': nombreCliente,
    'forma_pago': formaPago,
  };

  factory VentaModel.fromMap(
    Map<String, dynamic> map,
    List<DetalleVentaModel> productos,
  ) => VentaModel(
    id: map['id'],
    fecha: DateTime.parse(map['fecha']),
    total: map['total'],
    observacion: map['observacion'],
    nombreCliente: map['nombre_cliente'],
    formaPago: map['forma_pago'],
    productos: productos,
  );
}
