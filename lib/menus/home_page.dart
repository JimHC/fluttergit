import 'package:CampoyTT/crud_productos/CPE.dart';
import 'package:flutter/material.dart';
import 'package:CampoyTT/crud_productos/IngresoDocumentos.dart';
import 'package:CampoyTT/crud_productos/UDScreen.dart';


class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 16, 110, 57),
        title: Text(
          'CRUD PRODUCTOS',style: TextStyle(color: Colors.white),
        ),
        actions: [],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/gifdefondo2.gif'), // Ruta de la imagen de fondo
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
              ' REGISTRAR ',
              'Crear o registrar productos',
              Icons.create,
              IngresoDocumentosScreen(key: UniqueKey()),
              'assets/REGISTRAR.jpg', // Ruta de la imagen de Más Información
            ),
            _buildContainer(
              context,
              ' MODIFICAR ',
              'Modifica los productos registrados',
              Icons.delete,
              UDScreen(),
              'assets/MODIFICAR.jpg', // Ruta de la imagen de Más Información
            ),
            _buildContainer(
              context,
              ' ESTADO ',
              'Conoce el estado de esta seccion ',
              Icons.info,
              CPEScreen(),
              'assets/ESTADO.jpeg', // Ruta de la imagen de Otro
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
              decoration: BoxDecoration(color: Colors.green,
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
