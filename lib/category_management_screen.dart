import 'package:flutter/material.dart';
import 'database_helper.dart';

class CategoryManagementScreen extends StatefulWidget {
  final VoidCallback onCategoryChanged;

  CategoryManagementScreen({required this.onCategoryChanged});

  @override
  _CategoryManagementScreenState createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    categories = await _dbHelper.getCategories();
    setState(() {});
  }

  Future<void> _addCategory(BuildContext context) async {
    final TextEditingController _controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm danh mục'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(labelText: 'Tên danh mục'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () async {
              if (_controller.text.isNotEmpty) {
                await _dbHelper.addCategory(_controller.text);
                widget.onCategoryChanged(); // Gọi callback
                await _loadCategories();
                Navigator.pop(context);
              }
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(int id) async {
    final notes = await _dbHelper.getNotes();
    final hasNotes = notes.any((note) => note['category_id'] == id);

    if (hasNotes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể xóa danh mục vì có ghi chú liên quan.')),
      );
      return;
    }

    await _dbHelper.deleteCategory(id);
    widget.onCategoryChanged(); // Gọi callback
    await _loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quản lý danh mục'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return ListTile(
            title: Text(category['name']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteCategory(category['id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCategory(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
