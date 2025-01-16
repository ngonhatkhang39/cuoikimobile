import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  Future<void> deleteNoteToTrash(int id) async {
    final db = await database;

    await db.update(
      'notes', // Tên bảng
      {'is_deleted': 1}, // Cập nhật trường 'is_deleted' thành 1
      where: 'id = ?', // Điều kiện lọc ghi chú theo id
      whereArgs: [id], // Giá trị id
    );
  }
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'note_app.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            content TEXT,
            color TEXT,
            category_id INTEGER,
            is_deleted INTEGER DEFAULT 0,
            FOREIGN KEY (category_id) REFERENCES categories (id)
          )
        ''');

        /*await db.insert('categories', {'name': 'Thùng rác'});*/
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE notes ADD COLUMN is_deleted INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return await db.query('categories');
  }

  Future<int> addCategory(String name) async {
    final db = await database;
    return await db.insert('categories', {'name': name});
  }

  Future<int> updateCategory(int id, Map<String, dynamic> category) async {
    final db = await database;
    return await db.update('categories', category, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', where: 'is_deleted = 0');
  }

  Future<List<Map<String, dynamic>>> getTrashNotes() async {
    final db = await database;
    return await db.query('notes', where: 'is_deleted = 1');
  }

  Future<int> addNote(Map<String, dynamic> note) async {
    final db = await database;
    return await db.insert('notes', note);
  }

  Future<int> updateNote(int id, Map<String, dynamic> note) async {
    final db = await database;
    return await db.update('notes', note, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.update('notes', {'is_deleted': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> restoreNote(int id, int categoryId) async {
    final db = await database;
    return await db.update('notes', {
      'is_deleted': 0,
      'category_id': categoryId,
    }, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteNotePermanently(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }
}
