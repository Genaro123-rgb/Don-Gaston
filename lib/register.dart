// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dongastonn/database/databaseHelper.dart';
import 'package:dongastonn/login.dart';

class CrearCuentaScreen extends StatefulWidget {
  @override
  _CrearCuentaScreenState createState() => _CrearCuentaScreenState();
}

class _CrearCuentaScreenState extends State<CrearCuentaScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _limiteController = TextEditingController();
  final TextEditingController _contacto1Controller = TextEditingController();
  final TextEditingController _contacto2Controller = TextEditingController();
  final TextEditingController _contacto3Controller = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _contrasenaController.dispose();
    _limiteController.dispose();
    _contacto1Controller.dispose();
    _contacto2Controller.dispose();
    _contacto3Controller.dispose();
    super.dispose();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  Future<void> _openContactPicker(TextEditingController controller) async {
    try {
      await _requestPermission();
      Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Selecciona un contacto"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: contacts.length,
                itemBuilder: (BuildContext context, int index) {
                  Contact contact = contacts.elementAt(index);
                  return ListTile(
                    title: Text(contact.displayName ?? ''),
                    onTap: () {
                      String phoneNumber = contact.phones?.isNotEmpty == true
                          ? contact.phones!.first.value!
                          : 'Número no disponible';
                      controller.text = phoneNumber;
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      print('Error al acceder a los contactos: $e');
    }
  }

  Widget _buildContactField(TextEditingController controller, String hintText) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: GoogleFonts.orelegaOne(fontSize: 25),
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.contacts),
          onPressed: () => _openContactPicker(controller),
        ),
      ],
    );
  }

  Future<void> _registrarUsuario() async {
    if (_nombreController.text.isEmpty ||
        _contrasenaController.text.isEmpty ||
        _limiteController.text.isEmpty ||
        _contacto1Controller.text.isEmpty ||
        _contacto2Controller.text.isEmpty ||
        _contacto3Controller.text.isEmpty) {
      _mostrarErrorDialog('Por favor, rellena todos los campos requeridos.');
      return;
    }

    try {
      Map<String, dynamic> usuario = {
        'nombre': _nombreController.text,
        'contrasena': _contrasenaController.text,
        'limite': double.tryParse(_limiteController.text) ?? 0.0,
        'contacto1': _contacto1Controller.text,
        'contacto2': _contacto2Controller.text,
        'contacto3': _contacto3Controller.text,
      };

      DatabaseHelper helper = DatabaseHelper();
      await helper.init();
      await helper.insertUsuario(usuario);
      _mostrarUsuariosActualizados();
    } catch (e) {
      _mostrarErrorDialog('Error al registrar usuario: $e');
    }
  }

  void _mostrarUsuariosActualizados() async {
    /*
    DatabaseHelper helper = DatabaseHelper();
    await helper.init();
    List<Map<String, dynamic>> usuarios = await helper.getUsuarios();
    String listaUsuarios = usuarios.map((u) => u['nombre']).join('\n');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Usuarios Registrados'),
          content: SingleChildScrollView(
            child: Text(listaUsuarios),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
            ),
          ],
        );
      },
    );*/

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registro'),
          content: SingleChildScrollView(
            child: Text("Usuario registrado exitosamente."),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
            ),
          ],
        );
      },
    );
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
                Navigator.of(context).pop();
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
              SizedBox(height: 20,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.addressCard), SizedBox(width: 10,),
                  Text("Ingresa tus datos aquí", style: GoogleFonts.orelegaOne(fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _nombreController,
                      style: GoogleFonts.orelegaOne(fontSize: 25),
                      decoration: InputDecoration(hintText: 'Nombre(s)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
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
                    TextField(
                      controller: _limiteController,
                      style: GoogleFonts.orelegaOne(fontSize: 25),
                      decoration: InputDecoration(hintText: 'Limite de gastos', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0))),
                    ),
                    SizedBox(height: 20),
                    _buildContactField(_contacto1Controller, 'Contacto 1'),
                    SizedBox(height: 20),
                    _buildContactField(_contacto2Controller, 'Contacto 2'),
                    SizedBox(height: 20),
                    _buildContactField(_contacto3Controller, 'Contacto 3'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(28, 82, 3, 1.0))),
                      onPressed: _registrarUsuario,
                      child: Container(
                        width: double.infinity,
                        height: 65,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(child: Text("Registrar", style: GoogleFonts.orelegaOne(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Color.fromRGBO(168, 29, 29, 1))),
                      onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen())); },
                      child: Container(
                        width: double.infinity,
                        height: 65,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Center(child: Text("Cancelar", style: GoogleFonts.orelegaOne(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white))),
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
}

