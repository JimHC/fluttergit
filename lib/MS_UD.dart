import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class MS_UD extends StatefulWidget {
  const MS_UD({Key? key});

  @override
  State<MS_UD> createState() => _MS_UDState();
}

class _MS_UDState extends State<MS_UD> {
  String _searchCode = '';
  String? _cantidadAntes;
  String? _codigoDoc;
  String? _descripcionDoc;
  String? _skuDoc;
  bool _changesMade = false; // Variable para rastrear si se realizaron cambios

  Future<void> updateDocument(
      String docId, Map<String, dynamic> newData) async {
    await FirebaseFirestore.instance
        .collection('MS_ESTADO')
        .doc(docId)
        .update(newData);
  }

  Future<void> deleteDocument(String docId) async {
    await FirebaseFirestore.instance
        .collection('MS_ESTADO')
        .doc(docId)
        .delete();
  }

  Future<String?> _uploadImage(File image) async {
    try {
      final storageRef = firebase_storage.FirebaseStorage.instance.ref();
      final imageName = '${DateTime.now()}.png';
      final uploadTask = storageRef.child(imageName).putFile(image);
      final snapshot = await uploadTask;

      if (snapshot.state == firebase_storage.TaskState.success) {
        final downloadURL = await snapshot.ref.getDownloadURL();
        return downloadURL;
      }
    } catch (error) {
      print('Error uploading image: $error');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Codigos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Buscar por código o descripción',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchCode = value;
                });
              },
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('MS_ESTADO').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: CircularProgressIndicator());
              }

              final documents = snapshot.data!.docs;

              final filteredDocuments = documents.where((doc) {
                final codeMatch = doc['CODIGO'].toString().contains(_searchCode);
                final descriptionMatch =
                    doc['DESCRIPCION'].toString().contains(_searchCode);

                return codeMatch || descriptionMatch;
              }).toList();

              return Expanded(
                child: ListView.builder(
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final docData = filteredDocuments[index].data() as Map<String, dynamic>;
                    final docId = filteredDocuments[index].id;

                    Map<String, dynamic> updatedData = {};

                    return GestureDetector(
                      onTap: () {
                        _cantidadAntes = docData['CANTIDAD'];
                        _codigoDoc = docData['CODIGO'];
                        _descripcionDoc = docData['DESCRIPCION'];
                        _skuDoc = docData['SKU'];
                        _changesMade = false; // Restablecer cambios realizados

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Editar Datos'),
                              content: SingleChildScrollView(
                                child: Container(
                                  width: 300,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextFormField(
                                        initialValue: docData['CANTIDAD'],
                                        onChanged: (value) {
                                          updatedData['CANTIDAD'] = value;
                                          _changesMade = true; // Se realizó un cambio
                                        },
                                        decoration: InputDecoration(
                                            labelText: 'Cantidad'),
                                      ),
                                      TextFormField(
                                        initialValue: docData['CODIGO'],
                                        onChanged: (value) {
                                          updatedData['CODIGO'] = value;
                                          _changesMade = true; // Se realizó un cambio
                                        },
                                        decoration: InputDecoration(
                                            labelText: 'Código'),
                                      ),
                                      TextFormField(
                                        initialValue: docData['DESCRIPCION'],
                                        onChanged: (value) {
                                          updatedData['DESCRIPCION'] = value;
                                          _changesMade = true; // Se realizó un cambio
                                        },
                                        decoration: InputDecoration(
                                            labelText: 'Descripción'),
                                      ),
                                      TextFormField(
                                        initialValue: docData['SKU'],
                                        onChanged: (value) {
                                          updatedData['SKU'] = value;
                                          _changesMade = true; // Se realizó un cambio
                                        },
                                        decoration:
                                            InputDecoration(labelText: 'Marca'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final imagePicker = ImagePicker();
                                          final pickedImage =
                                              await imagePicker.getImage(
                                                  source: ImageSource.gallery);

                                          if (pickedImage != null) {
                                            final imageFile =
                                                File(pickedImage.path);
                                            final imageUrl =
                                                await _uploadImage(imageFile);
                                            if (imageUrl != null) {
                                              setState(() {
                                                updatedData['imageUrl'] =
                                                    imageUrl;
                                              });
                                              _changesMade = true; // Se realizó un cambio
                                            }
                                          }
                                        },
                                        child: Text('Cargar Imagen'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await Future.delayed(Duration(seconds: 3));
                                    if (_changesMade) {
                                      await _updateDocumentWithHistory(docId, updatedData);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Guardar'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await deleteDocument(docId);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Eliminar'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(10.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CANTIDAD: ${docData['CANTIDAD']}'),
                                  Text('CODIGO: ${docData['CODIGO']}'),
                                  Text('DESCRIPCION: ${docData['DESCRIPCION']}'),
                                  Text('SKU: ${docData['SKU']}'),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 100,
                              height: 200,
                              child: Image.network(docData['imageUrl']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _updateDocumentWithHistory(
    String docId, Map<String, dynamic> updatedData) async {
  final currentCantidad = updatedData['CANTIDAD'];

  if (_cantidadAntes != null && currentCantidad != null) {
    final diferencia =
        (int.parse(currentCantidad) - int.parse(_cantidadAntes!)).toString();
    final fechaHora = DateTime.now().toUtc().toString();

    final registroData = {
      'CANTIDAD_ACTUAL': currentCantidad,
      'CANTIDAD_ANTES': _cantidadAntes!,
      'CODIGO': _codigoDoc ?? '', // Usar los valores capturados o cadena vacía si es nulo
      'DESCRIPCION': _descripcionDoc ?? '', // Usar los valores capturados o cadena vacía si es nulo
      'DIFERENCIA': diferencia,
      'FECHA_HORA': fechaHora,
      'MOVIMIENTO': 'ACTUALIZACION',
      'NOMBRE': 'ACT',
      'SKU': _skuDoc ?? '', // Usar los valores capturados o cadena vacía si es nulo
    };

    await FirebaseFirestore.instance
        .collection('MS_REGISTRO')
        .add(registroData);
  }

  await updateDocument(docId, updatedData);
}

}

void main() {
  runApp(MaterialApp(home: MS_UD()));
}
