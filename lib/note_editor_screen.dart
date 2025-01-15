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
  List<Color> customColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.cyan,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.lime,
  ];

  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;

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

  void toggleBold() {
    setState(() {
      isBold = !isBold;
    });
  }

  void toggleItalic() {
    setState(() {
      isItalic = !isItalic;
    });
  }

  void toggleUnderline() {
    setState(() {
      isUnderlined = !isUnderlined;
    });
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
              // Kiểm tra nếu người dùng không chọn danh mục
              if (selectedCategory == null) {
                // Hiển thị Snackbar yêu cầu chọn danh mục
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vui lòng chọn danh mục!')),
                );
                return; // Không lưu nếu không chọn danh mục
              }

              // Lưu ghi chú
              Navigator.pop(context, {
                'title': _titleController.text,
                'content': _contentController.text,
                'category_id': selectedCategory,
                'color': selectedColor.value.toString(),
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView( // Bọc phần thân trong SingleChildScrollView
        child: Padding(
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
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(isBold ? Icons.format_bold : Icons.format_bold_outlined),
                    onPressed: toggleBold,
                  ),
                  IconButton(
                    icon: Icon(isItalic ? Icons.format_italic : Icons.format_italic_outlined),
                    onPressed: toggleItalic,
                  ),
                  IconButton(
                    icon: Icon(isUnderlined ? Icons.format_underline : Icons.format_underline_outlined),
                    onPressed: toggleUnderline,
                  ),
                ],
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
                              availableColors: customColors,
                              /*muc tren la bang mau khong co mau den*/
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
      ),
    );
  }
}
