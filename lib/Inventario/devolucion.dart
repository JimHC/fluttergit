import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'listmapadevolucion.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Devoluciones(),
    );
  }
}

class Devoluciones extends StatefulWidget {
  const Devoluciones({Key? key}) : super(key: key);

  @override
  State<Devoluciones> createState() => _DevolucionesState();
}

class _DevolucionesState extends State<Devoluciones> {
  final palletController = TextEditingController();
  final responsableController = TextEditingController();
  List<Map<String, dynamic>> productosSeleccionados = [];
  String? gtin;
  int cantidad = 1;
  String observacion = " ";
  Map<String, dynamic>? datos;

  void mostrarVentanaEmergente(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void resetState() {
    setState(() {
      gtin = null;
      cantidad = 1;
      datos = null;
    });
  }

  void mostrarDialogoModificarCantidad(Map<String, dynamic> producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int nuevaCantidad = producto['Cantidad'];
        return AlertDialog(
          title: Text('Modificar cantidad'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  nuevaCantidad = int.tryParse(value) ?? nuevaCantidad;
                },
                decoration: InputDecoration(
                  hintText: 'Ingresar nueva cantidad',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  producto['Cantidad'] = nuevaCantidad;
                });
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
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
        title: Text('Inventario '),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
                keyboardType: TextInputType.number,

              onChanged: (value) {
                setState(() {
                  gtin = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Ingresar EAN o SKU',
                border: OutlineInputBorder(),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      datos = buscarDatosPorGTIN(gtin);
                      if (datos == null) {
                        mostrarVentanaEmergente(
                            'Codigo incorrecto o ya ingresado');
                      }
                    });
                  },
                  child: Icon(Icons.search),
                ),
                ElevatedButton(
                  onPressed: () async {
                    String? barcodeScanResult =
                        await FlutterBarcodeScanner.scanBarcode(
                      '#ff6666',
                      'Cancelar',
                      true, // Habilitar linterna o flash
                      ScanMode.BARCODE,
                    );

                    if (barcodeScanResult != '-1') {
                      setState(() {
                        gtin = barcodeScanResult;
                        datos = buscarDatosPorGTIN(gtin);
                        if (datos == null) {
                          mostrarVentanaEmergente(
                              'Codigo ingresado o ya ingresado');
                        }
                      });
                    }
                  },
                  child: Icon(Icons.barcode_reader),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Ingreso de datos'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Nombre del pallet ?( aplica tambien para el nombre del excel)'),
                              TextFormField(
                                controller: palletController,
                              ),
                              SizedBox(height: 8.0),
                              Text('Ingrese su nombre'),
                              TextFormField(
                                controller: responsableController,
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Aceptar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                generarYGuardarExcel();
                              },
                            ),
                            TextButton(
                              child: Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/devolucion');

                      // Navegar a la pantalla de Devolución
                    },
                    child: Icon(Icons.refresh)),
                ElevatedButton(
                    onPressed: generarYGuardarExcel,
                    child: Icon(Icons.download)),
              ],
            ),
            SizedBox(height: 16),
            if (datos != null)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('GTIN: ${datos!['GTIN']}'),
                      Text('SKU: ${datos!['Sku']}'),
                      Text('Descripción: ${datos!['Descripcion']}'),
                      Text('Marca: ${datos!['Marca']}'),
                      Text('Clasificacion: ${datos!['Clasificacion']}'),
                      SizedBox(height: 16),
                      Text('Cantidad:'),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  cantidad = int.tryParse(value) ?? 0;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Ingresar cantidad',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (datos != null) {
                                  if (!productosSeleccionados.any((producto) =>
                                      producto['GTIN'] == datos!['GTIN'])) {
                                    productosSeleccionados.add({
                                      'GTIN': datos!['GTIN'],
                                      'Sku': datos!['Sku'],
                                      'Descripcion': datos!['Descripcion'],
                                      'Marca': datos!['Marca'],
                                      'Cantidad': cantidad,
                                      'Observacion':datos!['Clasificacion']
                                    });
                                    datos =
                                        null; // Establecer datos como null para ocultar el widget Card
                                  } else {
                                    mostrarVentanaEmergente(
                                        'PRODUCTO YA REGISTRADO');
                                  }
                                }
                              });
                            },
                            child: Text('Agregar'),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.text,
                              onChanged: (value) {
                                setState(() {
                                  observacion = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Ingresar alguna observacion',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: productosSeleccionados.length,
                itemBuilder: (context, index) {
                  final producto = productosSeleccionados[index];
                  final numeroIndice = index + 1; // Obtener el número de índice

                  return ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Número: $numeroIndice'), // Mostrar el número de índice
                        Text('${producto['Descripcion']}'),
                        Text('Cantidad: ${producto['Cantidad']}'),
                      ],
                    ),
                    onTap: () {
                      mostrarDialogoModificarCantidad(producto);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic>? buscarDatosPorGTIN(String? codigo) {
    for (var fila in tablaDatos) {
      if (fila['GTIN'] == codigo || fila['Sku'] == codigo) {
        if (!productosSeleccionados.any((producto) =>
            producto['GTIN'] == fila['GTIN'] ||
            producto['Sku'] == fila['Sku'])) {
          return fila;
        } else {
          return null; // The product has already been added
        }
      }
    }
    return null;
  }

  Future<void> generarYGuardarExcel() async {
    // Crear el archivo Excel
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.appendRow([
      'Pallet: ',
      palletController.text,
      'Responsable:  ',
      responsableController.text
    ]);

    // Agregar la fila de encabezados
    List<String> encabezados = [
      'Número',
      ...productosSeleccionados[0].keys.toList()
    ];
    sheet.appendRow(encabezados);

    // Agregar cada fila de datos con números consecutivos en la primera columna
    for (var i = 0; i < productosSeleccionados.length; i++) {
      List<dynamic> rowData = [
        i + 1,
        ...productosSeleccionados[i].values.toList()
      ];
      sheet.appendRow(rowData);
    }

    // Obtener la ruta de almacenamiento local
    Directory? directory = await getExternalStorageDirectory();

    if (directory != null) {
      String filePath;
      if (palletController.text.isEmpty) {
        filePath = '${directory.path}/inventario.xlsx';
      } else {
        filePath = '${directory.path}/${palletController.text}.xlsx';
      }

      // Guardar el archivo Excel
      File file = File(filePath);
      await file.writeAsBytes(excel.encode()!);

      print(
          'El archivo Excel ha sido guardado en la siguiente ubicación: $filePath');

      // Abrir el archivo Excel
      await OpenFile.open(filePath);
    } else {
      print('No se pudo acceder al directorio de almacenamiento externo.');
    }
  }
}
