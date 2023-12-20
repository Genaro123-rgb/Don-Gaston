// ignore_for_file: unused_field

import 'package:dongastonn/globals.dart';
import 'package:dongastonn/registrarGasto.dart';
import 'package:flutter/material.dart';
import 'package:dongastonn/database/databaseHelper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class NuevoGastoScreen extends StatefulWidget {
  @override
  _NuevoGastoScreenState createState() => _NuevoGastoScreenState();
}

class _NuevoGastoScreenState extends State<NuevoGastoScreen> {
  double _limiteGasto = 0.0;
  double _porcentajeGastado = 0.0;

  @override
  void initState() {
    super.initState();
    _obtenerDatosGasto();
  }

  Future<void> _obtenerDatosGasto() async {
    DatabaseHelper helper = DatabaseHelper();
    double limiteGasto = await helper.getLimiteGastoMensual(usuarioActual);
    double totalGastos = await helper.getTotalGastosMesActual(usuarioActual);

    setState(() {
      _limiteGasto = limiteGasto;
      _porcentajeGastado =
          (limiteGasto > 0) ? (totalGastos / limiteGasto * 100) : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromRGBO(28, 82, 3, 1.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegistrarGastoScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(FontAwesomeIcons.plus, color: Colors.white),
                          SizedBox(width: 30),
                          Text("Nuevo Gasto",
                              style: GoogleFonts.orelegaOne(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Gasto Mensual",
                    style: GoogleFonts.orelegaOne(
                        fontSize: 30, fontWeight: FontWeight.bold)),
                Text("Límite: ${_limiteGasto.toStringAsFixed(2)}",
                    style: GoogleFonts.orelegaOne(
                        fontSize: 30, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Container(
                  height: 450,
                  color: Colors.amber,
                  child: PieChart(
                    PieChartData(
                      centerSpaceRadius: 50,
                      sections: [
                        PieChartSectionData(
                          color: Colors.red,
                          value: _porcentajeGastado,
                          radius: 100,
                        ),
                        PieChartSectionData(
                          color: Colors.green,
                          value: 100 - _porcentajeGastado,
                          radius: 100,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
