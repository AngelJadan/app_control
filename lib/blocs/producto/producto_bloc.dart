import 'package:flutter_bloc/flutter_bloc.dart';
import 'producto_event.dart';
import 'producto_state.dart';
import '../../repositories/producto_repository.dart';

class ProductoBloc extends Bloc<ProductoEvent, ProductoState> {
  final ProductoRepository repository;

  ProductoBloc(this.repository) : super(ProductoInitialState()) {
    // 1. Manejador para Listar Productos
    on<CargarProductosEvent>((event, emit) async {
      emit(ProductoLoadingState());
      try {
        final productos = await repository.obtenerProductos();
        emit(ProductosCargadosState(productos));
      } catch (e) {
        emit(ProductoErrorState("Error al cargar inventario: ${e.toString()}"));
      }
    });

    // 2. Manejador para Crear un Producto
    on<CrearProductoEvent>((event, emit) async {
      emit(ProductoLoadingState());
      try {
        await repository.crearProducto(event.producto);
        emit(ProductoOperacionExitoState("Producto creado correctamente"));
        // Automáticamente recargamos la lista actualizada
        final productos = await repository.obtenerProductos();
        emit(ProductosCargadosState(productos));
      } catch (e) {
        emit(ProductoErrorState("Error al crear producto: ${e.toString()}"));
      }
    });

    // 3. Manejador para Editar un Producto
    on<EditarProductoEvent>((event, emit) async {
      emit(ProductoLoadingState());
      try {
        await repository.actualizarProducto(event.producto);
        emit(ProductoOperacionExitoState("Producto actualizado con éxito"));
        final productos = await repository.obtenerProductos();
        emit(ProductosCargadosState(productos));
      } catch (e) {
        emit(ProductoErrorState("Error al editar producto: ${e.toString()}"));
      }
    });

    // 4. Manejador para Aumentar Stock Directamente
    on<AumentarStockEvent>((event, emit) async {
      emit(ProductoLoadingState());
      try {
        await repository.aumentarInventario(
          event.productoId,
          event.cantidadASumar,
        );
        emit(ProductoOperacionExitoState("Inventario aumentado con éxito"));
        final productos = await repository.obtenerProductos();
        emit(ProductosCargadosState(productos));
      } catch (e) {
        emit(
          ProductoErrorState("Error al aumentar inventario: ${e.toString()}"),
        );
      }
    });

    // 5. Manejador para Eliminar un Producto
    on<EliminarProductoEvent>((event, emit) async {
      emit(ProductoLoadingState());
      try {
        await repository.eliminarProducto(event.productoId);
        emit(ProductoOperacionExitoState("Producto eliminado permanentemente"));
        final productos = await repository.obtenerProductos();
        emit(ProductosCargadosState(productos));
      } catch (e) {
        // SQLite arrojará un error si el producto ya está enlazado a una venta vieja (por integridad referencial)
        emit(
          ProductoErrorState(
            "No se puede eliminar el producto porque tiene ventas asociadas en el historial.",
          ),
        );
      }
    });
  }
}
