import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'mysj_nextgen.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // User Table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        fullName TEXT,
        icNumber TEXT,
        phone TEXT,
        securityQuestion TEXT,
        securityAnswer TEXT
      )
    ''');

    // Vitals Table
    await db.execute('''
      CREATE TABLE vitals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER,
        type TEXT,
        value TEXT,
        timestamp TEXT
      )
    ''');
  }

  // Auth Methods
  Future<int> registerUser({
    required String username,
    required String password,
    required String fullName,
    required String icNumber,
    required String phone,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final db = await database;
    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
        'fullName': fullName,
        'icNumber': icNumber,
        'phone': phone,
        'securityQuestion': securityQuestion,
        'securityAnswer': securityAnswer,
      });
    } catch (e) {
      return -1; // Duplicate or error
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<bool> resetPassword(String username, String answer, String newPassword) async {
    final db = await database;
    final user = await getUser(username);
    if (user == null) return false;

    if (user['securityAnswer'] == answer) {
      await db.update(
        'users',
        {'password': newPassword},
        where: 'username = ?',
        whereArgs: [username],
      );
      return true;
    }
    return false;
  }
}
