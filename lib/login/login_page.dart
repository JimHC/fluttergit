import 'package:CampoyTT/menus/home_1.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;

      if (user != null) {
        if (user.emailVerified) {
          print('Inicio de sesión exitoso: ${user.email}');
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => Home_1(),
              transitionDuration: Duration(milliseconds: 500),
              transitionsBuilder: (_, animation, __, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );
        } else {
          _showSnackBar('Verifica tu correo electrónico antes de iniciar sesión');
        }
      } else {
        _showSnackBar('Error al iniciar sesión');
      }
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
      _showSnackBar('Error durante el inicio de sesión');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _resetEmailController.text;

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showSnackBar('Se ha enviado un correo para restablecer tu contraseña');
      _showSnackBar('Verifique su correo');
    } catch (e) {
      print('Error al enviar el correo de restablecimiento de contraseña: $e');
      _showSnackBar('Error al enviar el correo de restablecimiento de contraseña');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/gifdefondo2.gif',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: 0.5,
                        child: Image.asset(
                          'assets/logo.png',
                          width: 350.0,
                          height: 350.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32.0),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                         filled: true,
                        fillColor: Color.fromARGB(170, 198, 230, 195),
                        
                        
                        labelText: 'Correo',
                        labelStyle: TextStyle(color: Color.fromARGB(255, 26, 255, 0)),

                        border: OutlineInputBorder(
                          
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 8, 244, 252))),

                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ingrese su correo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      style: TextStyle(color: Color.fromARGB(255, 6, 34, 1)),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(170, 198, 230, 195),
                        labelText: 'Contraseña', 
                        labelStyle: TextStyle(color: Color.fromARGB(255, 26, 255, 0)),
                        border: OutlineInputBorder(
                          
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Color.fromARGB(255, 8, 244, 252))),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(135, 20, 183, 52)
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Iniciar sesión',style: TextStyle(color: Colors.green),),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Restablecer contraseña'),
                              content: TextFormField(
                                controller: _resetEmailController,
                                decoration: InputDecoration(
                                  labelText: 'Correo',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Ingrese su correo';
                                  }
                                  return null;
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _resetPassword();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Enviar correo'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text('¿Olvidaste tu contraseña?',style: TextStyle(
                        color: Colors.green,
                      ),),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()),
                        );
                      },
                      child: const Text("No tienes una cuenta? Crea una",style: TextStyle(color: Colors.green),),
                    ),
                    SizedBox(
                      height: 100,
                    ),
                    Container(
                      color: Colors.black,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/like.gif',
                            width: 100,
                            height: 100,
                          ),
                          Expanded(
                            child: Text(
                              "                                                      Aplicación que uso para practicar conceptos de programación móvil. Agradecería mucho recomendaciones o fallos que puedan encontrar para así mejorar.                                                .",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
