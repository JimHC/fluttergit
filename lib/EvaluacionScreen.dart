import 'dart:async';
import 'package:flutter/material.dart';

class EvaluacionScreen extends StatefulWidget {
  @override
  _EvaluacionScreenState createState() => _EvaluacionScreenState();
}

class _EvaluacionScreenState extends State<EvaluacionScreen> {
  dynamic respuesta1;
  dynamic respuesta2;
  bool mostrarRespuestas = false;
  bool examenTerminado = false;
  Timer? timer;

  int tiempoRestante = 5 * 60; // 5 minutos en segundos

  void evaluarRespuestas() {
    setState(() {
      mostrarRespuestas = true;
    });
    final bool aprobado = calcularAprobacion();
    mostrarResultadoExamen(aprobado);
  }

  void reiniciarExamen() {
    setState(() {
      respuesta1 = null;
      respuesta2 = null;
      mostrarRespuestas = false;
      examenTerminado = false;
      reiniciarCronometro();
    });
  }

  void reiniciarCronometro() {
    if (timer != null) {
      timer!.cancel();
    }
    tiempoRestante = 5 * 60; // Reiniciar el tiempo a 5 minutos
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (tiempoRestante > 0) {
          tiempoRestante--;
        } else {
          timer.cancel();
          mostrarTiempoAgotadoDialog();
          evaluarRespuestas();
        }
      });
    });
  }

  bool calcularAprobacion() {
    int respuestasCorrectas = 0;
    if (respuesta1 == 'a') {
      respuestasCorrectas++;
    }
    if (respuesta2 == 'b') {
      respuestasCorrectas++;
    }
    return respuestasCorrectas >= 2; // Aprobar si hay al menos 2 respuestas correctas
  }

  void mostrarResultadoExamen(bool aprobado) {
    String mensaje = aprobado
        ? 'Felicitaciones, estás apto para el inventario.'
        : 'Desaprobado. Un inventario es algo muy importante para la empresa y para todos. Un error en el conteo perjudicaría a toda la empresa. Vuelve a intentarlo.';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Resultado del examen'),
          content: Text(mensaje),
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
  }

  void mostrarTiempoAgotadoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tiempo agotado'),
          content: Text('El tiempo del examen ha concluido.'),
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
  }

  @override
  void initState() {
    super.initState();
    reiniciarCronometro();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluación'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiempo restante: ${tiempoRestante ~/ 60}:${tiempoRestante % 60}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.0),
              Text(
                '1. ¿Qué es un inventario?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile(
                    title: Text('a) Es un tipo de bla bla bla'),
                    value: 'a',
                    groupValue: respuesta1,
                    onChanged: (value) {
                      setState(() {
                        respuesta1 = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('b) segundo'),
                    value: 'b',
                    groupValue: respuesta1,
                    onChanged: (value) {
                      setState(() {
                        respuesta1 = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('c) tercero'),
                    value: 'c',
                    groupValue: respuesta1,
                    onChanged: (value) {
                      setState(() {
                        respuesta1 = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('d) cuarto'),
                    value: 'd',
                    groupValue: respuesta1,
                    onChanged: (value) {
                      setState(() {
                        respuesta1 = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                '2. ¿Cuáles son los tres primeros datos que se deben tener en cuenta en el inventario?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile(
                    title: Text('a) bla bla bla'),
                    value: 'a',
                    groupValue: respuesta2,
                    onChanged: (value) {
                      setState(() {
                        respuesta2 = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('b) EAN, CANTIDAD, CAJA'),
                    value: 'b',
                    groupValue: respuesta2,
                    onChanged: (value) {
                      setState(() {
                        respuesta2 = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('c) BASDASD'),
                    value: 'c',
                    groupValue: respuesta2,
                    onChanged: (value) {
                      setState(() {
                        respuesta2 = value;
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('d) ASDSAD'),
                    value: 'd',
                    groupValue: respuesta2,
                    onChanged: (value) {
                      setState(() {
                        respuesta2 = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: evaluarRespuestas,
                child: Text('Terminar evaluación'),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: reiniciarExamen,
                    child: Text('Reiniciar examen'),
                  ),
                  ElevatedButton(
                    onPressed: mostrarRespuestas ? mostrarRespuestasCorrectasDialog : null,
                    child: Text('Ver respuestas correctas'),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              mostrarRespuestas
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Respuesta 1:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        respuesta1 == 'a'
                            ? Text(
                                'Correcto: bla bla bla bla',
                                style: TextStyle(color: Colors.green),
                              )
                            : Text(
                                'Incorrecto: bla bla bla',
                                style: TextStyle(color: Colors.red),
                              ),
                        SizedBox(height: 10.0),
                        Text(
                          'Respuesta 2:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        respuesta2 == 'b'
                            ? Text(
                                'Correcto: bla bla bla bla',
                                style: TextStyle(color: Colors.green),
                              )
                            : Text(
                                'Incorrecto: bla bla bla',
                                style: TextStyle(color: Colors.red),
                              ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  void mostrarRespuestasCorrectasDialog() {
    TextEditingController passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respuestas correctas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (passwordController.text == 'lascorrectas') {
                  Navigator.of(context).pop();
                  mostrarRespuestasCorrectas();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contraseña incorrecta.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Ver respuestas'),
            ),
          ],
        );
      },
    );
  }

  void mostrarRespuestasCorrectas() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Respuestas correctas'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Respuesta 1:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Correcto: bla bla bla bla',
                style: TextStyle(color: Colors.green),
              ),
              SizedBox(height: 10.0),
              Text(
                'Respuesta 2:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Correcto: EAN, CANTIDAD, CAJA',
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
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
  }
}

void main() {
  runApp(MaterialApp(
    home: EvaluacionScreen(),
  ));
}



