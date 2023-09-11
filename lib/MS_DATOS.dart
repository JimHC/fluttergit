import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

class MS_DATOS extends StatefulWidget {
  const MS_DATOS({super.key});

  @override
  State<MS_DATOS> createState() => _MS_DATOSState();
}

class _MS_DATOSState extends State<MS_DATOS> {


  Future<void> _openExcel() async {
    final Excel excel = Excel.createExcel();
    final Sheet sheet = excel['Sheet1'];

    // Adding headers
    sheet.appendRow(['CANTIDAD', 'CODIGO', 'DESCRIPCION', 'SKU']);

    // Fetching data from Firestore and adding to Excel
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('MS_ESTADO').get();
    snapshot.docs.forEach((document) {
      sheet.appendRow([
        document['CANTIDAD'],
        document['CODIGO'],
        document['DESCRIPCION'],
        document['SKU'],
      ]);
    });

    // Save the Excel file
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String filePath = '$appDocPath/ms_estado.xlsx';

    final List<int>? excelBytes = await excel.save();
    if (excelBytes != null) {
      final File file = File(filePath);
      await file.writeAsBytes(excelBytes);

      // Open the Excel file
      OpenFile.open(filePath);
    } else {
      // Handle the case where saving Excel bytes failed
      print('Error saving Excel file');
    }
  }


Future<void> _openExcel3() async {
  final Excel excel = Excel.createExcel();
  final Sheet sheet = excel['Sheet1'];

  // Adding headers
  sheet.appendRow([
    'BODEGA',
    'CANTIDAD_ACTUAL',
    'CODIGO',
    'DESCRIPCION',
    'FECHA',
    'HORA', // Nueva columna para la hora
    'NOMBRE',
    'PV',
    'SKU',
    'TURNO'
  ]);

  // Fetching data from Firestore and adding to Excel
  QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('MS_CONTEO').get();
  snapshot.docs.forEach((document) {
    // Convertir Timestamp a DateTime
    Timestamp timestamp = document['FECHA_HORA'];
    DateTime fechaHora = timestamp.toDate();

    // Formatear la fecha y hora en los formatos deseados
    String fechaFormateada = DateFormat('dd MMMM yyyy').format(fechaHora);
    String horaFormateada = DateFormat('HH:mm:ss').format(fechaHora);

    sheet.appendRow([
      document['BODEGA'],
      document['CANTIDAD_ACTUAL'],
      document['CODIGO'],
      document['DESCRIPCION'],

      fechaFormateada, // Usar la fecha formateada aquí
      horaFormateada, // Usar la hora formateada aquí
      document['NOMBRE'],
      document['PV'],
      document['SKU'],
      document['TURNO'],
    ]);
  });

  // Save the Excel file
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  final String filePath = '$appDocPath/ms_registro.xlsx';

  final List<int>? excelBytes = await excel.save();
  if (excelBytes != null) {
    final File file = File(filePath);
    await file.writeAsBytes(excelBytes);

    // Open the Excel file
    OpenFile.open(filePath);
  } else {
    // Handle the case where saving Excel bytes failed
    print('Error saving Excel file');
  }
}


  Future<void> _openExcel2() async {
  final Excel excel = Excel.createExcel();
  final Sheet sheet = excel['Sheet1'];

  // Adding headers
  sheet.appendRow([
    'CANTIDAD_ACTUAL',
    'CANTIDAD_ANTES',
    'CODIGO',
    'DESCRIPCION',
    'DIFERENCIA',
    'FECHA',
    'HORA', // Nueva columna para la hora
    'MOVIMIENTO',
    'NOMBRE',
    'SKU'
  ]);

  // Fetching data from Firestore and adding to Excel
  QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('MS_REGISTRO').get();
  snapshot.docs.forEach((document) {
    // Convertir Timestamp a DateTime
    Timestamp timestamp = document['FECHA_HORA'];
    DateTime fechaHora = timestamp.toDate();

    // Formatear la fecha y hora en los formatos deseados
    String fechaFormateada = DateFormat('dd MMMM yyyy').format(fechaHora);
    String horaFormateada = DateFormat('HH:mm:ss').format(fechaHora);

    sheet.appendRow([
      document['CANTIDAD_ACTUAL'],
      document['CANTIDAD_ANTES'],
      document['CODIGO'],
      document['DESCRIPCION'],
      document['DIFERENCIA'],
      fechaFormateada, // Usar la fecha formateada aquí
      horaFormateada, // Usar la hora formateada aquí
      document['MOVIMIENTO'],
      document['NOMBRE'],
      document['SKU'],
    ]);
  });

  // Save the Excel file
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  final String filePath = '$appDocPath/ms_registro.xlsx';

  final List<int>? excelBytes = await excel.save();
  if (excelBytes != null) {
    final File file = File(filePath);
    await file.writeAsBytes(excelBytes);

    // Open the Excel file
    OpenFile.open(filePath);
  } else {
    // Handle the case where saving Excel bytes failed
    print('Error saving Excel file');
  }
}



  
  
 Future<void> _createPDF3() async {
  final pdf = pw.Document();

  // Fetching data from Firestore
  DateTime today = DateTime.now();
  DateTime startOfDay = DateTime(today.year, today.month, today.day);
  DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

  QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
      .instance
      .collection('MS_CONTEO')
      .where('FECHA_HORA', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay)
      .get();

  // Adding headers
  List<List<String>> data = [
    [
      'BODEGA',
      'CANTIDAD_ACTUAL',
      'CODIGO',
      'DESCRIPCION',
      'FECHA_HORA',
      'NOMBRE',
      'PV',
      'SKU',
      'TURNO'
    ]
  ];

  snapshot.docs.forEach((document) {
    // Convertir Timestamp a DateTime
    Timestamp timestamp = document['FECHA_HORA'];
    DateTime fechaHora = timestamp.toDate();

    // Formatear la fecha y hora en el formato deseado
    String fechaHoraFormateada = DateFormat('dd MMMM yyyy, HH:mm:ss').format(fechaHora);

    // Agregar datos al array
    data.add([
      document['BODEGA'],
      document['CANTIDAD_ACTUAL'],
      document['CODIGO'],
      document['DESCRIPCION'],
      fechaHoraFormateada, // Usar la fecha y hora formateada aquí
      document['NOMBRE'],
      document['PV'],
      document['SKU'],
      document['TURNO'],
    ]);
  });

  // Creating a table format
  pdf.addPage(pw.Page(
    build: (pw.Context context) {
      return pw.Table.fromTextArray(
        context: context,
        data: data,
        border: pw.TableBorder.all(
          color: PdfColors.black,
          width: 1,
        ),
        cellAlignment: pw.Alignment.centerLeft,
      );
    },
  ));

  // Save the PDF file
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  final String filePath = '$appDocPath/ms_registro.pdf';

  final File file = File(filePath);
  await file.writeAsBytes(await pdf.save());

  // Open the PDF file
  OpenFile.open(filePath);
}

  Future<void> _createPDF2() async {
    final pdf = pw.Document();

    // Fetching data from Firestore
    DateTime today = DateTime.now();
    DateTime startOfDay = DateTime(today.year, today.month, today.day);
    DateTime endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('MS_REGISTRO')
        .where('FECHA_HORA', isGreaterThanOrEqualTo: startOfDay, isLessThanOrEqualTo: endOfDay)
        .get();

    // Adding data to PDF
    List<List<String>> data = [];

    // Adding headers
    data.add([
      'CANTIDAD_ACTUAL',
      'CANTIDAD_ANTES',
      'CODIGO',
      'DESCRIPCION',
      'DIFERENCIA',
      'FECHA_HORA',
    ]);

    snapshot.docs.forEach((document) {
      // Convertir Timestamp a DateTime
      Timestamp timestamp = document['FECHA_HORA'];
      DateTime fechaHora = timestamp.toDate();

      // Formatear la fecha y hora en el formato deseado
      String fechaHoraFormateada = DateFormat('dd MMMM yyyy, HH:mm:ss').format(fechaHora);

      data.add([
        document['CANTIDAD_ACTUAL'],
        document['CANTIDAD_ANTES'],
        document['CODIGO'],
        document['DESCRIPCION'],
        document['DIFERENCIA'],
        fechaHoraFormateada, // Usar la fecha y hora formateada aquí
      ]);
    });

    // Creating a table format
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Table.fromTextArray(
          context: context,
          data: data,
          border: pw.TableBorder.all(
            color: PdfColors.black,
            width: 1,
          ),
          cellAlignment: pw.Alignment.centerLeft,
        );
      },
    ));

    // Save the PDF file
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String filePath = '$appDocPath/ms_registro.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    OpenFile.open(filePath);
  }


  Future<void> _createPDF() async {
    final pdf = pw.Document();

    // Fetching data from Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('MS_ESTADO').get();

    // Adding data to PDF
    List<List<String>> data = [];

    // Adding headers

    data.add(['CANTIDAD', 'CODIGO', 'DESCRIPCION', 'SKU']);

    snapshot.docs.forEach((document) {
      data.add([
        document['CANTIDAD'],
        document['CODIGO'],
        document['DESCRIPCION'],
        document['SKU'],
      ]);
    });

    // Creating a table format
    pdf.addPage(pw.Page(
      build: (pw.Context context) {
        return pw.Table.fromTextArray(
          context: context,
          data: data,
          border: pw.TableBorder.all(
            color: PdfColors.black,
            width: 1,
          ),
          cellAlignment: pw.Alignment.centerLeft,
        );
      },
    ));

    // Save the PDF file
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    final String filePath = '$appDocPath/ms_estado.pdf';

    final File file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the PDF file
    OpenFile.open(filePath);
  }

  @override
 Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('REPORTE GENERAL MS'),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          // Containers for EXCEL
          Container(
            
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromARGB(255, 35, 199, 68),
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
              children: [
                Text("EXCEL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  
                  child: Column(
                    children: [
                      // Botón 1
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                          children: [
                            Text("REPORTE GENERAL CODIGOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Obtiene todo los codigos y sus descripciones"),
                            ElevatedButton(
                              onPressed: _openExcel,
                              child: const Text('CODIGOS'),
                            ),
                          ],
                        ),
                      ),
                      
                      // Botón 2
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                          children: [
                            Text("EGRESOS / INGRESOS ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Obtiene todo los ingresos y egresos que fueron realizados"),
                            ElevatedButton(
                              onPressed: _openExcel2,
                              child: const Text('MOVIMIENTOS'),
                            ),
                          ],
                        ),
                      ),
                      
                      // Botón 3
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                          children: [
                            Text("TRICONTEOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Obtiene todo los conteos de Marca Sensible hechas generalmente por OPERACIONES"),
                            ElevatedButton(
                              onPressed: _openExcel3,
                              child: const Text('TRICONTEOS'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Containers for PDF
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Color.fromARGB(255, 192, 80, 80),
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
              children: [
                Text("PDF", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Botón 4
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                          children: [
                            Text("LISTADO PDF", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Ver en PDF los codigos y sus descripciones "),
                            ElevatedButton(
                              onPressed: _createPDF,
                              child: const Text('PDF MS_ESTADO'),
                            ),
                          ],
                        ),
                      ),
                      
                      // Botón 5
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                          children: [
                            Text("EGRESOS / INGRESOS DEL DIA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Obtiene los Ingresos y Egresos del dia actual"),
                            ElevatedButton(
                              onPressed: _createPDF2,
                              child: const Text('PDF_MOVIMIENTOS'),
                            ),
                          ],
                        ),
                      ),
                      
                      // Botón 6
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(vertical: 8),
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
                          children: [
                            Text("Triconteos del dia", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("Obtiene los conteos de MS del dia actual"),
                            ElevatedButton(
                              onPressed: _createPDF3,
                              child: const Text('PDF_TRICONTEOS'),
                            ),
                          ],
                        ),
                      ),
                    ],
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