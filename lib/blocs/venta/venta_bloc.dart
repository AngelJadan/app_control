import 'package:flutter_bloc/flutter_bloc.dart';
import 'venta_event.dart';
import 'venta_state.dart';
import '../../repositories/venta_repository.dart';

class VentaBloc extends Bloc<VentaEvent, VentaState> {
  final VentaRepository repository;

  VentaBloc(this.repository) : super(VentaInitialState()) {
    on<RealizarVentaEvent>((event, emit) async {
      emit(VentaLoadingState());
      try {
        await repository.registrarVenta(event.venta);
        emit(VentaSuccessState());
      } catch (e) {
        emit(VentaErrorState("Error al procesar la venta: ${e.toString()}"));
      }
    });

    on<RealizarDevolucionVentaEvent>((event, emit) async {
      emit(VentaLoadingState());
      try {
        await repository.realizarDevolucionVenta(
          event.ventaId,
          event.motivoDevolucion,
        );
      } catch (e) {
        emit(
          VentaErrorState(
            "Error al procesar la devolución de venta: ${e.toString()}",
          ),
        );
      }
    });

    on<CargarReporteEvent>((event, emit) async {
      emit(VentaLoadingState());
      try {
        final ventas = await repository.obtenerVentasPorFecha(
          event.fechaInicio,
          event.fechaFin,
        );
        emit(ReporteCargadoState(ventas));
      } catch (e) {
        emit(VentaErrorState("Error al cargar reportes: ${e.toString()}"));
      }
    });
  }
}
