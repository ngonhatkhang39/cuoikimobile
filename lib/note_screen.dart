import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'note_editor_screen.dart';
import 'note_detail_screen.dart';
import 'category_management_screen.dart';
import '../main.dart'; // Import để truy cập isDarkMode

class NoteScreen extends StatefulWidget {
  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> notes = [];
  String? selectedCategory;
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    categories = await _dbHelper.getCategories();
    notes = await _dbHelper.getNotes();
    setState(() {});
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
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Hủy')),
          TextButton(
            onPressed: () async {
              await _dbHelper.addCategory(_controller.text);
              await _loadData();
              Navigator.pop(context);
            },
            child: Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrEditNote({Map<String, dynamic>? note}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
          categories: categories,
        ),
      ),
    );

    if (result != null) {
      if (note == null) {
        await _dbHelper.addNote(result);
      } else {
        await _dbHelper.updateNote(note['id'], result);
      }
      await _loadData();
    }
  }

  Future<void> _deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chú'),
        actions: [
          IconButton(
            icon: Icon(NoteApp.isDarkMode.value
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () {
              setState(() {
                NoteApp.isDarkMode.value = !NoteApp.isDarkMode.value;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Danh mục'),
              decoration: BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: Icon(Icons.manage_accounts),
              title: Text('Quản lý danh mục'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryManagementScreen(
                      onCategoryChanged: _loadCategories,
                    ),
                  ),
                );
                _loadCategories();
              },
            ),
            ListTile(
              leading: Icon(Icons.all_inclusive),
              title: Text('Tất cả ghi chú'),
              onTap: () {
                setState(() {
                  selectedCategory = null;
                });
                Navigator.pop(context);
              },
            ),
            ...categories.map((category) {
              return ListTile(
                title: Text(category['name']),
                onTap: () {
                  setState(() {
                    selectedCategory = category['id'].toString();
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Thêm danh mục'),
              onTap: () => _addCategory(context),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm kiếm ghi chú...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 1,
              ),
              itemCount: notes
                  .where((note) =>
              (selectedCategory == null ||
                  note['category_id'].toString() == selectedCategory) &&
                  (searchText.isEmpty ||
                      note['title']
                          .toLowerCase()
                          .contains(searchText.toLowerCase())))
                  .length,
              itemBuilder: (context, index) {
                final filteredNotes = notes
                    .where((note) =>
                (selectedCategory == null ||
                    note['category_id'].toString() ==
                        selectedCategory) &&
                    (searchText.isEmpty ||
                        note['title']
                            .toLowerCase()
                            .contains(searchText.toLowerCase())))
                    .toList();
                final note = filteredNotes[index];
                final categoryName = categories.firstWhere((cat) =>
                cat['id'].toString() == note['category_id'].toString())['name'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NoteDetailScreen(
                          title: note['title'],
                          content: note['content'] ?? '',
                          categoryName: categoryName,
                          color: Color(int.parse(note['color'])),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(int.parse(note['color'])),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoryName,
                          style: TextStyle(fontSize: 12, color: Colors.black),
                        ),
                        SizedBox(height: 4),
                        Text(
                          note['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _addOrEditNote(note: note),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () async {
                                await _deleteNote(note['id']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditNote(),
      ),
    );
  }
}
