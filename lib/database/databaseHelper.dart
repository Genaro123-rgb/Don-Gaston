import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal() {
    init();
  }

  late Database _db;

  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'GastosHormiga.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        contrasena TEXT NOT NULL,
        limite REAL NOT NULL,
        contacto1 TEXT NOT NULL,
        contacto2 TEXT NOT NULL,
        contacto3 TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_usuario INTEGER NOT NULL,
        concepto TEXT NOT NULL,
        fecha TEXT NOT NULL,
        categoria TEXT NOT NULL,
        monto REAL NOT NULL,
        FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
      )
    ''');
  }

  Future<bool> checkUser(String username, String password) async {
    var res = await _db.query(
      'usuarios',
      where: 'nombre = ? AND contrasena = ?',
      whereArgs: [username, password],
    );
    return res.isNotEmpty;
  }

  Future<int> insertUsuario(Map<String, dynamic> usuario) async {
    return await _db.insert('usuarios', usuario);
  }

  Future<List<Map<String, dynamic>>> getUsuarios() async {
    return await _db.query('usuarios');
  }

  Future<Map<String, dynamic>> getUsuarioDetalles(String nombreUsuario) async {
    final result = await _db.query(
      'usuarios',
      where: 'nombre = ?',
      whereArgs: [nombreUsuario],
    );
    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {}; 
    }
  }

  Future<double> getTotalGastosMesActual(String nombreUsuario) async {
  await init();
  final now = DateTime.now();
  final primerDiaMes = DateTime(now.year, now.month, 1);
  final ultimoDiaMes = DateTime(now.year, now.month + 1, 0).subtract(Duration(days: 1));
  final formatoFecha = DateFormat('yyyy-MM-dd');
  String fechaInicio = formatoFecha.format(primerDiaMes);
  String fechaFin = formatoFecha.format(ultimoDiaMes);

  final result = await _db.rawQuery('''
    SELECT SUM(monto) as total FROM gastos
    WHERE fecha >= '$fechaInicio' AND fecha <= '$fechaFin'
    AND id_usuario IN (
      SELECT id FROM usuarios WHERE nombre = ?
    )
  ''', [nombreUsuario]);

  if (result.isNotEmpty && result.first["total"] != null) {
    return result.first["total"] as double;
  } else {
    return 0.0;
  }
}

  Future<int> actualizarUsuario(Map<String, dynamic> usuario) async {
  await init(); 
  return await _db.update(
    'usuarios',
    usuario,
    where: 'id = ?',
    whereArgs: [usuario['id']], // Utilizando el ID para la actualización
  );
}


  Future<List<Map<String, dynamic>>> queryAllGastos() async {
    return await _db.query('gastos');
  }

  Future<double> getLimiteGastoMensual(String nombreUsuario) async {
    final result = await _db.query(
      'usuarios',
      columns: ['limite'],
      where: 'nombre = ?',
      whereArgs: [nombreUsuario],
    );
    if (result.isNotEmpty && result.first['limite'] != null) {
      return result.first['limite'] as double;
    } else {
      return 0.0;
    }
  }

  Future<int> insertarGasto({
    required int idUsuario,
    required String concepto,
    required double monto,
    required String categoria,
    required String fecha,
  }) async {
    Map<String, dynamic> gasto = {
      'id_usuario': idUsuario,
      'concepto': concepto,
      'monto': monto,
      'categoria': categoria,
      'fecha': fecha,
    };

    return await _db.insert('gastos', gasto);
  }

  Future<int> getUsuarioId(String nombreUsuario) async {
    final result = await _db.query(
      'usuarios',
      columns: ['id'],
      where: 'nombre = ?',
      whereArgs: [nombreUsuario],
    );

    if (result.isNotEmpty) {
      return result.first['id'] as int;
    } else {
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getGastosUsuario(int idUsuario) async {
    return await _db.query(
      'gastos',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
    );
  }

  Future<void> updateGasto(Map<String, dynamic> gasto) async {
    // Implementa la lógica para actualizar el gasto en la base de datos
    // Por ejemplo:
    await _db.update('gastos', gasto, where: 'id = ?', whereArgs: [gasto['id']]);
  }

  Future<void> deleteGasto(int gastoId) async {
    // Implementa la lógica para eliminar el gasto de la base de datos
    // Por ejemplo:
    await _db.delete('gastos', where: 'id = ?', whereArgs: [gastoId]);
  }

  Future<List<String>> obtenerContactosDeUsuario(int idUsuario) async {
  List<String> contactos = [];

  try {
    final List<Map<String, dynamic>> maps = await _db.query(
      'usuarios',
      columns: ['contacto1', 'contacto2', 'contacto3'],
      where: 'id = ?',
      whereArgs: [idUsuario],
    );

    if (maps.isNotEmpty) {
      Map<String, dynamic> usuario = maps.first;
      if (usuario['contacto1'] != null) contactos.add(usuario['contacto1']);
      if (usuario['contacto2'] != null) contactos.add(usuario['contacto2']);
      if (usuario['contacto3'] != null) contactos.add(usuario['contacto3']);
    }
  } catch (e) {
    print('Error al obtener contactos: $e');
  }

  return contactos;
}

}

