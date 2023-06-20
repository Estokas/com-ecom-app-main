import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/services/api_handler.dart';

class PartsTab extends StatefulWidget {
  const PartsTab({super.key});
  @override
  _PartsTabState createState() => _PartsTabState();
}

class _PartsTabState extends State<PartsTab> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _variantController = TextEditingController();
  bool _isEnabled = false;
  late File _imageFile = Null as File;

  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    // _fetchCategories();
  }

  Future<List<String>> _fetchCategories() async {
    final response = await ApiHandler.dio
        .get('http://localhost:8000/api/rest/v1/category/product');
    if (response.statusCode == 200) {
      // final data = jsonDecode(response.data);
      // return response.data;
      print(response.data);
      _categories = [];
      for (var item in response.data) {
        // Check if the item is a String, if so, add to stringList
        if (item.runtimeType == String) {
          _categories.add(item);
        }
      }
      print(_categories);
      return _categories;
      // setState(() {
      //   print(data.toString());
      //   // _categories = response.data.map((item) => item.toString()).toList();
      //   _categories = List<String>.from(data);
      //   // print(_categories);
      //   // final List<dynamic> data = json.decode(response.data);
      //   // _categories = data.map((e) => e.toString()).toList();
      //   // return _categories;
      // });
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
    return FutureBuilder<List<String>>(
        future: _fetchCategories(),
        builder: (context, snapshot) {
          // print(snapshot);
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Still fetching data from the server
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Error fetching data from the server
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            _categories = snapshot.data ?? [];
            _categoryController.text = _categories[0];
            _isEnabled = false;
            print(_categories);
            return SingleChildScrollView(
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
                        // value: _categoryController.text == null
                        //     ? _categoryController.text
                        //     : _categories
                        //         .where((i) => i == _categoryController.text)
                        //         .first,
                        value: _categoryController.text,
                        isDense: true,
                        items: _categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          _categoryController.text = value!;
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
                        controller: _priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          prefixText: '\₱',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter price';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _variantController,
                        decoration: InputDecoration(
                          labelText: 'Variant',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter variant';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Text('Enabled'),
                          Switch(
                            value: _isEnabled ?? false,
                            onChanged: (value) {
                              _isEnabled = value;
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
                          print("onpressed");
                          // print(_imageFile ?? "");
                          // if (_formKey.currentState!.validate()) {
                          ApiHandler().addProduct({
                            "shop": _shopNameController.text,
                            "name": _productNameController.text,
                            "description": _descriptionController.text,
                            "variant": _variantController.text,
                            "price": _priceController.text,
                            "category": _categoryController.text,
                            "enable": _isEnabled,
                            // "image": _imageFile ?? "",
                          }).then((value) => {
                                if (value) {_showMyDialog(context)}
                              });
                          // TODO: Implement product creation logic
                          // }
                        },
                        child: Text('Create Product'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}

Future<void> _showMyDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Registering successful!'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
