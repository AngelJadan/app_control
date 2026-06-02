import 'package:app_control/data/models/venta_model.dart';

abstract class VentaState {}

class VentaInitialState extends VentaState {}

class VentaLoadingState extends VentaState {}

class VentaSuccessState extends VentaState {}

class ReporteCargadoState extends VentaState {
  final List<VentaModel> ventas;
  ReporteCargadoState(this.ventas);
}

class VentaErrorState extends VentaState {
  final String error;
  VentaErrorState(this.error);
}
