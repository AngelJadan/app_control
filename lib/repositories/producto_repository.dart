import '../../data/database/db_helper.dart';
import '../../data/models/producto_model.dart';

class ProductoRepository {
  final dbHelper = DbHelper.instance;

  // 1. Obtener todos los productos de la base de datos
  Future<List<ProductoModel>> obtenerProductos() async {
    final db = await dbHelper.database;

    // Consultamos la tabla ordenando por nombre de forma ascendente
    final List<Map<String, dynamic>> maps = await db.query(
      'productos',
      orderBy: 'nombre ASC',
    );

    // Convertimos la lista de Maps de SQLite a una lista de objetos ProductoModel
    return List.generate(maps.length, (i) {
      return ProductoModel.fromMap(maps[i]);
    });
  }

  // 2. Crear o insertar un producto nuevo en el inventario
  Future<int> crearProducto(ProductoModel producto) async {
    final db = await dbHelper.database;

    // insert() devuelve el ID autogenerado por SQLite
    return await db.insert('productos', producto.toMap());
  }

  // 3. Aumentar el inventario (Sumar stock a un producto existente)
  Future<void> aumentarInventario(int productoId, int cantidadASumar) async {
    final db = await dbHelper.database;

    // Ejecutamos una transacción o una consulta directa que sume el stock en base al valor actual
    await db.rawUpdate(
      '''
      UPDATE productos 
      SET cantidad = cantidad + ? 
      WHERE id = ?
    ''',
      [cantidadASumar, productoId],
    );
  }

  // 4. Actualizar datos generales del producto (Nombre, Precio, Descripción)
  Future<int> actualizarProducto(ProductoModel producto) async {
    final db = await dbHelper.database;

    return await db.update(
      'productos',
      producto.toMap(),
      where: 'id = ?',
      whereArgs: [producto.id],
    );
  }

  // 5. Eliminar un producto (Opcional, SQLite validará que no tenga ventas asociadas)
  Future<int> eliminarProducto(int id) async {
    final db = await dbHelper.database;

    return await db.delete('productos', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ProductoModel>> findProductoWhereName(String nombre) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'productos',
      where: 'nombre=?',
      whereArgs: [nombre],
    );

    // Convertimos la lista de Maps de SQLite a una lista de objetos ProductoModel
    return List.generate(maps.length, (i) {
      return ProductoModel.fromMap(maps[i]);
    });
  }
}
