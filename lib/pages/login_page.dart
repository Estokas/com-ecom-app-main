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
  bool _isCustomer = false;

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
                value: _isCustomer,
                onChanged: (bool? value) {
                  setState(() {
                    _isCustomer = value ?? false;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  ApiHandler()
                      .login(
                          email: _username.text,
                          password: _password.text,
                          role: _isCustomer == false ? "USER" : "PROVIDER")
                      .then((value) {
                    if (value['success']) {
                      if (_isCustomer == false && value['role'] == 'USER') {
                        context.router.replace(const HomeRoute());
                      }
                      if (_isCustomer == true && value['role'] == 'PROVIDER') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePageCustomer()));
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
