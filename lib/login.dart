// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print

import 'package:dongastonn/globals.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dongastonn/register.dart';
import 'package:dongastonn/menuPrincipal.dart';
import 'package:dongastonn/database/databaseHelper.dart'; // Importa tu DatabaseHelper

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    _passwordVisible = false;
  }

  Future<void> _validarUsuario() async {
    String usuario = _usuarioController.text;
    String contrasena = _contrasenaController.text;

    DatabaseHelper helper = DatabaseHelper();
    await helper.init(); // Asegúrate de inicializar la base de datos

    bool usuarioValido = await helper.checkUser(
        usuario, contrasena); // Implementa esta función en tu DatabaseHelper

    if (usuarioValido) {
      usuarioActual =
          usuario; //Se le asigna el usuario actual a la variable global
      DatabaseHelper helper = DatabaseHelper();
      idUsuarioActual = await helper.getUsuarioId(usuarioActual);
      print("idUsuarioActual: "+idUsuarioActual.toString());
      print("usuarioActual: "+usuarioActual);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MenuPrincipalScreen()),
      );
    } else {
      _mostrarErrorDialog('Usuario o contraseña incorrectos');
    }
  }

  void _mostrarErrorDialog(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el AlertDialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD9D9D9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Iniciar Sesión",
                style: GoogleFonts.orelegaOne(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              Image.asset(
                'img/logoDonGaston.png', // Asegúrate de tener esta imagen en tu proyecto
                width: 250,
                height: 250,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _usuarioController,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.orelegaOne(fontSize: 25),
                      decoration: InputDecoration(
                        hintText: 'Usuario',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onSubmitted: (value) {
                        FocusScope.of(context).nextFocus();
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _contrasenaController,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.orelegaOne(fontSize: 25),
                      decoration: InputDecoration(
                        hintText: 'Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromRGBO(59, 89, 152, 1.0),
                        ),
                      ),
                      onPressed: () async {
                        print("Iniciar Sesión presionado");
                        await _validarUsuario(); // Llama a la función de validación
                      },
                      child: Container(
                        width: double.infinity,
                        height: 65,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: Text(
                            "Iniciar Sesión",
                            style: GoogleFonts.orelegaOne(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Color.fromRGBO(28, 82, 3, 1.0),
                        ),
                      ),
                      onPressed: () async {
                        print("Crear Cuenta presionado");
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CrearCuentaScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 65,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(
                          child: Text(
                            "Crear Cuenta",
                            style: GoogleFonts.orelegaOne(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }
}
