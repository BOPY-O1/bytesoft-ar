import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ByteSoftApp());
}

// --- MODELO DE DATOS PARA LOS LUGARES ---
class Landmark {
  final String id;
  final String nombre;
  final String descripcion;
  final String horario;
  final String curiosidad;
  final IconData icono;

  Landmark({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.horario,
    required this.curiosidad,
    required this.icono,
  });
}

// --- BASE DE DATOS LOCAL DE POZA RICA ---
final Map<String, Landmark> lugaresPozaRica = {
  'parque_juarez': Landmark(
    id: 'parque_juarez',
    nombre: 'Parque Juárez',
    descripcion: 'El corazón de la ciudad. Inaugurado en los años 50, es el centro cívico y social donde se encuentra el monumento a Benito Juárez.',
    horario: 'Abierto 24 horas',
    curiosidad: 'Aquí se encuentra la emblemática Biblioteca Francisco I. Madero.',
    icono: Icons.account_balance,
  ),
  'parque_americas': Landmark(
    id: 'parque_americas',
    nombre: 'Parque de las Américas',
    descripcion: 'Ubicado en el cerro del Abuelo, ofrece la mejor vista de la ciudad. Es sede del Museo de la Ciudad (MUCI).',
    horario: '08:00 - 20:00 hrs',
    curiosidad: 'Su mirador permite ver gran parte de la zona metropolitana.',
    icono: Icons.landscape,
  ),
  'plaza_civica': Landmark(
    id: 'plaza_civica',
    nombre: 'Plaza Cívica 18 de Marzo',
    descripcion: 'Símbolo del orgullo petrolero. Lugar de las grandes fiestas del petróleo y eventos masivos.',
    horario: 'Abierto 24 horas',
    curiosidad: 'Es el sitio principal de la conmemoración de la Expropiación Petrolera.',
    icono: Icons.oil_barrel,
  ),
};

class ByteSoftApp extends StatelessWidget {
  const ByteSoftApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const EscanerPatrimonio(),
    );
  }
}

class EscanerPatrimonio extends StatefulWidget {
  const EscanerPatrimonio({super.key});
  @override
  State<EscanerPatrimonio> createState() => _EscanerPatrimonioState();
}

class _EscanerPatrimonioState extends State<EscanerPatrimonio> {
  Landmark? lugarDetectado;
  bool mostrarInfo = false;

  void _onDetect(BarcodeCapture capture) {
    final String? code = capture.barcodes.first.rawValue;
    if (code != null && lugaresPozaRica.containsKey(code)) {
      setState(() {
        lugarDetectado = lugaresPozaRica[code];
        mostrarInfo = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. CÁMARA DE FONDO
          MobileScanner(onDetect: _onDetect),

          // 2. FILTRO OSCURO SI HAY INFO
          if (mostrarInfo)
            Container(color: Colors.black.withOpacity(0.4)),

          // 3. TARJETA ESTILO "GLASSMORPHISM" (MODERNA)
          if (mostrarInfo && lugarDetectado != null)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: mostrarInfo ? 1 : 0,
                child: InfoCard(
                  lugar: lugarDetectado!,
                  onClose: () => setState(() => mostrarInfo = false),
                ),
              ),
            ),
            
          // MIRA DEL ESCÁNER (Si no hay info)
          if (!mostrarInfo)
            Center(
              child: Container(
                width: 280, height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// --- WIDGET DE LA TARJETA MODERNA ---
class InfoCard extends StatelessWidget {
  final Landmark lugar;
  final VoidCallback onClose;

  const InfoCard({super.key, required this.lugar, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Cabecera con ícono y cerrar
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(lugar.icono, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        lugar.nombre,
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                    )
                  ],
                ),
              ),
              // Contenido con Scroll
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("HISTORIA Y CULTURA", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 10),
                      Text(lugar.descripcion, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
                      const SizedBox(height: 25),
                      const Text("DATOS RÁPIDOS", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 10),
                      InfoRow(icon: Icons.access_time, label: lugar.horario),
                      InfoRow(icon: Icons.lightbulb_outline, label: lugar.curiosidad),
                      const SizedBox(height: 20),
                      // Simulación de Botón de fotos
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.5), borderRadius: BorderRadius.circular(15)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library, color: Colors.white),
                            SizedBox(width: 10),
                            Text("Ver Galería de Fotos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoRow({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}