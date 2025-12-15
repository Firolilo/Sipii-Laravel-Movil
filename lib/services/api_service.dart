import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/foco_incendio.dart';
import '../models/biomasa.dart';
import '../models/tipo_biomasa.dart';

class ApiService {
  // URL de la API unificada (actualizada al servidor desplegado)
  // Cambiada para apuntar a la instancia pública: http://sipi.dasalas.shop
  static const String baseUrl = 'http://sipi.dasalas.shop/api';
  
  // Headers por defecto (sin autenticación)
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Headers con token de autenticación
  static Future<Map<String, String>> get authHeaders async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Guardar token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Obtener token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Eliminar token
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('user_role');
    await prefs.remove('is_admin');
    await prefs.remove('is_volunteer');
  }

  // Verificar si está autenticado
  static Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Obtener rol del usuario
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Verificar si es administrador
  static Future<bool> isAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_admin') ?? false;
  }

  // Verificar si es voluntario
  static Future<bool> isVolunteer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_volunteer') ?? false;
  }

  // Obtener datos completos del usuario
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user_data');
    if (userData != null) {
      return json.decode(userData);
    }
    return null;
  }

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

  /// Obtener MIS biomasas (autenticado)
  /// Endpoint: GET /api/biomasas - Devuelve solo las biomasas del usuario autenticado
  static Future<List<Biomasa>> getMisBiomasas() async {
    try {
      final authHeadersMap = await authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/biomasas'),
        headers: authHeadersMap,
      );

      print('DEBUG getMisBiomasas: Status ${response.statusCode}');

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

        print('DEBUG getMisBiomasas: ${biomasasJson.length} biomasas encontradas');
        
        return biomasasJson.map((json) => Biomasa.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar mis biomasas: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getMisBiomasas: $e');
      return [];
    }
  }

  /// Obtener todas las biomasas (endpoint público o admin)
  /// Endpoint: GET /api/public/biomasas - Devuelve TODAS las biomasas
  static Future<List<Biomasa>> getBiomasas() async {
    try {
      final authHeadersMap = await authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/public/biomasas'),
        headers: authHeadersMap,
      );

      print('DEBUG getBiomasas: Status ${response.statusCode}');

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

        print('DEBUG getBiomasas: Primeros 2 registros raw:');
        for (var i = 0; i < (biomasasJson.length > 2 ? 2 : biomasasJson.length); i++) {
          print('  Biomasa ${i + 1}: estado = ${biomasasJson[i]['estado']}');
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

  // ==================== AUTENTICACIÓN ====================

  /// Registro de usuario
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String telefono,
    required String cedulaIdentidad,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'telefono': telefono,
          'cedula_identidad': cedulaIdentidad,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Guardar token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        // Guardar datos del usuario
        if (data['user'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', json.encode(data['user']));
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error en el registro',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('Error en register: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Login de usuario
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        
        // Guardar token
        if (data['token'] != null) {
          await saveToken(data['token']);
        }
        
        // Guardar datos del usuario
        if (data['user'] != null) {
          await prefs.setString('user_data', json.encode(data['user']));
        }
        
        // Guardar información de roles
        if (data['role'] != null) {
          await prefs.setString('user_role', data['role']);
        }
        if (data['is_admin'] != null) {
          await prefs.setBool('is_admin', data['is_admin']);
        }
        if (data['is_volunteer'] != null) {
          await prefs.setBool('is_volunteer', data['is_volunteer']);
        }
        
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Credenciales incorrectas',
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      final headers = await authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );

      // Limpiar token local independientemente del resultado
      await clearToken();

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {'success': true}; // Aún así consideramos exitoso el logout local
      }
    } catch (e) {
      print('Error en logout: $e');
      await clearToken(); // Limpiar token local de todos modos
      return {'success': true};
    }
  }

  // ==================== CRUD BIOMASAS (PROTEGIDO) ====================

  /// Crear biomasa (requiere autenticación)
  static Future<Map<String, dynamic>> createBiomasa({
    required int tipoBiomasaId,
    required String densidad,
    required List<List<double>> coordenadas,
    required double areaM2,
    double? perimetroM,
    String? descripcion,
  }) async {
    try {
      final headers = await authHeaders;
      
      // Preparar datos
      final body = {
        'tipo_biomasa_id': tipoBiomasaId,
        'densidad': densidad,
        'coordenadas': coordenadas,
        'area_m2': areaM2,
        'fecha_reporte': DateTime.now().toIso8601String(),
      };
      
      // Solo agregar campos opcionales si tienen valor
      if (perimetroM != null) {
        body['perimetro_m'] = perimetroM;
      }
      if (descripcion != null && descripcion.isNotEmpty) {
        body['descripcion'] = descripcion;
      }
      
      print('DEBUG: Enviando biomasa - ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/biomasas'),
        headers: headers,
        body: json.encode(body),
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear biomasa',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('Error en createBiomasa: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Actualizar biomasa (requiere autenticación)
  static Future<Map<String, dynamic>> updateBiomasa({
    required int id,
    required int tipoBiomasaId,
    required String densidad,
    required List<List<double>> coordenadas,
    required double areaM2,
    double? perimetroM,
    String? descripcion,
  }) async {
    try {
      final headers = await authHeaders;
      final response = await http.put(
        Uri.parse('$baseUrl/biomasas/$id'),
        headers: headers,
        body: json.encode({
          'tipo_biomasa_id': tipoBiomasaId,
          'densidad': densidad,
          'coordenadas': coordenadas,
          'area_m2': areaM2,
          'perimetro_m': perimetroM,
          'descripcion': descripcion,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar biomasa',
        };
      }
    } catch (e) {
      print('Error en updateBiomasa: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Eliminar biomasa (requiere autenticación)
  static Future<Map<String, dynamic>> deleteBiomasa(int id) async {
    try {
      final headers = await authHeaders;
      final response = await http.delete(
        Uri.parse('$baseUrl/biomasas/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al eliminar biomasa',
        };
      }
    } catch (e) {
      print('Error en deleteBiomasa: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ==================== MODERACIÓN DE BIOMASAS (SOLO ADMIN) ====================

  /// Aprobar biomasa (requiere autenticación admin)
  static Future<Map<String, dynamic>> aprobarBiomasa(int id) async {
    try {
      final headers = await authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/biomasas/$id/aprobar'),
        headers: headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al aprobar biomasa',
        };
      }
    } catch (e) {
      print('Error en aprobarBiomasa: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Rechazar biomasa (requiere autenticación admin)
  static Future<Map<String, dynamic>> rechazarBiomasa(int id, String motivo) async {
    try {
      final headers = await authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/biomasas/$id/rechazar'),
        headers: headers,
        body: json.encode({
          'motivo_rechazo': motivo,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al rechazar biomasa',
        };
      }
    } catch (e) {
      print('Error en rechazarBiomasa: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ==================== CRUD PREDICCIONES ====================

  /// Obtener todas las predicciones
  static Future<List<dynamic>> getPredictions() async {
    try {
      final headers = await authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/predictions'),
        headers: headers,
      );

      print('DEBUG Predictions: Status ${response.statusCode}');
      print('DEBUG Predictions: Body ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('data')) {
          print('DEBUG Predictions: Returning ${data['data'].length} items from data key');
          return data['data'];
        } else if (data is List) {
          print('DEBUG Predictions: Returning ${data.length} items from list');
          return data;
        }
        print('DEBUG Predictions: Returning empty array');
        return [];
      } else {
        throw Exception('Error al cargar predicciones: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getPredictions: $e');
      return [];
    }
  }

  /// Obtener una predicción específica
  static Future<Map<String, dynamic>?> getPrediction(int id) async {
    try {
      final headers = await authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/predictions/$id'),
        headers: headers,
      );

      print('DEBUG getPrediction($id): Status ${response.statusCode}');
      print('DEBUG getPrediction($id): Body ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Si viene envuelto en 'data', extraerlo
        if (data is Map && data.containsKey('data')) {
          print('DEBUG getPrediction: Returning data from data key');
          return data['data'] as Map<String, dynamic>;
        }
        
        print('DEBUG getPrediction: Returning raw data');
        return data is Map<String, dynamic> ? data : (data as Map).cast<String, dynamic>();
      } else {
        throw Exception('Error al cargar predicción: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getPrediction: $e');
      return null;
    }
  }

  /// Crear predicción (requiere autenticación admin)
  static Future<Map<String, dynamic>> createPrediction({
    required int focoIncendioId,
    required double temperature,
    required double humidity,
    required double windSpeed,
    required double windDirection,
    required String terrainType,
    required int predictionHours,
  }) async {
    try {
      final headers = await authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/predictions'),
        headers: headers,
        body: json.encode({
          'foco_incendio_id': focoIncendioId,
          'temperature': temperature,
          'humidity': humidity,
          'wind_speed': windSpeed,
          'wind_direction': windDirection,
          'terrain_type': terrainType,
          'prediction_hours': predictionHours,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear predicción',
        };
      }
    } catch (e) {
      print('Error en createPrediction: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Actualizar predicción (requiere autenticación admin)
  static Future<Map<String, dynamic>> updatePrediction({
    required int id,
    required int focoIncendioId,
    required double temperature,
    required double humidity,
    required double windSpeed,
    required double windDirection,
    required String terrainType,
    required int predictionHours,
  }) async {
    try {
      final headers = await authHeaders;
      final response = await http.put(
        Uri.parse('$baseUrl/predictions/$id'),
        headers: headers,
        body: json.encode({
          'foco_incendio_id': focoIncendioId,
          'temperature': temperature,
          'humidity': humidity,
          'wind_speed': windSpeed,
          'wind_direction': windDirection,
          'terrain_type': terrainType,
          'prediction_hours': predictionHours,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar predicción',
        };
      }
    } catch (e) {
      print('Error en updatePrediction: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Eliminar predicción (requiere autenticación admin)
  static Future<Map<String, dynamic>> deletePrediction(int id) async {
    try {
      final headers = await authHeaders;
      final response = await http.delete(
        Uri.parse('$baseUrl/predictions/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al eliminar predicción',
        };
      }
    } catch (e) {
      print('Error en deletePrediction: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ==================== GESTIÓN DE USUARIOS (SOLO ADMIN) ====================

  /// Obtener todos los usuarios
  static Future<List<dynamic>> getUsers() async {
    try {
      final headers = await authHeaders;
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('data')) {
          return data['data'];
        } else if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception('Error al cargar usuarios: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getUsers: $e');
      return [];
    }
  }

  /// Crear usuario (requiere autenticación admin)
  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    String? telefono,
    String? cedulaIdentidad,
  }) async {
    try {
      final headers = await authHeaders;
      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: headers,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'telefono': telefono,
          'cedula_identidad': cedulaIdentidad,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al crear usuario',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('Error en createUser: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Actualizar usuario (requiere autenticación admin)
  static Future<Map<String, dynamic>> updateUser({
    required int id,
    required String name,
    required String email,
    String? password,
    String? telefono,
    String? cedulaIdentidad,
  }) async {
    try {
      final headers = await authHeaders;
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
        body: json.encode({
          'name': name,
          'email': email,
          if (password != null && password.isNotEmpty) 'password': password,
          'telefono': telefono,
          'cedula_identidad': cedulaIdentidad,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar usuario',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      print('Error en updateUser: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Eliminar usuario (requiere autenticación admin)
  static Future<Map<String, dynamic>> deleteUser(int id) async {
    try {
      final headers = await authHeaders;
      final response = await http.delete(
        Uri.parse('$baseUrl/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true};
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error al eliminar usuario',
        };
      }
    } catch (e) {
      print('Error en deleteUser: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  /// Actualizar rol de usuario (requiere autenticación admin)
  static Future<Map<String, dynamic>> updateUserRole(int id, String role) async {
    try {
      final headers = await authHeaders;
      final response = await http.put(
        Uri.parse('$baseUrl/users/$id/role'),
        headers: headers,
        body: json.encode({
          'role': role,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error al actualizar rol',
        };
      }
    } catch (e) {
      print('Error en updateUserRole: $e');
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // ==================== DASHBOARD ====================

  /// Obtener biomasas para el mapa (GeoJSON)
  static Future<Map<String, dynamic>?> getDashboardBiomasas() async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/api', '')}/dashboard/biomasas'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar biomasas del dashboard: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getDashboardBiomasas: $e');
      return null;
    }
  }

  /// Obtener datos del clima actual (Open-Meteo)
  static Future<Map<String, dynamic>?> getWeather() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al cargar clima: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getWeather: $e');
      return null;
    }
  }

  /// Obtener datos de incendios de NASA FIRMS
  static Future<List<dynamic>> getFirmsData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/fires'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data is Map && data.containsKey('data')) {
          return data['data'];
        } else if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception('Error al cargar datos FIRMS: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en getFirmsData: $e');
      return [];
    }
  }

  /// Obtener URL para descargar PDF de predicción
  static String getPredictionPdfUrl(int predictionId) {
    return '$baseUrl/public/predictions/$predictionId/pdf';
  }

  /// Obtener URL para descargar PDF de simulación
  static String getSimulationPdfUrl(int simulationId) {
    return '$baseUrl/public/simulaciones/$simulationId/pdf';
  }
}
