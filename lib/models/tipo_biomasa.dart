class TipoBiomasa {
  final int id;
  final String nombre;
  final String? descripcion;
  final String? color;

  TipoBiomasa({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.color,
  });

  factory TipoBiomasa.fromJson(Map<String, dynamic> json) {
    return TipoBiomasa(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? json['tipo_biomasa'] ?? '',
      descripcion: json['descripcion'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'color': color,
    };
  }
}
