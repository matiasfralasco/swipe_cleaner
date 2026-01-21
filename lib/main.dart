import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Quita la etiqueta 'Debug' de la esquina
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black, // Fondo negro puro para ahorrar batería
      ),
      home: const CleanerHome(),
    );
  }
}

class CleanerHome extends StatefulWidget {
  const CleanerHome({super.key});

  @override
  State<CleanerHome> createState() => _CleanerHomeState();
}

class _CleanerHomeState extends State<CleanerHome> {
  // VARIABLES DE ESTADO
  List<AssetEntity> _fotos = [];
  final List<AssetEntity> _papelera = [];
  List<AssetPathEntity> _albumes = [];
  AssetPathEntity? _albumSeleccionado;
  bool _cargando = true;
  bool _sinPermisos = false;
  final CardSwiperController _controller = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  // 1. SOLICITAR PERMISOS Y CARGAR CARPETAS
  Future<void> _inicializar() async {
    // Pedimos permisos múltiples para cubrir Android viejo y nuevo
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.photos,
    ].request();

    bool permisoConcedido = statuses[Permission.storage]!.isGranted || 
                            statuses[Permission.photos]!.isGranted ||
                            await Permission.photos.isLimited;

    if (permisoConcedido) {
      // Obtenemos TODOS los álbumes disponibles
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        filterOption: FilterOptionGroup(
          orders: [const OrderOption(type: OrderOptionType.createDate, asc: false)],
        ),
      );
      
      setState(() {
        _albumes = albums;
        _cargando = false;
      });
    } else {
      setState(() {
        _sinPermisos = true;
        _cargando = false;
      });
    }
  }

  // 2. CARGAR FOTOS DEL ÁLBUM SELECCIONADO
  Future<void> _cargarFotosDelAlbum(AssetPathEntity album) async {
    setState(() => _cargando = true);
    
    try {
      final List<AssetEntity> media = await album.getAssetListPaged(page: 0, size: 100);
      
      setState(() {
        _albumSeleccionado = album;
        _fotos = media;
        _papelera.clear(); // Limpiar papelera al cambiar álbum
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al cargar fotos: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  // 3. VOLVER A LA PANTALLA DE SELECCIÓN
  void _volverASeleccion() {
    setState(() {
      _albumSeleccionado = null;
      _fotos.clear();
      _papelera.clear();
    });
  }

  // 4. BORRAR FOTOS REALMENTE
  Future<void> _vaciarPapelera() async {
    if (_papelera.isEmpty) return;

    final List<String> idsParaBorrar = _papelera.map((e) => e.id).toList();
    final messenger = ScaffoldMessenger.of(context);

    try {
      // Esto lanza el popup nativo del sistema
      final List<String> result = await PhotoManager.editor.deleteWithIds(idsParaBorrar);
      
      if (result.isNotEmpty) {
        // Feedback visual
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text("¡${result.length} fotos eliminadas!"),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _papelera.clear(); // Limpiamos la lista local
          });
        }
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de carga
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Pantalla sin permisos
    if (_sinPermisos) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Necesitamos acceso a tus fotos"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: openAppSettings, 
                child: const Text("Abrir Configuración")
              )
            ],
          ),
        ),
      );
    }

    // PANTALLA DE SELECCIÓN DE CARPETAS
    if (_albumSeleccionado == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Swipe Cleaner - Selecciona Carpeta"),
          elevation: 0,
        ),
        body: _albumes.isEmpty
            ? const Center(child: Text("No hay carpetas disponibles"))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: _albumes.length,
                itemBuilder: (context, index) {
                  final album = _albumes[index];
                  return GestureDetector(
                    onTap: () => _cargarFotosDelAlbum(album),
                    child: Card(
                      color: Colors.grey[900],
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Stack(
                        children: [
                          // Imagen de fondo (previsualización)
                          FutureBuilder<List<AssetEntity>>(
                            future: album.getAssetListPaged(page: 0, size: 1),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                                final primeraFoto = snapshot.data!.first;
                                return FutureBuilder<Uint8List?>(
                                  future: primeraFoto.thumbnailData,
                                  builder: (context, thumbSnapshot) {
                                    if (thumbSnapshot.hasData && thumbSnapshot.data != null) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          image: DecorationImage(
                                            image: MemoryImage(thumbSnapshot.data!),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      );
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.grey[900]!,
                                            Colors.grey[800]!,
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey[900]!,
                                      Colors.grey[800]!,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Overlay oscuro para mejorar legibilidad del texto
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                          ),
                          // Contenido (texto)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                child: Text(
                                  album.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                                child: FutureBuilder<int>(
                                  future: album.assetCountAsync,
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                        "${snapshot.data} fotos",
                                        style: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }
                                    return const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    }

    // Pantalla principal (Si no hay fotos en el álbum seleccionado)
    if (_fotos.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text("${_albumSeleccionado?.name} - Vacía"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _volverASeleccion,
          ),
        ),
        body: const Center(child: Text("¡No hay fotos en esta carpeta!")),
      );
    }

    // LA APP FUNCIONAL (SWIPE)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("${_albumSeleccionado?.name}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _volverASeleccion,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(
                "${_papelera.length} 🗑️", 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: CardSwiper(
              controller: _controller,
              cardsCount: _fotos.length,
              numberOfCardsDisplayed: 3,
              backCardOffset: const Offset(0, 40), // Efecto visual de pila
              padding: const EdgeInsets.all(24.0),
              
              // Lógica del Swipe
              onSwipe: (previousIndex, currentIndex, direction) {
                final foto = _fotos[previousIndex];
                
                if (direction == CardSwiperDirection.left) {
                  // IZQUIERDA = BASURA
                  setState(() { _papelera.add(foto); });
                }
                // DERECHA = GUARDAR (No hacemos nada, solo pasa)
                return true; 
              },
              
              // Diseño de la Carta
              cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.grey[900], // Fondo mientras carga
                    child: FutureBuilder<File?>(
                      future: _fotos[index].file,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          return Image.file(
                            snapshot.data!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Botón de Borrado
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _papelera.isEmpty ? Colors.grey[800] : Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _papelera.isNotEmpty ? _vaciarPapelera : null,
                child: Text(
                  _papelera.isEmpty ? "Desliza a la izquierda para borrar" : "ELIMINAR ${_papelera.length} FOTOS",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}