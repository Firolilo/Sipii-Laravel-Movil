import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../models/biomasa.dart';
import '../models/tipo_biomasa.dart';

class BiomasaFormScreen extends StatefulWidget {
  const BiomasaFormScreen({super.key});

  @override
  State<BiomasaFormScreen> createState() => _BiomasaFormScreenState();
}

class _BiomasaFormScreenState extends State<BiomasaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  
  // Controllers
  final _areaController = TextEditingController();
  final _perimetroController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  // Form data
  List<TipoBiomasa> _tiposBiomasa = [];
  TipoBiomasa? _selectedTipo;
  String _densidad = 'Media';
  List<LatLng> _polygonPoints = [];
  bool _isLoading = false;
  bool _isEditMode = false;
  Biomasa? _biomasaToEdit;

  @override
  void initState() {
    super.initState();
    _loadTiposBiomasa();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Verificar si se pasó una biomasa para editar (solo una vez)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Biomasa && !_isEditMode) {
      _biomasaToEdit = args;
      _isEditMode = true;
      // Esperar a que se carguen los tipos antes de cargar datos
      if (_tiposBiomasa.isNotEmpty) {
        _loadBiomasaData();
      }
    }
  }

  void _loadBiomasaData() {
    if (_biomasaToEdit == null || _tiposBiomasa.isEmpty) return;

    setState(() {
      _densidad = _biomasaToEdit!.densidad;
      _areaController.text = _biomasaToEdit!.areaM2.toString();
      _perimetroController.text = _biomasaToEdit!.perimetroM?.toString() ?? '';
      _descripcionController.text = _biomasaToEdit!.descripcion ?? '';
      
      // Convertir coordenadas a LatLng
      _polygonPoints = _biomasaToEdit!.coordenadas.map((coord) {
        return LatLng(coord[0], coord[1]);
      }).toList();
      
      // Seleccionar tipo de biomasa - con validación
      final tipoId = _biomasaToEdit!.tipoBiomasaId;
      try {
        _selectedTipo = _tiposBiomasa.firstWhere(
          (tipo) => tipo.id == tipoId,
        );
      } catch (e) {
        // Si no encuentra el tipo, usar el primero disponible
        _selectedTipo = _tiposBiomasa.isNotEmpty ? _tiposBiomasa.first : null;
      }
    });
  }

  Future<void> _loadTiposBiomasa() async {
    try {
      final tipos = await ApiService.getTiposBiomasa();
      setState(() {
        _tiposBiomasa = tipos;
        if (_tiposBiomasa.isNotEmpty && _selectedTipo == null) {
          _selectedTipo = _tiposBiomasa.first;
        }
        // Si estamos en modo edición y ya se cargaron los tipos, cargar datos de biomasa
        if (_isEditMode && _biomasaToEdit != null) {
          _loadBiomasaData();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar tipos de biomasa: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _perimetroController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _addPointToPolygon(LatLng point) {
    setState(() {
      _polygonPoints.add(point);
      _calculateArea();
    });
  }

  void _removeLastPoint() {
    if (_polygonPoints.isEmpty) return;
    setState(() {
      _polygonPoints.removeLast();
      _calculateArea();
    });
  }

  void _clearPolygon() {
    setState(() {
      _polygonPoints.clear();
      _areaController.clear();
      _perimetroController.clear();
    });
  }

  void _calculateArea() {
    if (_polygonPoints.length < 3) {
      _areaController.text = '0.0';
      _perimetroController.text = '0.0';
      return;
    }

    // Calcular área usando fórmula de Shoelace
    double area = 0.0;
    final n = _polygonPoints.length;
    
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      area += _polygonPoints[i].latitude * _polygonPoints[j].longitude;
      area -= _polygonPoints[j].latitude * _polygonPoints[i].longitude;
    }
    
    area = (area.abs() / 2.0) * 111319.9 * 111319.9; // Convertir a m²
    
    // Calcular perímetro
    double perimetro = 0.0;
    const distance = Distance();
    
    for (int i = 0; i < n; i++) {
      final j = (i + 1) % n;
      perimetro += distance.as(LengthUnit.Meter, _polygonPoints[i], _polygonPoints[j]);
    }

    _areaController.text = area.round().toString();
    _perimetroController.text = perimetro.round().toString();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes dibujar un polígono con al menos 3 puntos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedTipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes seleccionar un tipo de biomasa'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Convertir LatLng a array de coordenadas
      final coordenadas = _polygonPoints.map((point) {
        return [point.latitude, point.longitude];
      }).toList();

      final area = double.parse(_areaController.text).round().toDouble();
      final perimetro = _perimetroController.text.isNotEmpty 
          ? double.parse(_perimetroController.text).round().toDouble() 
          : null;

      Map<String, dynamic> result;

      if (_isEditMode && _biomasaToEdit != null) {
        // Actualizar biomasa existente
        result = await ApiService.updateBiomasa(
          id: _biomasaToEdit!.id,
          tipoBiomasaId: _selectedTipo!.id,
          densidad: _densidad,
          coordenadas: coordenadas,
          areaM2: area,
          perimetroM: perimetro,
          descripcion: _descripcionController.text.isNotEmpty 
              ? _descripcionController.text 
              : null,
        );
      } else {
        // Crear nueva biomasa
        result = await ApiService.createBiomasa(
          tipoBiomasaId: _selectedTipo!.id,
          densidad: _densidad,
          coordenadas: coordenadas,
          areaM2: area,
          perimetroM: perimetro,
          descripcion: _descripcionController.text.isNotEmpty 
              ? _descripcionController.text 
              : null,
        );
      }

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditMode 
                    ? 'Biomasa actualizada exitosamente' 
                    : 'Biomasa creada exitosamente. Pendiente de aprobación.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al guardar biomasa'),
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Biomasa' : 'Reportar Biomasa'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Mapa
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: const LatLng(-17.7486, -60.7464), // San José de Chiquitos
                      initialZoom: 13,
                      onTap: (_, point) => _addPointToPolygon(point),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sipii.app',
                      ),
                      if (_polygonPoints.length >= 3)
                        PolygonLayer(
                          polygons: [
                            Polygon(
                              points: _polygonPoints,
                              color: Colors.green.withOpacity(0.3),
                              borderColor: Colors.green,
                              borderStrokeWidth: 3,
                            ),
                          ],
                        ),
                      MarkerLayer(
                        markers: _polygonPoints.asMap().entries.map((entry) {
                          return Marker(
                            point: entry.value,
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'undo',
                          onPressed: _removeLastPoint,
                          backgroundColor: Colors.orange,
                          child: const Icon(Icons.undo),
                        ),
                        const SizedBox(height: 8),
                        FloatingActionButton.small(
                          heroTag: 'clear',
                          onPressed: _clearPolygon,
                          backgroundColor: Colors.red,
                          child: const Icon(Icons.clear),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        'Puntos: ${_polygonPoints.length}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Formulario
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tipo de Biomasa
                    DropdownButtonFormField<TipoBiomasa>(
                      value: _selectedTipo,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Biomasa',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _tiposBiomasa.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Row(
                            children: [
                              if (tipo.color != null)
                                Container(
                                  width: 20,
                                  height: 20,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: _parseColor(tipo.color!),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(tipo.nombre),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedTipo = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un tipo de biomasa';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Densidad
                    DropdownButtonFormField<String>(
                      value: _densidad,
                      decoration: const InputDecoration(
                        labelText: 'Densidad',
                        prefixIcon: Icon(Icons.grass),
                      ),
                      items: ['Baja', 'Media', 'Alta'].map((densidad) {
                        return DropdownMenuItem(
                          value: densidad,
                          child: Text(densidad),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _densidad = value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Área (calculada automáticamente)
                    TextFormField(
                      controller: _areaController,
                      decoration: InputDecoration(
                        labelText: 'Área (m²)',
                        prefixIcon: const Icon(Icons.square_foot),
                        suffixText: 'm²',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabled: false,
                      ),
                      readOnly: true,
                      style: const TextStyle(color: Colors.black87),
                      validator: (value) {
                        if (value == null || value.isEmpty || value == '0.0') {
                          return 'El área debe ser mayor a 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Perímetro (calculado automáticamente)
                    TextFormField(
                      controller: _perimetroController,
                      decoration: InputDecoration(
                        labelText: 'Perímetro (m)',
                        prefixIcon: const Icon(Icons.straighten),
                        suffixText: 'm',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        enabled: false,
                      ),
                      readOnly: true,
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    
                    // Descripción
                    TextFormField(
                      controller: _descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción (opcional)',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _isEditMode ? 'Actualizar Biomasa' : 'Guardar Biomasa',
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.green;
    }
  }
}
