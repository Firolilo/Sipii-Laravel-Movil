import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/foco_incendio.dart';
import '../models/biomasa.dart';
import '../models/tipo_biomasa.dart';

class ApiService {
  // URL de la API separada (puerto 8001)
  static const String baseUrl = 'http://192.168.0.27:8001/api';
  
  // Headers por defecto
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Obtener todos los focos de incendio (endpoint público)
  static Future<List<FocoIncendio>> getFocosIncendio() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/focos-incendios'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // La respuesta puede ser un objeto con 'data' o directamente un array
        List<dynamic> focosJson;
        if (data is Map && data.containsKey('data')) {
          focosJson = data['data'];
        } else if (data is List) {
          focosJson = data;
        } else {
          return [];
        }

        return focosJson.map((json) => FocoIncendio.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar focos de incendio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getFocosIncendio: $e');
      return [];
    }
  }

  /// Obtener todas las biomasas (endpoint público)
  /// Endpoint: GET /api/public/biomasas - Devuelve TODAS las biomasas (sin autenticación)
  static Future<List<Biomasa>> getBiomasas() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/biomasas'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<dynamic> biomasasJson;
        if (data is Map && data.containsKey('data')) {
          biomasasJson = data['data'];
        } else if (data is List) {
          biomasasJson = data;
        } else {
          return [];
        }

        return biomasasJson.map((json) => Biomasa.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar biomasas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getBiomasas: $e');
      return [];
    }
  }

  /// Obtener tipos de biomasa (endpoint público)
  static Future<List<TipoBiomasa>> getTiposBiomasa() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/tipos-biomasa'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        List<dynamic> tiposJson;
        if (data is Map && data.containsKey('data')) {
          tiposJson = data['data'];
        } else if (data is List) {
          tiposJson = data;
        } else {
          return [];
        }

        return tiposJson.map((json) => TipoBiomasa.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar tipos de biomasa: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getTiposBiomasa: $e');
      return [];
    }
  }

  /// Login (preparado para futura implementación)
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error en login: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en login: $e');
      return null;
    }
  }
}
