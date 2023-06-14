import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Item {
  final String name;
  final String categoryId;

  Item({required this.name, required this.categoryId});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      categoryId: json['categoryId'],
    );
  }
}

class ServiceHome extends StatefulWidget {
  late final String url;

  // ServiceHome({required this.url});

  @override
  _ServiceHomeState createState() => _ServiceHomeState();
}

class _ServiceHomeState extends State<ServiceHome> {
  late Future<List<Category>> _categoriesFuture;
  List<Category> _categories = [];
  late Future<List<Item>> _itemsFuture;
  List<Item> _items = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _fetchCategories();
    _itemsFuture = _fetchItems();
  }

  Future<List<Category>> _fetchCategories() async {
    final response = await http.get(Uri.parse('${widget.url}/categories'));
    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);
      _categories =
          responseBody.map((category) => Category.fromJson(category)).toList();
      return _categories;
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  Future<List<Item>> _fetchItems() async {
    final response = await http.get(Uri.parse('${widget.url}/items'));
    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);
      _items = responseBody.map((item) => Item.fromJson(item)).toList();
      return _items;
    } else {
      throw Exception('Failed to fetch items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return DropdownButton<String>(
                    value: _selectedCategory,
                    items: _categories
                        .map((category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            ))
                        .toList(),
                    onChanged: (selectedCategory) {
                      if (selectedCategory != null) {
                        setState(() {
                          _selectedCategory = selectedCategory;
                          _itemsFuture =
                              _fetchItemsForCategory(selectedCategory);
                        });
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Item>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final filteredItems = _selectedCategory == null
                      ? _items
                      : _items
                          .where((item) => item.categoryId == _selectedCategory)
                          .toList();
                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredItems[index].name),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Item>> _fetchItemsForCategory(String categoryId) async {
    final response =
        await http.get(Uri.parse('${widget.url}/items?categoryId=$categoryId'));
    if (response.statusCode == 200) {
      final List<dynamic> responseBody = json.decode(response.body);
      _items = responseBody.map((item) => Item.fromJson(item)).toList();
      return _items;
    } else {
      throw Exception('Failed to fetch items for category');
    }
  }
}
