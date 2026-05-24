import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
import 'package:video_player/video_player.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

// --- Imports de AR_FLUTTER_PLUGIN ---
import 'package:ar_flutter_plugin/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin/models/ar_node.dart';
import 'package:ar_flutter_plugin/models/ar_hittest_result.dart';
import 'package:ar_flutter_plugin/models/ar_anchor.dart';
import 'package:ar_flutter_plugin/datatypes/node_types.dart';
// ------------------------------------

void main() {
  runApp(const ByteSoftApp());
}

class ByteSoftApp extends StatelessWidget {
  const ByteSoftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteSoft AR',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EscanerBorrador(),
    );
  }
}

class EscanerBorrador extends StatefulWidget {
  const EscanerBorrador({super.key});

  @override
  State<EscanerBorrador> createState() => _EscanerBorradorState();
}

class _EscanerBorradorState extends State<EscanerBorrador> {
  bool _targetDetectado = false;
  final bool _tieneModelo3D = true;
  bool _modoVideoActivo = true;

  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  
  // CAMBIO AQUÍ: Cambiamos ARAnchor por ARPlaneAnchor
  ARPlaneAnchor? anclaTarget; 
  
  ARNode? nodoLocal;

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/promo.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(true);
        setState(() {});
      });
  }

  @override
  void dispose() {
    arSessionManager?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ARView(onARViewCreated: onARViewCreated),
          
          if (_targetDetectado && _modoVideoActivo && _videoController.value.isInitialized)
            Center(
              child: SizedBox(
                width: 250, height: 400,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20), 
                  child: VideoPlayer(_videoController)
                ),
              ),
            ),
          
          if (_targetDetectado)
            Positioned(
              bottom: 40, left: 20, right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(heroTag: "v", onPressed: _activarModoVideo, child: const Icon(Icons.play_arrow)),
                  FloatingActionButton(heroTag: "3d", onPressed: _activarModo3D, child: const Icon(Icons.view_in_ar)),
                  FloatingActionButton(heroTag: "i", onPressed: _mostrarInfo, child: const Icon(Icons.info_outline)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void onARViewCreated(ARSessionManager s, ARObjectManager o, ARAnchorManager a, ARLocationManager l) {
    arSessionManager = s; arObjectManager = o; arAnchorManager = a;
    arSessionManager!.onInitialize(showPlanes: true);
    arObjectManager!.onInitialize();
    arSessionManager!.onPlaneOrPointTap = onPlaneOrPointTap;
  }

  Future<void> onPlaneOrPointTap(List<ARHitTestResult> results) async {
    if (!_targetDetectado && results.isNotEmpty) {
      var hit = results.first;
      var nuevoAncla = ARPlaneAnchor(transformation: hit.worldTransform);
      if (await arAnchorManager!.addAnchor(nuevoAncla) == true) {
        setState(() {
          anclaTarget = nuevoAncla;
          _targetDetectado = true;
        });
        _videoController.play();
      }
    }
  }

  void _activarModoVideo() {
    setState(() { _modoVideoActivo = true; });
    if (nodoLocal != null) arObjectManager!.removeNode(nodoLocal!);
    _videoController.play();
  }

  Future<void> _activarModo3D() async {
    if (!_tieneModelo3D || anclaTarget == null) return;
    setState(() { _modoVideoActivo = false; });
    _videoController.pause();
    var newNode = ARNode(
      type: NodeType.localGLTF2,
      uri: "assets/models/modelo_prueba.gltf",
      scale: vector.Vector3(0.2, 0.2, 0.2),
    );
    if (await arObjectManager!.addNode(newNode, planeAnchor: anclaTarget!) == true) {
      nodoLocal = newNode;
    }
  }

  void _mostrarInfo() {
    showModalBottomSheet(
      context: context, 
      builder: (ctx) => const Padding(
        padding: EdgeInsets.all(20), 
        child: Text("ByteSoft AR - Info", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      )
    );
  }
}