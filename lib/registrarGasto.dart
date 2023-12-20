// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dongastonn/database/databaseHelper.dart';
import 'package:dongastonn/globals.dart';
import 'package:dongastonn/menuPrincipal.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

const platform = MethodChannel('send_sms');

class RegistrarGastoScreen extends StatefulWidget {
  @override
  _RegistrarGastoScreen createState() => _RegistrarGastoScreen();
}

class _RegistrarGastoScreen extends State<RegistrarGastoScreen> {
  final TextEditingController _conceptoController = TextEditingController();
  final TextEditingController _montoController = TextEditingController();
  String? selectedCategory;
  List<String> categories = [
    'Alimentacion y Bebidas',
    'Transporte',
    'Entretenimiento y Ocio',
    'Compras en Línea/Suscripciones',
    'Restaurantes y Cafeterias',
    'Compras Impulsivas',
    'Salud y Belleza',
    'Otros'
  ];

  Future<void> _registrarGasto() async {
    if (idUsuarioActual == -1) {
      print('Usuario no encontrado');
      return;
    }

    if (_conceptoController.text.isEmpty ||
        _montoController.text.isEmpty ||
        selectedCategory == null) {
      print('Por favor, completa todos los campos');
      return;
    }

    try {
      print("ID del usuario Actual: " + idUsuarioActual.toString());
      double monto = double.tryParse(_montoController.text) ?? 0.0;
      String fechaActual = DateFormat('yyyy-MM-dd').format(DateTime.now());

      DatabaseHelper helper = DatabaseHelper();
      double totalGastos =
          await helper.getTotalGastosMesActual(usuarioActual);
      double limiteMensual =
          await helper.getLimiteGastoMensual(usuarioActual);

      if (totalGastos + monto > limiteMensual) {
        _enviarAlertaSMS();
      }

      await helper.insertarGasto(
        idUsuario: idUsuarioActual,
        concepto: _conceptoController.text,
        monto: monto,
        categoria: selectedCategory!,
        fecha: fechaActual,
      );

      print("Gasto registrado exitosamente");
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MenuPrincipalScreen(initialPage: 1)),
      );
    } catch (e) {
      print('Error al registrar el gasto: $e');
    }
  }

  Future<void> requestSendSmsPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      await Permission.sms.request();
    }
  }

  void _enviarAlertaSMS() async {
    try {
      await requestSendSmsPermission();
      DatabaseHelper helper = DatabaseHelper();
      List<String> numeros =
          await helper.obtenerContactosDeUsuario(idUsuarioActual);

      if (numeros.isEmpty) {
        print("No hay contactos registrados para el usuario actual.");
        return;
      }

      String mensaje = "Alerta: El límite de gastos mensual de " +
          usuarioActual +
          " ha sido superado.";

      for (String numero in numeros) {
        await platform
            .invokeMethod('send', {'phoneNumber': numero, 'message': mensaje});
      }
    } catch (e) {
      print('Error al enviar SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD9D9D9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.penToSquare, size: 30),
                    SizedBox(width: 20),
                    Text(
                      "Agrega aquí los\ndatos de tu gasto",
                      style: GoogleFonts.orelegaOne(
                        fontSize: 33,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 70),
                TextField(
                  controller: _conceptoController,
                  style: GoogleFonts.orelegaOne(fontSize: 25),
                  decoration: InputDecoration(
                    hintText: 'Concepto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  style: GoogleFonts.orelegaOne(
                      fontSize: 25,
                      color: const Color.fromARGB(255, 91, 88, 88)),
                  value: selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    hintText: 'Categoría',
                    hintStyle: GoogleFonts.orelegaOne(
                        fontSize: 25,
                        color: const Color.fromARGB(255, 91, 88, 88)),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                    });
                  },
                  items:
                      categories.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _montoController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  style: GoogleFonts.orelegaOne(fontSize: 25),
                  decoration: InputDecoration(
                    hintText: 'Monto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 100),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(28, 82, 3, 1.0),
                    ),
                  ),
                  onPressed: () async {
                    print("Registrar presionado");
                    _registrarGasto();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        "Registrar",
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
                      Color.fromRGBO(168, 29, 29, 1),
                    ),
                  ),
                  onPressed: () async {
                    print("Cancelar presionado");
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Text(
                        "Cancelar",
                        style: GoogleFonts.orelegaOne(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
