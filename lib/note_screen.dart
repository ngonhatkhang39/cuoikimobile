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

  Future<void> _loadTrashNotes() async {
    notes = await _dbHelper.getTrashNotes();
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Hủy')),
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

  Future<void> _deleteNoteToTrash(int id) async {
    await _dbHelper.deleteNoteToTrash(id);
    await _loadData();
  }

  Future<void> _deleteNotePermanently(int id) async {
    await _dbHelper.deleteNotePermanently(id);
    await _loadTrashNotes();
  }

  Future<void> _restoreNote(int id, int categoryId) async {
    await _dbHelper.restoreNote(id, categoryId);
    await _loadTrashNotes();
  }

  @override
  Widget build(BuildContext context) {
    // Lọc ghi chú theo danh mục và tìm kiếm
    List<Map<String, dynamic>> filteredNotes = notes.where((note) {
      bool matchesCategory = true;
      bool matchesSearch = note['title'].toLowerCase().contains(searchText.toLowerCase());

      if (selectedCategory != null && selectedCategory != 'trash') {
        matchesCategory = note['category_id'].toString() == selectedCategory;
      }

      return matchesCategory && matchesSearch;
    }).toList();

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
            SizedBox(
              height: 75, // Đặt chiều cao theo mong muốn
              child: DrawerHeader(
                child: Text(
                  'One Note',
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5E8A), Color(0xFF8A2BE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                margin: EdgeInsets.zero,
              ),
            ),
            ListTile(
              leading: Icon(Icons.all_inclusive),
              title: Text('Tất cả ghi chú'),
              onTap: () {
                setState(() {
                  selectedCategory = null;
                });
                Navigator.pop(context);
                _loadData();
              },
            ),

            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Thùng rác'),
              onTap: () {
                setState(() {
                  selectedCategory = 'trash';
                });
                Navigator.pop(context);
                _loadTrashNotes();
              },
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
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color(0xFFFF5E8A), // Màu viền hồng
                    width: 2.0, // Độ dày viền
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color(0xFFFF5E8A), // Màu viền khi không focus (hồng)
                    width: 2.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Color(0xFF8A2BE2), // Màu viền khi focus (tím)
                    width: 2.0,
                  ),
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
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                String categoryName = 'Không xác định'; // Mặc định
                try {
                  categoryName = categories.firstWhere((cat) => cat['id'] == note['category_id'])['name'];
                } catch (e) {
                  // Xử lý nếu không tìm thấy danh mục
                }

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
                          children: selectedCategory == 'trash'
                              ? [
                            IconButton(
                              icon: Icon(Icons.restore, color: Colors.white,),
                              onPressed: () => _restoreNote(note['id'], note['category_id']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.white),
                              onPressed: () => _deleteNotePermanently(note['id']),
                            ),
                          ]
                              : [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _addOrEditNote(note: note),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.white),
                              onPressed: () => _deleteNoteToTrash(note['id']),
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
      floatingActionButton: Container(
        height: 56, // Kích thước chiều cao của FAB
        width: 56, // Kích thước chiều rộng của FAB
        decoration: BoxDecoration(
          shape: BoxShape.circle, // Đảm bảo FAB có hình tròn
          gradient: LinearGradient(
            colors: [Color(0xFFFF5E8A), Color(0xFF8A2BE2)], // Gradient hồng -> tím
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FloatingActionButton(
          onPressed: () => _addOrEditNote(),
          backgroundColor: Colors.transparent, // Đặt màu nền trong suốt
          elevation: 0, // Loại bỏ bóng (nếu muốn)
          child: Icon(Icons.add, color: Colors.white), // Icon màu trắng
        ),
      ),
    );
  }
}
