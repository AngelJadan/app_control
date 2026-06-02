import '../../data/models/producto_model.dart';

abstract class ProductoState {}

class ProductoInitialState extends ProductoState {}

class ProductoLoadingState extends ProductoState {}

// Estado cuando los productos se leen con éxito de SQLite
class ProductosCargadosState extends ProductoState {
  final List<ProductoModel> productos;
  ProductosCargadosState(this.productos);
}

// Estado de éxito tras guardar, editar o eliminar
class ProductoOperacionExitoState extends ProductoState {
  final String mensaje;
  ProductoOperacionExitoState(this.mensaje);
}

class ProductoErrorState extends ProductoState {
  final String error;
  ProductoErrorState(this.error);
}
