import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/biomasa.dart';

class MisBiomasasScreen extends StatefulWidget {
  const MisBiomasasScreen({super.key});

  @override
  State<MisBiomasasScreen> createState() => _MisBiomasasScreenState();
}

class _MisBiomasasScreenState extends State<MisBiomasasScreen> {
  List<Biomasa> _biomasas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBiomasas();
  }

  Future<void> _loadBiomasas() async {
    setState(() => _isLoading = true);

    try {
      final biomasas = await ApiService.getBiomasas();
      setState(() {
        _biomasas = biomasas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar biomasas: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Biomasas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBiomasas,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBiomasas,
              child: _biomasas.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _biomasas.length,
                      itemBuilder: (context, index) {
                        return _buildBiomasaCard(_biomasas[index]);
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/biomasa-form');
          if (result == true) {
            _loadBiomasas();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.nature_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay biomasas reportadas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca el botón + para crear un reporte',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiomasaCard(Biomasa biomasa) {
    final status = biomasa.estado ?? 'pendiente';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.nature, color: Colors.green, size: 40),
            title: Text(
              biomasa.tipoBiomasa?.nombre ?? biomasa.tipoBiomasaNombre ?? 'Sin tipo',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Densidad: ${biomasa.densidad}'),
                Text('Área: ${biomasa.areaM2.toStringAsFixed(2)} m²'),
                if (biomasa.descripcion != null && biomasa.descripcion!.isNotEmpty)
                  Text(
                    biomasa.descripcion!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
            trailing: Chip(
              avatar: Icon(statusIcon, size: 16, color: Colors.white),
              label: Text(
                statusText,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: statusColor,
            ),
          ),
          if (status == 'rechazada' && biomasa.motivoRechazo != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red[50],
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Motivo: ${biomasa.motivoRechazo}',
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          if (status == 'aprobada' && biomasa.aprobadaPor != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.green[50],
              child: Text(
                'Aprobada por: Admin • ${biomasa.fechaRevision ?? ''}',
                style: TextStyle(color: Colors.green[800], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          if (status == 'pendiente')
            ButtonBar(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                  onPressed: () => _editBiomasa(biomasa),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => _deleteBiomasa(biomasa),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'aprobada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      case 'pendiente':
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'aprobada':
        return Icons.check_circle;
      case 'rechazada':
        return Icons.cancel;
      case 'pendiente':
      default:
        return Icons.schedule;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      case 'pendiente':
      default:
        return 'Pendiente';
    }
  }

  Future<void> _editBiomasa(Biomasa biomasa) async {
    final result = await Navigator.pushNamed(
      context,
      '/biomasa-form',
      arguments: biomasa,
    );
    if (result == true) {
      _loadBiomasas();
    }
  }

  Future<void> _deleteBiomasa(Biomasa biomasa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Biomasa'),
        content: const Text('¿Estás seguro de que deseas eliminar este reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await ApiService.deleteBiomasa(biomasa.id);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Biomasa eliminada exitosamente')),
          );
          _loadBiomasas();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Error al eliminar')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
