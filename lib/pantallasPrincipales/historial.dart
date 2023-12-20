import 'package:dongastonn/registrarGasto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dongastonn/database/databaseHelper.dart';
import 'package:dongastonn/globals.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({Key? key}) : super(key: key);

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  void _updateGastos() {
    setState(() {});
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.clockRotateLeft, size: 30),
                    SizedBox(width: 20),
                    Text("Historial de gastos",
                        style: GoogleFonts.orelegaOne(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Colors.grey, thickness: 2),
                SizedBox(height: 10),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().getGastosUsuario(idUsuarioActual),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("No hay gastos registrados.");
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var gasto = snapshot.data![index];
                        return ListTile(
                          title: Text(gasto["concepto"],
                              style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                          subtitle: Text("Monto: \$${gasto["monto"]}",
                              style: TextStyle(fontSize: 20)),
                          onTap: () => _mostrarDetalleGasto(
                              context, gasto, _updateGastos),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => RegistrarGastoScreen()));
        },
        child: Icon(Icons
            .add), // Icono para el botón, puedes cambiarlo según tus necesidades
        backgroundColor:
            Color.fromARGB(255, 186, 160, 160), // Color del botón, cámbialo según tu diseño
      ),
    );
  }

  void _mostrarDetalleGasto(BuildContext context, Map<String, dynamic> gasto,
      VoidCallback onGastoUpdated) {
    final TextEditingController conceptoController =
        TextEditingController(text: gasto["concepto"]);
    final TextEditingController fechaController =
        TextEditingController(text: gasto["fecha"]);
    final TextEditingController montoController =
        TextEditingController(text: gasto["monto"].toString());

    String selectedCategory = gasto["categoria"] ?? 'Otros';

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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Gasto"),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: conceptoController,
                    decoration: InputDecoration(
                      labelText: "Concepto",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      selectedCategory = newValue!;
                    },
                    items: categories
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: "Categoría",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: montoController,
                    decoration: InputDecoration(
                      labelText: "Monto",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                    ],
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: fechaController,
                    decoration: InputDecoration(
                      labelText: "Fecha",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Guardar Cambios'),
              onPressed: () async {
                bool confirm = await _showConfirmationDialog(context,
                    "¿Estás seguro de que quieres guardar los cambios?");
                if (confirm) {
                  Map<String, dynamic> updatedGasto = {
                    "id": gasto["id"],
                    "concepto": conceptoController.text,
                    "fecha": fechaController.text,
                    "monto": double.parse(montoController.text),
                    "categoria": selectedCategory,
                  };
                  await DatabaseHelper().updateGasto(updatedGasto);
                  onGastoUpdated();
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text('Eliminar Gasto'),
              onPressed: () async {
                bool confirm = await _showConfirmationDialog(context,
                    "¿Estás seguro de que quieres eliminar este gasto?");
                if (confirm) {
                  await DatabaseHelper().deleteGasto(gasto["id"]);
                  onGastoUpdated();
                  Navigator.of(context).pop();
                }
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
