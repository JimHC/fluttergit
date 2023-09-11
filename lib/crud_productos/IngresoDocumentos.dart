import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';

 final user = FirebaseAuth.instance.currentUser;
    final userEmail = user?.email ?? '';
    final username = userEmail.split('@')[0];


class IngresoDocumentosScreen extends StatefulWidget {
  const IngresoDocumentosScreen({required Key key}) : super(key: key);

  @override
  _IngresoDocumentosScreenState createState() =>
      _IngresoDocumentosScreenState();
}

class _IngresoDocumentosScreenState extends State<IngresoDocumentosScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _pluController = TextEditingController();
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _comentarioController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _kgUndController = TextEditingController();
  File? _image;

  String _mensaje = '';

  List<String> _tipoOptions = [
    "Frutas y Verduras",
    "Comida Rapida",
    "Productos en Oferta",
    "Pollo, Pavo y Cerdo",
    "Panaderia",
    "Otros"
  ];

  List<String> _kgUndOptions = ["KG", "UNIDAD"];

  @override
  void dispose() {
    _nombreController.dispose();
    _pluController.dispose();
    _tipoController.dispose();
    _comentarioController.dispose();
    _descripcionController.dispose();
    _kgUndController.dispose();
    super.dispose();
  }

  Future<void> _enviarFormulario() async {
    if (_formKey.currentState!.validate()) {
      String nombre = _nombreController.text;
      String plu = _pluController.text;
      String tipo = _tipoController.text;
      String comentario = _comentarioController.text;
      String descripcion = _descripcionController.text;
      String kgUnd = _kgUndController.text;

      // Subir la imagen al Firebase Storage
      String imageUrl = await _uploadImage();

      // Crear un mapa con los datos del documento
      Map<String, dynamic> documentoData = {
        'nombre': nombre,
        'plu': plu,
        'tipo': tipo,
        'comentario': comentario,
        'descripcion': descripcion,
        'kgUnd': kgUnd,
        'imageUrl': imageUrl,
        'correo': username
      };

      // Guardar el documento en Firestore
      FirebaseFirestore.instance
          .collection('frutasyverduras')
          .add(documentoData)
          .then((DocumentReference docRef) {
        setState(() {
          _mensaje = 'Producto Agregado';
        });
        _mostrarDialogo();
      }).catchError((error) {
        setState(() {
          _mensaje = 'Error al agregar el producto';
        });
      });
    }
  }

  Future<String> _uploadImage() async {
    String imageUrl = '';

    if (_image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
          FirebaseStorage.instance.ref().child('frutasyverduras/$fileName');
      UploadTask uploadTask = storageReference.putFile(_image!);
      await uploadTask.whenComplete(() async {
        imageUrl = await storageReference.getDownloadURL();
      });
    }

    return imageUrl;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _mostrarDialogo() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Producto Agregado'),
          content: Text('El producto ha sido agregado exitosamente.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                // Limpiar los campos de texto
                _nombreController.clear();
                _pluController.clear();
                _tipoController.clear();
                _comentarioController.clear();
                _descripcionController.clear();
                _kgUndController.clear();
                setState(() {
                  _mensaje = '';
                  _image = null;
                });
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
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
        title: Text('Ingreso de Documentos'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingresa un nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _pluController,
                decoration: InputDecoration(labelText: 'PLU'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor, ingresa un PLU';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _tipoController.text.isNotEmpty ? _tipoController.text : null,
                decoration: InputDecoration(labelText: 'Tipo'),
                items: _tipoOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _tipoController.text = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona un tipo';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _comentarioController,
                decoration: InputDecoration(labelText: 'Comentario'),
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
              ),
              DropdownButtonFormField<String>(
                value: _kgUndController.text.isNotEmpty ? _kgUndController.text : null,
                decoration: InputDecoration(labelText: 'KG/UND'),
                items: _kgUndOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _kgUndController.text = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecciona un valor en KG/UND';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Seleccionar Imagen'),
              ),
              SizedBox(height: 16),
              if (_image != null)
                Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _enviarFormulario,
                child: Text('Agregar Producto'),
              ),
              SizedBox(height: 16),
              Text(_mensaje),
            ],
          ),
        ),
      ),
    );
  }
}
