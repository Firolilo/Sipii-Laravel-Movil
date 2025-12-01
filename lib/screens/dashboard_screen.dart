import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/api_service.dart';
import '../models/foco_incendio.dart';
import '../models/biomasa.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<FocoIncendio> _focos = [];
  List<Biomasa> _biomasas = [];
  Map<String, dynamic>? _weatherData;
  bool _isLoading = true;
  String? _userName;
  String? _userRole;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardData();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getUserData();
    final role = await ApiService.getUserRole();
    final isAdmin = await ApiService.isAdmin();
    
    setState(() {
      _userName = userData?['name'] ?? 'Usuario';
      _userRole = role;
      _isAdmin = isAdmin;
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Cargar en paralelo
      final results = await Future.wait([
        ApiService.getFocosIncendio(),
        ApiService.getBiomasas(),
        ApiService.getWeather(),
      ]);

      setState(() {
        _focos = results[0] as List<FocoIncendio>;
        _biomasas = results[1] as List<Biomasa>;
        _weatherData = results[2] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard SIPII'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildWeatherCard(),
                    _buildStatsCard(),
                    _buildMap(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_userName ?? 'Usuario'),
            accountEmail: Text(_userRole == 'administrador' ? 'Administrador' : 'Voluntario'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                _isAdmin ? Icons.admin_panel_settings : Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.nature),
            title: const Text('Mis Biomasas'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/mis-biomasas');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_location),
            title: const Text('Reportar Biomasa'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/biomasa-form');
            },
          ),
          ListTile(
            leading: const Icon(Icons.analytics),
            title: const Text('Predicciones'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/predictions');
            },
          ),
          if (_isAdmin) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'ADMINISTRACIÓN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.fact_check),
              title: const Text('Moderar Biomasas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/moderar-biomasas');
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: const Text('Gestión de Predicciones'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/predictions-management');
              },
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_weatherData == null) {
      return const SizedBox.shrink();
    }

    final current = _weatherData!['current'] ?? {};
    final temp = current['temperature_2m']?.toString() ?? '--';
    final humidity = current['relative_humidity_2m']?.toString() ?? '--';
    final windSpeed = current['wind_speed_10m']?.toString() ?? '--';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Clima Actual',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherItem(Icons.thermostat, '$temp°C', 'Temperatura'),
                _buildWeatherItem(Icons.water_drop, '$humidity%', 'Humedad'),
                _buildWeatherItem(Icons.air, '$windSpeed km/h', 'Viento'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              Icons.whatshot,
              _focos.length.toString(),
              'Focos Activos',
              Colors.red,
            ),
            _buildStatItem(
              Icons.nature,
              _biomasas.length.toString(),
              'Biomasas',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildMap() {
    return SizedBox(
      height: 600,
      child: Card(
        margin: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(-17.7486, -60.7464), // San José de Chiquitos
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.sipii.app',
            ),
            // Marcadores de focos de incendio
            MarkerLayer(
              markers: _focos.map((foco) {
                final coords = foco.coordenadas;
                if (coords.isEmpty || coords.length < 2) return null;
                
                return Marker(
                  point: LatLng(coords[0], coords[1]),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => _showFocoInfo(foco),
                    child: const Icon(
                      Icons.whatshot,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                );
              }).whereType<Marker>().toList(),
            ),
            // Polígonos de biomasas aprobadas
            PolygonLayer(
              polygons: _biomasas.where((b) => b.estado == 'aprobada').map((biomasa) {
                try {
                  final coords = biomasa.coordenadas;
                  if (coords.isEmpty) return null;

                  final points = coords.map((coord) {
                    if (coord.length >= 2) {
                      final lat = (coord[0] as num).toDouble();
                      final lng = (coord[1] as num).toDouble();
                      return LatLng(lat, lng);
                    }
                    return null;
                  }).whereType<LatLng>().toList();

                  if (points.isEmpty) return null;

                  // Obtener color del tipo de biomasa o usar verde por defecto
                  Color biomasaColor = Colors.green;
                  if (biomasa.tipoBiomasa?.color != null) {
                    try {
                      final colorStr = biomasa.tipoBiomasa!.color!;
                      // Si el color viene en formato hex #RRGGBB
                      if (colorStr.startsWith('#')) {
                        biomasaColor = Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
                      }
                    } catch (e) {
                      biomasaColor = Colors.green;
                    }
                  } else if (biomasa.tipoBiomasaColor != null) {
                    try {
                      final colorStr = biomasa.tipoBiomasaColor!;
                      if (colorStr.startsWith('#')) {
                        biomasaColor = Color(int.parse(colorStr.substring(1), radix: 16) + 0xFF000000);
                      }
                    } catch (e) {
                      biomasaColor = Colors.green;
                    }
                  }

                  return Polygon(
                    points: points,
                    color: biomasaColor.withOpacity(0.3),
                    borderStrokeWidth: 2,
                    borderColor: biomasaColor,
                    isFilled: true,
                  );
                } catch (e) {
                  print('Error creando polígono: $e');
                  return null;
                }
              }).whereType<Polygon>().toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFocoInfo(FocoIncendio foco) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Foco de Incendio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ubicación: ${foco.ubicacion}'),
            const SizedBox(height: 8),
            Text('Fecha: ${foco.fecha}'),
            const SizedBox(height: 8),
            Text('Intensidad: ${foco.intensidad.toStringAsFixed(1)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ApiService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
