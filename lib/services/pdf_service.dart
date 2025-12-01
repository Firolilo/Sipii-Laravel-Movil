import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class PdfService {
  /// Descargar PDF desde el servidor (usar esto para Flutter)
  static Future<void> downloadPredictionPdfFromServer(int predictionId) async {
    final url = ApiService.getPredictionPdfUrl(predictionId);
    
    try {
      // Intentar abrir en el navegador
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Si no se puede abrir, descargar manualmente
        final response = await http.get(uri);
        
        if (response.statusCode == 200) {
          final output = await getTemporaryDirectory();
          final file = File('${output.path}/prediccion_$predictionId.pdf');
          await file.writeAsBytes(response.bodyBytes);
          
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'Informe de Predicción SIPII',
          );
        } else {
          throw Exception('Error al descargar PDF: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error descargando PDF: $e');
      rethrow;
    }
  }

  /// Generar PDF de predicción
  static Future<void> generatePredictionPdf(Map<String, dynamic> prediction) async {
    final pdf = pw.Document();
    
    final focoInfo = prediction['focoIncendio'] ?? {};
    final ubicacion = focoInfo['ubicacion'] ?? 'Ubicación desconocida';
    final fecha = focoInfo['fecha'] ?? '';
    final intensidad = focoInfo['intensidad'] ?? 0;
    final path = prediction['path'] as List? ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            // Encabezado
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'SIPII - Sistema de Predicción de Incendios',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Informe de Predicción de Incendio',
                    style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Información del foco
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                border: pw.Border.all(color: PdfColors.blue200),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Información del Foco de Incendio',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  _buildInfoRow('Ubicación:', ubicacion),
                  _buildInfoRow('Fecha:', _formatDate(fecha)),
                  _buildInfoRow('Intensidad:', intensidad.toString()),
                  _buildInfoRow('Duración predicción:', '${path.length} horas'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Parámetros de propagación
            if (path.isNotEmpty) ...[
              pw.Text(
                'Parámetros de Propagación',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              _buildParametersTable(path),
              pw.SizedBox(height: 20),
            ],

            // Trayectoria
            if (path.isNotEmpty) ...[
              pw.Text(
                'Trayectoria Detallada',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              _buildTrajectoryTable(path),
            ],

            // Pie de página
            pw.SizedBox(height: 30),
            pw.Divider(),
            pw.Text(
              'Generado: ${DateTime.now().toString().substring(0, 19)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ];
        },
      ),
    );

    // Guardar y compartir
    await _savePdf(pdf, 'prediccion_${prediction['id']}_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
  }

  static pw.Widget _buildParametersTable(List path) {
    final firstPoint = path[0];
    final lastPoint = path.length > 1 ? path[path.length - 1] : firstPoint;

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Parámetro', isHeader: true),
            _buildTableCell('Inicial', isHeader: true),
            _buildTableCell('Final', isHeader: true),
          ],
        ),
        _buildParameterRow(
          'Intensidad',
          firstPoint['intensity']?.toString() ?? '--',
          lastPoint['intensity']?.toString() ?? '--',
        ),
        _buildParameterRow(
          'Radio (km)',
          firstPoint['spread_radius_km']?.toString() ?? '--',
          lastPoint['spread_radius_km']?.toString() ?? '--',
        ),
        _buildParameterRow(
          'Área afectada (km²)',
          firstPoint['affected_area_km2']?.toString() ?? '--',
          lastPoint['affected_area_km2']?.toString() ?? '--',
        ),
        _buildParameterRow(
          'Perímetro (km)',
          firstPoint['perimeter_km']?.toString() ?? '--',
          lastPoint['perimeter_km']?.toString() ?? '--',
        ),
      ],
    );
  }

  static pw.TableRow _buildParameterRow(String param, String initial, String final_) {
    return pw.TableRow(
      children: [
        _buildTableCell(param),
        _buildTableCell(initial),
        _buildTableCell(final_),
      ],
    );
  }

  static pw.Widget _buildTrajectoryTable(List path) {
    final maxRows = path.length > 20 ? 20 : path.length;
    
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Hora', isHeader: true),
            _buildTableCell('Coordenadas', isHeader: true),
            _buildTableCell('Intensidad', isHeader: true),
            _buildTableCell('Área (km²)', isHeader: true),
          ],
        ),
        ...List.generate(maxRows, (index) {
          final point = path[index];
          final hour = point['hour'] ?? index;
          final lat = point['lat']?.toStringAsFixed(4) ?? '--';
          final lng = point['lng']?.toStringAsFixed(4) ?? '--';
          final intensity = point['intensity']?.toStringAsFixed(2) ?? '--';
          final area = point['affected_area_km2']?.toStringAsFixed(2) ?? '--';

          return pw.TableRow(
            children: [
              _buildTableCell('$hour'),
              _buildTableCell('$lat, $lng'),
              _buildTableCell(intensity),
              _buildTableCell(area),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  static String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'Sin fecha';
    
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  static Future<void> _savePdf(pw.Document pdf, String filename) async {
    try {
      // Guardar el PDF en archivos temporales
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/$filename');
      await file.writeAsBytes(await pdf.save());

      // Compartir el archivo
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Informe de Predicción SIPII',
        text: 'Informe de predicción de incendio generado por SIPII',
      );
    } catch (e) {
      print('Error guardando PDF: $e');
      rethrow;
    }
  }

  /// Imprimir PDF directamente
  static Future<void> printPredictionPdf(Map<String, dynamic> prediction) async {
    final pdf = pw.Document();
    
    final focoInfo = prediction['focoIncendio'] ?? {};
    final ubicacion = focoInfo['ubicacion'] ?? 'Ubicación desconocida';
    final fecha = focoInfo['fecha'] ?? '';
    final intensidad = focoInfo['intensidad'] ?? 0;
    final path = prediction['path'] as List? ?? [];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Informe de Predicción de Incendio',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildInfoRow('Ubicación:', ubicacion),
            _buildInfoRow('Fecha:', _formatDate(fecha)),
            _buildInfoRow('Intensidad:', intensidad.toString()),
            _buildInfoRow('Duración:', '${path.length} horas'),
            pw.SizedBox(height: 20),
            if (path.isNotEmpty) _buildParametersTable(path),
            pw.SizedBox(height: 20),
            if (path.isNotEmpty) _buildTrajectoryTable(path),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
