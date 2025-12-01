import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/biomasa.dart';

class ModerarBiomasasScreen extends StatefulWidget {
  const ModerarBiomasasScreen({super.key});

  @override
  State<ModerarBiomasasScreen> createState() => _ModerarBiomasasScreenState();
}

class _ModerarBiomasasScreenState extends State<ModerarBiomasasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Biomasa> _biomasas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBiomasas();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  List<Biomasa> get _pendientes =>
      _biomasas.where((b) => b.estado == 'pendiente').toList();
  List<Biomasa> get _aprobadas =>
      _biomasas.where((b) => b.estado == 'aprobada').toList();
  List<Biomasa> get _rechazadas =>
      _biomasas.where((b) => b.estado == 'rechazada').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderar Biomasas'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.schedule),
              text: 'Pendientes (${_pendientes.length})',
            ),
            Tab(
              icon: const Icon(Icons.check_circle),
              text: 'Aprobadas (${_aprobadas.length})',
            ),
            Tab(
              icon: const Icon(Icons.cancel),
              text: 'Rechazadas (${_rechazadas.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBiomasas,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBiomasasList(_pendientes, isPendiente: true),
                  _buildBiomasasList(_aprobadas),
                  _buildBiomasasList(_rechazadas),
                ],
              ),
            ),
    );
  }

  Widget _buildBiomasasList(List<Biomasa> biomasas, {bool isPendiente = false}) {
    if (biomasas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay biomasas en esta categoría',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: biomasas.length,
      itemBuilder: (context, index) {
        return _buildBiomasaCard(biomasas[index], isPendiente: isPendiente);
      },
    );
  }

  Widget _buildBiomasaCard(Biomasa biomasa, {bool isPendiente = false}) {
    final status = biomasa.estado ?? 'pendiente';
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.nature, color: statusColor, size: 30),
            ),
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
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                Text(
                  'Reportado: ${biomasa.fechaReporte}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
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
          if (isPendiente)
            ButtonBar(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Aprobar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                  onPressed: () => _aprobarBiomasa(biomasa),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Rechazar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => _rechazarBiomasa(biomasa),
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

  Future<void> _aprobarBiomasa(Biomasa biomasa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aprobar Biomasa'),
        content: Text(
          '¿Estás seguro de que deseas aprobar el reporte de ${biomasa.tipoBiomasa?.nombre ?? 'biomasa'}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Aprobar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final result = await ApiService.aprobarBiomasa(biomasa.id);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biomasa aprobada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadBiomasas();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al aprobar'),
              backgroundColor: Colors.red,
            ),
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

  Future<void> _rechazarBiomasa(Biomasa biomasa) async {
    final motivoController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar Biomasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Por qué deseas rechazar este reporte de ${biomasa.tipoBiomasa?.nombre ?? 'biomasa'}?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: motivoController,
              decoration: const InputDecoration(
                labelText: 'Motivo de rechazo',
                hintText: 'Escribe el motivo...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 250,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (motivoController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Debes escribir un motivo de rechazo'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );

    if (confirm != true) {
      motivoController.dispose();
      return;
    }

    final motivo = motivoController.text.trim();
    motivoController.dispose();

    try {
      final result = await ApiService.rechazarBiomasa(biomasa.id, motivo);

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Biomasa rechazada'),
              backgroundColor: Colors.red,
            ),
          );
          _loadBiomasas();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al rechazar'),
              backgroundColor: Colors.red,
            ),
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
