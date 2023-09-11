import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'dart:io';





class MarcaSensiblePGC extends StatefulWidget {
  const MarcaSensiblePGC({Key? key}) : super(key: key);

  @override
  _MarcaSensibleState createState() => _MarcaSensibleState();
}

class _MarcaSensibleState extends State<MarcaSensiblePGC> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  Map<String, dynamic>? _documentoData;

  // Function to update the quantity
  void _actualizarCantidad() {
    String codigo = codigoController.text;
    String cantidad = cantidadController.text;
    String nombre = nombreController.text;

    if (codigo.isEmpty || cantidad.isEmpty || nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, complete todos los campos')),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('MS_ESTADO')
        .where('CODIGO', isEqualTo: codigo)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        String oldCantidad = doc['CANTIDAD'];

        querySnapshot.docs.first.reference.update({'CANTIDAD': cantidad}).then(
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cantidad actualizada')),
            );
            _clearFields();
            setState(() {
              _documentoData = null;
            });

            FirebaseFirestore.instance.collection('MS_REGISTRO').add({
              'CODIGO': codigo,
              'DIFERENCIA':
                  (int.parse(cantidad) - int.parse(oldCantidad)).toString(),
              'CANTIDAD_ANTES': oldCantidad,
              'CANTIDAD_ACTUAL': cantidad,
              'DESCRIPCION': doc['DESCRIPCION'],
              'SKU': doc['SKU'],
              'NOMBRE': nombre,
              'FECHA_HORA': DateTime.now(),
              'MOVIMIENTO': int.parse(cantidad) - int.parse(oldCantidad) >= 0
                  ? 'INGRESO'
                  : 'EGRESO',
            });
          },
        ).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar la cantidad')),
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se encontró un documento con ese código')),
        );
      }
    });
  }

  // Function to view document data
  void _verDatosDocumento() {
    String codigo = codigoController.text;

    if (codigo.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('MS_ESTADO')
          .where('CODIGO', isEqualTo: codigo)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;
          setState(() {
            _documentoData = doc.data() as Map<String, dynamic>;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('No se encontró un documento con ese código')),
          );
        }
      });
    }
  }

  // Function to scan barcode
  Future<void> _escanearCodigo() async {
    String codigoEscaneado = await FlutterBarcodeScanner.scanBarcode(
      '#FF0000',
      'Cancelar',
      true,
      ScanMode.DEFAULT,
    );

    if (codigoEscaneado != '-1') {
      codigoController.text = codigoEscaneado;
      _verDatosDocumento();
    }
  }
  

void _generarExcel() async {
  final excel = Excel.createExcel();
  final sheet = excel['NombreHoja']; // Cambia 'NombreHoja' al nombre deseado

  // Agregar encabezados
  sheet.appendRow([
    'Código',
    'SKU',
    'Descripción',
    'Cantidad Actual',
    'Cantidad Anterior',
    'Diferencia',
    'Movimiento',
    'Fecha y Hora',
    'Nombre',
  ]);

  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(Duration(days: 1));

  final querySnapshot = await FirebaseFirestore.instance
      .collection('MS_REGISTRO')
      .where('FECHA_HORA', isGreaterThanOrEqualTo: startOfDay)
      .where('FECHA_HORA', isLessThan: endOfDay)
      .get();

  for (final doc in querySnapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final formattedTime = DateFormat('HH:mm:ss').format(data['FECHA_HORA'].toDate());

    sheet.appendRow([
      data['CODIGO'],
      data['SKU'],
      data['DESCRIPCION'],
      data['CANTIDAD_ACTUAL'],
      data['CANTIDAD_ANTES'],
      data['DIFERENCIA'],
      data['MOVIMIENTO'],
      formattedTime,
      data['NOMBRE'],
    ]);
  }

  // Guardar el archivo Excel con un nombre específico
  final excelFile = await excel.encode();
  
  if (excelFile != null) {
    final dir = await getExternalStorageDirectory();
  
    if (dir != null) {
      final excelPath = '${dir.path}/nombre_archivo.xlsx'; // Cambia 'nombre_archivo.xlsx' al nombre deseado
  
      final file = File(excelPath);
      await file.writeAsBytes(excelFile);
  
      // Abrir el archivo en Excel
      try {
        await OpenFile.open(excelPath);
      } catch (e) {
        // Muestra un SnackBar en caso de error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al abrir el archivo en Excel')),
        );
      }
    } else {
      // Manejar el caso en que dir sea nulo
    }
  } else {
    // Manejar el caso en que excelFile sea nulo
  }
}


  // Helper function to clear text fields
  void _clearFields() {
    codigoController.clear();
    cantidadController.clear();
    nombreController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var verdeoscuro = Color.fromARGB(255, 1, 18, 2);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'BODEGA (I / E)',
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
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text Form Field for Code
              _buildTextField(
                controller: codigoController,
                labelText: 'CODIGO',
                onPressed: _verDatosDocumento,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _escanearCodigo,
                child: Text('Escanear Código de Barras'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(136, 1, 16, 4),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (_documentoData != null) ...[
                // Display Document Data
                _buildDocumentDataWidget(),
                SizedBox(height: 10),
              ],
              // Text Form Field for New Quantity
              _buildTextField(
                controller: cantidadController,
                labelText: 'NUEVA CANTIDAD',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              // Text Form Field for Name
              _buildTextField(
                controller: nombreController,
                labelText: 'NOMBRE',
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _actualizarCantidad,
                  child: Text('ACTUALIZAR CANTIDAD'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 1, 16, 4),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Center(
                    child: Text(
                      'HISTORIAL DEL DIA',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _generarExcel();
                      },
                      child: Text("VER EXCEL"))
                ],
              ),
              // StreamBuilder for History
              _buildHistoryStreamBuilder(),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build Text Form Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onPressed,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 23.0,
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Color.fromARGB(183, 6, 71, 22),
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(171, 255, 255, 255),
        ),
        suffixIcon: IconButton(
          onPressed: onPressed,
          icon: Icon(Icons.search),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }

  // Helper function to build Document Data Widget
  Widget _buildDocumentDataWidget() {
    return Container(
      /////111111111
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'CANTIDAD:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 72, 129, 25),
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${_documentoData!['CANTIDAD']}',
                  style: TextStyle(
                    color: Color.fromARGB(255, 26, 152, 57),
                    fontSize: 25,
                  ),
                ),
                Text(
                  'CODIGO:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${_documentoData!['CODIGO']}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'DESCRIPCION:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${_documentoData!['DESCRIPCION']}',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'MARCA:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${_documentoData!['SKU']}',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          if (_documentoData!['imageUrl'] != null)
            Container(
              width: 150,
              height: 200,
              child: Image.network(
                _documentoData!['imageUrl'],
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  // Helper function to build StreamBuilder for History
  // Helper function to build StreamBuilder for History
  Widget _buildHistoryStreamBuilder() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(Duration(days: 1));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('MS_REGISTRO')
          .where('FECHA_HORA', isGreaterThanOrEqualTo: startOfDay)
          .where('FECHA_HORA', isLessThan: endOfDay)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> reversedDocs =
              snapshot.data!.docs.reversed.toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: reversedDocs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              String formattedTime =
                  DateFormat('HH:mm:ss').format(data['FECHA_HORA'].toDate());
              Color movimientoColor = data['MOVIMIENTO'] == 'INGRESO'
                  ? const Color.fromARGB(255, 24, 82, 26)
                  : Colors.red;

              return Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(132, 255, 255, 255),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Código:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${data['CODIGO']}'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('SKU:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${data['SKU']}'),
                      ],
                    ),
                    Text('DESCRIPCION:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${data['DESCRIPCION']}'),
                    Row(
                      children: [
                        Text('Cantidad Actual:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${data['CANTIDAD_ACTUAL']}'),
                        SizedBox(width: 10),
                        Text('Cantidad Anterior:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${data['CANTIDAD_ANTES']}'),
                      ],
                    ),
                    Row(
                      children: [
                        Text('DIFERENCIA:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${data['DIFERENCIA']}'),
                        SizedBox(width: 10),
                        Text('${data['MOVIMIENTO']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: movimientoColor)),
                        SizedBox(width: 10),
                      ],
                    ),
                    Text('FECHA_HORA:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$formattedTime'),
                    Text('NOMBRE:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${data['NOMBRE']}'),
                  ],
                ),
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return Text('Error al cargar los datos');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
