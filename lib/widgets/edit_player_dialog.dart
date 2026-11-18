import 'package:flutter/material.dart';

import '../models/player.dart';

class PlayerEditResult {
  final String name;
  final Color backgroundColor;
  final bool delete;

  const PlayerEditResult({
    required this.name,
    required this.backgroundColor,
    this.delete = false,
  });
}

class EditPlayerDialog extends StatefulWidget {
  final Player player;

  const EditPlayerDialog({required this.player, Key? key}) : super(key: key);

  @override
  State<EditPlayerDialog> createState() => _EditPlayerDialogState();
}

class _EditPlayerDialogState extends State<EditPlayerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late Color _selectedColor;

  static const _colorOptions = [
    Colors.red, Colors.green, Colors.blue, Colors.orange,
    Colors.purple, Colors.yellow, Colors.pink, Colors.cyan,
    Colors.brown, Colors.teal, Colors.indigo, Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.player.name);
    _selectedColor = widget.player.backgroundColor;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _finish({bool delete = false}) {
    if (!delete && !_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(PlayerEditResult(
      name: _nameController.text.trim(),
      backgroundColor: _selectedColor,
      delete: delete,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Edit Player'),
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Player',
            onPressed: () => _finish(delete: true),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a player name.'
                    : null,
              ),
              SizedBox(height: 16),
              Text('Select Background Color:'),
              SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _colorOptions.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 50,
                      height: 50,
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedColor == color
                              ? Colors.lightBlueAccent
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _finish(),
          child: Text('Save'),
        ),
      ],
    );
  }
}
