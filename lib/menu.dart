import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flare_flutter/flare_actor.dart';

void main() {
  runApp(MaterialApp(
    home: MenuScreen(),
  ));
}

class MenuScreen extends StatelessWidget {
  final List<String> imageList = [
    'assets/unavez.jpg',
    'assets/unavez.jpg',
    'assets/unavez.jpg',
    // Agrega aquí más rutas de imágenes si deseas repetir la misma imagen varias veces
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menú'),
      ),
      body: Stack(
        children: [
          // Fondo animado
          FlareActor(
            'assets/gifdefondo1.gif',
            alignment: Alignment.center,
            fit: BoxFit.cover,
            animation: 'idle',
          ),
          // Contenido del menú
          ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CarouselSlider(
                      items: imageList.map((image) {
                        return Image.asset(
                          image,
                          width: 320,
                          height: 350,
                        );
                      }).toList(),
                      options: CarouselOptions(
                        autoPlay: true,
                        aspectRatio: 1.6,
                        enlargeCenterPage: true,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    buildMenuItem(
                      icon: Icons.inventory,
                      description: 'Mi Inventario 1.0',
                      onTap: () {
                        Navigator.pushNamed(context, '/inventariopgc');
                        // Navegar a la pantalla de Inventario PGC
                      },
                      details: 'Pistoleo libre, inventario basico ',
                    ),
                    SizedBox(height: 16.0),
                    buildMenuItem(
                      icon: Icons.inventory_rounded,
                      description: 'Mi Inventario 2.0',
                      onTap: () {
                        Navigator.pushNamed(context, '/devolucion');
                        // Navegar a la pantalla de Devolución
                      },
                      details:
                          'Pistoleo exacto, puede ser usado tambien para merma y devolucion',
                    ),
                    SizedBox(height: 16.0),
                    buildMenuItem(
                      icon: Icons.inventory,
                      description: 'Mi Inventario 3.0',
                      onTap: () {
                        Navigator.pushNamed(context, '/menu');
                        // Navegar a la pantalla de Inventario PGC
                      },
                      details:
                          'Incluye el online, trabaja con firebase todos pueden ver los pallets contados, los que faltan y los que estan en pleno conteo (EN DESARROLLO)',
                    ),
                    SizedBox(height: 16.0),
                    buildMenuItem(
                      icon: Icons.question_answer_sharp,
                      description: '¿Qué es un inventario?',
                      onTap: () {
                        Navigator.pushNamed(context, '/merma');
                        // Navegar a la pantalla de Merma
                      },
                      details: 'Detalles sobre los inventarios',
                    ),
                    SizedBox(height: 16.0),
                    buildMenuItem(
                      icon: Icons.info,
                      description: 'Más información',
                      onTap: () {
                        Navigator.pushNamed(context, '/masinfo');
                        // Navegar a la pantalla de Más Información
                      },
                      details: 'Detalles adicionales',
                    ),
                    SizedBox(height: 16.0),
                    buildMenuItem(
                      icon: Icons.assignment,
                      description: 'Evaluacion',
                      onTap: () {
                        Navigator.pushNamed(context, '/evaluacion');
                        // Navegar a la pantalla de Evaluación
                      },
                      details:
                          'Confirma tus conocimientos y demuestra que eres apto para dar un buen inventario',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    required String details,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(description),
        onTap: onTap,
        subtitle: Text(details),
      ),
    );
  }
}
