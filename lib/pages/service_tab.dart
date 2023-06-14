import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceTab extends StatefulWidget {
  const ServiceTab({super.key});
  @override
  _ServiceTabState createState() => _ServiceTabState();
}

class _ServiceTabState extends State<ServiceTab> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _feeController = TextEditingController();
  bool _isEnabled = false;
  late File _imageFile = Null as File;

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response =
        await http.get(Uri.parse('http://localhost/api/v1/categories'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _categories = List<String>.from(data['categories']);
      });
    } else {
      throw Exception('Failed to fetch categories');
    }
  }

  void _onImageSelected(File imageFile) {
    setState(() {
      _imageFile = imageFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _shopNameController,
                  decoration: InputDecoration(
                    labelText: 'Shop Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter shop name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _productNameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _categoryController.text,
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoryController.text = value!;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select category';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Category',
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _feeController,
                  decoration: InputDecoration(
                    labelText: 'Fee',
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter fee';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Text('Enabled'),
                    Switch(
                      value: _isEnabled,
                      onChanged: (value) {
                        setState(() {
                          _isEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                // _imageFile != Null
                //     ? Image.file(_imageFile)
                //     :
                Placeholder(
                  fallbackHeight: 200.0,
                ),
                // Image.network(
                //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSOXcDykoP41FGa5zgAD3jWB0qeCPsc1gHY9V6qGzlC&s"),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement image upload functionality
                  },
                  child: Text('Upload Image'),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // TODO: Implement product creation logic
                    }
                  },
                  child: Text('Create Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
