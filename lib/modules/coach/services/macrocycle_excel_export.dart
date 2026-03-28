import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../../../data/models/macrocycle.dart';
import '../../../data/models/macrocycle_event.dart';
import '../../../data/models/microcycle.dart';

/// Servicio de exportación de un macrociclo a formato Excel (.xlsx).
///
/// Genera un archivo con múltiples hojas:
/// 1. Resumen General
/// 2. Períodos / Etapas
/// 3. Mesociclos
/// 4. Microciclos (Planificación semanal)
/// 5. Eventos
class MacrocycleExcelExport {
  /// Exporta el macrociclo a un archivo Excel y retorna la ruta del archivo.
  static Future<String> exportToExcel(Macrocycle macrocycle) async {
    final excel = Excel.createExcel();

    // ── Hoja 1: Resumen General ──────────────────────────────────────
    _buildResumenSheet(excel, macrocycle);

    // ── Hoja 2: Períodos ─────────────────────────────────────────────
    _buildPeriodosSheet(excel, macrocycle);

    // ── Hoja 3: Mesociclos ───────────────────────────────────────────
    _buildMesociclosSheet(excel, macrocycle);

    // ── Hoja 4: Microciclos ──────────────────────────────────────────
    _buildMicrociclosSheet(excel, macrocycle);

    // ── Hoja 5: Eventos ──────────────────────────────────────────────
    _buildEventosSheet(excel, macrocycle);

    // Eliminar hoja por defecto
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // Guardar archivo
    final dir = await getApplicationDocumentsDirectory();
    final sanitizedName = macrocycle.name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(' ', '_');
    final fileName = 'Macrociclo_${sanitizedName}_${macrocycle.startDate.year}.xlsx';
    final filePath = '${dir.path}/$fileName';

    final fileBytes = excel.save();
    if (fileBytes != null) {
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);
    }

    return filePath;
  }

  // ══════════════════════════════════════════════════════════════════════
  // HOJA 1: RESUMEN GENERAL
  // ══════════════════════════════════════════════════════════════════════

  static void _buildResumenSheet(Excel excel, Macrocycle macrocycle) {
    final sheet = excel['Resumen General'];

    // Estilo de encabezado
    final headerStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#477D9E'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final labelStyle = CellStyle(
      bold: true,
      fontSize: 11,
      backgroundColorHex: ExcelColor.fromHexString('#F4F6F9'),
    );

    final valueStyle = CellStyle(
      fontSize: 11,
    );

    // Título
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0),
    );
    final titleCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    titleCell.value = TextCellValue('MACROCICLO DE ENTRENAMIENTO ${macrocycle.startDate.year}');
    titleCell.cellStyle = headerStyle;

    // Subtítulo
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
      CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1),
    );
    final subtitleCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1));
    subtitleCell.value = TextCellValue('BOCCIA COACHING APP – Formato ${macrocycle.startDate.year}');
    subtitleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#477D9E'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Datos generales
    int row = 3;
    final data = {
      'Nombre del macrociclo': macrocycle.name,
      'Atleta': macrocycle.athleteName,
      'Fecha de inicio':
          '${macrocycle.startDate.day}/${macrocycle.startDate.month}/${macrocycle.startDate.year}',
      'Fecha de fin':
          '${macrocycle.endDate.day}/${macrocycle.endDate.month}/${macrocycle.endDate.year}',
      'Duración total (días)': '${macrocycle.totalDays}',
      'Semanas totales': '${macrocycle.totalWeeks}',
      'Número de etapas': '${macrocycle.periods.length}',
      'Número de mesociclos': '${macrocycle.mesocycles.length}',
      'Número de microciclos': '${macrocycle.microcycles.length}',
      'Número de eventos': '${macrocycle.events.length}',
    };

    data.forEach((label, value) {
      final labelCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      labelCell.value = TextCellValue(label);
      labelCell.cellStyle = labelStyle;

      final valueCell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      valueCell.value = TextCellValue(value);
      valueCell.cellStyle = valueStyle;

      row++;
    });

    // Notas
    if (macrocycle.notes != null && macrocycle.notes!.isNotEmpty) {
      row++;
      final notasLabel = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
      notasLabel.value = TextCellValue('Observaciones');
      notasLabel.cellStyle = labelStyle;

      final notasValue = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row));
      notasValue.value = TextCellValue(macrocycle.notes!);
    }

    // Ancho de columnas
    sheet.setColumnWidth(0, 30);
    sheet.setColumnWidth(1, 40);
  }

  // ══════════════════════════════════════════════════════════════════════
  // HOJA 2: PERÍODOS / ETAPAS
  // ══════════════════════════════════════════════════════════════════════

  static void _buildPeriodosSheet(Excel excel, Macrocycle macrocycle) {
    final sheet = excel['Etapas - Períodos'];

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#477D9E'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Encabezados
    final headers = [
      '#',
      'Período / Etapa',
      'Tipo',
      'Fecha Inicio',
      'Fecha Fin',
      'Semanas',
    ];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Datos
    for (int i = 0; i < macrocycle.periods.length; i++) {
      final period = macrocycle.periods[i];
      final row = i + 1;
      final color = _excelColorForPeriod(period.type);

      final rowStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: color,
      );

      _setCell(sheet, 0, row, '${i + 1}', rowStyle);
      _setCell(sheet, 1, row, period.name, rowStyle);
      _setCell(sheet, 2, row, period.type.label, rowStyle);
      _setCell(sheet, 3, row,
          '${period.startDate.day}/${period.startDate.month}/${period.startDate.year}',
          rowStyle);
      _setCell(sheet, 4, row,
          '${period.endDate.day}/${period.endDate.month}/${period.endDate.year}',
          rowStyle);
      _setCell(sheet, 5, row, '${period.weeks}', rowStyle);
    }

    sheet.setColumnWidth(0, 5);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 25);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 10);
  }

  // ══════════════════════════════════════════════════════════════════════
  // HOJA 3: MESOCICLOS
  // ══════════════════════════════════════════════════════════════════════

  static void _buildMesociclosSheet(Excel excel, Macrocycle macrocycle) {
    final sheet = excel['Mesociclos'];

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#477D9E'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = [
      '#',
      'Nombre',
      'Tipo',
      'Fecha Inicio',
      'Fecha Fin',
      'Semanas',
      'Objetivo',
    ];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    for (int i = 0; i < macrocycle.mesocycles.length; i++) {
      final meso = macrocycle.mesocycles[i];
      final row = i + 1;

      final rowStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: row.isEven
            ? ExcelColor.fromHexString('#F4F6F9')
            : ExcelColor.fromHexString('#FFFFFF'),
      );

      _setCell(sheet, 0, row, '${meso.number}', rowStyle);
      _setCell(sheet, 1, row, meso.name, rowStyle);
      _setCell(sheet, 2, row, meso.type.label, rowStyle);
      _setCell(sheet, 3, row,
          '${meso.startDate.day}/${meso.startDate.month}/${meso.startDate.year}',
          rowStyle);
      _setCell(sheet, 4, row,
          '${meso.endDate.day}/${meso.endDate.month}/${meso.endDate.year}',
          rowStyle);
      _setCell(sheet, 5, row, '${meso.weeks}', rowStyle);
      _setCell(sheet, 6, row, meso.objective ?? '', rowStyle);
    }

    sheet.setColumnWidth(0, 5);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 20);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 10);
    sheet.setColumnWidth(6, 40);
  }

  // ══════════════════════════════════════════════════════════════════════
  // HOJA 4: MICROCICLOS
  // ══════════════════════════════════════════════════════════════════════

  static void _buildMicrociclosSheet(Excel excel, Macrocycle macrocycle) {
    final sheet = excel['Microciclos - Semanas'];

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#477D9E'),
      horizontalAlign: HorizontalAlign.Center,
    );

    // Título principal
    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
      CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0),
    );
    final titleCell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    titleCell.value = TextCellValue(
        'PLANIFICACIÓN SEMANAL – ${macrocycle.name} (${macrocycle.startDate.year})');
    titleCell.cellStyle = headerStyle;

    // Encabezados de fila de meses
    final row1 = 1;
    final headers = [
      'Micro #',
      'Sem. Año',
      'Etapa',
      'Mesociclo',
      'Tipo Micro',
      'Fecha Inicio',
      'Fecha Fin',
      'Mes',
    ];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row1));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        fontSize: 10,
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        backgroundColorHex: ExcelColor.fromHexString('#2F536A'),
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // Datos de microciclos
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];

    for (int i = 0; i < macrocycle.microcycles.length; i++) {
      final micro = macrocycle.microcycles[i];
      final row = i + 2;

      // Color según tipo de microciclo
      final bgColor = _excelColorForMicrocycleType(micro.type);
      final rowStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: bgColor,
      );

      _setCell(sheet, 0, row, '${micro.number}', rowStyle);
      _setCell(sheet, 1, row, '${micro.weekNumber}', rowStyle);
      _setCell(sheet, 2, row, micro.periodName ?? '-', rowStyle);
      _setCell(sheet, 3, row, micro.mesocycleName ?? '-', rowStyle);
      _setCell(sheet, 4, row, micro.type.label, rowStyle);
      _setCell(sheet, 5, row,
          '${micro.startDate.day}/${micro.startDate.month}/${micro.startDate.year}',
          rowStyle);
      _setCell(sheet, 6, row,
          '${micro.endDate.day}/${micro.endDate.month}/${micro.endDate.year}',
          rowStyle);
      _setCell(
          sheet, 7, row, months[micro.startDate.month - 1], rowStyle);
    }

    sheet.setColumnWidth(0, 10);
    sheet.setColumnWidth(1, 10);
    sheet.setColumnWidth(2, 25);
    sheet.setColumnWidth(3, 30);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 15);
    sheet.setColumnWidth(6, 15);
    sheet.setColumnWidth(7, 8);
  }

  // ══════════════════════════════════════════════════════════════════════
  // HOJA 5: EVENTOS
  // ══════════════════════════════════════════════════════════════════════

  static void _buildEventosSheet(Excel excel, Macrocycle macrocycle) {
    final sheet = excel['Eventos'];

    final headerStyle = CellStyle(
      bold: true,
      fontSize: 11,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#477D9E'),
      horizontalAlign: HorizontalAlign.Center,
    );

    final headers = [
      '#',
      'Nombre',
      'Tipo',
      'Fecha Inicio',
      'Fecha Fin',
      'Duración (días)',
      'Ubicación',
      'Notas',
    ];
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    for (int i = 0; i < macrocycle.events.length; i++) {
      final event = macrocycle.events[i];
      final row = i + 1;

      final color = _excelColorForEventType(event.type);
      final rowStyle = CellStyle(
        fontSize: 10,
        backgroundColorHex: color,
      );

      _setCell(sheet, 0, row, '${i + 1}', rowStyle);
      _setCell(sheet, 1, row, event.name, rowStyle);
      _setCell(sheet, 2, row, event.type.label, rowStyle);
      _setCell(sheet, 3, row,
          '${event.startDate.day}/${event.startDate.month}/${event.startDate.year}',
          rowStyle);
      _setCell(sheet, 4, row,
          '${event.endDate.day}/${event.endDate.month}/${event.endDate.year}',
          rowStyle);
      _setCell(sheet, 5, row, '${event.durationDays}', rowStyle);
      _setCell(sheet, 6, row, event.location ?? '', rowStyle);
      _setCell(sheet, 7, row, event.notes ?? '', rowStyle);
    }

    sheet.setColumnWidth(0, 5);
    sheet.setColumnWidth(1, 30);
    sheet.setColumnWidth(2, 18);
    sheet.setColumnWidth(3, 15);
    sheet.setColumnWidth(4, 15);
    sheet.setColumnWidth(5, 15);
    sheet.setColumnWidth(6, 20);
    sheet.setColumnWidth(7, 30);
  }

  // ══════════════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════════════

  static void _setCell(
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

  static ExcelColor _excelColorForPeriod(PeriodType type) {
    switch (type) {
      case PeriodType.preparatorioGeneral:
        return ExcelColor.fromHexString('#D6EAF8'); // Azul claro
      case PeriodType.preparatorioEspecial:
        return ExcelColor.fromHexString('#E8DAEF'); // Morado claro
      case PeriodType.competitivo:
        return ExcelColor.fromHexString('#FADBD8'); // Rojo claro
      case PeriodType.transicion:
        return ExcelColor.fromHexString('#D5F5E3'); // Verde claro
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

  static ExcelColor _excelColorForEventType(EventType type) {
    switch (type) {
      case EventType.competencia:
        return ExcelColor.fromHexString('#FADBD8');
      case EventType.concentracion:
        return ExcelColor.fromHexString('#E8DAEF');
      case EventType.campus:
        return ExcelColor.fromHexString('#D1F2EB');
      case EventType.evaluacion:
        return ExcelColor.fromHexString('#D6EAF8');
      case EventType.descanso:
        return ExcelColor.fromHexString('#D5F5E3');
      case EventType.otro:
        return ExcelColor.fromHexString('#F4F6F9');
    }
  }
}
