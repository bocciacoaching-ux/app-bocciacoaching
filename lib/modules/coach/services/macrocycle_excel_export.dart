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
      // 1) Agrupar semanas consecutivas por mes
      final List<List<int>> monthGroups = []; // [month, year, startIdx, endIdx]
      int groupStart = 0;
      int groupMonth = micros[0].startDate.month;
      int groupYear = micros[0].startDate.year;
      for (int i = 1; i < totalWeeks; i++) {
        final m = micros[i].startDate.month;
        final y = micros[i].startDate.year;
        if (m != groupMonth || y != groupYear) {
          monthGroups.add([groupMonth, groupYear, groupStart, i - 1]);
          groupStart = i;
          groupMonth = m;
          groupYear = y;
        }
      }
      // Último grupo
      monthGroups.add([groupMonth, groupYear, groupStart, totalWeeks - 1]);

      // 2) Escribir y mergear cada grupo
      for (final g in monthGroups) {
        final gMonth = g[0];
        final gStartIdx = g[2];
        final gEndIdx = g[3];
        final colStart = colOffset + gStartIdx;
        final colEnd = colOffset + gEndIdx;
        if (colEnd > colStart) {
          sheet.merge(
            CellIndex.indexByColumnRow(columnIndex: colStart, rowIndex: currentRow),
            CellIndex.indexByColumnRow(columnIndex: colEnd, rowIndex: currentRow),
          );
        }
        _setCellValue(sheet, colStart, currentRow,
            months[gMonth - 1], headerStyle);
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

    // ─── ROWS 15-25: Escala gráfica de porcentajes con barras ─────────
    // Cada fila = un nivel de porcentaje (100%, 90%, ..., 0%).
    // El color y nivel de llenado dependen del tipo de μ y de si la
    // semana tiene evento de competencia:
    //   - Verde (#00B050): μ normales, llena hasta el % del tipo de μ.
    //   - Amarillo (#FFFF00): μ5 (Choque 2 Intensidad) llena 100%.
    //   - Rojo (#FF0000): semanas con competencia (CN/CI) llena 100%.
    final greenBarStyle = CellStyle(
      fontSize: 8,
      backgroundColorHex: ExcelColor.fromHexString('#00B050'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final yellowBarStyle = CellStyle(
      fontSize: 8,
      backgroundColorHex: ExcelColor.fromHexString('#FFFF00'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final redBarStyle = CellStyle(
      fontSize: 8,
      backgroundColorHex: ExcelColor.fromHexString('#FF0000'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final emptyScaleStyle = CellStyle(
      fontSize: 8,
      horizontalAlign: HorizontalAlign.Center,
    );

    // Pre-calcular el porcentaje de barra y color por semana
    final List<int> barPctPerWeek = [];
    final List<CellStyle> barStylePerWeek = [];
    for (int i = 0; i < totalWeeks; i++) {
      final micro = micros[i];
      // Detectar si la semana tiene evento de competencia (CN o CI)
      bool hasCompetition = false;
      for (final event in macrocycle.events) {
        if (event.type == EventType.competencia &&
            !micro.startDate.isAfter(event.endDate) &&
            !micro.endDate.isBefore(event.startDate)) {
          hasCompetition = true;
          break;
        }
      }

      if (hasCompetition) {
        // Semana de competencia → rojo, 100%
        barPctPerWeek.add(100);
        barStylePerWeek.add(redBarStyle);
      } else if (micro.type == MicrocycleType.competitivo) {
        // μ5 (Choque 2 Intensidad) → amarillo, 100%
        barPctPerWeek.add(100);
        barStylePerWeek.add(yellowBarStyle);
      } else {
        // Otros tipos → verde, porcentaje según tipo de μ
        barPctPerWeek.add(_barPercentForMicrocycleType(micro.type));
        barStylePerWeek.add(greenBarStyle);
      }
    }

    for (int s = 0; s <= 10; s++) {
      currentRow = 15 + s;
      final pctThreshold = (10 - s) * 10; // 100, 90, 80, ..., 0
      _setCellValue(sheet, 0, currentRow, '$pctThreshold%',
          CellStyle(fontSize: 8, horizontalAlign: HorizontalAlign.Center));
      for (int i = 0; i < totalWeeks; i++) {
        final weekBarPct = barPctPerWeek[i];
        // Llenar si el porcentaje del μ es mayor al umbral.
        // Para 0%: llenar si hay barra (weekBarPct > 0).
        final shouldFill = pctThreshold == 0
            ? weekBarPct > 0
            : weekBarPct >= pctThreshold;
        if (shouldFill) {
          _setCellValue(
              sheet, colOffset + i, currentRow, '', barStylePerWeek[i]);
        } else {
          _setCellValue(sheet, colOffset + i, currentRow, '', emptyScaleStyle);
        }
      }
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
      _setCellValue(sheet, colOffset + i, currentRow,
          '${(dist.fisicaGeneral * 100).round()}%', percentStyle);
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
      _setCellValue(sheet, colOffset + i, currentRow,
          '${(dist.fisicaEspecial * 100).round()}%', percentStyle);
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
      _setCellValue(
          sheet, colOffset + i, currentRow, '${(dist.tecnica * 100).round()}%', percentStyle);
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
      _setCellValue(
          sheet, colOffset + i, currentRow, '${(dist.tactica * 100).round()}%', percentStyle);
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
      _setCellValue(
          sheet, colOffset + i, currentRow, '${(dist.teorica * 100).round()}%', percentStyle);
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
      _setCellValue(sheet, colOffset + i, currentRow,
          '${(dist.psicologica * 100).round()}%', percentStyle);
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
      _setCellValue(
          sheet, colOffset + i, currentRow, '${(dist.total * 100).round()}%', totalCellStyle);
    }

    // ─── ROW 33: Espacio ─────────────────────────────────────────────
    currentRow = 33;

    // ─── ROW 34-41: LEYENDA (formato compacto) ──────────────────────
    // Columnas: A=Etapa abrev, B=Etapa nombre, C=Meso abrev, D=Meso nombre,
    //           E=Micro abrev, F=Micro nombre, G-L=LUN-SAB, M=% total
    // Colores de días: Cyan (#00FFFF), Magenta (#FF00FF), Amarillo (#FFFF00),
    //                  Blanco, y combinaciones según la imagen de referencia.

    currentRow = 34;
    _setCellValue(sheet, 0, currentRow, 'LEGENDA:', CellStyle(
      bold: true, fontSize: 10,
    ));

    // Encabezados de días (columnas 6-11) y % (columna 12)
    final dayHeaderStyle = CellStyle(
      bold: true, fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
    );
    final dayNames = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB'];
    for (int d = 0; d < dayNames.length; d++) {
      _setCellValue(sheet, 6 + d, currentRow, dayNames[d], dayHeaderStyle);
    }

    // Estilos para colores de días por fila (según imagen)
    final cyanBg = CellStyle(
      fontSize: 9, horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#00FFFF'),
    );
    final magentaBg = CellStyle(
      fontSize: 9, horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#FF00FF'),
    );
    final yellowBg = CellStyle(
      fontSize: 9, horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#FFFF00'),
    );
    final whiteBg = CellStyle(
      fontSize: 9, horizontalAlign: HorizontalAlign.Center,
    );
    final pctStyle = CellStyle(
      fontSize: 9, horizontalAlign: HorizontalAlign.Center,
    );
    final legendLabelStyle = CellStyle(fontSize: 9);
    final legendBoldStyle = CellStyle(bold: true, fontSize: 9);

    // ── Fila 1: T0 – TRANSICION / MR – MESOCICLO DE RECUPERACION / μ1 – MICROCICLO INCORPORACION
    currentRow = 35;
    _setCellValue(sheet, 0, currentRow, 'T0', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#D1F2EB'),
    ));
    _setCellValue(sheet, 1, currentRow, 'TRANSICION', legendLabelStyle);
    _setCellValue(sheet, 2, currentRow, 'MR', legendBoldStyle);
    _setCellValue(sheet, 3, currentRow, 'MESOCICLO DE RECUPERACION', legendLabelStyle);
    _setCellValue(sheet, 4, currentRow, 'μ1', legendBoldStyle);
    _setCellValue(sheet, 5, currentRow, 'MICROCICLO INCORPORACION', legendLabelStyle);
    // Días: 30% 60% 30% 60% 30% (vacío) → promedio 42%
    _setCellValue(sheet, 6, currentRow, '30%', cyanBg);
    _setCellValue(sheet, 7, currentRow, '60%', magentaBg);
    _setCellValue(sheet, 8, currentRow, '30%', cyanBg);
    _setCellValue(sheet, 9, currentRow, '60%', magentaBg);
    _setCellValue(sheet, 10, currentRow, '30%', cyanBg);
    _setCellValue(sheet, 11, currentRow, '', whiteBg);
    _setCellValue(sheet, 12, currentRow, '42%', pctStyle);

    // ── Fila 2: G1 – PREPARACION GENERAL / MI – MESOCICLO DE INCORPORACION / μ2 – MICROCICLO ORDINÁRIO
    currentRow = 36;
    _setCellValue(sheet, 0, currentRow, 'G1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#D6EAF8'),
    ));
    _setCellValue(sheet, 1, currentRow, 'PREPARACION GENERAL', legendLabelStyle);
    _setCellValue(sheet, 2, currentRow, 'MI', legendBoldStyle);
    _setCellValue(sheet, 3, currentRow, 'MESOCICLO DE INCORPORACION', legendLabelStyle);
    _setCellValue(sheet, 4, currentRow, 'μ2', legendBoldStyle);
    _setCellValue(sheet, 5, currentRow, 'MICROCICLO ORDINÁRIO', legendLabelStyle);
    // Días: 60% 30% 60% 30% 60% (vacío) → promedio 48%
    _setCellValue(sheet, 6, currentRow, '60%', cyanBg);
    _setCellValue(sheet, 7, currentRow, '30%', magentaBg);
    _setCellValue(sheet, 8, currentRow, '60%', cyanBg);
    _setCellValue(sheet, 9, currentRow, '30%', magentaBg);
    _setCellValue(sheet, 10, currentRow, '60%', cyanBg);
    _setCellValue(sheet, 11, currentRow, '', whiteBg);
    _setCellValue(sheet, 12, currentRow, '48%', pctStyle);

    // ── Fila 3: E1 – PREPARACION ESPECIAL / MB – MESOCICLO DE BASE / μ3 – MICROCICLO ESTABILIZADOR
    currentRow = 37;
    _setCellValue(sheet, 0, currentRow, 'E1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#E8DAEF'),
    ));
    _setCellValue(sheet, 1, currentRow, 'PREPARACION ESPECIAL', legendLabelStyle);
    _setCellValue(sheet, 2, currentRow, 'MB', legendBoldStyle);
    _setCellValue(sheet, 3, currentRow, 'MESOCICLO DE BASE', legendLabelStyle);
    _setCellValue(sheet, 4, currentRow, 'μ3', legendBoldStyle);
    _setCellValue(sheet, 5, currentRow, 'MICROCICLO ESTABILIZADOR', legendLabelStyle);
    // Días: 70% 40% 70% 40% 70% (vacío) → promedio 58%
    _setCellValue(sheet, 6, currentRow, '70%', cyanBg);
    _setCellValue(sheet, 7, currentRow, '40%', magentaBg);
    _setCellValue(sheet, 8, currentRow, '70%', cyanBg);
    _setCellValue(sheet, 9, currentRow, '40%', magentaBg);
    _setCellValue(sheet, 10, currentRow, '70%', cyanBg);
    _setCellValue(sheet, 11, currentRow, '', whiteBg);
    _setCellValue(sheet, 12, currentRow, '58%', pctStyle);

    // ── Fila 4: P1 – PRECOMPETITIVO / ME – MESOCICLO DE ESTABILIZACION / μ4 – MICROCICLO DE CHOQUE 1 VOLUMEN
    currentRow = 38;
    _setCellValue(sheet, 0, currentRow, 'P1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#FADBD8'),
    ));
    _setCellValue(sheet, 1, currentRow, 'PRECOMPETITIVO', legendLabelStyle);
    _setCellValue(sheet, 2, currentRow, 'ME', legendBoldStyle);
    _setCellValue(sheet, 3, currentRow, 'MESOCICLO DE ESTABILIZACION', legendLabelStyle);
    _setCellValue(sheet, 4, currentRow, 'μ4', legendBoldStyle);
    _setCellValue(sheet, 5, currentRow, 'MICROCICLO DE CHOQUE 1 VOLUMEN', legendLabelStyle);
    // Días: 80% 20% 80% 20% 80% (vacío) → promedio 56%
    _setCellValue(sheet, 6, currentRow, '80%', yellowBg);
    _setCellValue(sheet, 7, currentRow, '20%', cyanBg);
    _setCellValue(sheet, 8, currentRow, '80%', yellowBg);
    _setCellValue(sheet, 9, currentRow, '20%', cyanBg);
    _setCellValue(sheet, 10, currentRow, '80%', yellowBg);
    _setCellValue(sheet, 11, currentRow, '', whiteBg);
    _setCellValue(sheet, 12, currentRow, '56%', pctStyle);

    // ── Fila 5: C1 – COMPETITIVO / MC – MESOCICLO DE CONTROL / μ5 – MICROCICLO DE CHOQUE 2 INTENSIDAD
    currentRow = 39;
    _setCellValue(sheet, 0, currentRow, 'C1', CellStyle(
      bold: true, fontSize: 9,
      backgroundColorHex: ExcelColor.fromHexString('#D5F5E3'),
    ));
    _setCellValue(sheet, 1, currentRow, 'COMPETITIVO', legendLabelStyle);
    _setCellValue(sheet, 2, currentRow, 'MC', legendBoldStyle);
    _setCellValue(sheet, 3, currentRow, 'MESOCICLO DE CONTROL', legendLabelStyle);
    _setCellValue(sheet, 4, currentRow, 'μ5', legendBoldStyle);
    _setCellValue(sheet, 5, currentRow, 'MICROCICLO DE CHOQUE 2 INTENSIDAD', legendLabelStyle);
    // Días: 100% 10% 100% 10% 100% (vacío) → promedio 64%
    _setCellValue(sheet, 6, currentRow, '100%', yellowBg);
    _setCellValue(sheet, 7, currentRow, '10%', cyanBg);
    _setCellValue(sheet, 8, currentRow, '100%', yellowBg);
    _setCellValue(sheet, 9, currentRow, '10%', cyanBg);
    _setCellValue(sheet, 10, currentRow, '100%', yellowBg);
    _setCellValue(sheet, 11, currentRow, '', whiteBg);
    _setCellValue(sheet, 12, currentRow, '64%', pctStyle);

    // ── Fila 6: CN – CAMPEONATO NACIONAL / MP – MESOCICLO PRÉ COMPETITIVO / μ6 – MICROCICLO DE CHOQUE 3 COMPETENCIA
    currentRow = 40;
    _setCellValue(sheet, 0, currentRow, 'CN', CellStyle(
      bold: true, fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#C0392B'),
    ));
    _setCellValue(sheet, 1, currentRow, 'CAMPEONATO NACIONAL', legendLabelStyle);
    _setCellValue(sheet, 2, currentRow, 'MP', legendBoldStyle);
    _setCellValue(sheet, 3, currentRow, 'MESOCICLO PRÉ COMPETITIVO', legendLabelStyle);
    _setCellValue(sheet, 4, currentRow, 'μ6', legendBoldStyle);
    _setCellValue(sheet, 5, currentRow, 'MICROCICLO DE CHOQUE 3 COMPETENCIA', legendLabelStyle);
    // Días: 100% 100% 100% 100% 100% 100% → promedio 100%
    final competitionDayBg = CellStyle(
      fontSize: 9, horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#660066'),
      fontColorHex: ExcelColor.fromHexString('#808080'),
    );
    _setCellValue(sheet, 6, currentRow, '100%', competitionDayBg);
    _setCellValue(sheet, 7, currentRow, '100%', competitionDayBg);
    _setCellValue(sheet, 8, currentRow, '100%', competitionDayBg);
    _setCellValue(sheet, 9, currentRow, '100%', competitionDayBg);
    _setCellValue(sheet, 10, currentRow, '100%', competitionDayBg);
    _setCellValue(sheet, 11, currentRow, '100%', competitionDayBg);
    _setCellValue(sheet, 12, currentRow, '100%', pctStyle);

    // ── Fila 7: CI – CAMPEONATO INTERNACIONAL / MCP – MESOCICLO COMPETITIVO / μ7 – MICROCICLO DE RECUPERACION
    currentRow = 41;
    _setCellValue(sheet, 0, currentRow, 'CI', CellStyle(
      bold: true, fontSize: 9,
      fontColorHex: ExcelColor.fromHexString('#8E44AD'),
    ));
    _setCellValue(sheet, 1, currentRow, 'CAMPEONATO INTERNACIONAL', legendLabelStyle);
    _setCellValue(sheet, 2, currentRow, 'MCP', legendBoldStyle);
    _setCellValue(sheet, 3, currentRow, 'MESOCICLO COMPETITIVO', legendLabelStyle);
    _setCellValue(sheet, 4, currentRow, 'μ7', legendBoldStyle);
    _setCellValue(sheet, 5, currentRow, 'MICROCICLO DE RECUPERACION', legendLabelStyle);
    // Días: 70% 40% 20% 70% 40% 20% → promedio 43%
    final recoveryDayBg = CellStyle(
      fontSize: 9, horizontalAlign: HorizontalAlign.Center,
      backgroundColorHex: ExcelColor.fromHexString('#800080'),
    );
    _setCellValue(sheet, 6, currentRow, '70%', recoveryDayBg);
    _setCellValue(sheet, 7, currentRow, '40%', recoveryDayBg);
    _setCellValue(sheet, 8, currentRow, '20%', recoveryDayBg);
    _setCellValue(sheet, 9, currentRow, '70%', recoveryDayBg);
    _setCellValue(sheet, 10, currentRow, '40%', recoveryDayBg);
    _setCellValue(sheet, 11, currentRow, '20%', recoveryDayBg);
    _setCellValue(sheet, 12, currentRow, '43%', pctStyle);

    // ─── Ajustar anchos de columna ───────────────────────────────────
    sheet.setColumnWidth(0, 25);
    for (int i = 0; i < totalWeeks; i++) {
      sheet.setColumnWidth(colOffset + i, 6);
    }
    // Columnas extra para leyenda (C=2, D=3, E=4, F=5 se usan en la leyenda)
    // Asegurar que tengan ancho adecuado si no fueron cubiertas por semanas
    if (totalWeeks < 2) sheet.setColumnWidth(2, 6);
    if (totalWeeks < 3) sheet.setColumnWidth(3, 30);
    if (totalWeeks < 4) sheet.setColumnWidth(4, 6);
    if (totalWeeks < 5) sheet.setColumnWidth(5, 35);
    // Columnas de días (G-L = 6-11) y total (M = 12)
    for (int d = 6; d <= 11; d++) {
      if (totalWeeks < d) sheet.setColumnWidth(d, 8);
    }
    if (totalWeeks < 12) sheet.setColumnWidth(12, 8);
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

  /// Porcentaje de llenado de la barra gráfica según el tipo de μ.
  /// Basado en los promedios de la leyenda del Excel "Macro formato 2026".
  /// - μ1 (transitorio): 42%
  /// - μ2 (ordinario): 48%
  /// - μ3 (activación/estabilizador): 58%
  /// - μ4 (choque/volumen): 56%
  /// - μ5 (competitivo/intensidad): 64%
  /// - μ7 (recuperación): 43%
  static int _barPercentForMicrocycleType(MicrocycleType type) {
    switch (type) {
      case MicrocycleType.transitorio: // μ1
        return 42;
      case MicrocycleType.ordinario: // μ2
        return 48;
      case MicrocycleType.activacion: // μ3
        return 58;
      case MicrocycleType.choque: // μ4
        return 56;
      case MicrocycleType.competitivo: // μ5
        return 64;
      case MicrocycleType.recuperacion: // μ7
        return 43;
    }
  }
}
