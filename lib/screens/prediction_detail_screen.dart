import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';

class PredictionDetailScreen extends StatefulWidget {
  const PredictionDetailScreen({super.key});

  @override
  State<PredictionDetailScreen> createState() => _PredictionDetailScreenState();
}

class _PredictionDetailScreenState extends State<PredictionDetailScreen> {
  Map<String, dynamic>? _prediction;
  bool _isLoading = true;
  int? _predictionId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is int && _predictionId == null) {
      _predictionId = args;
      _loadPrediction();
    }
  }

  Future<void> _loadPrediction() async {
    if (_predictionId == null) return;

    setState(() => _isLoading = true);

    try {
      final prediction = await ApiService.getPrediction(_predictionId!);
      setState(() {
        _prediction = prediction;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar predicción: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Predicción'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _prediction == null
              ? const Center(child: Text('No se encontró la predicción'))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildMap(),
                      _buildInfoCard(),
                      _buildParametersCard(),
                      _buildTrajectoryList(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMap() {
    final path = _prediction!['path'] as List<dynamic>? ?? [];
    if (path.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convertir path a LatLng
    final points = path.map((point) {
      if (point is Map) {
        final lat = point['lat'] ?? point['latitude'];
        final lng = point['lng'] ?? point['longitude'];
        if (lat != null && lng != null) {
          return LatLng(
            lat is num ? lat.toDouble() : double.parse(lat.toString()),
            lng is num ? lng.toDouble() : double.parse(lng.toString()),
          );
        }
      }
      return null;
    }).whereType<LatLng>().toList();

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: points.first,
          initialZoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.sipii.app',
          ),
          // Línea de trayectoria
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4,
                color: Colors.red,
                gradientColors: [
                  Colors.orange,
                  Colors.red,
                  Colors.deepOrange,
                ],
              ),
            ],
          ),
          // Marcador inicial
          MarkerLayer(
            markers: [
              Marker(
                point: points.first,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.green,
                  size: 40,
                ),
              ),
              if (points.length > 1)
                Marker(
                  point: points.last,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.flag,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final focoInfo = _prediction!['focoIncendio'] ?? {};
    final ubicacion = focoInfo['ubicacion'] ?? 'Ubicación desconocida';
    final fecha = focoInfo['fecha'] ?? '';
    final intensidad = focoInfo['intensidad'] ?? 0;
    final path = _prediction!['path'] as List? ?? [];

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación del Foco',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        ubicacion,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Fecha: ${_formatDate(fecha)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.local_fire_department, size: 20, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Intensidad: $intensidad',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.timeline, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Duración predicción: ${path.length} horas',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Sin fecha';
    
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildParametersCard() {
    final path = _prediction!['path'] as List? ?? [];
    if (path.isEmpty) return const SizedBox.shrink();
    
    // Obtener datos del primer punto del path
    final firstPoint = path[0];
    final intensity = firstPoint['intensity']?.toString() ?? '--';
    final spreadRadius = firstPoint['spread_radius_km']?.toString() ?? '--';
    final affectedArea = firstPoint['affected_area_km2']?.toString() ?? '--';
    final perimeter = firstPoint['perimeter_km']?.toString() ?? '--';
    
    // Obtener datos del último punto para ver la evolución
    final lastPoint = path.length > 1 ? path[path.length - 1] : firstPoint;
    final finalIntensity = lastPoint['intensity']?.toString() ?? '--';
    final finalArea = lastPoint['affected_area_km2']?.toString() ?? '--';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parámetros de Propagación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Estado Inicial',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildParamItem(
                    Icons.local_fire_department,
                    'Intensidad',
                    intensity,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildParamItem(
                    Icons.radio_button_unchecked,
                    'Radio',
                    '$spreadRadius km',
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildParamItem(
                    Icons.crop_square,
                    'Área afectada',
                    '$affectedArea km²',
                    Colors.red,
                  ),
                ),
                Expanded(
                  child: _buildParamItem(
                    Icons.timeline,
                    'Perímetro',
                    '$perimeter km',
                    Colors.purple,
                  ),
                ),
              ],
            ),
            if (path.length > 1) ...[
              const Divider(height: 24),
              Text(
                'Estado Final (${path.length}h)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildParamItem(
                      Icons.local_fire_department,
                      'Intensidad final',
                      finalIntensity,
                      Colors.deepOrange,
                    ),
                  ),
                  Expanded(
                    child: _buildParamItem(
                      Icons.crop_square,
                      'Área final',
                      '$finalArea km²',
                      Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParamItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrajectoryList() {
    final path = _prediction!['path'] as List<dynamic>? ?? [];
    if (path.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Trayectoria Hora por Hora',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: path.length > 10 ? 10 : path.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final point = path[index] as Map<String, dynamic>;
              final hour = point['hour'] ?? index;
              final lat = point['lat'];
              final lng = point['lng'];
              final intensity = point['intensity']?.toStringAsFixed(2) ?? '--';
              final area = point['affected_area_km2']?.toStringAsFixed(2) ?? '--';
              
              String coords = 'Coordenadas no disponibles';
              if (lat != null && lng != null) {
                coords = '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.1 + (index * 0.09)),
                  child: Text(
                    '$hour',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('Hora $hour'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coords, style: const TextStyle(fontSize: 12)),
                    Text(
                      'Intensidad: $intensity | Área: $area km²',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            },
          ),
          if (path.length > 10)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '+${path.length - 10} puntos más',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
