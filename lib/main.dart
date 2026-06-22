import 'dart:ui'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:camera/camera.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:video_player/video_player.dart'; 

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Error de cámara: $e');
  }
  // Forzar que la app inicie en vertical por defecto
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ARtourApp());
}

class ARtourApp extends StatelessWidget {
  const ARtourApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ARtour PR',
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const PantallaInicio(),
    );
  }
}

// --- MODELOS DE DATOS ---
class VideoHistorico {
  final String titulo;
  final String rutaLocal;
  VideoHistorico(this.titulo, this.rutaLocal);
}

class PuntoHistorico {
  final String nombre;
  final String informacion;
  final String imagenCabecera;
  final String modelo3dUrl;
  final List<VideoHistorico> videos;
  final List<String> imagenesGaleria;

  PuntoHistorico({
    required this.nombre,
    required this.informacion,
    required this.imagenCabecera,
    required this.modelo3dUrl,
    required this.videos,
    required this.imagenesGaleria,
  });
}

// --- BASE DE DATOS LOCAL: ARTOUR PR ---
final List<PuntoHistorico> rutaHistorica = [
  PuntoHistorico(
    nombre: "POZO POZA RICA N° 2",
    informacion: "El Pozo Poza Rica N° 2 es un emblema de los orígenes de la ciudad. Este lugar fue el escenario del histórico 'Brote', marcando el inicio del auge petrolero que transformó por completo a la región del Totonacapan y forjó la identidad de sus habitantes.",
    imagenCabecera: "assets/images/imagen_pozo_4.png", 
    modelo3dUrl: "assets/pozo2_3d.glb",
    videos: [
      VideoHistorico("PARTE 1: El origen", "assets/videos/pozo_1.mp4"),
      VideoHistorico("PARTE 2: El brote", "assets/videos/pozo_2.mp4"),
      VideoHistorico("PARTE 3: El campamento", "assets/videos/pozo_3.mp4"),
      VideoHistorico("PARTE 4: El pozo taponado", "assets/videos/pozo_4.mp4"),
    ],
    imagenesGaleria: [
      "assets/images/imagen_pozo_1.png",
      "assets/images/imagen_pozo_2.jpeg",
      "assets/images/imagen_pozo_3.png",
      "assets/images/imagen_pozo_4.png",
    ],
  ),
];

// --- PANTALLA DE INICIO (ONBOARDING) RESPONSIVA ---
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. LÍMITE DE ESCALADO DE TEXTO: Evita que las fuentes del sistema deformen la app
    final mediaQuery = MediaQuery.of(context);
    // Usamos textScaler para versiones recientes de Flutter
    final scale = mediaQuery.textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.1);

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: scale),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- ARRIBA: LOGO FIJO ---
                Center(
                  child: Image.asset(
                    "assets/images/Logo_Bytesoft_.png", 
                    height: 55, 
                    errorBuilder: (context, error, stackTrace) => const Text("ByteSoft", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // --- CENTRO: CONTENIDO DESLIZABLE (Evita que se deforme o desaparezca) ---
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
                          child: const Text("ARTOUR PR", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
                        ),
                        const SizedBox(height: 25),
                        const Text("Descubre la\nhistoria de forma\ninteractiva.", style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 1.1)),
                        const SizedBox(height: 20),
                        Text("Preservamos, promovemos y damos a conocer la riqueza cultural, los orígenes y la historia de nuestra ciudad mediante realidad aumentada.", style: TextStyle(color: Colors.grey.shade400, fontSize: 16, height: 1.5)),
                        const SizedBox(height: 35),
                        _buildPaso(Icons.qr_code_scanner, "Escanea puntos históricos"),
                        const SizedBox(height: 15),
                        _buildPaso(Icons.video_library, "Desbloquea archivos multimedia"),
                        const SizedBox(height: 15),
                        _buildPaso(Icons.view_in_ar, "Explora modelos en 3D"),
                        const SizedBox(height: 20), // Margen inferior para que no quede pegado al botón
                      ],
                    ),
                  ),
                ),

                // --- ABAJO: BOTÓN FIJO SIEMPRE VISIBLE ---
                SizedBox(
                  width: double.infinity, height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: Colors.blueAccent.withOpacity(0.5), offset: const Offset(0, 8), blurRadius: 15),
                        BoxShadow(color: Colors.white.withOpacity(0.2), offset: const Offset(0, -2), blurRadius: 2),
                      ]
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const EscanerMapaAI())),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                      child: const Text("Empezar a Escanear", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildPaso(IconData icono, String texto) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10), 
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), 
          child: Icon(icono, color: Colors.blueAccent, size: 20)
        ),
        const SizedBox(width: 15),
        // Expanded asegura que si el texto es muy grande, baje a la siguiente línea en vez de dar error
        Expanded(
          child: Text(texto, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500))
        ),
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
  PuntoHistorico? _puntoSeleccionado;
  String _iaLabel = "Cargando IA...";
  double _iaConfidence = 0.0;

  @override
  void initState() {
    super.initState();
    _initAI().then((_) => _initCamera());
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
        imageHeight: image.height, imageWidth: image.width,
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
          if (camera != null && camera.isInitialized) SizedBox.expand(child: Transform.scale(scale: scale, child: Center(child: CameraPreview(_cameraController!)))),
          if (!_mapaDetectado) Positioned(top: 50, left: 20, right: 20, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(10), border: Border.all(color: _iaConfidence > 0.70 ? Colors.green : Colors.red)), child: Column(children: [const Text("Modo Debug IA:", style: TextStyle(color: Colors.white70, fontSize: 12)), Text("$_iaLabel - ${(_iaConfidence * 100).toStringAsFixed(1)}%", style: TextStyle(color: _iaConfidence > 0.70 ? Colors.greenAccent : Colors.redAccent, fontSize: 18, fontWeight: FontWeight.bold))]))),
          if (!_mapaDetectado) Center(child: GestureDetector(onDoubleTap: () { setState(() { _mapaDetectado = true; }); _cameraController!.stopImageStream(); }, child: Container(width: 300, height: 400, decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent, width: 3), borderRadius: BorderRadius.circular(20)), child: const Align(alignment: Alignment.bottomCenter, child: Padding(padding: EdgeInsets.all(10.0), child: Text("Buscando Marcador...", style: TextStyle(color: Colors.white, backgroundColor: Colors.black54, fontWeight: FontWeight.bold), textAlign: TextAlign.center)))))),
          
          if (_mapaDetectado)
            Center(
              child: _puntoSeleccionado == null
                  ? MenuRutaCard(
                      onSelect: (punto) { setState(() { _puntoSeleccionado = punto; }); },
                      onClose: () { setState(() { _mapaDetectado = false; }); _initCamera(); },
                    )
                  : DetallePozoCard(
                      punto: _puntoSeleccionado!,
                      onBack: () { setState(() { _puntoSeleccionado = null; }); },
                    ),
            ),
        ],
      ),
    );
  }
}

// --- MENÚ INICIAL ---
class MenuRutaCard extends StatelessWidget {
  final Function(PuntoHistorico) onSelect;
  final VoidCallback onClose;

  const MenuRutaCard({super.key, required this.onSelect, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, height: 350,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 15))],
          ),
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
                        const Text("Marcador Detectado", style: TextStyle(color: Color(0xFF90213B), fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("Puntos Históricos", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.black54), onPressed: onClose),
                  ],
                ),
              ),
              const Divider(height: 1, indent: 24, endIndent: 24, color: Colors.black12),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: rutaHistorica.length,
                  itemBuilder: (context, index) {
                    final item = rutaHistorica[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFB83A5A), Color(0xFF801C30)]),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: const Color(0xFF90213B).withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 4))]
                          ),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                        ),
                        title: Text(item.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF90213B)),
                        onTap: () => onSelect(item),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TARJETA PRINCIPAL DEL POZO ---
// --- TARJETA PRINCIPAL DEL POZO ---
class DetallePozoCard extends StatelessWidget {
  final PuntoHistorico punto;
  final VoidCallback onBack;

  const DetallePozoCard({super.key, required this.punto, required this.onBack});

  // NUEVO: Estilo de botón Neumórfico/Soft UI (Basado en la imagen de referencia)
  Widget _buildModernButton({required String text, required VoidCallback onPressed, bool isExpanded = false, Widget? expandedContent}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF982B46), // Color principal Vino
        borderRadius: BorderRadius.circular(30), // Bordes muy redondeados (Pill shape)
        boxShadow: [
          // Sombra suave abajo para dar altura
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 8),
            blurRadius: 15,
          ),
          // Brillo muy sutil arriba para el efecto 3D suave
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: isExpanded
          ? expandedContent
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      // El círculo interno con icono que se ve en tu referencia
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  // Helper para adaptar el ExpansionTile al nuevo diseño
  Widget _buildModernExpansionTile(BuildContext context, {required String title, required List<Widget> children}) {
    return _buildModernButton(
      text: title,
      onPressed: () {},
      isExpanded: true,
      expandedContent: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          iconColor: Colors.white,
          collapsedIconColor: Colors.white,
          trailing: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 20,
            ),
          ),
          children: children,
        ),
      ),
    );
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
                src: punto.modelo3dUrl, alt: "Modelo 3D Pozo", ar: false, autoRotate: true,
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

  void _reproducirVideo(BuildContext context, List<VideoHistorico> listaVideos, int indexSeleccionado) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PantallaVisorVideo(videos: listaVideos, indiceInicial: indexSeleccionado)),
    );
  }

  void _abrirVisorGaleria(BuildContext context, int indexInicial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VisorGaleria(
          imagenes: punto.imagenesGaleria,
          indiceInicial: indexInicial,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), 
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9, height: 650,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), 
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5)
          ),
          child: Column(
            children: [
              // CABECERA
              Stack(
                children: [
                  Image.asset(punto.imagenCabecera, height: 180, width: double.infinity, fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(height: 180, color: Colors.grey, child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white, size: 50))),
                  ),
                  Positioned(bottom: 0, left: 0, right: 0, child: Container(height: 80, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.9), Colors.transparent])))),
                  Positioned(
                    bottom: 15, left: 20,
                    child: Text(punto.nombre, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ),
                  Positioned(top: 15, left: 15, child: CircleAvatar(backgroundColor: Colors.black54, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: onBack)))
                ],
              ),
              
              // CONTENIDO
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Información", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87)),
                            const SizedBox(height: 8),
                            Text(punto.informacion, style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500, height: 1.4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // SECCIÓN VIDEOS (Estilo Moderno)
                      _buildModernExpansionTile(
                        context,
                        title: "VIDEOS",
                        children: punto.videos.asMap().entries.map((entry) {
                          int index = entry.key;
                          VideoHistorico video = entry.value;
                          return Container(
                            color: Colors.black.withOpacity(0.1), 
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                              leading: const Icon(Icons.play_circle_fill, color: Colors.white70, size: 28),
                              title: Text(video.titulo, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              onTap: () => _reproducirVideo(context, punto.videos, index),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // BOTÓN VER EN 3D (Estilo Moderno)
                      _buildModernButton(
                        text: "VER EN 3D",
                        onPressed: () => _mostrarModelo3D(context),
                      ),
                      const SizedBox(height: 20),

                      // SECCIÓN GALERÍA (Estilo Moderno)
                      _buildModernExpansionTile(
                        context,
                        title: "GALERÍA",
                        children: [
                          Container(
                            color: Colors.black.withOpacity(0.1),
                            padding: const EdgeInsets.all(15),
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: punto.imagenesGaleria.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 15),
                                  child: GestureDetector(
                                    onTap: () => _abrirVisorGaleria(context, index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.asset(
                                          punto.imagenesGaleria[index], 
                                          width: 220, 
                                          fit: BoxFit.cover,
                                          errorBuilder: (c,o,s) => Container(width: 220, color: Colors.grey.shade300, child: const Icon(Icons.image)),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NUEVA PANTALLA: VISOR DE VIDEO COMPLETO CON CONTROLES Y LISTA ---
class PantallaVisorVideo extends StatefulWidget {
  final List<VideoHistorico> videos;
  final int indiceInicial;
  
  const PantallaVisorVideo({super.key, required this.videos, required this.indiceInicial});

  @override
  State<PantallaVisorVideo> createState() => _PantallaVisorVideoState();
}

class _PantallaVisorVideoState extends State<PantallaVisorVideo> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _mostrarControles = true;
  late int _indiceActual;
  bool _esPantallaCompleta = false; // Estado de la rotación

  @override
  void initState() {
    super.initState();
    _indiceActual = widget.indiceInicial;
    // Habilitar rotación libre mientras se ve el video
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _inicializarVideoActual();
  }

  void _inicializarVideoActual() {
    _isInitialized = false;
    _controller = VideoPlayerController.asset(widget.videos[_indiceActual].rutaLocal)
      ..initialize().then((_) {
        setState(() { _isInitialized = true; });
        _controller.play();
        _ocultarControlesAutomaticamente();
      });
  }

  // --- LÓGICA PARA CAMBIAR AL SIGUIENTE O ANTERIOR VIDEO ---
  void _cambiarVideo(int nuevoIndice) async {
    if (nuevoIndice >= 0 && nuevoIndice < widget.videos.length) {
      final oldController = _controller;
      setState(() {
        _isInitialized = false;
        _indiceActual = nuevoIndice;
      });
      await oldController.pause();
      await oldController.dispose();
      _inicializarVideoActual();
    }
  }

  // --- LÓGICA PARA FORZAR PANTALLA COMPLETA ---
  void _togglePantallaCompleta() {
    setState(() {
      _esPantallaCompleta = !_esPantallaCompleta;
      if (_esPantallaCompleta) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
        ]);
      }
    });
  }

  void _ocultarControlesAutomaticamente() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() { _mostrarControles = false; });
      }
    });
  }

  @override
  void dispose() {
    // Al salir, forzamos que el teléfono vuelva a ser vertical
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _controller.dispose();
    super.dispose();
  }

  String _formatearDuracion(Duration duracion) {
    String dosDigitos(int n) => n.toString().padLeft(2, "0");
    String minutos = dosDigitos(duracion.inMinutes.remainder(60));
    String segundos = dosDigitos(duracion.inSeconds.remainder(60));
    return "$minutos:$segundos";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. El Reproductor de Video Central
          Center(
            child: _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  )
                : const CircularProgressIndicator(color: Colors.amberAccent),
          ),
          
          // 2. Detector de Toque (Mostrar/Ocultar interfaz)
          GestureDetector(
            onTap: () {
              setState(() { _mostrarControles = !_mostrarControles; });
              if (_mostrarControles && _controller.value.isPlaying) {
                _ocultarControlesAutomaticamente();
              }
            },
            child: Container(color: Colors.transparent),
          ),
          
          // 3. Controles en Pantalla
          if (_mostrarControles && _isInitialized)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BARRA SUPERIOR (Atrás y Título del Video)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              widget.videos[_indiceActual].titulo,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // BOTONES DE REPRODUCCIÓN Y NAVEGACIÓN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón Anterior
                      IconButton(
                        icon: Icon(Icons.skip_previous, color: _indiceActual > 0 ? Colors.white : Colors.white30, size: 45),
                        onPressed: _indiceActual > 0 ? () => _cambiarVideo(_indiceActual - 1) : null,
                      ),
                      const SizedBox(width: 10),
                      // Retroceder 10s
                      IconButton(
                        icon: const Icon(Icons.replay_10, color: Colors.white, size: 40),
                        onPressed: () {
                          final current = _controller.value.position;
                          _controller.seekTo(current - const Duration(seconds: 10));
                        },
                      ),
                      const SizedBox(width: 15),
                      // Play / Pause
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                          color: Colors.white,
                          size: 75,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying ? _controller.pause() : _controller.play();
                          });
                          if (_controller.value.isPlaying) _ocultarControlesAutomaticamente();
                        },
                      ),
                      const SizedBox(width: 15),
                      // Adelantar 10s
                      IconButton(
                        icon: const Icon(Icons.forward_10, color: Colors.white, size: 40),
                        onPressed: () {
                          final current = _controller.value.position;
                          _controller.seekTo(current + const Duration(seconds: 10));
                        },
                      ),
                      const SizedBox(width: 10),
                      // Botón Siguiente
                      IconButton(
                        icon: Icon(Icons.skip_next, color: _indiceActual < widget.videos.length - 1 ? Colors.white : Colors.white30, size: 45),
                        onPressed: _indiceActual < widget.videos.length - 1 ? () => _cambiarVideo(_indiceActual + 1) : null,
                      ),
                    ],
                  ),

                  // BARRA INFERIOR (Progreso, Duración y PANTALLA COMPLETA)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Row(
                        children: [
                          ValueListenableBuilder(
                            valueListenable: _controller,
                            builder: (context, VideoPlayerValue value, child) {
                              return Text(_formatearDuracion(value.position), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
                            },
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: VideoProgressIndicator(
                              _controller,
                              allowScrubbing: true,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              colors: VideoProgressColors(
                                playedColor: const Color(0xFFA8324E),
                                bufferedColor: Colors.white.withOpacity(0.3),
                                backgroundColor: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(_formatearDuracion(_controller.value.duration), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 10),
                          // BOTÓN DE PANTALLA COMPLETA
                          IconButton(
                            icon: Icon(_esPantallaCompleta ? Icons.fullscreen_exit : Icons.fullscreen, color: Colors.white, size: 30),
                            onPressed: _togglePantallaCompleta,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// --- PANTALLA: VISOR DE GALERÍA CON ZOOM Y SWIPE ---
class VisorGaleria extends StatefulWidget {
  final List<String> imagenes;
  final int indiceInicial;

  const VisorGaleria({super.key, required this.imagenes, required this.indiceInicial});

  @override
  State<VisorGaleria> createState() => _VisorGaleriaState();
}

class _VisorGaleriaState extends State<VisorGaleria> {
  late PageController _pageController;
  late int _indiceActual;

  @override
  void initState() {
    super.initState();
    _indiceActual = widget.indiceInicial;
    _pageController = PageController(initialPage: widget.indiceInicial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagenes.length,
            onPageChanged: (index) {
              setState(() {
                _indiceActual = index;
              });
            },
            itemBuilder: (context, index) {
              return ImagenInteractiva(rutaImagen: widget.imagenes[index]);
            },
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_indiceActual + 1} / ${widget.imagenes.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// --- WIDGET INTERNO: CONTROLADOR DE ZOOM INDEPENDIENTE ---
class ImagenInteractiva extends StatefulWidget {
  final String rutaImagen;
  const ImagenInteractiva({super.key, required this.rutaImagen});

  @override
  State<ImagenInteractiva> createState() => _ImagenInteractivaState();
}

class _ImagenInteractivaState extends State<ImagenInteractiva> {
  final TransformationController _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      _transformationController.value = Matrix4.identity()
        ..translate(-position.dx * 2, -position.dy * 2)
        ..scale(3.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0, 
        maxScale: 5.0, 
        panEnabled: true,
        child: Image.asset(
          widget.rutaImagen,
          fit: BoxFit.contain, 
        ),
      ),
    );
  }
}