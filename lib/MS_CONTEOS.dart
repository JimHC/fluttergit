import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

void main() {
  runApp(MaterialApp(home: MS_CONTEO()));
}

class MS_CONTEO extends StatefulWidget {
  const MS_CONTEO({Key? key}) : super(key: key);

  @override
  _MS_CONTEOState createState() => _MS_CONTEOState();
}

class _MS_CONTEOState extends State<MS_CONTEO> {
  final TextEditingController codigoController = TextEditingController();
  final TextEditingController cantidadController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController bodegaController = TextEditingController();
  final TextEditingController pvController = TextEditingController();
  String selectedOption = "MAÑANA"; // Opción seleccionada por defecto

  Map<String, dynamic>? _documentoData;

  void _actualizarCantidad() {
    String codigo = codigoController.text;
    String cantidad = cantidadController.text;
    String nombre = nombreController.text;
    String bodega = bodegaController.text;
    String pv = pvController.text;
    String turno = selectedOption;

    if (codigo.isNotEmpty && cantidad.isNotEmpty && nombre.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('MS_ESTADO')
          .where('CODIGO', isEqualTo: codigo)
          .get()
          .then((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          var doc = querySnapshot.docs.first;

          querySnapshot.docs.first.reference
              .update({'CANTIDAD': cantidad}).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cantidad actualizada')),
            );
            codigoController.clear();
            cantidadController.clear();
            nombreController.clear();
            bodegaController.clear();
            pvController.clear();
            setState(() {
              _documentoData = null;
            });

            FirebaseFirestore.instance.collection('MS_CONTEO').add({
              'CODIGO': codigo,
              'CANTIDAD_ACTUAL': cantidad,
              'DESCRIPCION': doc['DESCRIPCION'],
              'SKU': doc['SKU'],
              'NOMBRE': nombre,
              'FECHA_HORA': DateTime.now(),
              'BODEGA': bodega,
              'PV': pv,
              'TURNO': turno
            });
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al actualizar la cantidad')),
            );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PROYECTO MS OP')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: codigoController,
              decoration: InputDecoration(
                labelText: 'Código',
                suffixIcon: IconButton(
                  onPressed: _verDatosDocumento,
                  icon: Icon(Icons.search),
                ),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _escanearCodigo,
              child: Text('Escanear Código de Barras'),
            ),
            if (_documentoData != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BODEGA:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_documentoData!['CANTIDAD']}'),
                        Text('CODIGO:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_documentoData!['CODIGO']}'),
                        Text('DESCRIPCION:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_documentoData!['DESCRIPCION']}'),
                        Text('SKU:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${_documentoData!['SKU']}'),
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
            ],
            TextFormField(
              controller: nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextFormField(
              controller: bodegaController,
              decoration: InputDecoration(labelText: 'Bodega'),
            ),
            TextFormField(
              controller: pvController,
              decoration: InputDecoration(labelText: 'Piso de Venta'),
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: cantidadController,
              decoration: InputDecoration(labelText: 'OH DISPONIBLE'),
            ),
            SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              value: selectedOption,
              onChanged: (newValue) {
                setState(() {
                  selectedOption = newValue!;
                });
              },
              items: ["MAÑANA", "TARDE", "NOCHE"]
                  .map((option) => DropdownMenuItem(
                        value: option,
                        child: Text(option),
                      ))
                  .toList(),
              decoration: InputDecoration(
                labelText: "Selecciona una opción",
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _actualizarCantidad,
              child: Text('Actualizar Cantidad'),
            ),
            SizedBox(height: 32),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('MS_CONTEO')
                  .where('FECHA_HORA',
                      isGreaterThanOrEqualTo:
                          DateTime.now().subtract(Duration(days: 1)).toUtc(),
                      isLessThan: DateTime.now().add(Duration(days: 1)).toUtc())
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Widget> documentosWidgets = [];
                  snapshot.data!.docs.forEach((document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    documentosWidgets.add(
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('BODEGA: ${data['BODEGA']}',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('CANTIDAD_ACTUAL: ${data['CANTIDAD_ACTUAL']}'),
                            Text('CODIGO: ${data['CODIGO']}'),
                            Text('DESCRIPCION: ${data['DESCRIPCION']}'),
                            Text('NOMBRE: ${data['NOMBRE']}'),
                            Text('PV: ${data['PV']}'),
                            Text('SKU: ${data['SKU']}'),
                            Text('TURNO: ${data['TURNO']}'),
                            Text('FECHA_HORA: ${data['FECHA_HORA']}'),
                          ],
                        ),
                      ),
                    );
                  });
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 32),
                      Text(
                        'Documentos del día actual:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Column(
                        children: documentosWidgets,
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error al cargar los documentos');
                } else {
                  return CircularProgressIndicator(); // Muestra un indicador de carga mientras se obtienen los datos
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
