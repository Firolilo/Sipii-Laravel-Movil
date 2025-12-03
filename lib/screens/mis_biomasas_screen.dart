import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/biomasa.dart';

class BiomasasScreen extends StatefulWidget {
  const BiomasasScreen({super.key});

  @override
  State<BiomasasScreen> createState() => _BiomasasScreenState();
}

class _BiomasasScreenState extends State<BiomasasScreen> {
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
      final allBiomasas = await ApiService.getBiomasas();
      // Filtrar solo las aprobadas
      final biomasas = allBiomasas.where((b) => b.estado == 'aprobada').toList();
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
        title: const Text('Biomasas'),
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
            'No hay biomasas aprobadas',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Las biomasas aparecerán aquí cuando sean aprobadas',
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
    // Obtener color del tipo de biomasa
    Color tipoColor = Colors.green;
    if (biomasa.tipoBiomasaColor != null) {
      try {
        final hex = biomasa.tipoBiomasaColor!.replaceAll('#', '');
        tipoColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: tipoColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: tipoColor, width: 2),
          ),
          child: Icon(Icons.nature, color: tipoColor, size: 28),
        ),
        title: Text(
          biomasa.tipoBiomasa?.nombre ?? biomasa.tipoBiomasaNombre ?? 'Sin tipo',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.grass, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Densidad: ${biomasa.densidad}'),
              ],
            ),
            Row(
              children: [
                Icon(Icons.square_foot, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Área: ${_formatArea(biomasa.areaM2)}'),
              ],
            ),
            if (biomasa.descripcion != null && biomasa.descripcion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  biomasa.descripcion!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.check_circle, color: Colors.green),
        isThreeLine: true,
      ),
    );
  }

  String _formatArea(double area) {
    if (area >= 10000) {
      return '${(area / 10000).toStringAsFixed(2)} ha';
    }
    return '${area.toStringAsFixed(0)} m²';
  }
}
