import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/pdf_service.dart';

class PredictionsListScreen extends StatefulWidget {
  const PredictionsListScreen({super.key});

  @override
  State<PredictionsListScreen> createState() => _PredictionsListScreenState();
}

class _PredictionsListScreenState extends State<PredictionsListScreen> {
  List<dynamic> _predictions = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
    _loadPredictions();
  }

  Future<void> _loadUserRole() async {
    final isAdmin = await ApiService.isAdmin();
    setState(() => _isAdmin = isAdmin);
  }

  Future<void> _loadPredictions() async {
    setState(() => _isLoading = true);

    try {
      final predictions = await ApiService.getPredictions();
      setState(() {
        _predictions = predictions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar predicciones: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predicciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPredictions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPredictions,
              child: _predictions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _predictions.length,
                      itemBuilder: (context, index) {
                        return _buildPredictionCard(_predictions[index]);
                      },
                    ),
            ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  '/predictions-management',
                );
                if (result == true) {
                  _loadPredictions();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
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
            'No hay predicciones disponibles',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
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
    
    // Calcular duración en base a la cantidad de puntos en el path
    final duration = path.length;
    
    // Obtener temperatura del primer punto del path si existe
    String? temperature;
    if (path.isNotEmpty && path[0]['temperature'] != null) {
      temperature = '${path[0]['temperature']}°C';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/prediction-detail',
            arguments: id,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.analytics, color: Colors.blue, size: 40),
                  const SizedBox(width: 16),
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
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(Icons.schedule, '$duration horas'),
                  const SizedBox(width: 8),
                  _buildInfoChip(Icons.local_fire_department, 'Intensidad: $intensidad'),
                  if (temperature != null) ...[
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.thermostat, temperature),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _generatePdf(prediction),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF'),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _generatePdf(Map<String, dynamic> prediction) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descargando PDF...')),
      );

      final predictionId = prediction['id'];
      await PdfService.downloadPredictionPdfFromServer(predictionId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF descargado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al descargar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
