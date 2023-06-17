// import 'dart:ffi';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/routes/router.gr.dart';
import 'package:mobile_app/services/api_handler.dart';
import 'package:mobile_app/pages/home_page_customer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginState();
}

class _LoginState extends State<LoginPage> {
  final TextEditingController _username = TextEditingController(),
      _password = TextEditingController();
  bool _isProvider = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 50),
          constraints:
              BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(
                Icons.computer,
                size: 50,
              ),
              const Text(
                'Login',
                style: TextStyle(fontSize: 25),
              ),
              TextField(
                controller: _username,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
              CheckboxListTile(
                title: Text("I'm a service provider"),
                value: _isProvider,
                onChanged: (bool? value) {
                  setState(() {
                    _isProvider = value ?? false;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  ApiHandler()
                      .login(
                          email: _username.text,
                          password: _password.text,
                          role: _isProvider == false ? "USER" : "PROVIDER")
                      .then((value) {
                    if (value['success']) {
                      if (value['role'] == "USER" && _isProvider == false) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePageCustomer()));
                      }
                      if (value['role'] == "PROVIDER" && _isProvider == true) {
                        context.router.replace(const HomeRoute());
                      }
                    }
                  });
                },
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  context.router.push(const RegisterRoute());
                },
                child: const Text(
                  'Register instead',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
