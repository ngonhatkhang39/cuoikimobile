import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NoteEditorScreen extends StatefulWidget {
  final Map<String, dynamic>? note;
  final List<Map<String, dynamic>> categories;

  NoteEditorScreen({this.note, required this.categories});

  @override
  _NoteEditorScreenState createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? selectedCategory;
  Color selectedColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'];
      _contentController.text = widget.note!['content'];
      selectedCategory = widget.note!['category_id'].toString();
      selectedColor = Color(int.parse(widget.note!['color']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Thêm Ghi Chú' : 'Chỉnh Sửa Ghi Chú'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, {
                'title': _titleController.text,
                'content': _contentController.text,
                'category_id': selectedCategory,
                'color': selectedColor.value.toString(),
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Tiêu đề'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'Nội dung'),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              items: widget.categories.map((category) {
                return DropdownMenuItem(
                  value: category['id'].toString(),
                  child: Text(category['name']),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Danh mục'),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Màu:'),
                SizedBox(width: 10),
                GestureDetector(
                  onTap: () async {
                    Color? color = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Chọn màu'),
                        content: SingleChildScrollView(
                          child: BlockPicker(
                            pickerColor: selectedColor,
                            onColorChanged: (color) => Navigator.pop(context, color),
                          ),
                        ),
                      ),
                    );
                    if (color != null) {
                      setState(() {
                        selectedColor = color;
                      });
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
