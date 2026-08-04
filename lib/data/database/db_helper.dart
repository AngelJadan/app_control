import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sistema_inventario.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreateDB,
      //onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON'); // Habilitar llaves foráneas
  }

  // Se ejecuta solo en instalaciones desde cero (Versión 3 directa)
  Future<void> _onCreateDB(Database db, int version) async {
    // 1. Tabla de Productos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        precio REAL NOT NULL,
        descripcion TEXT,
        cantidad INTEGER NOT NULL,
        tipo TEXT
      )
    ''');

    // 2. Tabla de Ventas
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        subtotal REAL NOT NULL,
        descuento REAL NOT NULL,
        total REAL NOT NULL,
        nombre_cliente TEXT NOT NULL,
        forma_pago TEXT NOT NULL,
        observacion TEXT,
        existe_devolucion INTEGER NOT NULL DEFAULT 0,
        motivo_devolucion TEXT DEFAULT NULL
      )
    ''');

    // 3. Tabla de Detalles de Ventas
    await db.execute('''
      CREATE TABLE detalle_ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL,
        precio_unitario REAL NOT NULL,
        FOREIGN KEY (venta_id) REFERENCES ventas(id) ON DELETE CASCADE,
        FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE RESTRICT
      )
    ''');

    // Datos iniciales de prueba
    await db.insert('productos', {
      'nombre': 'Coca-Cola 500ml',
      'precio': 1.25,
      'descripcion': 'Bebida refrescante',
      'cantidad': 50,
      'tipo': 'Bien',
    });

    await db.insert('productos', {
      'nombre': 'Chocolate Bar',
      'precio': 0.45,
      'descripcion': 'Chocolate de mesa',
      'cantidad': 30,
      'tipo': 'Bien',
    });
  }

  // Se ejecuta si el usuario ya tenía la app en v1 o v2 y actualiza a v3
  //Future<void> _onUpgradeDB(Database db, int oldVersion, int newVersion) async {
  //  if (oldVersion < 2) {
  //    // 1. Columna opcional en productos
  //    await db.execute('''
  //      ALTER TABLE productos ADD COLUMN tipo TEXT;
  //    ''');
  //  }
  //  if (oldVersion < 3 && oldVersion > 1) {
  //    // 2. Columnas obligatorias en ventas (requieren DEFAULT 0)
  //    await db.execute('''
  //      ALTER TABLE ventas ADD COLUMN subtotal REAL NOT NULL DEFAULT 0.0;
  //    ''');
  //    await db.execute('''
  //      ALTER TABLE ventas ADD COLUMN ;
  //    ''');
  //  }
  //}
}
