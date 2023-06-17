import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/pages/cart_page.dart';
import 'package:mobile_app/pages/login_page.dart';
import 'package:mobile_app/pages/parts_tab.dart';
import 'package:mobile_app/pages/service_tab.dart';
import 'package:mobile_app/routes/router.gr.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../providers/cart.dart';
import '../services/api_handler.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Shop {
  final int id;
  final String name;

  Shop({required this.id, required this.name});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Item {
  final String id;
  final String name;
  final String imageUrl;
  final int price;
  final String description;

  Item(
      {required this.id,
      required this.name,
      required this.imageUrl,
      required this.price,
      required this.description});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['title'],
      imageUrl: json['image_url'],
      price: json['price'].toDouble(),
      description: json['description'],
    );
  }
}

class HomePageCustomer extends StatefulWidget {
  @override
  _HomePageCustomerState createState() => _HomePageCustomerState();
}

class _HomePageCustomerState extends State<HomePageCustomer> {
  List<String> _shops = [
    "123"
    // Shop(id: 1, name: 'shop1'),
    // Shop(id: 2, name: 'shop2'),
    // Shop(id: 3, name: 'shop3'),
    // Shop(id: 4, name: 'shop4'),
  ];
  late String _selectedShop = _shops[0];
  List<Item> _items = [
    Item(
        id: '1',
        name: "title1",
        imageUrl: "imageUrl1",
        price: 1,
        description: 'description1'),
    // Item(
    //     id: 2,
    //     name: "title2",
    //     imageUrl: "imageUrl2",
    //     price: 2,
    //     description: 'description2'),
    // Item(
    //     id: 3,
    //     name: "title3",
    //     imageUrl: "imageUrl3",
    //     price: 3,
    //     description: 'description3'),
    // Item(
    //     id: 4,
    //     name: "title4",
    //     imageUrl: "imageUrl4",
    //     price: 4,
    //     description: 'description4'),
    // Item(
    //     id: 5,
    //     name: "title5",
    //     imageUrl: "imageUrl5",
    //     price: 5,
    //     description: 'description5'),
    // Item(
    //     id: 6,
    //     name: "title6",
    //     imageUrl: "imageUrl6",
    //     price: 6,
    //     description: 'description6'),
    // Item(
    //     id: 7,
    //     name: "title7",
    //     imageUrl: "imageUrl7",
    //     price: 7,
    //     description: 'description7'),
  ];

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    final response =
        await ApiHandler.dio.get('http://localhost:8000/api/rest/v1/shops');
    // final data = jsonDecode(response.data);
    print(response.data);
    List<String> shops = [];
    for (var shop in response.data) {
      // Check if the item is a String, if so, add to stringList
      if (shop.runtimeType == String) {
        shops.add(shop);
      }
    }
    setState(() {
      _shops = shops;
      _selectedShop = _shops[0];
      _fetchItems();
    });
  }

  Future<void> _fetchItems() async {
    final response = await ApiHandler.dio
        .get("http://localhost:8000/api/rest/v1/shops/${_selectedShop}");
    print(response.data);
    List<Item> items = [];
    for (var i in response.data) {
      if (!i.containsKey('image')) {
        i['image'] = {"path": ''};
      }
      try {
        items.add(Item(
          id: i['_id'],
          description: i['description'],
          imageUrl: i['image']['path'],
          name: i['name'],
          price: i['price'],
        ));
      } catch (e) {
        items.add(Item(
          id: i['_id'],
          description: i['description'],
          imageUrl: i['image']['path'],
          name: i['name'],
          price: i['fee'],
        ));
      }
    }
    setState(() {
      _items = items;
    });
    print(_items[0]);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider'),
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            context.router.push(const AccountRoute());
          },
          icon: const Icon(Icons.menu),
        ),
        actions: <Widget>[
          badges.Badge(
            badgeContent: Consumer<CartProvider>(
              builder: (context, value, child) {
                return Text(
                  value.getCounter().toString(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
            position: badges.BadgePosition.custom(start: 30, bottom: 30),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CartScreen()));
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ),
          const SizedBox(
            width: 20.0,
          ),
        ],
      ),
      body:
          // FutureBuilder<List<String>>(
          //   future: _fetchShops(),
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return CircularProgressIndicator();
          //     }
          //     _fetchItems();
          //     return
          Column(
        children: [
          DropdownButton<String>(
            value: null,
            items: _shops.map((String shop) {
              return DropdownMenuItem<String>(
                value: shop,
                child: Text(
                  shop,
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.red,
                    decorationStyle: TextDecorationStyle.dashed,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? shop) {
              setState(() {
                _selectedShop = shop ?? '';
                _fetchItems();
              });
            },
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: _items.length,
              itemBuilder: (BuildContext context, int index) {
                Item item;
                try {
                  item = _items[index];
                  print(item);
                } catch (e) {
                  return CircularProgressIndicator();
                }
                return Card(
                  child: Column(
                    children: [
                      Image.network('${ApiHandler.baseURl}${item.imageUrl}'),
                      Text(item.name),
                      Text('\$${item.price}'),
                      Text(item.description),
                      ElevatedButton(
                        child: Text('Add to cart'),
                        onPressed: () {
                          // Add the item to the cart
                          cart.addItem({
                            "id": item.id,
                            "imageUrl": item.imageUrl,
                            "name": item.name,
                            "price": item.price,
                            "description": item.description
                          }, 'product');
                        },
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
    // },
  }
}
