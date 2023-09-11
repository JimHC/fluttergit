import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PruebaScreen extends StatefulWidget {
  const PruebaScreen({Key? key}) : super(key: key);

  @override
  _PruebaScreenState createState() => _PruebaScreenState();
}

class _PruebaScreenState extends State<PruebaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  TextEditingController _passwordController = TextEditingController();
  bool _isPasswordCorrect = false;
  bool _showPassword = false; // Controla la visibilidad de la contraseña
  String _errorMessage = ''; // Mensaje de error

  @override
  void initState() {
    super.initState();
  }

  void _checkPassword() async {
    final enteredPassword = _passwordController.text;
    final documentSnapshot = await _firestore
        .collection('clave')
        .doc('usuario')
        .get();

    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      final correctPassword = data['clave'];

      setState(() {
        _isPasswordCorrect = enteredPassword == correctPassword.toString();
        if (!_isPasswordCorrect) {
          _errorMessage = 'Contraseña incorrecta, por favor inténtalo de nuevo.';
        } else {
          _errorMessage = '';
        }
      });

      if (_isPasswordCorrect) {
        // Navegar a la pantalla de mensaje cuando la contraseña es correcta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MensajeScreen(),
          ),
        );
      }
    }
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword, // Controla la visibilidad de la contraseña
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Ingresa tu contraseña',
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      return Text(
        _errorMessage,
        style: TextStyle(color: Colors.red),
      );
    }
    return SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil de Usuario'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPasswordField(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _checkPassword();
              },
              child: Text('Verificar Contraseña'),
            ),
            SizedBox(height: 20),
            _buildErrorMessage(),
          ],
        ),
      ),
    );
  }
}

class MensajeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mensaje'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hola',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            // Puedes agregar más contenido aquí si es necesario
          ],
        ),
      ),
    );
  }
}
