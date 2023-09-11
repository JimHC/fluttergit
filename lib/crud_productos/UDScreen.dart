import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UDScreen extends StatefulWidget {
  const UDScreen({Key? key}) : super(key: key);

  @override
  State<UDScreen> createState() => _UDScreenState();
}

class _UDScreenState extends State<UDScreen> {
  final CollectionReference _fruitsAndVegetablesCollection =
      FirebaseFirestore.instance.collection('frutasyverduras');

  String _editedName = '';
  String _editedPlu = '';
  String _searchTerm = '';

  void _editDocument(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar documento'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    _editedName = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _editedPlu = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'PLU',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateDocument(documentId);
                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _updateDocument(String documentId) async {
    await _fruitsAndVegetablesCollection.doc(documentId).update({
      'nombre': _editedName,
      'plu': _editedPlu,
    });
  }

  void _deleteDocument(String documentId) async {
    await _fruitsAndVegetablesCollection.doc(documentId).delete();
  }

  void _searchDocuments(String value) {
    setState(() {
      _searchTerm = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis documentos'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchDocuments,
              decoration: InputDecoration(
                labelText: 'Buscar por nombre o PLU',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fruitsAndVegetablesCollection.snapshots(),
              builder: (
                BuildContext context,
                AsyncSnapshot<QuerySnapshot> snapshot,
              ) {
                if (snapshot.hasError) {
                  return Text('Error al obtener los datos');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final documents = snapshot.data!.docs;

                final filteredDocuments = documents.where((document) {
                  final data = document.data() as Map<String, dynamic>;
                  final nombre = data['nombre'].toString().toLowerCase();
                  final plu = data['plu'].toString().toLowerCase();

                  return nombre.contains(_searchTerm) || plu.contains(_searchTerm);
                }).toList();

                if (filteredDocuments.isEmpty) {
                  return Center(
                    child: Text('No se encontraron resultados'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (BuildContext context, int index) {
                    final document = filteredDocuments[index];
                    final data = document.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 2.0,
                      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          data['nombre'],
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.0),
                            Text(
                              'Descripción: ${data['descripcion']}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              'KG/Und: ${data['kgUnd']}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              'PLU: ${data['plu']}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              'Tipo: ${data['tipo']}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              'Comentario: ${data['comentario']}',
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(height: 8.0),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _editedName = data['nombre'];
                                _editedPlu = data['plu'];
                                _editDocument(document.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _deleteDocument(document.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
