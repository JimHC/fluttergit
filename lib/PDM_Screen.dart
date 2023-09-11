import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PDM_Screen extends StatefulWidget {
  const PDM_Screen({Key? key}) : super(key: key);

  @override
  State<PDM_Screen> createState() => _PDM_ScreenState();
}

class _PDM_ScreenState extends State<PDM_Screen> {
  String newClave = '';
  TextEditingController searchController = TextEditingController();

  void updateDocument(String documentId, Map<String, dynamic> newData) {
    FirebaseFirestore.instance.collection('PDM').doc(documentId).update(newData);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documentos PDM'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('PDM').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No hay documentos disponibles.');
                }

                List<DocumentSnapshot> filteredDocs = snapshot.data!.docs
                    .where((doc) => doc['nombre'].toString().toLowerCase().contains(searchController.text.toLowerCase()))
                    .toList();

                return ListView(
                  children: filteredDocs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    bool usoValue = data['uso'] as bool;
                    Color cardColor = usoValue ? Colors.green : Colors.red;

                    return GestureDetector(
                      onTap: () {
                        if (usoValue == false) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String prestamista = '';
                              String prestatario = '';
                              int newClaveValue = 100000 + Random().nextInt(900000);

                              return AlertDialog(
                                title: Text('Modificar préstamo'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextFormField(
                                      onChanged: (value) {
                                        prestamista = value;
                                      },
                                      decoration: InputDecoration(labelText: 'Nuevo prestamista'),
                                    ),
                                    TextFormField(
                                      onChanged: (value) {
                                        prestatario = value;
                                      },
                                      decoration: InputDecoration(labelText: 'Nuevo prestatario'),
                                    ),
                                    SizedBox(height: 10),
                                    Text('Nueva Clave: $newClaveValue'),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      if (prestamista.isNotEmpty && prestatario.isNotEmpty) {
                                        setState(() {
                                          newClave = newClaveValue.toString();
                                        });

                                        updateDocument(document.id, {
                                          'prestamista': prestamista,
                                          'prestatario': prestatario,
                                          'clave': newClaveValue,
                                          'uso': true,
                                        });

                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text('Guardar'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              String enteredClave = '';

                              return AlertDialog(
                                title: Text('Devolver libro'),
                                content: TextFormField(
                                  onChanged: (value) {
                                    enteredClave = value;
                                  },
                                  decoration: InputDecoration(labelText: 'Ingresa la clave'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      if (enteredClave.isNotEmpty && enteredClave == data['clave'].toString()) {
                                        updateDocument(document.id, {
                                          'prestamista': 'N.A',
                                          'prestatario': 'N.A',
                                          'uso': false,
                                        });

                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text('Devolver'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Card(
                        margin: EdgeInsets.all(10),
                        color: cardColor,
                        child: Column(
                          children: [
                            Image.network(data['imageUrl'], fit: BoxFit.cover, height: 200),
 Text(data['nombre'], style: TextStyle(color: Colors.white)),                           
                              
                               Text('Prestamista: ${data['prestamista']} -', style: TextStyle(color: Colors.white)),
                            Text(' Prestatario: ${data['prestatario']}',style: TextStyle(color: Colors.white))
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PDM_Screen(),
  ));
}
