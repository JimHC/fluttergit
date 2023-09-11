import 'package:CampoyTT/MS_CONTEOS.dart';
import 'package:CampoyTT/MS_CRUDPGC.dart';
import 'package:CampoyTT/MS_DATOS.dart';
import 'package:CampoyTT/MS_READPGC.dart';
import 'package:CampoyTT/MS_UD.dart';
import 'package:CampoyTT/Marca_Sensible.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
var waitxd = Color.fromARGB(255, 255, 255, 255); // Esto representa el color blanco en formato ARGB


class MS_MENU extends StatelessWidget {
  final List<String> imageList = [
    'assets/tottus.jpg',
    'assets/tottusgente.jpeg',
    'assets/tottusgente2.jpg',
    // Agrega aquí más rutas de imágenes si deseas repetir la misma imagen varias veces
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MENU MARCA SENSIBLE ',style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 1, 18, 2),
      ),
      body: Container(
        // Establece el fondo utilizando la propiedad BoxDecoration
        decoration: BoxDecoration(
          image: DecorationImage(
            // Ruta al archivo GIF en la carpeta assets
            image: AssetImage('assets/gifdefondo2.gif'),
            // Ajusta la imagen a la pantalla completa
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
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
                  SizedBox(height: 16),
                  Card(
                    elevation: 7, // Añade una sombra a la tarjeta
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Color.fromARGB(255, 9, 97, 56),
                    child: Text(
                      " BODEGA MARCA SENSIBLE ",
                      style: TextStyle(
                        fontSize: 18, // Cambia el tamaño de fuente
                        fontWeight:
                            FontWeight.bold, 
                            color: waitxd// Cambia el peso de la fuente
                      ),
                    ),
                  ),
                  buildMenuItem(
                    icon: Icons.inventory,
                    description: 'INGRESO / EGRESO',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MarcaSensiblePGC()));
                      // Navegar a la pantalla de Inventario PGC
                    },
                    details:
                        ' Aumenta si ingresas mercaderia al pallet y disminuye cuando necesites reponer mercaderia del pallet ',
                  ),
                  SizedBox(height: 10),
                  buildMenuItem(
                    icon: Icons.inventory,
                    description: 'INGRESA CODIGOS NUEVOS',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MS_CRUDPGC()));
                      // Navegar a la pantalla de Inventario PGC
                    },
                    details:
                        'Si deseas ingresar nuevos codigos al pallet lo puedes agregar en esta seccion',
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  buildMenuItem(
                    icon: Icons.question_answer_sharp,
                    description: ' CONSULTA (EXPERIMENTAL) ',
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MS_READ_PGC()));
                      // Navegar a la pantalla de Inventario PGC
                    },
                    details:
                        ' Puedes ver los ingresos y egresos de un codigo en una determinada fecha ',
                  ),
                  SizedBox(height: 16.0),
                  buildMenuItem(
                    icon: Icons.question_answer_sharp,
                    description: ' MODIFICAR CODIGOS ',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MS_UD()));
                      // Navegar a la pantalla de Inventario PGC
                    },
                    details:
                        ' Seccion donde puedes ver todo los codigos pertenecientes al pallet y poder modificar los datos ',
                  ),
                  SizedBox(
                    height: 100,
                  ),
                  Card(
                    elevation: 7, // Añade una sombra a la tarjeta
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Color.fromARGB(255, 9, 97, 56),

                    child: Text(
                      " TRICONTEO DE MARCA SENSIBLE ",
                      style: TextStyle(
                        fontSize: 18, // Cambia el tamaño de fuente
                        fontWeight:
                            FontWeight.bold, 
                            color: waitxd// Cambia el peso de la fuente
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  buildMenuItem(
                    icon: Icons.inventory,
                    description: ' TRICONTEOS (EN PRUEBA)',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MS_CONTEO()));
                      // Navegar a la pantalla de Inventario PGC
                    },
                    details: 'Seccion donde realizas tus tres conteos diarios',
                  ),
                  SizedBox(height: 100),
                  Card(
                    elevation: 7, // Añade una sombra a la tarjeta
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Color.fromARGB(255, 9, 97, 56),
                    child: Text(
                      " DATOS ",
                      style: TextStyle(
                        fontSize: 18, // Cambia el tamaño de fuente
                        fontWeight:
                            FontWeight.bold, // Cambia el peso de la fuente
                            color: waitxd
                      ),
                    ),
                  ),
                  buildMenuItem(
                    icon: Icons.question_answer_sharp,
                    description: ' DATOS ',
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MS_DATOS()));
                      // Navegar a la pantalla de Inventario PGC
                    },
                    details: ' Ver datos (Excel, pdf) ',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMenuItem({
    required IconData icon,
    required String description,
    required VoidCallback onTap,
    required String details,
  }) {
    return Card(
      elevation: 7, // Añade una sombra a la tarjeta
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: Color.fromARGB(88, 76, 175, 79),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0), // Añade un relleno interno
        leading: Icon(icon),
        title: Text(
          description,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white, // Cambia el tamaño de fuente
            fontWeight: FontWeight.bold, // Cambia el peso de la fuente
          ),
        ),
        onTap: onTap,
        subtitle: Text(
          details,
          style: TextStyle(color: Color.fromARGB(169, 255, 255, 255)),
        ),
      ),
    );
  }
}
