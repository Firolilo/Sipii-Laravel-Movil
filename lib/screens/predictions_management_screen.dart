import 'package:flutter/material.dart';
import '../services/api_service.dart';

class PredictionsManagementScreen extends StatefulWidget {
  const PredictionsManagementScreen({super.key});

  @override
  State<PredictionsManagementScreen> createState() => _PredictionsManagementScreenState();
}

class _PredictionsManagementScreenState extends State<PredictionsManagementScreen> {
  List<dynamic> _predictions = [];
  List<dynamic> _focos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getPredictions(),
        ApiService.getFocosIncendio(),
      ]);

      setState(() {
        _predictions = results[0] as List;
        _focos = results[1] as List;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _showCreatePredictionDialog() async {
    int? selectedFocoId;
    final temperatureController = TextEditingController(text: '25');
    final humidityController = TextEditingController(text: '60');
    final windSpeedController = TextEditingController(text: '15');
    final windDirectionController = TextEditingController(text: '180');
    String terrainType = 'Bosque';
    final predictionHoursController = TextEditingController(text: '24');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Crear Nueva Predicción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Foco de Incendio',
                  border: OutlineInputBorder(),
                ),
                items: _focos.map((foco) {
                  return DropdownMenuItem<int>(
                    value: foco['id'],
                    child: Text(foco['ubicacion'] ?? 'Foco #${foco['id']}'),
                  );
                }).toList(),
                onChanged: (value) => selectedFocoId = value,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: temperatureController,
                decoration: const InputDecoration(
                  labelText: 'Temperatura (°C)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: humidityController,
                decoration: const InputDecoration(
                  labelText: 'Humedad (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: windSpeedController,
                decoration: const InputDecoration(
                  labelText: 'Velocidad del viento (km/h)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: windDirectionController,
                decoration: const InputDecoration(
                  labelText: 'Dirección del viento (°)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de terreno',
                  border: OutlineInputBorder(),
                ),
                value: terrainType,
                items: ['Bosque', 'Pastizal', 'Matorral', 'Mixto'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) => terrainType = value ?? 'Bosque',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: predictionHoursController,
                decoration: const InputDecoration(
                  labelText: 'Horas de predicción',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedFocoId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Debes seleccionar un foco')),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result != true || selectedFocoId == null) return;

    try {
      final createResult = await ApiService.createPrediction(
        focoIncendioId: selectedFocoId!,
        temperature: double.parse(temperatureController.text),
        humidity: double.parse(humidityController.text),
        windSpeed: double.parse(windSpeedController.text),
        windDirection: double.parse(windDirectionController.text),
        terrainType: terrainType,
        predictionHours: int.parse(predictionHoursController.text),
      );

      if (mounted) {
        if (createResult['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Predicción creada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(createResult['message'] ?? 'Error al crear predicción'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deletePrediction(int id, String ubicacion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Predicción'),
        content: Text(
          '¿Estás seguro de eliminar la predicción de "$ubicacion"?\n\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await ApiService.deletePrediction(id);
      
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Predicción eliminada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadData();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al eliminar predicción'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Predicciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _predictions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _predictions.length,
                    itemBuilder: (context, index) {
                      return _buildPredictionCard(_predictions[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePredictionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Predicción'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay predicciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _showCreatePredictionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Crear Primera Predicción'),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard(Map<String, dynamic> prediction) {
    final id = prediction['id'];
    final focoInfo = prediction['focoIncendio'] ?? {};
    final ubicacion = focoInfo['ubicacion'] ?? 'Ubicación desconocida';
    final fecha = focoInfo['fecha'] ?? '';
    final path = prediction['path'] as List? ?? [];
    final intensidad = focoInfo['intensidad'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.blue, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ubicacion,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${_formatDate(fecha)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.schedule, '${path.length} horas'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.local_fire_department, 'Int: $intensidad'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/prediction-detail',
                      arguments: id,
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Ver Detalle'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deletePrediction(id, ubicacion),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Sin fecha';
    
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
