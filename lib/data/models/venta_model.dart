import 'detalle_venta_model.dart';

class VentaModel {
  final int? id;
  final DateTime fecha;
  final double subtotal;
  final double descuento;
  final double total;
  final String? observacion;
  final String nombreCliente;
  final String
  formaPago; // Efectivo, Transferencia, Deposito, En factura, Cortesia
  final bool
  existeDevolucion; // Indica si la venta tiene una devolución asociada
  final String? motivoDevolucion; // Motivo de la devolución, si existe
  final List<DetalleVentaModel> productos;

  VentaModel({
    this.id,
    required this.fecha,
    required this.subtotal,
    required this.descuento,
    required this.total,
    this.observacion,
    required this.nombreCliente,
    required this.formaPago,
    required this.productos,
    required this.existeDevolucion,
    this.motivoDevolucion,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'fecha': fecha.toIso8601String(),
    'subtotal': subtotal,
    'descuento': descuento,
    'total': total,
    'observacion': observacion,
    'nombre_cliente': nombreCliente,
    'forma_pago': formaPago,
    'existe_devolucion': existeDevolucion ? 1 : 0, // Convertir de bool a int
    'motivo_devolucion': motivoDevolucion,
  };

  factory VentaModel.fromMap(
    Map<String, dynamic> map,
    List<DetalleVentaModel> productos,
  ) => VentaModel(
    id: map['id'],
    fecha: DateTime.parse(map['fecha']),
    subtotal: map['subtotal'],
    descuento: map['descuento'],
    total: map['total'],
    observacion: map['observacion'],
    nombreCliente: map['nombre_cliente'],
    formaPago: map['forma_pago'],
    existeDevolucion: map['existe_devolucion'] == 1, // Convertir de int a bool
    motivoDevolucion: map['motivo_devolucion'],
    productos: productos,
  );
}
