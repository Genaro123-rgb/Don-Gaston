import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dongastonn/globals.dart';
import 'package:dongastonn/database/databaseHelper.dart';

class ConfigScreen extends StatefulWidget {
  final Function(String) actualizarTituloUsuario;

  const ConfigScreen({Key? key, required this.actualizarTituloUsuario})
      : super(key: key);

  @override
  _ConfigScreenState createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _limiteController = TextEditingController();
  final TextEditingController _contacto1Controller = TextEditingController();
  final TextEditingController _contacto2Controller = TextEditingController();
  final TextEditingController _contacto3Controller = TextEditingController();
  bool _isEditing = false;
  int idUsuarioActual = -1; // Asegúrate de asignar este valor correctamente

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  void _cargarDatosUsuario() async {
    var detallesUsuario =
        await DatabaseHelper().getUsuarioDetalles(usuarioActual);
    setState(() {
      idUsuarioActual = detallesUsuario['id'] ?? -1;
      _nombreController.text = detallesUsuario['nombre'] ?? '';
      _contrasenaController.text = detallesUsuario['contrasena'] ?? '';
      _limiteController.text = detallesUsuario['limite'].toString();
      _contacto1Controller.text = detallesUsuario['contacto1'] ?? '';
      _contacto2Controller.text = detallesUsuario['contacto2'] ?? '';
      _contacto3Controller.text = detallesUsuario['contacto3'] ?? '';
    });
  }

  Future<void> _actualizarInformacionUsuario() async {
    Map<String, dynamic> usuarioActualizado = {
      'id': idUsuarioActual,
      'nombre': _nombreController.text,
      'contrasena': _contrasenaController.text,
      'limite': double.tryParse(_limiteController.text) ?? 0.0,
      'contacto1': _contacto1Controller.text,
      'contacto2': _contacto2Controller.text,
      'contacto3': _contacto3Controller.text,
    };

    try {
      await DatabaseHelper().actualizarUsuario(usuarioActualizado);
      usuarioActual = _nombreController.text;
      print("Usuario actualizado correctamente.");
    } catch (e) {
      print("Error al actualizar el usuario: $e");
    }
  }

  Future<bool> _showConfirmationDialog(
      BuildContext context, String message) async {
    bool confirm = false;
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Confirmación'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                confirm = false;
              },
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                confirm = true;
              },
            ),
          ],
        );
      },
    );
    return confirm;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.gear, size: 30),
                  SizedBox(width: 20),
                  Text("Configuracion",
                      style: GoogleFonts.orelegaOne(
                          fontSize: 30, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              _buildTextField(_nombreController, 'Nombre', _isEditing),
              SizedBox(
                height: 20,
              ),
              _buildTextField(_contrasenaController, 'Contraseña', _isEditing),
              SizedBox(
                height: 20,
              ),
              _buildTextField(
                  _limiteController, 'Límite de gastos', _isEditing),
              SizedBox(
                height: 20,
              ),
              _buildTextField(_contacto1Controller, 'Contacto 1', _isEditing),
              SizedBox(
                height: 20,
              ),
              _buildTextField(_contacto2Controller, 'Contacto 2', _isEditing),
              SizedBox(
                height: 20,
              ),
              _buildTextField(_contacto3Controller, 'Contacto 3', _isEditing),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonTheme(
                    minWidth: 150.0, // Define el ancho mínimo del botón
                    height: 50.0, // Define la altura del botón
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.yellow),
                      ),
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      child: Text('Modificar',
                          style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                  ),
                  SizedBox(width: 10), // Espacio entre los botones
                  ButtonTheme(
                    minWidth: 150.0, // Define el ancho mínimo del botón
                    height: 50.0, // Define la altura del botón
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 35, 89, 37)),
                      ),
                      onPressed: _isEditing ? _guardarCambios : null,
                      child: Text('Guardar',
                          style: TextStyle(color: Colors.white, fontSize: 25)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  TextField _buildTextField(
      TextEditingController controller, String label, bool isEnabled) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 20),
        border: OutlineInputBorder(),
      ),
      enabled: isEnabled,
      style: GoogleFonts.orelegaOne(),
    );
  }

  void _guardarCambios() async {
    bool confirm = await _showConfirmationDialog(
        context, "¿Estas seguro que quieres modificar la información?");
    if (confirm) {
      _actualizarInformacionUsuario();
      setState(() {
        _isEditing = false;
      });
      widget.actualizarTituloUsuario(
          _nombreController.text); // Llama a la función pasada como parámetro
    }
  }
}
