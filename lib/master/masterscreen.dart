import 'package:CampoyTT/master/OtrosScreen.dart';
import 'package:CampoyTT/master/PPC.dart';
import 'package:CampoyTT/master/Panaderia.dart';
import 'package:flutter/material.dart';
import 'package:CampoyTT/master/ComidaRapidaScreen.dart';
import 'package:CampoyTT/master/fruteriascreen.dart';
import 'dart:async';



import 'MasterDescarga.dart';
import 'POScreen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({Key? key}) : super(key: key);

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    FruteriaScreen(),
    ComidaRapidaScreen(),
    POScreen(),
    PPCScreen(),
    PanaderiaScreen(),
    OtrosScreen(),
    MasterDescarga()
  ];

  void _onTabTapped(int index) {
  // Delay for 2 seconds using Future.delayed
  Future.delayed(Duration(seconds: 1, milliseconds: 30), () {
    setState(() {
      _currentIndex = index;
    });
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF419240),
            icon: Container(
              width: _currentIndex == 0 ? 80 : 40,
              height: _currentIndex == 0 ? 80 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/manzana.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'Frutas',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF419240),
            icon: Container(
              width: _currentIndex == 1 ? 80 : 40,
              height: _currentIndex == 1 ? 80 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/comidarapida.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'Com.Rapida',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF419240),
            icon: Container(
              width: _currentIndex == 2 ? 80 : 40,
              height: _currentIndex == 2 ? 80 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/oferta.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'Prod. en Oferta',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF419240),
            icon: Container(
              width: _currentIndex == 3 ? 80 : 40,
              height: _currentIndex == 3 ? 80 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/pollocarnecerdo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'Pollo-Carne-Cerdo',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF419240),
            icon: Container(
              width: _currentIndex == 4 ? 80 : 40,
              height: _currentIndex == 4 ? 80 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/panaderia.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'Panaderia',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF419240),
            icon: Container(
              width: _currentIndex == 5 ? 80 : 40,
              height: _currentIndex == 5 ? 80 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/panaderia.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'Otros',
          ),
          BottomNavigationBarItem(
            backgroundColor: const Color(0xFF419240),
            icon: Container(
              width: _currentIndex == 5 ? 80 : 40,
              height: _currentIndex == 5 ? 80 : 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/panaderia.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            label: 'DESCARGAR',
          ),
        ],
        fixedColor: Color.fromARGB(255, 4, 52, 4),
        unselectedItemColor: const Color.fromARGB(117, 255, 255, 255),
      ),
    );
  }
}
