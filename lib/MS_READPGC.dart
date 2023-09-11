import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

int _numDocumentos = 0;

class MS_READ_PGC extends StatefulWidget {
  @override
  _MS_READ_PGCState createState() => _MS_READ_PGCState();
}

class _MS_READ_PGCState extends State<MS_READ_PGC> {
  TextEditingController _codigoController = TextEditingController();
  TextEditingController _diaController = TextEditingController();
  TextEditingController _mesController = TextEditingController();
  Map<String, dynamic>? _documentoData;

  MS_READ_PGCFirestoreService _registroService = MS_READ_PGCFirestoreService();
  List<QueryDocumentSnapshot> _searchResults = [];
  bool _codigoDisabled = false;
  bool _isLoading = false;
  bool _showExpanded = false;
  bool _scanButtonDisabled = false;
  var colorxd = Color.fromARGB(183, 6, 71, 22);

  void _clearFields() {
    setState(() {
      _codigoController.clear();
      _diaController.clear();
      _mesController.clear();
      _codigoDisabled = false;
      _showExpanded = false;
      _scanButtonDisabled = false;
    });
  }

  Future<void> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancelar",
      true,
      ScanMode.BARCODE,
    );

    if (!mounted) return;

    setState(() {
      _codigoController.text = barcodeScanRes;
    });
  }

  void _searchByCodeAndDate() async {
    setState(() {
      _isLoading = true;
      _showExpanded = false;
    });

    String codigo = _codigoController.text;
    int dia = int.tryParse(_diaController.text) ?? -1;
    int mes = int.tryParse(_mesController.text) ?? -1;

    if (!_codigoDisabled && codigo.isNotEmpty && dia > 0 && mes <= 0) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error de búsqueda'),
            content: Text('Buscar solo por código y día no tiene sentido.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    Set<QueryDocumentSnapshot> resultsSet = Set<QueryDocumentSnapshot>();

    if (_codigoDisabled) {
      resultsSet.addAll(await _registroService.searchByDate(dia, mes));
    } else {
      if (dia <= 0) {
        resultsSet.addAll(
            await _registroService.searchByCodeAndDate(codigo, -1, mes));
      } else {
        resultsSet.addAll(
            await _registroService.searchByCodeAndDate(codigo, dia, mes));
      }
    }

    List<QueryDocumentSnapshot> results = resultsSet.toList();

    results = results.where((result) {
      final data = result.data() as Map<String, dynamic>;
      final fechaHora = data['FECHA_HORA'].toDate();
      return fechaHora.month == mes;
    }).toList();

    setState(() {
      _searchResults = results;
      _isLoading = false;
      _showExpanded = true;
      _numDocumentos = _searchResults.length;
    });
  }

  void _verDatosDocumento() {
    String codigo = _codigoController.text;

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

          // Mostrar el AlertDialog con el contenido del documento
          _mostrarAlertDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('No se encontró un documento con ese código')),
          );
        }
      });
    }
  }

  // Método para mostrar el AlertDialog con el contenido del documento
  void _mostrarAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            // Cambia el color de fondo del AlertDialog aquí
          ),
          child: AlertDialog(
            backgroundColor: colorxd,
            title: Text(
              'Datos del codigo',
              style: TextStyle(color: Colors.white),
            ),
            content: _buildDocumentDataWidget(), // Contenido del AlertDialog
            actions: <Widget>[
              TextButton(
                child: Text('Cerrar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportToExcel() async {
    if (_searchResults.isEmpty) {
      return;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      'Código',
      'Descripción',
      'Cantidad Actual',
      'Cantidad Antes',
      'Diferencia',
      'Día',
      'Mes',
      'Año',
      'Hora',
      'Movimiento',
      'Nombre',
      'SKU',
    ]);

    for (final result in _searchResults) {
      final data = result.data() as Map<String, dynamic>;
      final fechaHora = data['FECHA_HORA'].toDate();

      sheet.appendRow([
        data['CODIGO'],
        data['DESCRIPCION'],
        data['CANTIDAD_ACTUAL'],
        data['CANTIDAD_ANTES'],
        data['DIFERENCIA'],
        fechaHora.day, // Día
        fechaHora.month, // Mes
        fechaHora.year, // Año
        DateFormat('HH:mm').format(fechaHora), // Hora
        data['MOVIMIENTO'],
        data['NOMBRE'],
        data['SKU'],
      ]);
    }

    final bytes = excel.encode()!;

    final directory = (await getApplicationDocumentsDirectory()).path;
    final filePath = '$directory/registro.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    OpenFile.open(filePath);
  }

  Card _buildEndCard() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Simplificar y Disfrutar mas la vida',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'MOVIMIENTO',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 1, 18, 2),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/gifdefondo2.gif'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Flexible(
                      flex: 5,
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 23),
                        keyboardType: TextInputType.number,
                        controller: _codigoController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed:
                                _scanButtonDisabled ? null : _scanBarcode,
                            icon: Icon(Icons.qr_code_scanner),
                          ),
                          labelText: 'Buscar por Código',
                          filled: true,
                          fillColor: colorxd,
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
                        enabled: !_codigoDisabled,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints:
                    BoxConstraints(maxWidth: 150), // Establece el ancho máximo deseado
                child: ElevatedButton(
                  onPressed: _verDatosDocumento,
                  child: Row(
                    children: [
                      Icon(Icons.search),
                      SizedBox(
                          width:
                              8), // Espacio entre el icono y el texto
                      Text("Ver Datos"), // Tu texto de búsqueda aquí
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(136, 1, 16, 4),
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              CheckboxListTile(
                title: Text(
                  'Seleccione aquí si desea buscar para todos los códigos',
                  style: TextStyle(color: Colors.white),
                ),
                value: _codigoDisabled,
                onChanged: (value) {
                  setState(() {
                    _codigoDisabled = value ?? false;
                    _scanButtonDisabled = _codigoDisabled;
                  });
                },
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 23),
                        controller: _diaController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Día',
                          filled: true,
                          fillColor: colorxd,
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
                    ),
                    SizedBox(width: 16),
                    Flexible(
                      child: TextField(
                        style: TextStyle(color: Colors.white, fontSize: 23),
                        controller: _mesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Mes',
                          filled: true,
                          fillColor: colorxd,
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
                    ),
                  ],
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _searchByCodeAndDate,
                      child: Icon(Icons.search),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(136, 1, 16, 4),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: _exportToExcel,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insert_drive_file,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Excel',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(136, 1, 16, 4),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      onPressed: _clearFields,
                      child: Icon(
                        Icons.refresh,
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(136, 1, 16, 4),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    Text(
                      "REGISTROS: $_numDocumentos",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              _isLoading ? CircularProgressIndicator() : SizedBox(),
              _showExpanded
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: _searchResults.length + 1,
                        itemBuilder: (context, index) {
                          if (index < _searchResults.length) {
                            final data = _searchResults[index].data()
                                as Map<String, dynamic>;
                            final fechaHora = data['FECHA_HORA'].toDate();
                            final formattedFechaHora =
                                DateFormat('dd MMM yyyy, HH:mm')
                                    .format(fechaHora);
                            return Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
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
                                  Center(child: Text(' ${data['CODIGO']}',style: TextStyle(color: Color.fromARGB(255, 4, 74, 16),fontWeight: FontWeight.bold,fontSize: 20),)),
                                  SizedBox(height: 5,),
                                  Text("Descripcion: ",style: TextStyle(fontWeight: FontWeight.bold),),
                                  Text('${data['DESCRIPCION']}'),
                                  Row(children: [
                                    Text("C.Actual: ",style: TextStyle(fontWeight: FontWeight.bold),),
                                    Text(
                                      
                                      '${data['CANTIDAD_ACTUAL']}'),
                                      SizedBox(width: 20,),
                                      Text("C.Antes",style: TextStyle(fontWeight: FontWeight.bold)),
                                      Text(
                                      '${data['CANTIDAD_ANTES']}'),
                                      SizedBox(width: 20,),
                                      Text("Dif: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                                                        Text('${data['DIFERENCIA']}'),


                                  ],),
                                  Row(children: [
                                    Text("Fecha/Hora: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('$formattedFechaHora'),

                                  ],),
                                  Row(children: [
                                    Text("Movimiento: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${data['MOVIMIENTO']}'),
                                    
                                  ],),
                                  Row(children: [
                                    Text("Nombre: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${data['NOMBRE']}'),
                                    
                                  ],),

                                  Row(children: [ Text("Marca: ",style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('${data['SKU']}'),
                                    
                                  ],),
                                  

                                  

                                  
                                 
                                ],
                              ),
                            );
                          } else {
                            // Último ítem de la lista, muestra el Card
                            return _buildEndCard();
                          }
                        },
                      ),
                    )
                  : Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50,
                          ),
                          Image.asset(
                            'assets/tottusgente2.jpg',
                            width: 300,
                            colorBlendMode: BlendMode.modulate,
                            height: 200,
                            color: Color.fromRGBO(208, 229, 207,
                                0.663), // Aplica una transparencia del 50%
                          )
                        ],
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentDataWidget() {
    return SingleChildScrollView(
      child: Container(
        color: colorxd,
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
            ),
          ],
        ),
      ),
    );
  }
}

class MS_READ_PGCFirestoreService {
  final CollectionReference _registroCollection =
      FirebaseFirestore.instance.collection('MS_REGISTRO');

  Future<List<QueryDocumentSnapshot>> searchByCodeAndDate(
      String codigo, int dia, int mes) async {
    try {
      Query query = _registroCollection.where('CODIGO', isEqualTo: codigo);

      if (dia > 0 && mes > 0) {
        QuerySnapshot snapshot = await query.get();
        List<QueryDocumentSnapshot> filteredResults = [];

        for (QueryDocumentSnapshot doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fechaHora = data['FECHA_HORA'].toDate();
          if (fechaHora.day == dia && fechaHora.month == mes) {
            filteredResults.add(doc);
          }
        }

        return filteredResults;
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error searching by code and date: $e');
      return [];
    }
  }

  Future<List<QueryDocumentSnapshot>> searchByDate(int dia, int mes) async {
    try {
      if (dia > 0 && mes > 0) {
        QuerySnapshot snapshot = await _registroCollection.get();
        List<QueryDocumentSnapshot> filteredResults = [];

        for (QueryDocumentSnapshot doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final fechaHora = data['FECHA_HORA'].toDate();
          if (fechaHora.day == dia && fechaHora.month == mes) {
            filteredResults.add(doc);
          }
        }

        return filteredResults;
      }

      final querySnapshot = await _registroCollection.get();

      return querySnapshot.docs;
    } catch (e) {
      print('Error searching by date: $e');
      return [];
    }
  }
}

void main() {
  runApp(MaterialApp(
    title: 'MS_READ_PGC',
    theme: ThemeData(
      primarySwatch: Colors.green,
    ),
    home: MS_READ_PGC(),
  ));
}

