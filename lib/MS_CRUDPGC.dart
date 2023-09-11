import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore CRUD Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MS_CRUDPGC(),
    );
  }
}

class MS_CRUDPGC extends StatefulWidget {
  const MS_CRUDPGC({Key? key}) : super(key: key);

  @override
  _MS_CRUDPGCState createState() => _MS_CRUDPGCState();
}

class _MS_CRUDPGCState extends State<MS_CRUDPGC> {
  final descripcioncontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  late String cantidad;
  late String descripcion;
  late String sku;
  File? _image;

  TextEditingController codigoController = TextEditingController();
  TextEditingController CantidadController = TextEditingController();
  TextEditingController Textfieldcodigo = TextEditingController();

  String scannedCodigo = "";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    codigoController.text = scannedCodigo;
  }

  Future<void> _getImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<void> _uploadImage(String documentId) async {
    if (_image != null) {
      final ref = _storage.ref().child('post_images/$documentId.jpg');
      await ref.putFile(_image!);
    } else {
      final defaultImageUrl = 'assets/interrogacion.jpg';
      final defaultImageBytes = await rootBundle.load(defaultImageUrl);
      final ref = _storage.ref().child('post_images/$documentId.jpg');
      await ref.putData(defaultImageBytes.buffer.asUint8List());
    }
  }

  Future<void> _addDocument() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (cantidad.isEmpty || descripcion.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ERROR'),
              content: Text(
                  'Por favor, complete todos los campos antes de registrar el código.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      if (scannedCodigo.isEmpty) {
        scannedCodigo = await FlutterBarcodeScanner.scanBarcode(
          "#FF9900",
          "Cancelar",
          true,
          ScanMode.BARCODE,
        );

        if (scannedCodigo == '-1') {
          return;
        }
      }

      final existingDocument = await _firestore
          .collection('MS_ESTADO')
          .where('CODIGO', isEqualTo: scannedCodigo)
          .limit(1)
          .get();

      if (existingDocument.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('ERROR'),
              content: Text('El código ya existe'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      final newDocumentRef = _firestore.collection('MS_ESTADO').doc();
      final documentId = newDocumentRef.id;

      await newDocumentRef.set({
        'CANTIDAD': cantidad,
        'CODIGO': scannedCodigo,
        'DESCRIPCION': descripcion,
        'SKU': selectedMarca,
        'imageUrl':
            'https://firebasestorage.googleapis.com/v0/b/masterttv2.appspot.com/o/post_images%2F$documentId.jpg?alt=media'
      });

      await _uploadImage(documentId);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('CÓDIGO REGISTRADO'),
            content: Text('El código fue registrado correctamente.'),
            actions: [
              TextButton(
                onPressed: () {
                  descripcioncontroller.clear();
                  CantidadController.clear();
                  Textfieldcodigo.clear();
                  setState(() {
                    selectedMarca = 'FLORIDA';
                  });
                  Navigator.of(context).pop();
                  _image = null;
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text('Ocurrió un error durante el registro: $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildSelectedImage() {
    if (_image != null) {
      return Container(
        padding: EdgeInsets.all(16.0),
        width: 200,
        height: 200,
        child: Image.file(_image!, fit: BoxFit.cover),
      );
    } else {
      return Container();
    }
  }

  Future<void> _scanBarcode() async {
    String barcode = await FlutterBarcodeScanner.scanBarcode(
      "#FF9900",
      "Cancelar",
      true,
      ScanMode.BARCODE,
    );

    if (barcode != '-1') {
      setState(() {
        scannedCodigo = barcode;
        codigoController.text = barcode;
        Textfieldcodigo.text = barcode;
      });
    }
  }

  List<String> marcas = [
    'FLORIDA',
    'MILO',
    'NESCAFE',
    'PRIMOR',
    'ALACENA',
    'PILSEN',
    'CAMPOMAR',
    'GILLETTE',
    'HEAD SHOULDERS',
    'BABYSEC',
    'DOVE',
    'NIVEA',
    'GILLETTE',
    'COLGATE',
    'PANTENE',
    'REXONA',
    'HUGGIES'
  ];

  String selectedMarca = 'FLORIDA';

  @override
  Widget build(BuildContext context) {
    var verdeoscuro = Color.fromARGB(255, 1, 18, 2);

    return Scaffold(
       resizeToAvoidBottomInset: false,
      
      appBar: AppBar(
        title: Text(
          'REGISTRO',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: verdeoscuro,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/gifdefondo2.gif'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  style: TextStyle(color: Colors.white,
                  fontSize: 23),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      scannedCodigo = value;
                    });
                  },
                  controller: Textfieldcodigo,
                  decoration: InputDecoration(
                    
                    filled: true,
                    fillColor: Color.fromARGB(183, 6, 71, 22),
                    labelStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(171, 255, 255, 255),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                    labelText: 'CODIGO',
                    suffixIcon: IconButton(
                      onPressed: _scanBarcode,
                      icon: Icon(Icons.qr_code_scanner),
                    ),
                  
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                   style: TextStyle(color: Colors.white,
                  fontSize: 23),
                  keyboardType: TextInputType.number,
                  controller: CantidadController,
                  onChanged: (value) => cantidad = value,
                  decoration: InputDecoration(
                    labelText: 'CANTIDAD',
                    filled: true,
                    fillColor: Color.fromARGB(183, 6, 71, 22),
                    labelStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(171, 255, 255, 255),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                   style: TextStyle(color: Colors.white,
                  fontSize: 23),
                  controller: descripcioncontroller,
                  onChanged: (value) => descripcion = value,
                  decoration: InputDecoration(
                    labelText: 'DESCRIPCIÓN',
                    filled: true,
                    fillColor: Color.fromARGB(183, 6, 71, 22),
                    labelStyle: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(171, 255, 255, 255),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Center(
                  child:                  Text("Seleccione la marca", style: TextStyle(color:Colors.white),)
 ,
                ),
                DropdownButton<String>(
                  value: selectedMarca,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMarca = newValue!;
                    });
                  },
                  items: marcas.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(171, 255, 255, 255),
                        ),
                      ),
                    );
                  }).toList(),
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(171, 228, 228, 228),
                  ),
                  dropdownColor:
                      Color.fromARGB(183, 6, 71, 22), // Color de fondo del menú
                  icon: Icon(
                                size: 50.0, // Aumenta el tamaño del ícono

                    Icons.arrow_drop_down, // Cambia el ícono de la flecha
                    color: Colors.white,
                  ),
                  underline: Container(
                    // Estilo del borde inferior
                    height: 2,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 20,),
                ElevatedButton(style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 1, 16, 4),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.white),
                    ),
                  ),
                  onPressed: _isLoading ? null : _getImage,
                  child: Text('Sube una imagen referente (opcional)'),
                ),
                SizedBox(height: 16.0),
                _buildSelectedImage(),
                SizedBox(height: 16.0),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 1, 16, 4),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.white),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          _addDocument();
                          setState(() {
                            // Esto elimina la referencia a la imagen seleccionada.
                          });
                        },
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Registrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
