import 'package:sqflite/sqflite.dart';

import '../../data/database/db_helper.dart';
import '../../data/models/venta_model.dart';
import '../../data/models/detalle_venta_model.dart';

class VentaRepository {
  final dbHelper = DbHelper.instance;

  Future<void> registrarVenta(VentaModel venta) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      // 1. Insertar la venta principal
      final ventaId = await txn.insert('ventas', venta.toMap());

      // 2. Procesar cada producto del carrito
      for (var item in venta.productos) {
        // Insertar el detalle de venta
        await txn.insert('detalle_ventas', item.toMap(ventaId));

        // Restar del inventario actual
        await txn.execute(
          '''
          UPDATE productos 
          SET cantidad = cantidad - ? 
          WHERE id = ?
        ''',
          [item.cantidad, item.productoId],
        );
      }
    });
  }

  Future<void> realizarDevolucionVenta(
    int ventaId,
    String motivoDevolucion,
  ) async {
    print('Iniciando transacción para devolución de venta con ID: $ventaId');

    final db = await dbHelper.database;
    await db.transaction((txn) async {
      // 1. Insertar la devolución como una nueva venta con un flag especial
      await txn.update(
        'ventas',
        {'existe_devolucion': 1, 'motivo_devolucion': motivoDevolucion},
        where: 'id = ?',
        whereArgs: [ventaId],
      );
      print('Marca de devolución actualizada para la venta ID: $ventaId');
      for (var detalle in await _obtenerDetallesVenta(ventaId, txn)) {
        // 2. Devolver los productos al inventario
        await txn.execute(
          '''
          UPDATE productos 
          SET cantidad = cantidad + ? 
          WHERE id = ?
        ''',
          [detalle!.cantidad, detalle.productoId],
        );
      }
      print('Productos devueltos al inventario para la venta ID: $ventaId');
    });
  }

  Future<List<VentaModel>> obtenerVentasPorFecha(
    DateTime inicio,
    DateTime fin,
  ) async {
    final db = await dbHelper.database;

    // Usar date() de SQLite para comparar solo la parte de la fecha (YYYY-MM-DD)
    // Las fechas ISO8601 se pueden comparar directamente como strings
    final String strInicio = inicio.toIso8601String().substring(0, 10);
    final String strFin = fin.toIso8601String().substring(0, 10);

    final List<Map<String, dynamic>> ventasMap = await db.rawQuery(
      '''
      SELECT * FROM ventas 
      WHERE DATE(fecha) BETWEEN ? AND ?
      ORDER BY fecha DESC
      ''',
      [strInicio, strFin],
    );

    List<VentaModel> ventas = [];

    for (var v in ventasMap) {
      // Obtener detalles de cada venta con JOIN para traer el nombre del producto
      final List<Map<String, dynamic>> detallesMap = await db.rawQuery(
        '''
        SELECT dv.*, p.nombre as nombre_producto 
        FROM detalle_ventas dv
        JOIN productos p ON dv.producto_id = p.id
        WHERE dv.venta_id = ?
      ''',
        [v['id']],
      );

      List<DetalleVentaModel> detalles =
          detallesMap.map((d) => DetalleVentaModel.fromMap(d)).toList();
      ventas.add(VentaModel.fromMap(v, detalles));
    }

    return ventas;
  }

  Future<Iterable<DetalleVentaModel?>> _obtenerDetallesVenta(
    int ventaId,
    Transaction txn,
  ) async {
    final List<Map<String, dynamic>> detallesMap = await txn.query(
      'detalle_ventas',
      where: 'venta_id = ?',
      whereArgs: [ventaId],
    );

    return detallesMap.map((d) => DetalleVentaModel.fromMap(d));
  }
}
