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
      version: 2,
      onConfigure: _onConfigure,
      onCreate: (db, version) async {
        // El onCreate se mantiene igual pero YA con el campo nuevo por si un usuario instala la app desde cero
        await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        precio REAL NOT NULL,
        descripcion TEXT,
        cantidad INTEGER NOT NULL,
        tipo TEXT -- Añadido aquí para nuevos usuarios
      )
    ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // 2. Este bloque se ejecutará SOLO en los usuarios que ya tenían la app instalada
        if (oldVersion < 2) {
          // Agrega la columna 'tipo' a la tabla existente
          await db.execute('''
          ALTER TABLE productos ADD COLUMN tipo TEXT;
        ''');
        }
      },
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON'); // Habilitar llaves foráneas
  }

  Future _createDB(Database db, int version) async {
    // Tabla de Productos
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        precio REAL NOT NULL,
        descripcion TEXT,
        cantidad INTEGER NOT NULL
      )
    ''');

    // Tabla de Ventas
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        total REAL NOT NULL,
        nombre_cliente TEXT NOT NULL,
        forma_pago TEXT NOT NULL,
        observacion TEXT
      )
    ''');

    // Tabla de Detalles de Ventas (Relación muchos-a-muchos)
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

    // Insertar productos de prueba
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
}
