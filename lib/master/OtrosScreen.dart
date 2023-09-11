import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OtrosScreen extends StatefulWidget {
  @override
  _OtrosScreenState createState() => _OtrosScreenState();
}

class _OtrosScreenState extends State<OtrosScreen> {
  final List<String> images = [
    'assets/manzana.jpg',
    'assets/pera.jpg',
    'assets/panaderia.jpg',
    // Agrega aquí las rutas de tus imágenes en la carpeta "assets"
  ];

  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  List<Map<String, dynamic>> allResults = [];

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  void fetchDocuments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('frutasyverduras')
        .where('tipo', isEqualTo: 'Otros')
        .get();

    setState(() {
      allResults = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      searchResults = allResults;
    });
  }

  void searchDocuments(String query) {
    setState(() {
      searchResults = allResults
          .where((doc) =>
              (doc['nombre']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  doc['plu']
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase())) &&
              doc['tipo'] == 'Otros')
          .toList();
    });
  }

  void showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item['nombre']),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item['imageUrl'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Peso: ${item['descripcion']}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 5),
              Text(
                item['comentario'],
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF82D37B),
        title: Text(
          'OTROS',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/MASTER_BACKGROUND.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 20),
            CarouselSlider(
              options: CarouselOptions(
                height: 200.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 3),
                autoPlayCurve: Curves.fastOutSlowIn,
                // Puedes ajustar las opciones según tus necesidades
              ),
              items: images.map((image) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text(
              'Productos extras',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(96, 130, 211,
                      123), // Ajustar el color del contenedor aquí
                  borderRadius: BorderRadius.circular(
                      10), // Ajustar el radio del borde aquí
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar por nombre o PLU',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide
                          .none, // Eliminar el borde del campo de texto
                    ),
                  ),
                  onChanged: (value) {
                    searchDocuments(value);
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> document = searchResults[index];
                  return Container(
                    color: Color.fromARGB(145, 130, 211, 123),
                    child: ListTile(
                      onTap: () {
                        // Muestra los detalles del elemento seleccionado
                        showItemDetails(document);
                      },
                      title: Text(
                        document['nombre'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peso: ${document['kgUnd']}',
                            style: TextStyle(
                              color: Color.fromARGB(255, 10, 37, 3),
                            ),
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                      leading: AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            document['imageUrl'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      trailing: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'PLU: ${document['plu']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
