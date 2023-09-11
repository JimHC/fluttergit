import 'package:CampoyTT/menus/home_inventario.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Home_pdv extends StatelessWidget {
  const Home_pdv({Key? key}) : super(key: key);

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';
    final username = userEmail.split('@')[0];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 16, 110, 57),
        title: Text('Bienvenido $username',style: TextStyle(
          color: Color.fromARGB(255, 251, 253, 251)
        ),),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
        
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/gifdefondo2.gif'), // Ruta de la imagen de fondo
            fit: BoxFit.cover,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          childAspectRatio: 1.0,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          children: [
            _buildContainer(
              context,
              ' INVENTARIO ',
              'Crea, modifica o elimina productos',
              Icons.create,
              Home_Inventario(),
              'assets/CRUD_PRODUCTOS.jpg', // Ruta de la imagen del Master
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContainer(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Widget screen,
    String backgroundImage,
  ) {
    return GestureDetector(
      onTap: () => _navigateToScreen(context, screen),
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6.0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Color.fromARGB(255, 11, 48, 2),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(color: const Color.fromARGB(255, 136, 176, 138),
              borderRadius: BorderRadius.circular(10)),

              
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 11, 48, 2),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: Color.fromARGB(172, 76, 175, 79),
              child: Text(
                description,
                style: const TextStyle(
                  
                  fontSize: 14,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}