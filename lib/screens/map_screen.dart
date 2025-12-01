import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../models/foco_incendio.dart';
import '../models/biomasa.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController _mapController;
  List<FocoIncendio> _focos = [];
  List<Biomasa> _biomasas = [];
  bool _isLoading = true;
  String? _error;

  // Coordenadas iniciales (San José de Chiquitos, Bolivia)
  final LatLng _initialCenter = const LatLng(-17.7486, -60.7464);
  final double _initialZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Cargar focos de incendio y biomasas en paralelo
      final results = await Future.wait([
        ApiService.getFocosIncendio(),
        ApiService.getBiomasas(),
      ]);

      setState(() {
        _focos = results[0] as List<FocoIncendio>;
        _biomasas = results[1] as List<Biomasa>;
        _isLoading = false;
      });

      // Mantener el mapa centrado en Santa Cruz, Bolivia
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _mapController.move(_initialCenter, _initialZoom);
          }
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los datos: $e';
        _isLoading = false;
      });
    }
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // Marcadores de focos de incendio (rojos)
    for (var foco in _focos) {
      markers.add(
        Marker(
          point: LatLng(foco.latitude, foco.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showFocoDetails(foco),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.red,
              size: 40,
            ),
          ),
        ),
      );
    }

    return markers;
  }

  List<Polygon> _buildPolygons() {
    final polygons = <Polygon>[];

    // Polígonos de biomasas con color dinámico según tipo
    for (var biomasa in _biomasas) {
      if (biomasa.coordenadas.isNotEmpty) {
        final points = biomasa.coordenadas
            .map((coord) => LatLng(coord[0], coord[1]))
            .toList();
        
        // Parsear color hexadecimal del tipo de biomasa
        Color fillColor = Colors.green;
        Color borderColor = Colors.green.shade700;
        
        if (biomasa.tipoBiomasaColor != null && biomasa.tipoBiomasaColor!.isNotEmpty) {
          try {
            final hexColor = biomasa.tipoBiomasaColor!.replaceAll('#', '');
            fillColor = Color(int.parse('FF$hexColor', radix: 16));
            borderColor = Color(int.parse('FF$hexColor', radix: 16)).withOpacity(0.8);
          } catch (e) {
            print('Error parseando color: $e');
          }
        }
        
        polygons.add(
          Polygon(
            points: points,
            color: fillColor.withOpacity(0.4),
            borderColor: borderColor,
            borderStrokeWidth: 2.5,
            isFilled: true,
          ),
        );
      }
    }

    return polygons;
  }

  void _handleMapTap(TapPosition tapPosition, LatLng tappedPoint) {
    
    // Buscar biomasa cuyo polígono contenga el punto
    for (var biomasa in _biomasas) {
      if (biomasa.coordenadas.isNotEmpty) {
        final points = biomasa.coordenadas
            .map((coord) => LatLng(coord[0], coord[1]))
            .toList();
        
        if (_isPointInPolygon(tappedPoint, points)) {
          _showBiomasaDetails(biomasa);
          return;
        }
      }
    }
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int j = 0; j < polygon.length - 1; j++) {
      if (_rayCastIntersect(point, polygon[j], polygon[j + 1])) {
        intersectCount++;
      }
    }

    return (intersectCount % 2) == 1; // odd = inside, even = outside
  }

  bool _rayCastIntersect(LatLng point, LatLng vertA, LatLng vertB) {
    double aY = vertA.latitude;
    double bY = vertB.latitude;
    double aX = vertA.longitude;
    double bX = vertB.longitude;
    double pY = point.latitude;
    double pX = point.longitude;

    if ((aY > pY && bY > pY) || (aY < pY && bY < pY) || (aX < pX && bX < pX)) {
      return false;
    }

    double m = (aY - bY) / (aX - bX);
    double bee = (-aX) * m + aY;
    double x = (pY - bee) / m;

    return x > pX;
  }

  void _showFocoDetails(FocoIncendio foco) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.red.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.orange.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_fire_department, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foco de Incendio',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getIntensityColor(foco.intensidad).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _getIntensityColor(foco.intensidad),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Intensidad: ${foco.intensidad}/10',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getIntensityColor(foco.intensidad),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.red.shade200, thickness: 1.5),
            const SizedBox(height: 16),
            _buildDetailRow('Ubicación', foco.ubicacion),
            _buildDetailRow('Fecha', foco.fecha.toString().split(' ')[0]),
            _buildDetailRow(
              'Coordenadas',
              '${foco.latitude.toStringAsFixed(6)}, ${foco.longitude.toStringAsFixed(6)}',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _compartirFocoPorWhatsApp(foco);
                    },
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // Verde WhatsApp
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Cerrar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity >= 8) return Colors.red.shade900;
    if (intensity >= 6) return Colors.red.shade700;
    if (intensity >= 4) return Colors.orange.shade700;
    return Colors.orange.shade500;
  }

  Future<void> _compartirFocoPorWhatsApp(FocoIncendio foco) async {
    final mensaje = '''
🔥 ALERTA: Foco de Incendio Detectado

📍 Ubicación: ${foco.ubicacion}
📅 Fecha: ${foco.fecha.toString().split(' ')[0]}
🔥 Intensidad: ${foco.intensidad}/10
🌍 Coordenadas:
   Lat: ${foco.latitude.toStringAsFixed(6)}
   Lng: ${foco.longitude.toStringAsFixed(6)}

📍 Ver en Google Maps:
https://www.google.com/maps?q=${foco.latitude},${foco.longitude}

Compartido desde SIPII App
    ''';

    try {
      await Share.share(
        mensaje,
        subject: '🔥 Alerta de Foco de Incendio',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: ${e.toString()}'),
            backgroundColor: Colors.orange.shade700,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Future<void> _compartirBiomasaPorWhatsApp(Biomasa biomasa) async {
    final centro = biomasa.center;
    final mensaje = '''
🌿 Información de Biomasa

🏷️ Tipo: ${biomasa.tipoBiomasaNombre ?? 'N/A'}
📊 Densidad: ${biomasa.densidad}
📏 Área: ${biomasa.areaM2.toStringAsFixed(2)} m²${biomasa.perimetroM != null ? '\nPerímetro: ${biomasa.perimetroM!.toStringAsFixed(2)} m' : ''}
📅 Fecha reporte: ${biomasa.fechaReporte.toString().split(' ')[0]}
🌍 Centro (aprox):
   Lat: ${centro[0].toStringAsFixed(6)}
   Lng: ${centro[1].toStringAsFixed(6)}

📍 Ver en Google Maps:
https://www.google.com/maps?q=${centro[0]},${centro[1]}

Compartido desde SIPII App
    ''';

    try {
      await Share.share(
        mensaje,
        subject: '🌿 Información de Biomasa',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al compartir: ${e.toString()}'),
            backgroundColor: Colors.orange.shade700,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _showBiomasaDetails(Biomasa biomasa) {
    // Parsear color hexadecimal del tipo de biomasa
    Color biomasaColor = Colors.green;
    if (biomasa.tipoBiomasaColor != null && biomasa.tipoBiomasaColor!.isNotEmpty) {
      try {
        final hexColor = biomasa.tipoBiomasaColor!.replaceAll('#', '');
        biomasaColor = Color(int.parse('FF$hexColor', radix: 16));
      } catch (e) {
        print('Error parseando color: $e');
      }
    }
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, biomasaColor.withOpacity(0.05)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: biomasaColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: biomasaColor, width: 2),
                  ),
                  child: Icon(Icons.grass, color: biomasaColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        biomasa.tipoBiomasaNombre ?? 'Biomasa',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: biomasaColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ID: ${biomasa.id}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: biomasaColor.withOpacity(0.3), thickness: 1.5),
            const SizedBox(height: 16),
            _buildDetailRow('Densidad', biomasa.densidad),
            _buildDetailRow('Área', '${biomasa.areaM2.toStringAsFixed(2)} m²'),
            if (biomasa.perimetroM != null)
              _buildDetailRow('Perímetro', '${biomasa.perimetroM!.toStringAsFixed(2)} m'),
            if (biomasa.descripcion != null && biomasa.descripcion!.isNotEmpty)
              _buildDetailRow('Descripción', biomasa.descripcion!),
            _buildDetailRow('Fecha reporte', biomasa.fechaReporte.toString().split(' ')[0]),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _compartirBiomasaPorWhatsApp(biomasa);
                    },
                    icon: const Icon(Icons.share, size: 20),
                    label: const Text('Compartir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366), // Verde WhatsApp
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Cerrar'),
                    style: TextButton.styleFrom(
                      foregroundColor: biomasaColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIPII - Mapa'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Recargar datos',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialCenter,
                        initialZoom: _initialZoom,
                        minZoom: 3.0,
                        maxZoom: 18.0,
                        onTap: _handleMapTap,
                      ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.sipii.flutter',
                          ),
                          PolygonLayer(
                            polygons: _buildPolygons(),
                          ),
                          MarkerLayer(
                            markers: _buildMarkers(),
                          ),
                        ],
                      ),
                    
                    // Leyenda con diseño mejorado
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.legend_toggle,
                                    color: Colors.orange.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Leyenda',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildLegendItem(
                                Icons.local_fire_department,
                                Colors.red,
                                'Focos',
                                _focos.length,
                              ),
                              const SizedBox(height: 8),
                              _buildLegendItem(
                                Icons.grass,
                                Colors.green,
                                'Biomasas',
                                _biomasas.length,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label ($count)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
