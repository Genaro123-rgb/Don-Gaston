import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dongastonn/globals.dart';
import 'package:dongastonn/pantallasPrincipales/configuracion.dart';
import 'package:dongastonn/pantallasPrincipales/historial.dart';
import 'package:dongastonn/pantallasPrincipales/nuevoGasto.dart';
import 'package:dongastonn/login.dart';

class MenuPrincipalScreen extends StatefulWidget {
  final int initialPage;

  MenuPrincipalScreen({Key? key, this.initialPage = 0}) : super(key: key);

  @override
  _MenuPrincipalScreenState createState() => _MenuPrincipalScreenState();
}

class _MenuPrincipalScreenState extends State<MenuPrincipalScreen> {
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
  }

  void actualizarTituloUsuario(String nuevoTitulo) {
    setState(() {
      usuarioActual = nuevoTitulo;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Aquí actualizamos el _pages para pasar la función actualizarTituloUsuario a ConfigScreen
    final List<Widget> _pages = [
      NuevoGastoScreen(),
      HistorialScreen(),
      ConfigScreen(actualizarTituloUsuario: actualizarTituloUsuario),
      LoginScreen()
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 214, 204, 204),
        title: Text("Hola, " + usuarioActual),
        automaticallyImplyLeading: false,
      ),
      body: Center(child: _pages.elementAt(_currentPage)),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.moneyBill), label: "Gastos"),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.magnifyingGlassDollar), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.gear), label: "Ajustes"),
          BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.rightFromBracket), label: "Salir"),
        ],
        currentIndex: _currentPage,
        selectedItemColor: Color.fromRGBO(152, 147, 142, 1),
        unselectedItemColor: Color(0xFFD9D9D9),
        backgroundColor: Color.fromRGBO(59, 89, 152, 1.0),
        onTap: (int inIndex) {
          if (inIndex == 3) {
            _showExitConfirmationDialog();
          } else {
            setState(() {
              _currentPage = inIndex;
            });
          }
        },
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text('¿Deseas cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                usuarioActual = "";
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

