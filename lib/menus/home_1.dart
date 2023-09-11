import 'package:CampoyTT/menus/home_cajas.dart';
import 'package:CampoyTT/menus/home_operaciones.dart';
import 'package:CampoyTT/menus/home_otros.dart';
import 'package:CampoyTT/menus/home_pdv.dart';
import 'package:CampoyTT/menus/home_perecibles.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class Home_1 extends StatelessWidget {
  const Home_1({Key? key}) : super(key: key);

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
              ' PISO DE VENTA ',
              'Seccion que compete solo a piso de venta',
              Icons.create,
              Home_pdv(),
              'assets/CRUD_PRODUCTOS.jpg', // Ruta de la imagen del Master
            ),_buildContainer(
              context,
              ' CAJAS ',
              'Seccion que compete a cajas',
              Icons.apple,
              Home_cajas(),
              'assets/fdpcrudproductos.jpeg', // Ruta de la imagen del Master
            ),_buildContainer(
              context,
              ' OPERACIONES ',
                            ' Seccion que compete a Operaciones ',

              Icons.apple,
              Home_operaciones(),
              'assets/COMUNICACION.png', // Ruta de la imagen del Master
            ),
            _buildContainer(
              context,
              ' PERECIBLES ',
              'Seccion que compete a pereciblesw',
              Icons.apple,
              Home_perecibles(),
              'assets/INVENTARIO.jpeg', // Ruta de la imagen del Master
            ),
            _buildContainer(
              context,
              ' OTROS ',
              'Otras funciones',
              Icons.apple,
              Home_otros(),
              'assets/INVENTARIO.jpeg', // Ruta de la imagen del Master
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