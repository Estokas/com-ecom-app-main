import 'dart:convert';
// import 'dart:ffi';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/main.dart';
import 'package:mobile_app/routes/router.gr.dart';

const String url = "http://localhost:8000/";

class ApiHandler {
  static const baseURl = "http://localhost:8000/";

  final storage = const FlutterSecureStorage();
  final router = getIt<AppRouter>();

  static final Dio dio = Dio(BaseOptions(
      baseUrl: baseURl,
      receiveTimeout: 3000,
      connectTimeout: 5000,
      contentType: "application/json"));

  void unauthorized(int status) {
    if (status == 401) {
      router.replaceAll([const LoginRoute()]);
    }
  }

  Future<Map<String, dynamic>> login(
      {required String email,
      required String password,
      required String role}) async {
    try {
      final response = await dio.post("/api/rest/v1/auth/login", data: {
        "email": email,
        "password": password,
        "role": role,
      });

      if (response.statusCode == 200) {
        final jwt = response.data['token'];
        dio.options.headers['authorization'] = "Bearer $jwt";

        return {"success": true, "role": response.data['role']};
      }
    } catch (e) {
      return {"success": false, "role": ""};
    }
    return {"success": false, "role": ""};
  }

  // Future<String?> refreshToken() async {
  //   try {
  //     final response = await dio.post("/api/rest/v1/auth/refresh-token");
  //
  //     if (response.statusCode == 200) {
  //       final jwt = response.data['token'];
  //       dio.options.headers['Cookie'] = "Bearer $jwt";
  //       return jwt;
  //     }
  //   } catch(e) {
  //     print(e);
  //   }
  //   return null;
  // }

  Future<dynamic> getSession() async {
    try {
      final response = await dio.get("/api/rest/v1/auth/session");
      if (response.statusCode == 200) {
        final data = response.data;
        return data;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    return null;
  }

  // Future<bool> login(username, password) async {
  //   if (username != "" && password != "") {
  //     //Response response = await dio.post("/api/accounts/login/",
  //     //    data: {"username": username, "password": password});
  //
  //     http.Response response = await http.post(
  //         Uri.parse("${url}api/accounts/login/"),
  //         body: <String, String>{"username": username, "password": password});
  //
  //     // final response = await http.post(Uri.parse("${url}api/accounts/login/"),
  //     //     headers: {"Content-Type": "application/json"},
  //     //     body: jsonEncode({"username": username, "password": password}));
  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('token', jsonResponse['token']);
  //       // await storage.write(
  //       //   key: 'token',
  //       //   value: json.decode(response.body)['token'],
  //       //   // value:
  //       //   //     "c962cd90e64b106079bdb2f482be24e851e2ec8d3261011f948db60845efffb5",
  //       // );
  //       return true;
  //     }
  //   }
  //   return false;
  // }

  Future<bool> logout() async {
    try {
      final response = await dio.post("/api/rest/v1/auth/logout");

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }

  Future<bool> register(customer) async {
    try {
      final response = await dio.post("/api/rest/v1/add/user", data: {
        "firstName": customer['firstName'],
        "lastName": customer['lastName'],
        "email": customer['email'],
        "password": customer['password'],
        "role": customer["role"],
        "enable": true,
      });

      if (response.statusCode == 200) {
        final jwt = response.data['token'];
        dio.options.headers['authorization'] = "Bearer $jwt";

        return true;
      }
    } catch (e) {
      print(e);
      return false;
    }
    return false;
  }

  Future<bool> authorize() async {
    // String? authToken = await storage.read(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    http.Response response = await http.get(
      Uri.parse('${url}api/sales/customerauthorize'),
      headers: {
        'Authorization': 'Token $authToken',
      },
    );
    unauthorized(response.statusCode);
    return response.statusCode == 200;
  }

  Future<List> productListFetch() async {
    try {
      final response = await dio.get('/api/rest/v1/products');
      print(response.data.runtimeType);
      // unauthorized(response.statusCode);

      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> addProduct(product) async {
    try {
      print(product);
      final response = await dio.post("/api/rest/v1/add/product", data: {
        "shop": product["shop"],
        "name": product["name"],
        "description": product["description"],
        "price": product["price"],
        "variant": product["variant"],
        "category": product["category"],
        "enable": product["enable"],
        "image": product["image"],
      });

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    return false;
  }

  Future<bool> addService(service) async {
    try {
      print(service);
      final response = await dio.post("/api/rest/v1/add/service", data: {
        "shop": service["shop"],
        "name": service["name"],
        "description": service["description"],
        "fee": service["fee"],
        // "variant": service["variant"],
        "category": service["category"],
        "enable": service["enable"],
        "image": service["image"],
      });

      if (response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    return false;
  }

  Future<Map> productDetailFetch(int productId) async {
    // String? authToken = await storage.read(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    http.Response response = await http.get(
      Uri.parse('${url}api/catalog/productdetail/$productId/'),
      headers: {'Authorization': 'Token $authToken'},
    );

    unauthorized(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  }

  Future<List> serviceListFetch() async {
    try {
      final response = await dio.get('/api/rest/v1/services');

      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List> orderListFetch(String status) async {
    try {
      final response = await dio
          .get('/api/rest/v1/orders', queryParameters: {'status': status});

      if (response.statusCode == 200) {
        return response.data;
      }
      return [];
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> createOrder(dynamic order) async {
    try {
      await dio.post('/api/rest/v1/add/order', data: order);
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Map> serviceDetailFetch(int serviceId) async {
    // String? authToken = await storage.read(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    http.Response response = await http.get(
      Uri.parse('${url}api/sales/servicedetail/$serviceId/'),
      headers: {'Authorization': 'Token $authToken'},
    );

    unauthorized(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  }

  Future<Map> customerDetailFetch() async {
    // String? authToken = await storage.read(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    http.Response response = await http.get(
      Uri.parse('${url}api/sales/customerdetail/'),
      headers: {'Authorization': 'Token $authToken'},
    );

    unauthorized(response.statusCode);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {};
  }

  Future<bool> productOrder(int productId) async {
    // String? authToken = await storage.read(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    http.Response response = await http.post(
      Uri.parse('${url}api/sales/productorder/'),
      headers: {'Authorization': 'Token $authToken'},
      body: {'product_id': '$productId'},
    );

    unauthorized(response.statusCode);

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }

  Future<bool> serviceBook(int serviceId, int technicianId) async {
    // String? authToken = await storage.read(key: 'token');
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');
    http.Response response = await http.post(
      Uri.parse('${url}api/sales/servicebook/'),
      headers: {'Authorization': 'Token $authToken'},
      body: {
        'product_id': '$serviceId',
        'technician_id': '$technicianId',
      },
    );

    unauthorized(response.statusCode);

    if (response.statusCode == 201) {
      return true;
    }

    return false;
  }
}
