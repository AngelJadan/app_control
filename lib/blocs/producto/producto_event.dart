import '../../data/models/producto_model.dart';

abstract class ProductoEvent {}

// Evento para cargar la lista inicial de productos desde la base de datos
class CargarProductosEvent extends ProductoEvent {}

// Evento para registrar un producto completamente nuevo
class CrearProductoEvent extends ProductoEvent {
  final ProductoModel producto;
  CrearProductoEvent(this.producto);
}

// Evento para editar los datos o aumentar el inventario de un producto existente
class EditarProductoEvent extends ProductoEvent {
  final ProductoModel producto;
  EditarProductoEvent(this.producto);
}

// Evento para aumentar stock directamente pasando el ID y las unidades a sumar
class AumentarStockEvent extends ProductoEvent {
  final int productoId;
  final int cantidadASumar;
  AumentarStockEvent({required this.productoId, required this.cantidadASumar});
}

// Evento para eliminar un producto del inventario
class EliminarProductoEvent extends ProductoEvent {
  final int productoId;
  EliminarProductoEvent(this.productoId);
}

class FiltrarProductoNombreProductoEvent extends ProductoEvent {
  final String nombre;
  FiltrarProductoNombreProductoEvent(this.nombre);
}
