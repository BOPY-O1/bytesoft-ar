import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:audioplayers/audioplayers.dart'; // <-- NUEVO: Importación de audio

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error de cámara: $e');
  }
  runApp(const ByteSoftApp());
}

class ByteSoftApp extends StatelessWidget {
  const ByteSoftApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const PantallaInicio(),
    );
  }
}

// --- MODELO DE DATOS PARA LOS RESTAURANTES ---
class Restaurante {
  final int numero;
  final String nombre;
  final String categoria;
  final String descripcion;
  final String direccion;
  final String imagenUrl;
  final String instagramUrl;
  final String mapsUrl;
  final String? modelo3dUrl;
  // --- NUEVO: Rutas de los audios por idioma ---
  final String? audioEs;
  final String? audioEn;

  Restaurante({
    required this.numero,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.direccion,
    required this.imagenUrl,
    required this.instagramUrl,
    required this.mapsUrl,
    this.modelo3dUrl,
    this.audioEs,
    this.audioEn,
  });
}

// --- BASE DE DATOS LOCAL ---
final List<Restaurante> rutaGastronomica = [
  Restaurante(
    numero: 1,
    nombre: "Espeto do Brasil",
    categoria: "Restaurante brasileño",
    descripcion: "Restaurante especializado en cortes premium, espadas brasileñas y una experiencia gastronómica familiar única en la región.",
    direccion: "Av. 20 de Noviembre 802, Col. Obrera, Poza Rica",
    imagenUrl: "https://images.unsplash.com/photo-1544025162-811114215b36?auto=format&fit=crop&w=800&q=80",
    instagramUrl: "https://instagram.com",
    mapsUrl: "http://googleusercontent.com/maps.google.com/3",
    modelo3dUrl: "assets/corte_carne.glb", 
    audioEs: "audio/espeto_es.mp3", 
    audioEn: "audio/espeto_en.mp3",
  ),
  Restaurante(
    numero: 2,
    nombre: "The Italian Coffee Company",
    categoria: "Cafetería y Postres",
    descripcion: "Disfruta de la mejor selección de café gourmet, bebidas frías, repostería fina y un ambiente ideal para charlas o trabajo.",
    direccion: "Av. 20 de Noviembre 600, Col. Obrera, Poza Rica",
    imagenUrl: "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80",
    instagramUrl: "https://instagram.com",
    mapsUrl: "http://googleusercontent.com/maps.google.com/4",
  ),
  Restaurante(
    numero: 3,
    nombre: "Restaurant Montana",
    categoria: "Comida Tradicional",
    descripcion: "Platillos tradicionales con un sazón único. Servicio cálido y un menú variado que encanta a todas las familias.",
    direccion: "Plaza 20, Local 5, Av. 20 de Noviembre 910, Col. Obrera",
    imagenUrl: "https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=800&q=80",
    instagramUrl: "https://instagram.com",
    mapsUrl: "http://googleusercontent.com/maps.google.com/5",
  ),
  Restaurante(
    numero: 4,
    nombre: "El Mesón Huasteco",
    categoria: "Cocina Regional",
    descripcion: "Auténtica comida de la Huasteca. Antojitos regionales, cecina y bocoles preparados al momento con el sabor de nuestra tierra.",
    direccion: "Av. 20 de Noviembre 1112, Col. Obrera, Poza Rica",
    imagenUrl: "https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80",
    instagramUrl: "https://instagram.com",
    mapsUrl: "http://googleusercontent.com/maps.google.com/6",
  ),
  Restaurante(
    numero: 5,
    nombre: "Sereno Cafetería",
    categoria: "Café de Especialidad",
    descripcion: "Un espacio moderno y acogedor enfocado en métodos de extracción de café, snacks deliciosos y un diseño visual increíble.",
    direccion: "Av. 20 de Noviembre 1310, Col. Obrera, Poza Rica",
    imagenUrl: "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80",
    instagramUrl: "https://instagram.com",
    mapsUrl: "http://googleusercontent.com/maps.google.com/7",
  ),
];

// --- PANTALLA DE INICIO (ONBOARDING) ---
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                ),
                child: const Text("BYTESOFT", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 2)),
              ),
              const SizedBox(height: 30),
              const Text(
                "Descubre la\nciudad de forma\ninteractiva.",
                style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800, height: 1.1),
              ),
              const SizedBox(height: 20),
              Text(
                "Digitalizamos los negocios locales. Apunta tu cámara a los mapas físicos y nuestra tecnología revelará información, rutas y detalles al instante.",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 16, height: 1.6),
              ),
              const SizedBox(height: 40),
              _buildPaso(Icons.camera_alt_outlined, "Abre el escáner visual"),
              const SizedBox(height: 15),
              _buildPaso(Icons.map_outlined, "Enfoca el mapa turístico"),
              const SizedBox(height: 15),
              _buildPaso(Icons.touch_app_outlined, "Explora la información"),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const EscanerMapaAI()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.5),
                  ),
                  child: const Text("Empezar a Escanear", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaso(IconData icono, String texto) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Icon(icono, color: Colors.blueAccent, size: 20),
        ),
        const SizedBox(width: 15),
        Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// --- ESCÁNER CON INTELIGENCIA ARTIFICIAL ---
class EscanerMapaAI extends StatefulWidget {
  const EscanerMapaAI({super.key});
  @override
  State<EscanerMapaAI> createState() => _EscanerMapaAIState();
}

class _EscanerMapaAIState extends State<EscanerMapaAI> {
  CameraController? _cameraController;
  bool _isDetecting = false;
  bool _mapaDetectado = false;
  
  Restaurante? _restauranteSeleccionado;
  
  String _iaLabel = "Cargando IA...";
  double _iaConfidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initAI();
    _initCamera();
  }

  Future<void> _initAI() async {
    await Tflite.loadModel(model: "assets/model.tflite", labels: "assets/labels.txt");
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    _cameraController = CameraController(cameras[0], ResolutionPreset.high);
    await _cameraController!.initialize();
    
    if (!mounted) return;
    setState(() {});

    _cameraController!.startImageStream((CameraImage image) {
      if (_isDetecting || _mapaDetectado) return;
      _isDetecting = true;

      Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5, imageStd: 127.5, rotation: 0, numResults: 2,
      ).then((recognitions) {
        if (recognitions != null && recognitions.isNotEmpty) {
          var prediccion = recognitions.first;
          setState(() {
            _iaLabel = prediccion['label'].toString();
            _iaConfidence = prediccion['confidence'];
          });
          
          if (prediccion['confidence'] > 0.80 && prediccion['index'] == 0) {
            setState(() { _mapaDetectado = true; });
            _cameraController!.stopImageStream();
          }
        }
        _isDetecting = false;
      });
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var camera = _cameraController?.value;
    var scale = 1.0;
    if (camera != null && camera.isInitialized) {
      final size = MediaQuery.of(context).size;
      scale = size.aspectRatio * camera.aspectRatio;
      if (scale < 1) scale = 1 / scale;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (camera != null && camera.isInitialized)
            SizedBox.expand(child: Transform.scale(scale: scale, child: Center(child: CameraPreview(_cameraController!)))),

          if (!_mapaDetectado)
            Positioned(
              top: 50, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10), border: Border.all(color: _iaConfidence > 0.70 ? Colors.green : Colors.red)),
                child: Column(
                  children: [
                    const Text("Modo Debug IA:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("$_iaLabel - ${(_iaConfidence * 100).toStringAsFixed(1)}%", style: TextStyle(color: _iaConfidence > 0.70 ? Colors.greenAccent : Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

          if (!_mapaDetectado)
            Center(
              child: GestureDetector(
                onDoubleTap: () {
                  setState(() { _mapaDetectado = true; });
                  _cameraController!.stopImageStream();
                },
                child: Container(
                  width: 300, height: 400,
                  decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent, width: 3), borderRadius: BorderRadius.circular(20)),
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(padding: EdgeInsets.all(10.0), child: Text("Buscando Mapa de la 20 de Noviembre...", style: TextStyle(color: Colors.white, backgroundColor: Colors.black54, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                  ),
                ),
              ),
            ),

          if (_mapaDetectado)
            Container(color: Colors.black.withOpacity(0.6)),
          
          if (_mapaDetectado)
            Center(
              child: _restauranteSeleccionado == null
                  ? MenuRutaCard(
                      onSelect: (restaurante) { setState(() { _restauranteSeleccionado = restaurante; }); },
                      onClose: () { setState(() { _mapaDetectado = false; }); _initCamera(); },
                    )
                  : ModernRestaurantCard(
                      restaurante: _restauranteSeleccionado!,
                      onBack: () { setState(() { _restauranteSeleccionado = null; }); },
                    ),
            ),
        ],
      ),
    );
  }
}

// --- WIDGET 1: MENÚ DE PUNTOS INTERACTIVOS ---
class MenuRutaCard extends StatelessWidget {
  final Function(Restaurante) onSelect;
  final VoidCallback onClose;

  const MenuRutaCard({super.key, required this.onSelect, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, height: 550,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 16, top: 20, bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Mapa Detectado", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    Text("Ruta 20 de Noviembre", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: onClose),
              ],
            ),
          ),
          const Divider(height: 1, indent: 24, endIndent: 24),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: rutaGastronomica.length,
              itemBuilder: (context, index) {
                final item = rutaGastronomica[index];
                return Card(
                  elevation: 0, color: Colors.grey.shade50, margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: CircleAvatar(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, child: Text("${item.numero}", style: const TextStyle(fontWeight: FontWeight.bold))),
                    title: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                    subtitle: Text(item.categoria, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueAccent),
                    onTap: () => onSelect(item),
                  ),
                );
              },
            ),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 20, top: 10), child: Text("Selecciona un negocio para ver su información", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)))
        ],
      ),
    );
  }
}

// --- WIDGET 2: DETALLE DINÁMICO DEL RESTAURANTE (AHORA CON AUDIO) ---
class ModernRestaurantCard extends StatefulWidget {
  final Restaurante restaurante;
  final VoidCallback onBack;

  const ModernRestaurantCard({super.key, required this.restaurante, required this.onBack});

  @override
  State<ModernRestaurantCard> createState() => _ModernRestaurantCardState();
}

class _ModernRestaurantCardState extends State<ModernRestaurantCard> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _idiomaSeleccionado = 'es'; // Empieza en Español por defecto

  @override
  void initState() {
    super.initState();
    // Escucha cuando el audio termina para resetear el botón a "Play"
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) setState(() { _isPlaying = false; });
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop(); // Detiene el audio si el usuario se sale de la tarjeta
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _lanzarUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) debugPrint('Error abriendo URL');
  }

  void _mostrarModelo3D(BuildContext context) {
    showDialog(
      context: context, barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, insetPadding: EdgeInsets.zero, elevation: 0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width, height: MediaQuery.of(context).size.height * 0.7,
              child: ModelViewer(
                src: widget.restaurante.modelo3dUrl!, alt: "Platillo 3D", ar: false, autoRotate: true,
                cameraControls: true, backgroundColor: Colors.transparent, disableZoom: false,
                cameraOrbit: "auto auto 200%", maxCameraOrbit: "auto auto 400%", minCameraOrbit: "auto auto 50%",
              ),
            ),
            Positioned(top: 40, right: 20, child: CircleAvatar(backgroundColor: Colors.white24, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)))),
            const Positioned(bottom: 40, child: Text("Gira y haz zoom con tus dedos", style: TextStyle(color: Colors.white70, letterSpacing: 1)))
          ],
        ),
      ),
    );
  }

  // Lógica de Reproducción de Audio
  void _toggleAudio() async {
  if (_isPlaying) {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  } else {
    // 1. Obtener la ruta desde el modelo de datos (dinámico)
    String? rutaAudio = _idiomaSeleccionado == 'es' 
        ? widget.restaurante.audioEs 
        : widget.restaurante.audioEn;

    // 2. Validar que la ruta no sea nula antes de intentar reproducir
    if (rutaAudio != null && rutaAudio.isNotEmpty) {
      try {
        // 3. AssetSource busca desde la raíz de tus assets definidos en pubspec
        await _audioPlayer.play(AssetSource(rutaAudio)); 
        setState(() => _isPlaying = true);
      } catch (e) {
        debugPrint("Error al cargar el audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al reproducir el audio"))
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Audio no disponible"))
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, height: 600,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(widget.restaurante.imagenUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 100, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.8), Colors.transparent])))),
                Positioned(
                  bottom: 15, left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Punto ${widget.restaurante.numero} del recorrido", style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      Text(widget.restaurante.nombre, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Positioned(top: 15, left: 15, child: CircleAvatar(backgroundColor: Colors.black38, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: widget.onBack)))
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- NUEVO REPRODUCTOR DE AUDIO ---
                    if (widget.restaurante.audioEs != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withOpacity(0.2))),
                        child: Row(
                          children: [
                            const Icon(Icons.volume_up, color: Colors.blueAccent, size: 24),
                            const SizedBox(width: 10),
                            // Selector de Idioma
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _idiomaSeleccionado,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                                  style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 14),
                                  items: const [
                                    DropdownMenuItem(value: 'es', child: Text("🇲🇽  Español")),
                                    DropdownMenuItem(value: 'en', child: Text("🇺🇸  English")),
                                  ],
                                  onChanged: (String? nuevoIdioma) {
                                    if (nuevoIdioma != null) {
                                      setState(() {
                                        _idiomaSeleccionado = nuevoIdioma;
                                        _audioPlayer.stop();
                                        _isPlaying = false;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            // Botón Play / Pause
                            IconButton(
                              icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
                              iconSize: 45,
                              color: Colors.blueAccent,
                              onPressed: _toggleAudio,
                            )
                          ],
                        ),
                      ),

                    Row(
                      children: [
                        Expanded(child: ElevatedButton.icon(onPressed: () => _lanzarUrl(widget.restaurante.mapsUrl), icon: const Icon(Icons.map, size: 18), label: const Text("Ir con Maps"), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                        const SizedBox(width: 10),
                        Expanded(child: ElevatedButton.icon(onPressed: () => _lanzarUrl(widget.restaurante.instagramUrl), icon: const Icon(Icons.favorite, size: 18), label: const Text("Instagram"), style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent.withOpacity(0.1), foregroundColor: Colors.pinkAccent, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                      ],
                    ),
                    
                    if (widget.restaurante.modelo3dUrl != null)
                      Container(width: double.infinity, margin: const EdgeInsets.only(top: 15), child: ElevatedButton.icon(onPressed: () => _mostrarModelo3D(context), icon: const Icon(Icons.view_in_ar, size: 20), label: const Text("Ver Platillo en 3D"), style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
                    
                    const SizedBox(height: 25),
                    Text(widget.restaurante.categoria, style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    const Text("Información", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                    const SizedBox(height: 8),
                    Text(widget.restaurante.descripcion, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}