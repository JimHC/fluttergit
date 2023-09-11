import 'package:flutter/material.dart';

class MermaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Consejos para un Inventario de Productos de Supermercados Eficiente'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/unavez.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    child: Text(
                      'Mi Blog',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Introducción:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Realizar un inventario eficiente en una tienda de supermercados es esencial para mantener un control adecuado de tus productos y minimizar las pérdidas por merma. Aquí te brindo información clave y consejos útiles para realizar un inventario efectivo:',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '1. Organización del Espacio:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Asegúrate de que tu espacio de almacenamiento esté organizado de manera lógica y eficiente. Divide las áreas según las categorías de productos y utiliza estanterías y sistemas de almacenamiento adecuados.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '2. Utiliza un Sistema de Código de Barras:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Implementa un sistema de código de barras para escanear los productos y registrar automáticamente la información en tu inventario. Esto agilizará el proceso y reducirá los errores manuales.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '3. Realiza Recuentos Periódicos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Programa sesiones de inventario regularmente para mantener tus registros actualizados. Realiza recuentos físicos de los productos y compáralos con tus registros para identificar discrepancias y corregirlas a tiempo.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '4. Utiliza Tecnología de Apoyo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Aprovecha las aplicaciones y software de gestión de inventario disponibles en el mercado. Estas herramientas pueden facilitar la captura de datos, generar informes y proporcionar análisis útiles para una gestión eficiente del inventario.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '5. EPPs (Elementos de Protección Personal):',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Cuando realices el inventario, asegúrate de utilizar los EPPs adecuados, como guantes y mascarillas, especialmente al manejar productos perecederos o sustancias químicas. Esto garantizará tu seguridad y la integridad de los productos.',
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Recuerda que un inventario de productos de supermercados bien administrado te ayudará a reducir las pérdidas por merma, mejorar la gestión de stock y brindar un mejor servicio a tus clientes. ¡Sigue estos consejos y optimiza tu inventario!',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


