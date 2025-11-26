class FocoIncendio {
  final int id;
  final DateTime fecha;
  final String ubicacion;
  final List<double> coordenadas; // [lat, lng]
  final double intensidad;

  FocoIncendio({
    required this.id,
    required this.fecha,
    required this.ubicacion,
    required this.coordenadas,
    required this.intensidad,
  });

  factory FocoIncendio.fromJson(Map<String, dynamic> json) {
    // Las coordenadas pueden venir como array o como objeto con lat/lng
    List<double> coords = [];
    if (json['coordenadas'] is List) {
      coords = List<double>.from(json['coordenadas'].map((e) => e.toDouble()));
    } else if (json['coordenadas'] is Map) {
      coords = [
        json['coordenadas']['lat']?.toDouble() ?? 0.0,
        json['coordenadas']['lng']?.toDouble() ?? 0.0,
      ];
    }

    return FocoIncendio(
      id: json['id'] ?? 0,
      fecha: DateTime.parse(json['fecha'] ?? DateTime.now().toIso8601String()),
      ubicacion: json['ubicacion'] ?? '',
      coordenadas: coords,
      intensidad: (json['intensidad'] ?? 0).toDouble(),
    );
  }

  double get latitude => coordenadas.isNotEmpty ? coordenadas[0] : 0.0;
  double get longitude => coordenadas.length > 1 ? coordenadas[1] : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'ubicacion': ubicacion,
      'coordenadas': coordenadas,
      'intensidad': intensidad,
    };
  }
}
