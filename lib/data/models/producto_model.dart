class ProductoModel {
  final int? id;
  final String nombre;
  final double precio;
  final String? descripcion;
  final int cantidad;
  final String? tipo;

  ProductoModel({
    this.id,
    required this.nombre,
    required this.precio,
    this.descripcion,
    required this.cantidad,
    required this.tipo,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'precio': precio,
    'descripcion': descripcion,
    'cantidad': cantidad,
    'tipo': tipo,
  };

  factory ProductoModel.fromMap(Map<String, dynamic> map) => ProductoModel(
    id: map['id'],
    nombre: map['nombre'],
    precio: map['precio'],
    descripcion: map['descripcion'],
    cantidad: map['cantidad'],
    tipo: map['tipo'],
  );
}
