import 'package:app_control/data/models/venta_model.dart';

abstract class VentaEvent {}

class RealizarVentaEvent extends VentaEvent {
  final VentaModel venta;
  RealizarVentaEvent(this.venta);
}

class CargarReporteEvent extends VentaEvent {
  final DateTime fechaInicio;
  final DateTime fechaFin;
  CargarReporteEvent(this.fechaInicio, this.fechaFin);
}
