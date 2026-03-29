import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/macrocycle.dart';
import '../../../data/models/macrocycle_event.dart';
import '../../../data/models/microcycle.dart';

/// Servicio de exportación de un macrociclo a formato Excel (.xlsx).
///
/// Genera un archivo con una sola hoja en formato idéntico al
/// "Macro formato 2026.xlsx" de referencia, incluyendo:
/// - Título del macrociclo
/// - Fila de meses
/// - Fila de semanas (números)
/// - Filas de fechas de inicio/fin de cada semana
/// - Fila de eventos (Local, CN, CI)
/// - Fila de Etapa (G1, E1, P1, C1, etc.)
/// - Fila de Mesociclo (MB, ME, MP, MCP, TO)
/// - Fila de Microciclo (μ1–μ7)
/// - Fila de Pico de Rendimiento
/// - Filas de porcentajes de categorías de entrenamiento
/// - Fila de TOTAL (suma = 1)
/// - Leyenda
class MacrocycleExcelExport {
  /// Exporta el macrociclo a un archivo Excel y retorna la ruta del archivo.
  static Future<String> exportToExcel(Macrocycle macrocycle) async {
    final excel = Excel.createExcel();

    // Crear la hoja principal con el nombre del atleta
    final sheetName = macrocycle.athleteName.isNotEmpty
        ? macrocycle.athleteName.toUpperCase()
        : 'MACROCICLO';
    final sheet = excel[sheetName];

    // Eliminar hoja por defecto
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Construir toda la información en una sola hoja
    _buildSingleSheet(sheet, macrocycle);

    // Guardar archivo
    final dir = await getApplicationDocumentsDirectory();
    final sanitizedName = macrocycle.name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    final fileName =
        'Macrociclo_${sanitizedName}_${macrocycle.startDate.year}.xlsx';
    final filePath = '${dir.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }

    return filePath;
  }

  // ══════════════════════════════════════════════════════════════════════
  // CONSTRUIR HOJA ÚNICA (formato Macro 2026)
  // ══════════════════════════════════════════════════════════════════════

  static void _buildSingleSheet(Sheet sheet, Macrocycle macrocycle) {
    final micros = macrocycle.microcycles;
    final totalWeeks = micros.length;

    // Columna A = etiquetas, columnas B en adelante = semanas
    // colOffset = 1 (col B = index 1)
    const colOffset = 1;

    // ── Estilos ──────────────────────────────────────────────────────
    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#2F536A'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 10,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#477D9E'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final labelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#F4F6F9'),
    );

    final dataStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
    );

    final percentStyle = CellStyle(
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
    );

    final months = [
      'ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO',
      'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE'
    ];

    // ─── ROW 0: Título del Macrociclo ────────────────────────────────
    int currentRow = 0;
    if (totalWeeks > 0) {
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow),
        CellIndex.indexByColumnRow(
            columnIndex: colOffset + totalWeeks - 1, rowIndex: currentRow),
      );
    }
    _setCellValue(sheet, 0, currentRow,
        'MACROCICLO DE BOCCIA ${macrocycle.name.toUpperCase()} ${macrocycle.startDate.year}',
        titleStyle);

    // ─── ROW 1: Meses ────────────────────────────────────────────────
    currentRow = 1;
    _setCellValue(sheet, 0, currentRow, 'Meses', labelStyle);
    if (micros.isNotEmpty) {
      int colStart = colOffset;
      int currentMonth = micros[0].startDate.month;
      for (int i = 0; i < totalWeeks; i++) {
        final microMonth = micros[i].startDate.month;
        if (microMonth != currentMonth || i == totalWeeks - 1) {
          final endCol = (i == totalWeeks - 1 && microMonth == currentMonth)
              ? colOffset + i
              : colOffset + i - 1;
          if (endCol > colStart) {
            sheet.merge(
              CellIndex.indexByColumnRow(
                  columnIndex: colStart, rowIndex: currentRow),
              CellIndex.indexByColumnRow(
                  columnIndex: endCol, rowIndex: currentRow),
            );
          }
          _setCellValue(sheet, colStart, currentRow,
              months[currentMonth - 1], headerStyle);
          if (microMonth != currentMonth) {
            colStart = colOffset + i;
            currentMonth = microMonth;
          }
          if (i == totalWeeks - 1 && microMonth != currentMonth) {
            // Último mes que quedó solo
            _setCellValue(sheet, colStart, currentRow,
                months[currentMonth - 1], headerStyle);
          }
        }
      }
      // Handle case where all micros are in same month
      if (totalWeeks > 0) {
        final firstMonth = micros[0].startDate.month;
        final lastMonth = micros[totalWeeks - 1].startDate.month;
        if (firstMonth == lastMonth) {
          if (totalWeeks > 1) {
            sheet.merge(
              CellIndex.indexByColumnRow(
                  columnIndex: colOffset, rowIndex: currentRow),
              CellIndex.indexByColumnRow(
                  columnIndex: colOffset + totalWeeks - 1,
                  rowIndex: currentRow),
            );
          }
          _setCellValue(sheet, colOffset, currentRow,
              months[firstMonth - 1], headerStyle);
        }
      }
    }

    // ─── ROW 2: Semanas (números) ────────────────────────────────────
    currentRow = 2;
    _setCellValue(sheet, 0, currentRow, 'Semanas', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      _setCellValue(
          sheet, colOffset + i, currentRow, '${i + 1}', dataStyle);
    }

    // ─── ROW 3: Fecha inicio de cada semana ──────────────────────────
    currentRow = 3;
    _setCellValue(sheet, 0, currentRow, 'Fecha Inicio', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final d = micros[i].startDate;
      _setCellValue(sheet, colOffset + i, currentRow,
          '${d.day}', dataStyle);
    }

    // ─── ROW 4: Fecha fin de cada semana ─────────────────────────────
    currentRow = 4;
    _setCellValue(sheet, 0, currentRow, 'Fecha Fin', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final d = micros[i].endDate;
      _setCellValue(sheet, colOffset + i, currentRow,
          '${d.day}', dataStyle);
    }

    // ─── ROW 5: Eventos locales ──────────────────────────────────────
    currentRow = 5;
    _setCellValue(sheet, 0, currentRow, 'Local', labelStyle);

    // ─── ROW 6: Campeonato Nacional ──────────────────────────────────
    currentRow = 6;
    _setCellValue(
        sheet, 0, currentRow, 'Campeonato Nacional', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final micro = micros[i];
      for (final event in macrocycle.events) {
        if (event.type == EventType.competencia &&
            !micro.startDate.isAfter(event.endDate) &&
            !micro.endDate.isBefore(event.startDate)) {
          final eventStyle = CellStyle(
            fontSize: 9,
            bold: true,
            fontColorHex: ExcelColor.fromHexString('#C0392B'),
            horizontalAlign: HorizontalAlign.Center,
          );
          _setCellValue(sheet, colOffset + i, currentRow, 'CN', eventStyle);
          break;
        }
      }
    }

    // ─── ROW 7: Campeonato Internacional ─────────────────────────────
    currentRow = 7;
    _setCellValue(
        sheet, 0, currentRow, 'Campeonato Internacional', labelStyle);

    // ─── ROW 8: Etapa ────────────────────────────────────────────────
    currentRow = 8;
    _setCellValue(sheet, 0, currentRow, 'Etapa', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final periodName = micros[i].periodName ?? '';
      final abbrev = _periodAbbrev(periodName, i, micros);
      if (abbrev.isNotEmpty) {
        final color = _periodColor(periodName);
        final style = CellStyle(
          fontSize: 9,
          bold: true,
          backgroundColorHex: color,
          horizontalAlign: HorizontalAlign.Center,
        );
        _setCellValue(sheet, colOffset + i, currentRow, abbrev, style);
      }
    }

    // ─── ROW 9: Mesociclo ────────────────────────────────────────────
    currentRow = 9;
    _setCellValue(sheet, 0, currentRow, 'Mesociclo', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final mesoName = micros[i].mesocycleName ?? '';
      final abbrev = _mesoAbbrev(mesoName);
      if (abbrev.isNotEmpty) {
        _setCellValue(
            sheet, colOffset + i, currentRow, abbrev, dataStyle);
      }
    }

    // ─── ROW 10: Microciclo ──────────────────────────────────────────
    currentRow = 10;
    _setCellValue(sheet, 0, currentRow, 'Microciclo', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final micro = micros[i];
      final microLabel = _microTypeLabel(micro.type);
      final color = _excelColorForMicrocycleType(micro.type);
      final style = CellStyle(
        fontSize: 9,
        backgroundColorHex: color,
        horizontalAlign: HorizontalAlign.Center,
      );
      _setCellValue(
          sheet, colOffset + i, currentRow, microLabel, style);
    }

    // ─── ROW 11: Pico de Rendimiento ─────────────────────────────────
    currentRow = 11;
    _setCellValue(
        sheet, 0, currentRow, 'Pico de Rendimiento', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      if (micros[i].type == MicrocycleType.competitivo) {
        final peakStyle = CellStyle(
          fontSize: 9,
          bold: true,
          fontColorHex: ExcelColor.fromHexString('#E74C3C'),
          backgroundColorHex: ExcelColor.fromHexString('#FADBD8'),
          horizontalAlign: HorizontalAlign.Center,
        );
        _setCellValue(sheet, colOffset + i, currentRow, 'X', peakStyle);
      }
    }

    // ─── ROW 12: Evaluaciones ────────────────────────────────────────
    currentRow = 12;
    _setCellValue(sheet, 0, currentRow, 'Evaluaciones COA', labelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final micro = micros[i];
      for (final event in macrocycle.events) {
        if (event.type == EventType.evaluacion &&
            !micro.startDate.isAfter(event.endDate) &&
            !micro.endDate.isBefore(event.startDate)) {
          _setCellValue(sheet, colOffset + i, currentRow, 'X', dataStyle);
          break;
        }
      }
    }

    // ─── ROW 13: Controles Técnicos ──────────────────────────────────
    currentRow = 13;
    _setCellValue(
        sheet, 0, currentRow, 'Controles Técnicos', labelStyle);

    // ─── ROW 14: Intercambios ────────────────────────────────────────
    currentRow = 14;
    _setCellValue(sheet, 0, currentRow, 'Intercambios', labelStyle);

    // ─── ROWS 15-25: Escala gráfica (1.0, 0.9, ..., 0.0) ───────────
    for (int s = 0; s <= 10; s++) {
      currentRow = 15 + s;
      final value = (10 - s) / 10.0;
      _setCellValue(sheet, 0, currentRow, value.toStringAsFixed(1),
          CellStyle(fontSize: 8, horizontalAlign: HorizontalAlign.Center));
    }

    // ─── ROW 26: FÍSICA GENERAL ──────────────────────────────────────
    currentRow = 26;
    final fgLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#D6EAF8'),
    );
    _setCellValue(sheet, 0, currentRow, 'FISICA GENERAL', fgLabelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final dist = micros[i].trainingDistribution;
      _setCellNumeric(sheet, colOffset + i, currentRow,
          dist.fisicaGeneral, percentStyle);
    }

    // ─── ROW 27: FÍSICA ESPECIAL ─────────────────────────────────────
    currentRow = 27;
    final feLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#E8DAEF'),
    );
    _setCellValue(
        sheet, 0, currentRow, 'FISICA ESPECIAL', feLabelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final dist = micros[i].trainingDistribution;
      _setCellNumeric(sheet, colOffset + i, currentRow,
          dist.fisicaEspecial, percentStyle);
    }

    // ─── ROW 28: TÉCNICA ─────────────────────────────────────────────
    currentRow = 28;
    final tecLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#D5F5E3'),
    );
    _setCellValue(sheet, 0, currentRow, 'TÉCNICA', tecLabelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final dist = micros[i].trainingDistribution;
      _setCellNumeric(
          sheet, colOffset + i, currentRow, dist.tecnica, percentStyle);
    }

    // ─── ROW 29: TÁTICA ──────────────────────────────────────────────
    currentRow = 29;
    final tacLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#FEF9E7'),
    );
    _setCellValue(sheet, 0, currentRow, 'TÁTICA', tacLabelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final dist = micros[i].trainingDistribution;
      _setCellNumeric(
          sheet, colOffset + i, currentRow, dist.tactica, percentStyle);
    }

    // ─── ROW 30: TEÓRICA ─────────────────────────────────────────────
    currentRow = 30;
    final teoLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#FADBD8'),
    );
    _setCellValue(sheet, 0, currentRow, 'TEÓRICA', teoLabelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final dist = micros[i].trainingDistribution;
      _setCellNumeric(
          sheet, colOffset + i, currentRow, dist.teorica, percentStyle);
    }

    // ─── ROW 31: PSICOLÓGICA ─────────────────────────────────────────
    currentRow = 31;
    final psiLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#D1F2EB'),
    );
    _setCellValue(sheet, 0, currentRow, 'PSICOLÓGICA', psiLabelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final dist = micros[i].trainingDistribution;
      _setCellNumeric(sheet, colOffset + i, currentRow,
          dist.psicologica, percentStyle);
    }

    // ─── ROW 32: TOTAL ───────────────────────────────────────────────
    currentRow = 32;
    final totalLabelStyle = CellStyle(
      bold: true,
      fontSize: 10,
      backgroundColorHex: ExcelColor.fromHexString('#2F536A'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    );
    final totalCellStyle = CellStyle(
      bold: true,
      fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#2F536A'),
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      horizontalAlign: HorizontalAlign.Center,
    );
    _setCellValue(sheet, 0, currentRow, 'TOTAL', totalLabelStyle);
    for (int i = 0; i < totalWeeks; i++) {
      final dist = micros[i].trainingDistribution;
      _setCellNumeric(
          sheet, colOffset + i, currentRow, dist.total, totalCellStyle);
    }

    // ─── ROW 33: Espacio ─────────────────────────────────────────────
    currentRow = 33;

    // ─── ROW 34-41: LEYENDA ──────────────────────────────────────────
    currentRow = 34;
    _setCellValue(sheet, 0, currentRow, 'LEGENDA:', CellStyle(
      bold: true,
      fontSize: 10,
    ));

    // Etapas
    currentRow = 35;
    _setCellValue(sheet, 0, currentRow, 'G1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#D6EAF8'),
    ));
    _setCellValue(sheet, 1, currentRow, 'PREPARACION GENERAL', CellStyle(fontSize: 9));
    _setCellValue(sheet, 3, currentRow, 'μ1', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 4, currentRow, 'MICROCICLO INCORPORACION', CellStyle(fontSize: 9));

    currentRow = 36;
    _setCellValue(sheet, 0, currentRow, 'E1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#E8DAEF'),
    ));
    _setCellValue(sheet, 1, currentRow, 'PREPARACION ESPECIAL', CellStyle(fontSize: 9));
    _setCellValue(sheet, 3, currentRow, 'μ2', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 4, currentRow, 'MICROCICLO ORDINÁRIO', CellStyle(fontSize: 9));

    currentRow = 37;
    _setCellValue(sheet, 0, currentRow, 'P1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#FADBD8'),
    ));
    _setCellValue(sheet, 1, currentRow, 'PRECOMPETITIVO', CellStyle(fontSize: 9));
    _setCellValue(sheet, 3, currentRow, 'μ3', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 4, currentRow, 'MICROCICLO ESTABILIZADOR', CellStyle(fontSize: 9));

    currentRow = 38;
    _setCellValue(sheet, 0, currentRow, 'C1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#D5F5E3'),
    ));
    _setCellValue(sheet, 1, currentRow, 'COMPETITIVO', CellStyle(fontSize: 9));
    _setCellValue(sheet, 3, currentRow, 'μ4', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 4, currentRow, 'MICROCICLO DE CHOQUE 1 VOLUMEN', CellStyle(fontSize: 9));

    currentRow = 39;
    _setCellValue(sheet, 0, currentRow, 'CN', CellStyle(
      bold: true, fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#C0392B'),
    ));
    _setCellValue(sheet, 1, currentRow, 'CAMPEONATO NACIONAL', CellStyle(fontSize: 9));
    _setCellValue(sheet, 3, currentRow, 'μ5', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 4, currentRow, 'MICROCICLO DE CHOQUE 2 INTENSIDAD', CellStyle(fontSize: 9));

    currentRow = 40;
    _setCellValue(sheet, 0, currentRow, 'CI', CellStyle(
      bold: true, fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#8E44AD'),
    ));
    _setCellValue(sheet, 1, currentRow, 'CAMPEONATO INTERNACIONAL', CellStyle(fontSize: 9));
    _setCellValue(sheet, 3, currentRow, 'μ6', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 4, currentRow, 'MICROCICLO DE CHOQUE 3 COMPETENCIA', CellStyle(fontSize: 9));

    currentRow = 41;
    _setCellValue(sheet, 3, currentRow, 'μ7', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 4, currentRow, 'MICROCICLO DE RECUPERACION', CellStyle(fontSize: 9));

    // ─── MESOCICLOS (leyenda) ────────────────────────────────────────
    currentRow = 43;
    _setCellValue(sheet, 0, currentRow, 'MESOCICLOS:', CellStyle(
      bold: true, fontSize: 10,
    ));

    currentRow = 44;
    _setCellValue(sheet, 0, currentRow, 'MB', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 1, currentRow, 'MESOCICLO DE BASE', CellStyle(fontSize: 9));

    currentRow = 45;
    _setCellValue(sheet, 0, currentRow, 'ME', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 1, currentRow, 'MESOCICLO DE ESTABILIZACION', CellStyle(fontSize: 9));

    currentRow = 46;
    _setCellValue(sheet, 0, currentRow, 'MP', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 1, currentRow, 'MESOCICLO PRÉ COMPETITIVO', CellStyle(fontSize: 9));

    currentRow = 47;
    _setCellValue(sheet, 0, currentRow, 'MCP', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 1, currentRow, 'MESOCICLO COMPETITIVO', CellStyle(fontSize: 9));

    currentRow = 48;
    _setCellValue(sheet, 0, currentRow, 'TO', CellStyle(bold: true, fontSize: 9));
    _setCellValue(sheet, 1, currentRow, 'TRANSICION', CellStyle(fontSize: 9));

    // ─── Ajustar anchos de columna ───────────────────────────────────
    sheet.setColumnWidth(0, 25);
    for (int i = 0; i < totalWeeks; i++) {
      sheet.setColumnWidth(colOffset + i, 6);
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  static void _setCellValue(
    Sheet sheet,
    int col,
    int row,
    String value,
    CellStyle style,
  ) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(value);
    cell.cellStyle = style;
  }

  static void _setCellNumeric(
    Sheet sheet,
    int col,
    int row,
    double value,
    CellStyle style,
  ) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = DoubleCellValue(value);
    cell.cellStyle = style;
  }

  /// Abreviatura del período para la fila de Etapa.
  static String _periodAbbrev(
      String periodName, int index, List<Microcycle> micros) {
    // Detectar cambio de período respecto al anterior
    if (index > 0 && micros[index].periodName == micros[index - 1].periodName) {
      return ''; // Solo poner la etiqueta en la primera semana del período
    }

    final lower = periodName.toLowerCase();
    if (lower.contains('general')) {
      // Contar cuántos bloques de este tipo ya hubo
      int count = 1;
      for (int j = 0; j < index; j++) {
        if ((micros[j].periodName ?? '').toLowerCase().contains('general') &&
            (j == 0 ||
                micros[j].periodName != micros[j - 1].periodName)) {
          count++;
        }
      }
      return 'G$count';
    } else if (lower.contains('especial')) {
      int count = 1;
      for (int j = 0; j < index; j++) {
        if ((micros[j].periodName ?? '').toLowerCase().contains('especial') &&
            (j == 0 ||
                micros[j].periodName != micros[j - 1].periodName)) {
          count++;
        }
      }
      return 'E$count';
    } else if (lower.contains('competitivo')) {
      int count = 1;
      for (int j = 0; j < index; j++) {
        if ((micros[j].periodName ?? '').toLowerCase().contains('competitivo') &&
            (j == 0 ||
                micros[j].periodName != micros[j - 1].periodName)) {
          count++;
        }
      }
      return 'C$count';
    } else if (lower.contains('transición') || lower.contains('transicion')) {
      return 'TO';
    } else if (lower.contains('precompetitivo') || lower.contains('pre')) {
      int count = 1;
      for (int j = 0; j < index; j++) {
        final pn = (micros[j].periodName ?? '').toLowerCase();
        if ((pn.contains('precompetitivo') || pn.contains('pre')) &&
            (j == 0 ||
                micros[j].periodName != micros[j - 1].periodName)) {
          count++;
        }
      }
      return 'P$count';
    }
    return '';
  }

  /// Color de fondo para la fila de etapa.
  static ExcelColor _periodColor(String periodName) {
    final lower = periodName.toLowerCase();
    if (lower.contains('general')) {
      return ExcelColor.fromHexString('#D6EAF8');
    } else if (lower.contains('especial')) {
      return ExcelColor.fromHexString('#E8DAEF');
    } else if (lower.contains('competitivo')) {
      return ExcelColor.fromHexString('#FADBD8');
    } else if (lower.contains('transición') || lower.contains('transicion')) {
      return ExcelColor.fromHexString('#D5F5E3');
    }
    return ExcelColor.fromHexString('#F4F6F9');
  }

  /// Abreviatura del mesociclo.
  static String _mesoAbbrev(String mesoName) {
    final lower = mesoName.toLowerCase();
    if (lower.contains('desarrollador') || lower.contains('base')) return 'MB';
    if (lower.contains('estabilizador')) return 'ME';
    if (lower.contains('pre-competitivo') || lower.contains('precompetitivo')) {
      return 'MP';
    }
    if (lower.contains('competitivo')) return 'MCP';
    if (lower.contains('recuperación') || lower.contains('recuperacion')) {
      return 'TO';
    }
    if (lower.contains('introductorio')) return 'MI';
    return '';
  }

  /// Etiqueta μ del tipo de microciclo.
  static String _microTypeLabel(MicrocycleType type) {
    switch (type) {
      case MicrocycleType.ordinario:
        return 'μ2';
      case MicrocycleType.choque:
        return 'μ4';
      case MicrocycleType.recuperacion:
        return 'μ7';
      case MicrocycleType.activacion:
        return 'μ3';
      case MicrocycleType.competitivo:
        return 'μ5';
      case MicrocycleType.transitorio:
        return 'μ1';
    }
  }

  static ExcelColor _excelColorForMicrocycleType(MicrocycleType type) {
    switch (type) {
      case MicrocycleType.ordinario:
        return ExcelColor.fromHexString('#FFFFFF');
      case MicrocycleType.choque:
        return ExcelColor.fromHexString('#F5EEF8');
      case MicrocycleType.recuperacion:
        return ExcelColor.fromHexString('#D5F5E3');
      case MicrocycleType.activacion:
        return ExcelColor.fromHexString('#FEF9E7');
      case MicrocycleType.competitivo:
        return ExcelColor.fromHexString('#FADBD8');
      case MicrocycleType.transitorio:
        return ExcelColor.fromHexString('#D1F2EB');
    }
  }
}
