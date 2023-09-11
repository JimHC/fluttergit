import 'package:flutter/material.dart';

class CPEScreen extends StatefulWidget {
  const CPEScreen({Key? key}) : super(key: key);

  @override
  _CPEScreenState createState() => _CPEScreenState();
}

class _CPEScreenState extends State<CPEScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REPORTE DE ESTADO'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: const Color.fromARGB(123, 76, 175, 79),
        child: ListView(
          
          children: [
            _buildBlogPost(
              'CRUD ( CREATE READ UPDATE DELETE)',
              'assets/CRUD.jpeg',
              'Obla bla bla tambien conocido como crear, leer actualizar y eliminar, todo esto con respecto a productos que se ingresan para que los usuarios puedan verlo, o tambien puede ser usado para clientes para que tengan en claro los plu de nuestros productos',
            ),
           
      
          ],
        ),
      ),
    );
  }

  Widget _buildBlogPost(String title, String imagePath, String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            imagePath,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(content),
        ],
      ),
    );
  }
}
