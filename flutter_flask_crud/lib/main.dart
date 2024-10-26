import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List items = [];

  final String apiUrl = 'http://127.0.0.1:5000';

  // Fetch items from Flask
  Future<void> fetchItems() async {
    final response = await http.get(Uri.parse('$apiUrl/get_items'));
    if (response.statusCode == 200) {
      setState(() {
        items = json.decode(response.body);
      });
    } else {
      showMessage('Failed to fetch items.');
    }
  }

  // Add item to Flask
  Future<void> addItem(String name, String description) async {
    final response = await http.post(
      Uri.parse('$apiUrl/add_item'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'description': description}),
    );
    if (response.statusCode == 201) {
      fetchItems();
      nameController.clear();
      descriptionController.clear();
      showMessage('Item added successfully.');
    } else {
      showMessage('Failed to add item.');
    }
  }

  // Delete item from Flask
  Future<void> deleteItem(int id) async {
    final response = await http.delete(Uri.parse('$apiUrl/delete_item/$id'));
    if (response.statusCode == 200) {
      fetchItems();
      showMessage('Item deleted successfully.');
    } else {
      showMessage('Failed to delete item.');
    }
  }

  // Update item in Flask
  Future<void> updateItem(int id, String name, String description) async {
    final response = await http.put(
      Uri.parse('$apiUrl/update_item/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'description': description}),
    );
    if (response.statusCode == 200) {
      fetchItems();
      showMessage('Item updated successfully.');
    } else {
      showMessage('Failed to update item.');
    }
  }

  // Show messages
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Show dialog to edit item
  void showEditDialog(int id, String currentName, String currentDescription) {
    nameController.text = currentName;
    descriptionController.text = currentDescription;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              updateItem(id, nameController.text, descriptionController.text);
              Navigator.of(context).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Item Manager')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Item Name'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                addItem(nameController.text, descriptionController.text),
            child: Text('Add Item'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text(item['description']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => showEditDialog(
                            item['id'], item['name'], item['description']),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteItem(item['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
