import 'dart:convert';
import 'tipo_biomasa.dart';

class Biomasa {
  final int id;
  final int tipoBiomasaId;
  final String densidad;
  final List<List<double>> coordenadas; // Polígono: [[lat, lng], [lat, lng], ...]
  final double areaM2;
  final double? perimetroM;
  final String? descripcion;
  final DateTime fechaReporte;
  final String? tipoBiomasaNombre;
  final String? tipoBiomasaColor;
  final TipoBiomasa? tipoBiomasa;
  final String? estado; // 'pendiente', 'aprobada', 'rechazada'
  final String? motivoRechazo;
  final int? aprobadaPor;
  final String? fechaRevision;

  Biomasa({
    required this.id,
    required this.tipoBiomasaId,
    required this.densidad,
    required this.coordenadas,
    required this.areaM2,
    this.perimetroM,
    this.descripcion,
    required this.fechaReporte,
    this.tipoBiomasaNombre,
    this.tipoBiomasaColor,
    this.tipoBiomasa,
    this.estado,
    this.motivoRechazo,
    this.aprobadaPor,
    this.fechaRevision,
  });

  factory Biomasa.fromJson(Map<String, dynamic> json) {
    // Parse coordenadas (puede venir como string JSON o como array)
    List<List<double>> coords = [];
    
    var coordenadasData = json['coordenadas'];
    
    // Si viene como string, parsear el JSON
    if (coordenadasData is String) {
      try {
        var parsed = jsonDecode(coordenadasData);
        if (parsed is List) {
          coords = parsed.map((coord) {
            if (coord is List) {
              return List<double>.from(coord.map((e) => e is num ? e.toDouble() : 0.0));
            }
            return <double>[];
          }).toList();
        }
      } catch (e) {
        print('Error parseando coordenadas: $e');
      }
    } 
    // Si viene como array directamente
    else if (coordenadasData is List) {
      coords = coordenadasData.map((coord) {
        if (coord is List) {
          return List<double>.from(coord.map((e) => e is num ? e.toDouble() : 0.0));
        }
        return <double>[];
      }).toList();
    }

    return Biomasa(
      id: json['id'] ?? 0,
      tipoBiomasaId: json['tipo_biomasa_id'] ?? 0,
      densidad: json['densidad']?.toString() ?? 'Media',
      coordenadas: coords,
      areaM2: (json['area_m2'] ?? 0).toDouble(),
      perimetroM: json['perimetro_m']?.toDouble(),
      descripcion: json['descripcion'],
      fechaReporte: DateTime.parse(
        json['fecha_reporte'] ?? DateTime.now().toIso8601String(),
      ),
      tipoBiomasaNombre: json['tipo_biomasa']?['tipo_biomasa'],
      tipoBiomasaColor: json['tipo_biomasa']?['color'],
      tipoBiomasa: json['tipo_biomasa'] != null 
          ? TipoBiomasa.fromJson(json['tipo_biomasa']) 
          : null,
      estado: json['estado'],
      motivoRechazo: json['motivo_rechazo'],
      aprobadaPor: json['aprobada_por'],
      fechaRevision: json['fecha_revision'],
    );
  }

  // Obtener el centro del polígono para mostrar en el mapa
  List<double> get center {
    if (coordenadas.isEmpty) return [0.0, 0.0];
    
    double latSum = 0;
    double lngSum = 0;
    
    for (var coord in coordenadas) {
      if (coord.length >= 2) {
        latSum += coord[0];
        lngSum += coord[1];
      }
    }
    
    return [
      latSum / coordenadas.length,
      lngSum / coordenadas.length,
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tipo_biomasa_id': tipoBiomasaId,
      'densidad': densidad,
      'coordenadas': coordenadas,
      'area_m2': areaM2,
      'perimetro_m': perimetroM,
      'descripcion': descripcion,
      'fecha_reporte': fechaReporte.toIso8601String(),
    };
  }
}
