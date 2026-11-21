// MODO DEMO — datos simulados en memoria. No se versiona.
part of 'mock_api.dart';

// ─── Helpers ──────────────────────────────────────────────────────────
String _uid(String prefix, int n) =>
    '$prefix-0000-4000-8000-${n.toString().padLeft(12, '0')}';

String _iso(DateTime d) => d.toIso8601String();

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

String _ddmmyyyy(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

double _r1(num v) => (v * 10).round() / 10;

const _team1 = '22222222-2222-2222-2222-000000000001';
const _team2 = '22222222-2222-2222-2222-000000000002';

/// Orden de cajones de la prueba de fuerza (assets/data/test.force.json).
const _forceBoxes = [
  8, 3, 16, 11, 4, 15, 12, 1, 18, 7, 2, 13, 10, 5, 14, 9, 6, 17, //
  12, 5, 18, 11, 2, 17, 8, 1, 14, 7, 4, 15, 10, 3, 16, 9, 6, 13,
];

const _dayPct = {
  'Lunes': 20,
  'Martes': 20,
  'Miercoles': 15,
  'Jueves': 20,
  'Viernes': 20,
  'Sabado': 5,
  'Domingo': 0,
};

class _DemoAthlete {
  final String id, firstName, lastName, email, category, dni;
  final double skill; // 0..1
  const _DemoAthlete(this.id, this.firstName, this.lastName, this.email,
      this.category, this.dni, this.skill);
  String get name => '$firstName $lastName';
  Map<String, dynamic> toJson() => {
        'userId': id,
        'dni': dni,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'address': 'Medellín, Antioquia',
        'country': 'Colombia',
        'image': null,
        'category': category,
        'seniority': '2022-02-01T00:00:00.000',
        'status': true,
        'createdAt': '2026-01-15T10:00:00.000',
        'updatedAt': '2026-01-15T10:00:00.000',
      };
}

class _DemoStore {
  final MockApiClient client;
  _DemoStore(this.client) {
    _seed();
  }

  final _rnd = Random(2026);
  int _seq = 1000;
  String _newId(String prefix) => _uid(prefix, ++_seq);

  final athletes = <_DemoAthlete>[
    _DemoAthlete(demoAthlete.id, demoAthlete.firstName, demoAthlete.lastName,
        demoAthlete.email, 'BC1', '10203040', 0.72),
    const _DemoAthlete('11111111-1111-1111-1111-000000000003', 'Valentina',
        'Ríos', 'valentina.rios@demo.com', 'BC2', '10203041', 0.80),
    const _DemoAthlete('11111111-1111-1111-1111-000000000004', 'Mateo',
        'Gómez', 'mateo.gomez@demo.com', 'BC3', '10203042', 0.62),
    const _DemoAthlete('11111111-1111-1111-1111-000000000005', 'Lucía',
        'Herrera', 'lucia.herrera@demo.com', 'BC4', '10203043', 0.68),
    const _DemoAthlete('11111111-1111-1111-1111-000000000006', 'Santiago',
        'Morales', 'santiago.morales@demo.com', 'BC2', '10203044', 0.55),
    const _DemoAthlete('11111111-1111-1111-1111-000000000007', 'Camila',
        'Torres', 'camila.torres@demo.com', 'BC1', '10203045', 0.66),
  ];

  late final List<Map<String, dynamic>> teams;
  final members = <String, List<String>>{};
  final strength = <Map<String, dynamic>>[];
  final direction = <Map<String, dynamic>>[];
  final saremas = <Map<String, dynamic>>[];
  final macrocycles = <Map<String, dynamic>>[];
  final sessions = <String, Map<String, dynamic>>{};
  final notifications = <Map<String, dynamic>>[];
  final profileEdits = <String, Map<String, dynamic>>{};

  DateTime get _now => DateTime.now();

  _DemoAthlete? athleteById(String id) {
    for (final a in athletes) {
      if (a.id == id) return a;
    }
    return null;
  }

  String nameOf(String id) {
    if (id == demoCoach.id) return '${demoCoach.firstName} ${demoCoach.lastName}';
    return athleteById(id)?.name ?? 'Atleta';
  }

  Map<String, dynamic>? teamById(String id) {
    for (final t in teams) {
      if (t['teamId'] == id) return t;
    }
    return null;
  }

  Map<String, dynamic> teamJson(Map<String, dynamic> t) =>
      {...t, 'memberCount': members[t['teamId']]?.length ?? 0};

  // ════════════════════════════════════════════════════════════════════
  // SEED
  // ════════════════════════════════════════════════════════════════════
  void _seed() {
    teams = [
      {
        'teamId': _team1,
        'nameTeam': 'Boccia Antioquia',
        'description': 'Equipo departamental de boccia — alto rendimiento.',
        'coachId': demoCoach.id,
        'status': true,
        'image': null,
        'bc1': true,
        'bc2': true,
        'bc3': true,
        'bc4': true,
        'pairs': true,
        'teams': false,
        'country': 'Colombia',
        'region': 'Antioquia',
        'createdAt': '2026-01-10T09:00:00.000',
        'updatedAt': '2026-06-01T09:00:00.000',
      },
      {
        'teamId': _team2,
        'nameTeam': 'Selección Juvenil',
        'description': 'Promesas sub-23 en proceso de formación.',
        'coachId': demoCoach.id,
        'status': true,
        'image': null,
        'bc1': false,
        'bc2': true,
        'bc3': true,
        'bc4': false,
        'pairs': false,
        'teams': true,
        'country': 'Colombia',
        'region': 'Antioquia',
        'createdAt': '2026-03-02T09:00:00.000',
        'updatedAt': '2026-03-02T09:00:00.000',
      },
    ];
    members[_team1] = athletes.map((a) => a.id).toList();
    members[_team2] = [athletes[1].id, athletes[2].id, athletes[4].id];

    // ── Evaluaciones de fuerza ──────────────────────────────────────
    final t1 = members[_team1]!;
    _seedStrength(_team1, 'Evaluación inicial de temporada', 82, t1, 0);
    _seedStrength(_team1, 'Control de fuerza — mes 2', 54,
        t1.where((id) => id != athletes[4].id).toList(), 1);
    _seedStrength(_team1, 'Control de fuerza — mes 3', 26, t1, 2);
    _seedStrength(_team1, 'Control mensual noviembre', 6,
        t1.where((id) => id != athletes[5].id).toList(), 3);
    _seedStrength(_team2, 'Diagnóstico juvenil', 30, members[_team2]!, 1);

    // ── Dirección / SAREMAS+ (resúmenes) ────────────────────────────
    for (final (i, d) in [(0, 64), (1, 18)].indexed) {
      direction.add({
        'assessDirectionId': _uid('44444444', i + 1),
        'evaluationDate': _iso(_now.subtract(Duration(days: d.$2))),
        'description': i == 0
            ? 'Control de dirección — pretemporada'
            : 'Control de dirección — mitad de temporada',
        'state': 'Completada',
        'stateName': 'Completada',
        'teamId': _team1,
        'teamName': 'Boccia Antioquia',
        'coachId': demoCoach.id,
        'coachName': nameOf(demoCoach.id),
        'athleteCount': 6,
        'throwCount': 6 * 24,
        'athletes': t1,
      });
    }
    for (final (i, d) in [(0, 40), (1, 12)].indexed) {
      saremas.add({
        'saremasEvalId': _uid('55555555', i + 1),
        'evaluationDate': _iso(_now.subtract(Duration(days: d.$2))),
        'description': i == 0 ? 'SAREMAS+ octubre' : 'SAREMAS+ noviembre',
        'teamId': _team1,
        'teamName': 'Boccia Antioquia',
        'coachId': demoCoach.id,
        'coachName': nameOf(demoCoach.id),
        'state': 'Finalizado',
        'athleteCount': 6,
        'throwCount': 6 * 28,
        'athletes': t1,
      });
    }

    // ── Macrociclos + sesiones ──────────────────────────────────────
    _seedMacrocycle(athletes[0], 1, 'Temporada 2026-2027');
    _seedMacrocycle(athletes[1], 2, 'Ciclo Nacional 2027');

    // ── Notificaciones ──────────────────────────────────────────────
    _notif(1, demoAthlete.id, demoCoach.id, 'Entrenamiento',
        'Andrés Atleta completó la sesión de entrenamiento de hoy.', 2,
        read: false);
    _notif(2, demoCoach.id, demoCoach.id, 'Evaluación',
        'Se guardaron los resultados de «Control mensual noviembre» (5 atletas).',
        26, read: false);
    _notif(3, athletes[2].id, demoCoach.id, 'Equipo',
        'Mateo Gómez se unió al equipo Boccia Antioquia.', 72);
    _notif(4, demoCoach.id, demoCoach.id, 'Rendimiento',
        'Lucía Herrera mejoró su efectividad un 12 % en el último control.',
        120);
    _notif(5, demoCoach.id, demoCoach.id, 'Alerta',
        'Camila Torres no ha sido evaluada en los últimos 25 días.', 200);
    _notif(10, demoCoach.id, demoAthlete.id, 'Invitación a equipo',
        'Carla Entrenadora te invitó a unirte al equipo Selección Juvenil.',
        5,
        read: false, ref: _team2);
    _notif(11, demoCoach.id, demoAthlete.id, 'Sesión de entrenamiento',
        'Tienes una sesión programada mañana a las 15:00.', 1, read: false);
    _notif(12, demoCoach.id, demoAthlete.id, 'Evaluación',
        'Ya puedes ver los resultados de tu evaluación de fuerza.', 140);
  }

  void _notif(int n, String sender, String receiver, String type, String msg,
      int hoursAgo,
      {bool read = true, String? ref}) {
    notifications.add({
      'notificationMessageId': _uid('66666666', n),
      'message': msg,
      'image': null,
      'senderId': sender,
      'receiverId': receiver,
      'notificationTypeId': _uid('77777777', type.length),
      'notificationTypeName': type,
      'status': read,
      'referenceId': ref,
      'createdAt': _iso(_now.subtract(Duration(hours: hoursAgo))),
    });
  }

  int _strengthSeq = 0;
  void _seedStrength(
      String teamId, String desc, int daysAgo, List<String> ids, int round) {
    final id = '${100 + ++_strengthSeq}';
    final date = _now.subtract(Duration(days: daysAgo));
    final throws = <Map<String, dynamic>>[];
    for (final aid in ids) {
      final a = athleteById(aid)!;
      final skill = (a.skill + round * 0.035).clamp(0.0, 0.95);
      for (var i = 0; i < _forceBoxes.length; i++) {
        final box = _forceBoxes[i];
        final difficulty = box / 18 * 1.6;
        final raw = skill * 5.0 - difficulty + (_rnd.nextDouble() * 2.8 - 1.4);
        final score = raw.round().clamp(0, 5);
        final r = (5 - score) * 8 + _rnd.nextDouble() * 6;
        final ang = _rnd.nextDouble() * pi * 2;
        throws.add({
          'evaluationDetailStrengthId': _uid('3333aaaa', throws.length + _strengthSeq * 1000),
          'athleteId': aid,
          'athleteName': a.name,
          'boxNumber': box,
          'throwOrder': i + 1,
          'targetDistance': 1.0 + box * 0.5,
          'scoreObtained': score,
          'status': score >= 3,
          'coordinateX': _r1(50 + r * cos(ang)),
          'coordinateY': _r1(50 + r * sin(ang)),
          'observations': null,
        });
      }
    }
    strength.add({
      'id': id,
      'assessStrengthId': id,
      'description': desc,
      'evaluationDate': _iso(date),
      'createdAt': _iso(date),
      'teamId': teamId,
      'coachId': demoCoach.id,
      'athleteIds': ids,
      'throws': throws,
    });
  }

  // ─── Macrociclo ─────────────────────────────────────────────────────
  void _seedMacrocycle(_DemoAthlete a, int n, String name) {
    final macroId = _uid('88888888', n);
    final today = _day(_now);
    final start = today.subtract(Duration(days: today.weekday - 1 + 7 * 8));
    const weeks = 24;
    final end = start.add(const Duration(days: weeks * 7 - 1));
    DateTime wk(int w) => start.add(Duration(days: 7 * (w - 1)));
    DateTime wkEnd(int w) => wk(w).add(const Duration(days: 6));

    final periods = [
      ('Preparatorio General', 'preparatorioGeneral', 1, 8),
      ('Preparatorio Especial', 'preparatorioEspecial', 9, 14),
      ('Competitivo', 'competitivo', 15, 21),
      ('Transición', 'transicion', 22, 24),
    ];
    final mesos = [
      ('Introductorio', 'introductorio', 1, 4, 'Adaptación y técnica base'),
      ('Desarrollador', 'desarrollador', 5, 8, 'Aumentar volumen de lanzamientos'),
      ('Estabilizador', 'estabilizador', 9, 14, 'Consolidar precisión en distancia larga'),
      ('Pre-competitivo', 'precompetitivo', 15, 17, 'Simulación de partidos'),
      ('Competitivo', 'competitivo', 18, 21, 'Máximo rendimiento en campeonato'),
      ('Recuperación', 'recuperacion', 22, 24, 'Descarga y evaluación'),
    ];
    String periodOf(int w) => periods.firstWhere((p) => w >= p.$3 && w <= p.$4).$1;
    String mesoOf(int w) => mesos.firstWhere((m) => w >= m.$3 && w <= m.$4).$1;
    String typeOf(int w) {
      if (w <= 8) return w % 4 == 0 ? 'recuperacion' : (w.isEven ? 'choque' : 'ordinario');
      if (w <= 14) return w % 3 == 0 ? 'activacion' : (w.isEven ? 'choque' : 'ordinario');
      if (w <= 21) return w == 18 || w == 21 ? 'competitivo' : 'activacion';
      return w == 22 ? 'recuperacion' : 'transitorio';
    }

    const dists = {
      'ordinario': [0.15, 0.15, 0.20, 0.20, 0.15, 0.15],
      'choque': [0.20, 0.20, 0.25, 0.15, 0.10, 0.10],
      'recuperacion': [0.25, 0.10, 0.15, 0.15, 0.20, 0.15],
      'activacion': [0.10, 0.15, 0.25, 0.25, 0.10, 0.15],
      'competitivo': [0.05, 0.10, 0.25, 0.30, 0.10, 0.20],
      'transitorio': [0.30, 0.10, 0.10, 0.10, 0.20, 0.20],
    };

    final micros = <Map<String, dynamic>>[];
    for (var w = 1; w <= weeks; w++) {
      final type = typeOf(w);
      final d = dists[type]!;
      final microId = _uid('9999${n.toString().padLeft(4, '0')}', w);
      micros.add({
        'microcycleId': microId,
        'number': w,
        'startDate': _iso(wk(w)),
        'endDate': _iso(wkEnd(w)),
        'weekNumber': w,
        'type': type,
        'mesocycleName': mesoOf(w),
        'periodName': periodOf(w),
        'notes': w == 18 ? 'Semana del Campeonato Nacional' : null,
        'hasPeakPerformance': w == 18,
        'macrocycleId': macroId,
        'trainingDistribution': {
          'fisicaGeneral': d[0],
          'fisicaEspecial': d[1],
          'tecnica': d[2],
          'tactica': d[3],
          'teorica': d[4],
          'psicologica': d[5],
        },
        'microcycleTypeId': type,
        'days': [
          for (final e in _dayPct.entries)
            {'dayOfWeek': e.key, 'throwPercentage': e.value, 'isCustom': false}
        ],
      });
      // Sesiones: lunes, miércoles y viernes.
      for (final (i, dow) in ['Lunes', 'Miercoles', 'Viernes'].indexed) {
        final date = wk(w).add(Duration(days: i * 2));
        final sid = '${n * 1000 + w * 10 + i + 1}';
        final status = date.isBefore(today)
            ? (w % 5 == 0 && i == 2 ? 'Terminada' : 'Finalizada')
            : 'Programada';
        sessions[sid] = _buildSession(sid, microId, dow, date, status, w);
      }
    }

    macrocycles.add({
      'macrocycleId': macroId,
      'athleteId': a.id,
      'athleteName': a.name,
      'name': '$name — ${a.firstName}',
      'startDate': _iso(start),
      'endDate': _iso(end),
      'coachId': demoCoach.id,
      'coachName': nameOf(demoCoach.id),
      'teamId': _team1,
      'teamName': 'Boccia Antioquia',
      'notes': 'Objetivo: podio en el Campeonato Nacional.',
      'createdAt': _iso(start.subtract(const Duration(days: 10))),
      'updatedAt': _iso(start),
      'periods': [
        for (final (i, p) in periods.indexed)
          {
            'macrocyclePeriodId': _uid('8888aaaa', n * 10 + i),
            'name': p.$1,
            'type': p.$2,
            'startDate': _iso(wk(p.$3)),
            'endDate': _iso(wkEnd(p.$4)),
            'weeks': p.$4 - p.$3 + 1,
            'macrocycleId': macroId,
          }
      ],
      'mesocycles': [
        for (final (i, m) in mesos.indexed)
          {
            'mesocycleId': _uid('8888bbbb', n * 10 + i),
            'number': i + 1,
            'name': m.$1,
            'type': m.$2,
            'startDate': _iso(wk(m.$3)),
            'endDate': _iso(wkEnd(m.$4)),
            'weeks': m.$4 - m.$3 + 1,
            'objective': m.$5,
            'macrocycleId': macroId,
          }
      ],
      'events': [
        _event(n, 1, 'Evaluación de control', 'evaluacion', wk(7), wk(7), 'Coliseo de Medellín', macroId),
        _event(n, 2, 'Concentración selección', 'concentracion', wk(10), wk(10).add(const Duration(days: 4)), 'Rionegro', macroId),
        _event(n, 3, 'Campeonato Nacional de Boccia', 'competencia', wk(18), wk(18).add(const Duration(days: 5)), 'Bogotá', macroId),
        _event(n, 4, 'Descanso de fin de temporada', 'descanso', wk(23), wkEnd(24), null, macroId),
      ],
      'microcycles': micros,
    });
  }

  Map<String, dynamic> _event(int n, int i, String name, String type,
          DateTime s, DateTime e, String? loc, String macroId) =>
      {
        'macrocycleEventId': _uid('8888cccc', n * 10 + i),
        'name': name,
        'type': type,
        'startDate': _iso(s),
        'endDate': _iso(e),
        'location': loc,
        'notes': null,
        'macrocycleId': macroId,
      };

  Map<String, dynamic> _buildSession(String sid, String microId, String dow,
      DateTime date, String status, int week) {
    final pct = _dayPct[dow]!;
    const base = 300;
    final st = date.add(const Duration(hours: 15));
    final done = status != 'Programada';
    final secStatus = done ? 'Finalizada' : 'Programada';
    final partsDef = [
      ('Propulsion', [('Calentamiento con lanzamientos cortos', 12), ('Bloque de fuerza a cajones', 18)]),
      ('Saremas', [('Diagonal propia', 14), ('Diagonal contraria', 14)]),
      ('2x1', [('Situaciones de ventaja', 10)]),
      ('Escenarios de juego', [('Final de parcial 3-2', 8), ('Bola de tie-break', 6)]),
    ];
    final maxThrows = (base * pct / 100).round();
    final f = maxThrows * 0.9 / 82;
    var k = 0;
    return {
      'trainingSessionId': sid,
      'microcycleId': microId,
      'dayOfWeek': dow,
      'duration': 120,
      'status': status,
      'startTime': _iso(st),
      'endTime': _iso(st.add(const Duration(hours: 2))),
      'photoEvidence1': null,
      'photoEvidence2': null,
      'photoEvidence3': null,
      'photoEvidence4': null,
      'throwPercentage': pct.toDouble(),
      'totalThrowsBase': base,
      'maxThrows': maxThrows,
      'createdAt': _iso(date.subtract(const Duration(days: 14))),
      'updatedAt': _iso(date.subtract(const Duration(days: 14))),
      'parts': [
        for (final (pi, p) in partsDef.indexed)
          {
            'sessionPartId': '$sid-p$pi',
            'name': p.$1,
            'order': pi + 1,
            'createdAt': _iso(date.subtract(const Duration(days: 14))),
            'sections': [
              for (final s in p.$2)
                {
                  'sessionSectionId': '$sid-s${k++}',
                  'sessionPartId': '$sid-p$pi',
                  'name': s.$1,
                  'numberOfThrows': max(2, (s.$2 * f).round()),
                  'status': secStatus,
                  'isOwnDiagonal': k.isEven,
                  'startTime': null,
                  'endTime': null,
                  'observation': done && k == 2
                      ? 'Buena consistencia en la semana $week.'
                      : null,
                  'createdAt': _iso(date.subtract(const Duration(days: 14))),
                  'updatedAt': null,
                }
            ],
          }
      ],
    };
  }

  // ════════════════════════════════════════════════════════════════════
  // ESTADÍSTICAS DE FUERZA
  // ════════════════════════════════════════════════════════════════════
  List<Map<String, dynamic>> strengthForTeam(String? teamId) => strength
      .where((e) => teamId == null || teamId.isEmpty || e['teamId'] == teamId)
      .toList()
    ..sort((a, b) =>
        (b['evaluationDate'] as String).compareTo(a['evaluationDate'] as String));

  List<Map<String, dynamic>> throwsOf(Map<String, dynamic> ev, [String? athleteId]) =>
      (ev['throws'] as List)
          .cast<Map<String, dynamic>>()
          .where((t) => athleteId == null || t['athleteId'] == athleteId)
          .toList();

  String stateOf(Map<String, dynamic> ev) =>
      (ev['throws'] as List).length >= 36 ? 'Completada' : 'En curso';

  Map<String, dynamic> strengthSummary(Map<String, dynamic> ev) => {
        'id': ev['id'],
        'assessStrengthId': ev['id'],
        'description': ev['description'],
        'evaluationDate': ev['evaluationDate'],
        'createdAt': ev['createdAt'],
        'state': stateOf(ev),
        'stateName': stateOf(ev),
        'teamId': ev['teamId'],
        'teamName': teamById(ev['teamId'] as String)?['nameTeam'],
        'coachId': ev['coachId'],
        'coachName': nameOf(ev['coachId'] as String),
        'athleteCount': (ev['athleteIds'] as List).length,
      };

  Map<String, dynamic> athleteStats(Map<String, dynamic> ev, String aid) {
    final ts = throwsOf(ev, aid);
    Map<String, num> range(int lo, int hi) {
      final r = ts.where((t) {
        final b = t['boxNumber'] as int;
        return b >= lo && b <= hi;
      }).toList();
      final hits = r.where((t) => t['status'] == true).length;
      final pts = r.fold<num>(0, (s, t) => s + (t['scoreObtained'] as num));
      return {
        'n': r.length,
        'eff': r.isEmpty ? 0 : hits / r.length,
        'acc': r.isEmpty ? 0 : pts / (r.length * 5),
        'avg': r.isEmpty ? 0 : pts / r.length,
      };
    }

    final eff = ts.where((t) => t['status'] == true).length;
    final pts = ts.fold<num>(0, (s, t) => s + (t['scoreObtained'] as num));
    final s = range(1, 6), m = range(7, 12), l = range(13, 18);
    double r3(num v) => (v * 1000).round() / 1000;
    return {
      'athleteId': aid,
      'athleteName': nameOf(aid),
      'assessStrengthId': ev['id'],
      'effectivenessPercentage': ts.isEmpty ? 0.0 : r3(eff / ts.length),
      'accuracyPercentage': ts.isEmpty ? 0.0 : r3(pts / (ts.length * 5)),
      'effectiveThrow': eff,
      'failedThrow': ts.length - eff,
      'shortThrow': s['n'],
      'mediumThrow': m['n'],
      'longThrow': l['n'],
      'shortEffectivenessPercentage': r3(s['eff']!),
      'mediumEffectivenessPercentage': r3(m['eff']!),
      'longEffectivenessPercentage': r3(l['eff']!),
      'shortAccuracyPercentage': r3(s['acc']!),
      'mediumAccuracyPercentage': r3(m['acc']!),
      'longAccuracyPercentage': r3(l['acc']!),
      'shortThrowAccuracy': _r1(s['avg']!),
      'mediumThrowAccuracy': _r1(m['avg']!),
      'longThrowAccuracy': _r1(l['avg']!),
    };
  }

  /// Efectividad (%) de un atleta en una evaluación, o null si no participó.
  double? effOf(Map<String, dynamic> ev, String aid) {
    final ts = throwsOf(ev, aid);
    if (ts.isEmpty) return null;
    return _r1(ts.where((t) => t['status'] == true).length / ts.length * 100);
  }

  List<double> effHistory(String aid, String? teamId) => strengthForTeam(teamId)
      .reversed
      .map((e) => effOf(e, aid))
      .whereType<double>()
      .toList();

  // ════════════════════════════════════════════════════════════════════
  // RUTAS
  // ════════════════════════════════════════════════════════════════════
  String _q(http.BaseRequest req, String k) =>
      req.url.queryParameters[k] ?? '';

  String get _me => client._current?.id ?? demoCoach.id;

  Map<String, _Handler> routes() => {
        // ── Usuario ───────────────────────────────────────────────────
        'GET /User': (req, body, m) {
          final u = client._current ?? demoCoach;
          return {...u.toJson(), ...?profileEdits[u.id]};
        },
        'PUT /User/UpdateUserInfo': (req, body, m) {
          final u = client._current ?? demoCoach;
          final edits = profileEdits.putIfAbsent(u.id, () => {});
          body?.forEach((k, v) {
            if (v != null && k != 'userId') edits[k] = v;
          });
          return {...u.toJson(), ...edits};
        },
        'POST /User/ValidateEmail': (req, body, m) => {'exists': false},
        'POST /User/AddAthlete': (req, body, m) {
          final id = _newId('11111111');
          final a = _DemoAthlete(
              id,
              body?['firstName'] as String? ?? 'Nuevo',
              body?['lastName'] as String? ?? 'Atleta',
              body?['email'] as String? ?? 'nuevo@demo.com',
              'BC1',
              body?['dni'] as String? ?? id.substring(id.length - 8),
              0.6);
          athletes.add(a);
          final team = body?['teamId'] as String?;
          members[team != null && team.isNotEmpty ? team : _team1]?.add(id);
          return a.toJson();
        },
        'POST /User/SearchAthletesForNameAndTeams': (req, body, m) {
          final q = (body?['firstName'] as String? ?? '').toLowerCase();
          return athletes
              .where((a) => a.name.toLowerCase().contains(q))
              .map((a) => a.toJson())
              .toList();
        },

        // ── Equipos ───────────────────────────────────────────────────
        'GET /v1/users/([^/]+)/teams': (req, body, m) {
          final uid = m.group(1)!;
          return teams
              .where((t) =>
                  t['coachId'] == uid || (members[t['teamId']] ?? []).contains(uid))
              .map(teamJson)
              .toList();
        },
        'GET /v1/teams/([^/]+)/members': (req, body, m) {
          final role = _q(req, 'roleId');
          if (role == AppConstants.roleCoachId) return [demoCoach.toJson()];
          return (members[m.group(1)] ?? [])
              .map((id) => athleteById(id))
              .whereType<_DemoAthlete>()
              .map((a) => a.toJson())
              .toList();
        },
        'POST /v1/teams/([^/]+)/members': (req, body, m) {
          final list = members.putIfAbsent(m.group(1)!, () => []);
          final uid = body?['userId'] as String?;
          if (uid != null && !list.contains(uid)) list.add(uid);
          return {'teamId': m.group(1), 'userId': uid};
        },
        'GET /v1/teams/([^/]+)/strength-statistics/recent': (req, body, m) {
          final evs = strengthForTeam(m.group(1));
          if (evs.isEmpty) return null;
          return {
            ...strengthSummary(evs.first),
            'statistics': [
              for (final id in evs.first['athleteIds'] as List)
                athleteStats(evs.first, id as String)
            ],
          };
        },
        'GET /v1/teams/([^/]+)': (req, body, m) {
          final t = teamById(m.group(1)!);
          return t == null ? _Status(404, {'success': false, 'message': 'No encontrado'}) : teamJson(t);
        },
        'PUT /v1/teams/([^/]+)': (req, body, m) {
          final t = teamById(m.group(1)!);
          if (t != null && body != null) {
            for (final k in ['image', 'bc1', 'bc2', 'bc3', 'bc4', 'country', 'region']) {
              if (body[k] != null) t[k] = body[k];
            }
            t['updatedAt'] = _iso(_now);
          }
          return true;
        },
        'POST /v1/teams': (req, body, m) {
          final id = _newId('22222222');
          teams.add({
            'teamId': id,
            'nameTeam': body?['nameTeam'] ?? 'Nuevo equipo',
            'description': body?['description'],
            'coachId': body?['coachId'] ?? _me,
            'status': true,
            'image': body?['image'],
            for (final k in ['bc1', 'bc2', 'bc3', 'bc4', 'pairs', 'teams'])
              k: body?[k] ?? false,
            'country': body?['country'],
            'region': body?['region'],
            'createdAt': _iso(_now),
            'updatedAt': _iso(_now),
          });
          members[id] = [];
          return id;
        },

        // ── Estadísticas (dashboard) ──────────────────────────────────
        'GET /Statistics/DashboardIndicators': (req, body, m) {
          final teamId = _q(req, 'teamId');
          final ids = teamId.isEmpty
              ? athletes.map((a) => a.id).toList()
              : (members[teamId] ?? <String>[]);
          final evs = strengthForTeam(teamId);
          final latest = evs.isEmpty ? null : evs.first;
          final effs = latest == null
              ? <double>[]
              : ids.map((id) => effOf(latest, id)).whereType<double>().toList();
          final recent = _now.subtract(const Duration(days: 21));
          final evaluatedRecently = evs
              .where((e) => DateTime.parse(e['evaluationDate'] as String).isAfter(recent))
              .expand((e) => (e['athleteIds'] as List).cast<String>())
              .toSet();
          bool inTeam(Map<String, dynamic> e) => teamId.isEmpty || e['teamId'] == teamId;
          return {
            'totalAthletes': ids.length,
            'totalEvaluations': evs.length +
                direction.where(inTeam).length +
                saremas.where(inTeam).length,
            'avgEffectiveness':
                effs.isEmpty ? 0.0 : _r1(effs.reduce((a, b) => a + b) / effs.length),
            'pendingEvaluations':
                ids.where((id) => !evaluatedRecently.contains(id)).length,
            'totalTeams': teams.where((t) => t['coachId'] == _me).length,
          };
        },
        'GET /Statistics/TopPerformanceAthletes': (req, body, m) {
          final teamId = _q(req, 'teamId');
          final limit = int.tryParse(_q(req, 'limit')) ?? 5;
          final ids = teamId.isEmpty ? athletes.map((a) => a.id) : (members[teamId] ?? []);
          final rows = <Map<String, dynamic>>[];
          for (final id in ids) {
            final h = effHistory(id, teamId);
            if (h.isEmpty) continue;
            rows.add({
              'athleteId': id,
              'athleteName': nameOf(id),
              'category': athleteById(id)?.category,
              'effectiveness': h.last,
              'trend': h.length > 1 ? (h.last - h[h.length - 2]).round() : 0,
              'evaluations': h.length,
            });
          }
          rows.sort((a, b) =>
              (b['effectiveness'] as double).compareTo(a['effectiveness'] as double));
          return rows.take(limit).toList();
        },
        'GET /Statistics/RecentTests': (req, body, m) {
          final teamId = _q(req, 'teamId');
          final limit = int.tryParse(_q(req, 'limit')) ?? 10;
          final rows = <Map<String, dynamic>>[];
          for (final ev in strengthForTeam(teamId)) {
            for (final id in (ev['athleteIds'] as List).cast<String>()) {
              final eff = effOf(ev, id);
              if (eff == null) continue;
              rows.add({
                'evaluationId': ev['id'],
                'testType': 'Fuerza',
                'athleteId': id,
                'athleteName': nameOf(id),
                'effectiveness': eff,
                'date': _ddmmyyyy(DateTime.parse(ev['evaluationDate'] as String)),
              });
            }
          }
          return rows.take(limit).toList();
        },
        'GET /Statistics/MonthlyEvolution': (req, body, m) {
          final teamId = _q(req, 'teamId');
          const names = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
          final months = <Map<String, dynamic>>[];
          for (var i = 5; i >= 0; i--) {
            final d = DateTime(_now.year, _now.month - i);
            final evs = strengthForTeam(teamId).where((e) {
              final ed = DateTime.parse(e['evaluationDate'] as String);
              return ed.year == d.year && ed.month == d.month;
            }).toList();
            final effs = [
              for (final e in evs)
                for (final id in (e['athleteIds'] as List).cast<String>())
                  effOf(e, id)
            ].whereType<double>().toList();
            months.add({
              'month': names[d.month - 1],
              'year': d.year,
              'evaluations': evs.length,
              'avgEffectiveness':
                  effs.isEmpty ? 0.0 : _r1(effs.reduce((a, b) => a + b) / effs.length),
            });
          }
          return {'months': months};
        },
        'GET /Statistics/AthleteFullDashboard/([^/]+)': (req, body, m) =>
            athleteDashboard(m.group(1)!),
        'GET /Statistics/AthleteStats/([^/]+)': (req, body, m) =>
            athleteDashboard(m.group(1)!),
        'GET /Statistics/NextSession/([^/]+)': (req, body, m) {
          final next = _athleteSessions(null)
              .where((s) => s['status'] == 'Programada')
              .toList();
          return next.isEmpty ? null : next.first;
        },

        // ── Evaluaciones de fuerza ────────────────────────────────────
        'GET /AssessStrength/CoachHasEvaluations/([^/]+)': (req, body, m) => {
              'hasEvaluations': strength.any((e) => e['coachId'] == m.group(1)),
              'count': strength.where((e) => e['coachId'] == m.group(1)).length,
            },
        'GET /AssessStrength/GetActiveEvaluation/([^/]+)/([^/]+)': (req, body, m) => null,
        // Sin teamId: la tarjeta de la app lo pinta como «Equipo #<uuid>».
        'GET /AssessStrength/GetTeamEvaluations/([^/]+)': (req, body, m) =>
            strengthForTeam(m.group(1))
                .map((e) => strengthSummary(e)..remove('teamId'))
                .toList(),
        'GET /AssessStrength/GetEvaluationStatistics/([^/]+)': (req, body, m) {
          final ev = strength.where((e) => e['id'] == m.group(1)).firstOrNull;
          if (ev == null) return <dynamic>[];
          final ids = {
            ...(ev['athleteIds'] as List).cast<String>(),
            ...throwsOf(ev).map((t) => t['athleteId'] as String),
          };
          return [for (final id in ids) if (throwsOf(ev, id).isNotEmpty) athleteStats(ev, id)];
        },
        'GET /AssessStrength/GetEvaluationDetails/([^/]+)': (req, body, m) {
          final ev = strength.where((e) => e['id'] == m.group(1)).firstOrNull;
          if (ev == null) return null;
          return {
            ...strengthSummary(ev),
            'athletes': [
              for (final id in (ev['athleteIds'] as List).cast<String>())
                {'athleteId': id, 'athleteName': nameOf(id)}
            ],
            'throws': ev['throws'],
          };
        },
        'POST /AssessStrength/AddEvaluation': (req, body, m) {
          final id = '${100 + ++_strengthSeq}';
          strength.add({
            'id': id,
            'assessStrengthId': id,
            'description': body?['description'] ?? 'Nueva evaluación',
            'evaluationDate': _iso(_now),
            'createdAt': _iso(_now),
            'teamId': body?['teamId'] ?? _team1,
            'coachId': body?['coachId'] ?? _me,
            'athleteIds': <String>[],
            'throws': <Map<String, dynamic>>[],
          });
          return {'assessStrengthId': id};
        },
        'POST /AssessStrength/AthletesToEvaluated': (req, body, m) {
          final ev = strength.where((e) => e['id'] == body?['assessStrengthId']).firstOrNull;
          final aid = body?['athleteId'] as String?;
          if (ev != null && aid != null) (ev['athleteIds'] as List).add(aid);
          return _Status(200, [
            {'athleteId': aid, 'assessStrengthId': body?['assessStrengthId']}
          ]);
        },
        'POST /AssessStrength/AddDeatilsToEvaluation': (req, body, m) {
          final ev = strength.where((e) => e['id'] == body?['assessStrengthId']).firstOrNull;
          if (ev != null && body != null) {
            final score = (body['scoreObtained'] as num?) ?? 0;
            (ev['throws'] as List).add({
              ...body,
              'athleteName': nameOf(body['athleteId'] as String? ?? ''),
              'scoreObtained': score.round(),
              'status': score >= 3,
            });
          }
          return _Status(200, [body]);
        },
        'PUT /AssessStrength/UpdateState': (req, body, m) => true,
        'POST /AssessStrength/Cancel': (req, body, m) {
          strength.removeWhere((e) => e['id'] == body?['assessStrengthId']);
          return true;
        },

        // ── Dirección ─────────────────────────────────────────────────
        'GET /AssessDirection/CoachHasEvaluations/([^/]+)': (req, body, m) => {
              'hasEvaluations': direction.any((e) => e['coachId'] == m.group(1)),
              'count': direction.where((e) => e['coachId'] == m.group(1)).length,
            },
        'GET /AssessDirection/GetActiveEvaluation/([^/]+)/([^/]+)': (req, body, m) => null,
        'GET /AssessDirection/GetTeamEvaluations/([^/]+)': (req, body, m) =>
            direction.where((e) => e['teamId'] == m.group(1)).toList(),
        'POST /AssessDirection/AddEvaluation': (req, body, m) {
          final id = _newId('44444444');
          direction.add({
            'assessDirectionId': id,
            'evaluationDate': _iso(_now),
            'description': body?['description'] ?? 'Nueva evaluación',
            'state': 'Completada',
            'stateName': 'Completada',
            'teamId': body?['teamId'] ?? _team1,
            'teamName': teamById(body?['teamId'] as String? ?? _team1)?['nameTeam'],
            'coachId': body?['coachId'] ?? _me,
            'coachName': nameOf(_me),
            'athleteCount': 0,
            'throwCount': 0,
            'athletes': <String>[],
          });
          return {'assessDirectionId': id};
        },
        'POST /AssessDirection/AthletesToEvaluated': (req, body, m) {
          final ev = direction.where((e) => e['assessDirectionId'] == body?['assessDirectionId']).firstOrNull;
          if (ev != null) {
            (ev['athletes'] as List).add(body?['athleteId']);
            ev['athleteCount'] = (ev['athletes'] as List).length;
          }
          return {'athleteId': body?['athleteId'], 'assessDirectionId': body?['assessDirectionId']};
        },
        'POST /AssessDirection/AddDetailsToEvaluation': (req, body, m) {
          final ev = direction.where((e) => e['assessDirectionId'] == body?['assessDirectionId']).firstOrNull;
          if (ev != null) ev['throwCount'] = (ev['throwCount'] as int) + 1;
          return _Status(200, true);
        },
        'PUT /AssessDirection/UpdateState': (req, body, m) => true,
        'POST /AssessDirection/Cancel': (req, body, m) {
          direction.removeWhere((e) => e['assessDirectionId'] == body?['assessDirectionId']);
          return true;
        },

        // ── SAREMAS+ ──────────────────────────────────────────────────
        'GET /AssessSaremas/CoachHasEvaluations/([^/]+)': (req, body, m) => {
              'hasEvaluations': saremas.any((e) => e['coachId'] == m.group(1)),
              'count': saremas.where((e) => e['coachId'] == m.group(1)).length,
            },
        'GET /AssessSaremas/GetActiveEvaluation/([^/]+)/([^/]+)': (req, body, m) => null,
        'GET /AssessSaremas/GetTeamEvaluations/([^/]+)': (req, body, m) =>
            saremas.where((e) => e['teamId'] == m.group(1)).toList(),
        'POST /AssessSaremas/AddEvaluation': (req, body, m) {
          final id = _newId('55555555');
          saremas.add({
            'saremasEvalId': id,
            'evaluationDate': _iso(_now),
            'description': body?['description'] ?? 'Nueva evaluación',
            'teamId': body?['teamId'] ?? _team1,
            'teamName': teamById(body?['teamId'] as String? ?? _team1)?['nameTeam'],
            'coachId': body?['coachId'] ?? _me,
            'coachName': nameOf(_me),
            'state': 'Activa',
            'athleteCount': 0,
            'throwCount': 0,
            'athletes': <String>[],
          });
          return {'saremasEvalId': id};
        },
        'POST /AssessSaremas/AthletesToEvaluated': (req, body, m) {
          final ev = saremas.where((e) => e['saremasEvalId'] == body?['saremasEvalId']).firstOrNull;
          if (ev != null) {
            (ev['athletes'] as List).add(body?['athleteId']);
            ev['athleteCount'] = (ev['athletes'] as List).length;
          }
          return {'athleteId': body?['athleteId'], 'saremasEvalId': body?['saremasEvalId']};
        },
        'POST /AssessSaremas/AddDetailsToEvaluation': (req, body, m) {
          final ev = saremas.where((e) => e['saremasEvalId'] == body?['saremasEvalId']).firstOrNull;
          if (ev != null) ev['throwCount'] = (ev['throwCount'] as int) + 1;
          return {'saremasEvalId': body?['saremasEvalId']};
        },
        'PUT /AssessSaremas/UpdateState': (req, body, m) {
          final ev = saremas.where((e) => e['saremasEvalId'] == body?['saremasEvalId']).firstOrNull;
          if (ev != null && body?['state'] != null) ev['state'] = body!['state'];
          return true;
        },
        'POST /AssessSaremas/Cancel': (req, body, m) {
          saremas.removeWhere((e) => e['saremasEvalId'] == body?['saremasEvalId']);
          return true;
        },

        // ── Notificaciones ────────────────────────────────────────────
        'GET /Notification/GetMessagesBy(?:Coach|Athlete)/([^/]+)': (req, body, m) =>
            notifications.where((n) => n['receiverId'] == m.group(1)).toList(),
        'GET /Notification/GetMessage/([^/]+)': (req, body, m) => notifications
            .where((n) => n['notificationMessageId'] == m.group(1))
            .firstOrNull,
        'GET /Notification/GetTypes': (req, body, m) => [
              for (final t in ['Invitación a equipo', 'Entrenamiento', 'Evaluación', 'Rendimiento', 'Alerta'])
                {'notificationTypeId': _uid('77777777', t.length), 'name': t, 'status': true}
            ],
        'PUT /Notification/UpdateMessage': (req, body, m) {
          final n = notifications
              .where((n) => n['notificationMessageId'] == body?['notificationMessageId'])
              .firstOrNull;
          if (n != null && body?['status'] is bool) n['status'] = body!['status'];
          return n ?? {};
        },
        'PUT /Notification/AcceptTeamInvitation/([^/]+)': (req, body, m) {
          final n = notifications
              .where((n) => n['notificationMessageId'] == m.group(1))
              .firstOrNull;
          if (n == null) return _Status(404, {'success': false, 'message': 'No encontrada'});
          n['status'] = true;
          final team = n['referenceId'] as String?;
          final list = members.putIfAbsent(team ?? _team2, () => []);
          if (!list.contains(n['receiverId'])) list.add(n['receiverId'] as String);
          return {'teamId': team, 'accepted': true};
        },
        'POST /Notification/SendTeamInvitation': (req, body, m) {
          final id = _newId('66666666');
          return {'notificationMessageId': id};
        },
        'POST /Notification/CreateMessage': (req, body, m) =>
            {'notificationMessageId': _newId('66666666')},

        // ── Tipos de microciclo ───────────────────────────────────────
        'GET /MicrocycleType/GetAll': (req, body, m) =>
            MicrocycleTypeDto.defaultTypes.map((t) => t.toJson()).toList(),

        // ── Macrociclos ───────────────────────────────────────────────
        'GET /Macrocycle/GetByTeam/([^/]+)': (req, body, m) => macrocycles
            .where((x) => x['teamId'] == m.group(1))
            .map(_macroSummary)
            .toList(),
        'GET /Macrocycle/GetByAthlete/([^/]+)': (req, body, m) => macrocycles
            .where((x) => x['athleteId'] == m.group(1))
            .map(_macroSummary)
            .toList(),
        'GET /Macrocycle/GetCoachMacrocycles/([^/]+)': (req, body, m) => macrocycles
            .where((x) => x['coachId'] == m.group(1))
            .map(_macroSummary)
            .toList(),
        'GET /Macrocycle/GetById/([^/]+)': (req, body, m) =>
            macrocycles.where((x) => x['macrocycleId'] == m.group(1)).firstOrNull,
        'POST /Macrocycle/Create': (req, body, m) {
          final id = _newId('88888888');
          var i = 0;
          final macro = <String, dynamic>{
            ...?body,
            'macrocycleId': id,
            'createdAt': _iso(_now),
            'updatedAt': _iso(_now),
            'periods': body?['periods'] ?? [],
            'events': [
              for (final e in (body?['events'] as List? ?? []))
                {...e as Map<String, dynamic>, 'macrocycleEventId': '$id-e${i++}', 'macrocycleId': id}
            ],
            'mesocycles': [
              for (final e in (body?['mesocycles'] as List? ?? []))
                {...e as Map<String, dynamic>, 'mesocycleId': '$id-m${i++}', 'macrocycleId': id}
            ],
            'microcycles': [
              for (final e in (body?['microcycles'] as List? ?? []))
                {...e as Map<String, dynamic>, 'microcycleId': '$id-u${i++}', 'macrocycleId': id}
            ],
          };
          macrocycles.add(macro);
          return macro;
        },
        'PUT /Macrocycle/Update': (req, body, m) {
          final x = macrocycles.where((x) => x['macrocycleId'] == body?['macrocycleId']).firstOrNull;
          if (x != null && body != null) {
            body.forEach((k, v) {
              if (v != null) x[k] = v;
            });
            x['updatedAt'] = _iso(_now);
          }
          return x ?? {};
        },
        'DELETE /Macrocycle/Delete/([^/]+)': (req, body, m) {
          macrocycles.removeWhere((x) => x['macrocycleId'] == m.group(1));
          return true;
        },
        'POST /Macrocycle/AddEvent': (req, body, m) {
          final x = macrocycles.where((x) => x['macrocycleId'] == body?['macrocycleId']).firstOrNull;
          final ev = {...?body, 'macrocycleEventId': _newId('8888cccc')};
          if (x != null) (x['events'] as List).add(ev);
          return ev;
        },
        'PUT /Macrocycle/UpdateEvent': (req, body, m) => body ?? {},
        'DELETE /Macrocycle/DeleteEvent/([^/]+)': (req, body, m) {
          for (final x in macrocycles) {
            (x['events'] as List).removeWhere((e) => (e as Map)['macrocycleEventId'] == m.group(1));
          }
          return true;
        },
        'PUT /Macrocycle/UpdateMicrocycle': (req, body, m) {
          for (final x in macrocycles) {
            for (final u in (x['microcycles'] as List).cast<Map<String, dynamic>>()) {
              if (u['microcycleId'] == body?['microcycleId']) {
                body!.forEach((k, v) {
                  if (v != null) u[k] = v;
                });
                return u;
              }
            }
          }
          return body ?? {};
        },
        'POST /Macrocycle/Duplicate/([^/]+)': (req, body, m) {
          final src = macrocycles.where((x) => x['macrocycleId'] == m.group(1)).firstOrNull;
          if (src == null) return _Status(404, {'success': false, 'message': 'No encontrado'});
          final copy = jsonDecode(jsonEncode(src)) as Map<String, dynamic>;
          copy['macrocycleId'] = _newId('88888888');
          copy['name'] = '${src['name']} (copia)';
          macrocycles.add(copy);
          return copy;
        },

        // ── Sesiones de entrenamiento ─────────────────────────────────
        'GET /TrainingSession/GetByMicrocycle/([^/]+)': (req, body, m) => sessions.values
            .where((s) => s['microcycleId'] == m.group(1))
            .map(_sessionSummary)
            .toList(),
        'GET /TrainingSession/GetById/([^/]+)': (req, body, m) => sessions[m.group(1)],
        'GET /TrainingSession/Athlete/GetSessionDetail/([^/]+)/([^/]+)': (req, body, m) =>
            sessions[m.group(1)],
        'POST /TrainingSession/Athlete/GetSessionsByDateRange': (req, body, m) =>
            _athleteSessions(body?['athleteId'] as String?),
        'PUT /TrainingSession/Athlete/(Start|Finish)Session': (req, body, m) {
          final s = sessions[body?['trainingSessionId']];
          if (s == null) return null;
          s['status'] = m.group(1) == 'Start' ? 'EnProceso' : 'Finalizada';
          return s;
        },
        'POST /TrainingSession/Create': (req, body, m) {
          final id = '${5000 + ++_seq}';
          final s = <String, dynamic>{
            ...?body,
            'trainingSessionId': id,
            'status': 'Programada',
            'maxThrows': (((body?['totalThrowsBase'] as num?) ?? 0) *
                    ((body?['throwPercentage'] as num?) ?? 0) /
                    100)
                .round(),
            'createdAt': _iso(_now),
            'updatedAt': _iso(_now),
          };
          var pi = 0;
          s['parts'] = [
            for (final p in (body?['parts'] as List? ?? []).cast<Map<String, dynamic>>())
              () {
                final pid = '$id-p${pi++}';
                var si = 0;
                return {
                  ...p,
                  'sessionPartId': pid,
                  'sections': [
                    for (final sec in (p['sections'] as List? ?? []).cast<Map<String, dynamic>>())
                      {...sec, 'sessionSectionId': '$pid-s${si++}', 'sessionPartId': pid, 'status': 'Programada'}
                  ],
                };
              }()
          ];
          sessions[id] = s;
          return s;
        },
        'PUT /TrainingSession/Update': (req, body, m) {
          final s = sessions[body?['trainingSessionId']];
          if (s == null) return null;
          body!.forEach((k, v) {
            if (v != null) s[k] = v;
          });
          s['updatedAt'] = _iso(_now);
          return s;
        },
        'DELETE /TrainingSession/Delete/([^/]+)': (req, body, m) {
          sessions.remove(m.group(1));
          return true;
        },
        'POST /TrainingSession/AddSection': (req, body, m) {
          final pid = body?['sessionPartId'];
          final sec = {...?body, 'sessionSectionId': _newId('bbbbbbbb'), 'status': 'Programada'};
          for (final s in sessions.values) {
            for (final p in (s['parts'] as List? ?? []).cast<Map<String, dynamic>>()) {
              if (p['sessionPartId'] == pid) (p['sections'] as List).add(sec);
            }
          }
          return sec;
        },
        'PUT /TrainingSession/UpdateSection': (req, body, m) {
          for (final s in sessions.values) {
            for (final p in (s['parts'] as List? ?? []).cast<Map<String, dynamic>>()) {
              for (final sec in (p['sections'] as List).cast<Map<String, dynamic>>()) {
                if (sec['sessionSectionId'] == body?['sessionSectionId']) {
                  body!.forEach((k, v) {
                    if (v != null) sec[k] = v;
                  });
                  return sec;
                }
              }
            }
          }
          return body ?? {};
        },
        'DELETE /TrainingSession/DeleteSection/([^/]+)': (req, body, m) {
          for (final s in sessions.values) {
            for (final p in (s['parts'] as List? ?? []).cast<Map<String, dynamic>>()) {
              (p['sections'] as List).removeWhere((x) => (x as Map)['sessionSectionId'] == m.group(1));
            }
          }
          return true;
        },
      };

  Map<String, dynamic> _macroSummary(Map<String, dynamic> x) => {
        'macrocycleId': x['macrocycleId'],
        'name': x['name'],
        'athleteName': x['athleteName'],
        'athleteId': x['athleteId'],
        'startDate': x['startDate'],
        'endDate': x['endDate'],
        'eventCount': (x['events'] as List? ?? []).length,
        'coachId': x['coachId'] ?? demoCoach.id,
        'coachName': nameOf(x['coachId'] as String? ?? demoCoach.id),
        'teamId': x['teamId'] ?? _team1,
        'teamName': teamById(x['teamId'] as String? ?? _team1)?['nameTeam'],
        'createdAt': x['createdAt'],
      };

  Map<String, dynamic> _sessionSummary(Map<String, dynamic> s) {
    final parts = (s['parts'] as List? ?? []).cast<Map<String, dynamic>>();
    return {
      'trainingSessionId': s['trainingSessionId'],
      'microcycleId': s['microcycleId'],
      'dayOfWeek': s['dayOfWeek'],
      'duration': s['duration'],
      'status': s['status'],
      'throwPercentage': s['throwPercentage'],
      'maxThrows': s['maxThrows'],
      'totalParts': parts.length,
      'totalSections':
          parts.fold<int>(0, (n, p) => n + (p['sections'] as List? ?? []).length),
      'createdAt': s['createdAt'],
    };
  }

  /// Sesiones (resumen de atleta) de los macrociclos del atleta indicado;
  /// si [athleteId] es null, de todos los macrociclos.
  List<Map<String, dynamic>> _athleteSessions(String? athleteId) {
    final out = <Map<String, dynamic>>[];
    for (final x in macrocycles) {
      if (athleteId != null && x['athleteId'] != athleteId) continue;
      for (final u in (x['microcycles'] as List).cast<Map<String, dynamic>>()) {
        for (final s in sessions.values.where((s) => s['microcycleId'] == u['microcycleId'])) {
          out.add({
            ..._sessionSummary(s),
            'macrocycleName': x['name'],
            'microcycleNumber': u['number'],
            'microcycleStartDate': u['startDate'],
            'microcycleEndDate': u['endDate'],
            'microcycleType': u['type'],
            'startTime': s['startTime'],
            'endTime': s['endTime'],
          });
        }
      }
    }
    out.sort((a, b) => (a['startTime'] as String? ?? '').compareTo(b['startTime'] as String? ?? ''));
    return out;
  }

  Map<String, dynamic> athleteDashboard(String aid) {
    final teamIds = members.entries.where((e) => e.value.contains(aid)).map((e) => e.key).toSet();
    final evs = strength.where((e) => effOf(e, aid) != null).toList()
      ..sort((a, b) => (b['evaluationDate'] as String).compareTo(a['evaluationDate'] as String));
    final effs = evs.map((e) => effOf(e, aid)!).toList();
    final dirs = direction.where((e) => (e['athletes'] as List).contains(aid)).toList();
    final sars = saremas.where((e) => (e['athletes'] as List).contains(aid)).toList();
    final mySessions = _athleteSessions(aid);
    final completed = mySessions
        .where((s) => s['status'] == 'Finalizada' || s['status'] == 'Terminada')
        .length;
    double avg(List<double> l) => l.isEmpty ? 0.0 : _r1(l.reduce((a, b) => a + b) / l.length);
    final a = athleteById(aid);
    final base = (a?.skill ?? 0.6) * 100;

    final recent = <Map<String, dynamic>>[
      for (final e in evs)
        {
          'evaluationId': e['id'],
          'type': 'Fuerza',
          'testType': 'Fuerza · ${e['description']}',
          'evaluationDate': e['evaluationDate'],
          'date': _ddmmyyyy(DateTime.parse(e['evaluationDate'] as String)),
          'score': effOf(e, aid),
          'state': 'Completada',
        },
      for (final (i, e) in dirs.indexed)
        {
          'evaluationId': e['assessDirectionId'],
          'type': 'Dirección',
          'testType': 'Dirección · ${e['description']}',
          'evaluationDate': e['evaluationDate'],
          'date': _ddmmyyyy(DateTime.parse(e['evaluationDate'] as String)),
          'score': _r1(base - 6 + i * 4),
          'state': 'Completada',
        },
      for (final (i, e) in sars.indexed)
        {
          'evaluationId': e['saremasEvalId'],
          'type': 'SAREMAS+',
          'testType': 'SAREMAS+ · ${e['description']}',
          'evaluationDate': e['evaluationDate'],
          'date': _ddmmyyyy(DateTime.parse(e['evaluationDate'] as String)),
          'score': _r1(base - 3 + i * 3),
          'state': 'Completada',
        },
    ]..sort((x, y) => (y['evaluationDate'] as String).compareTo(x['evaluationDate'] as String));

    final macro = macrocycles.where((x) => x['athleteId'] == aid).firstOrNull;
    Map<String, dynamic>? currentMicro;
    if (macro != null) {
      for (final u in (macro['microcycles'] as List).cast<Map<String, dynamic>>()) {
        final s = DateTime.parse(u['startDate'] as String);
        final e = DateTime.parse(u['endDate'] as String).add(const Duration(days: 1));
        if (!_now.isBefore(s) && _now.isBefore(e)) currentMicro = u;
      }
    }
    final macroProgress = macro == null
        ? 0.0
        : _r1(((_now.difference(DateTime.parse(macro['startDate'] as String)).inDays) /
                    (DateTime.parse(macro['endDate'] as String)
                        .difference(DateTime.parse(macro['startDate'] as String))
                        .inDays) *
                    100)
                .clamp(0, 100));

    return {
      'athleteId': aid,
      'athleteName': nameOf(aid),
      'teamName': teamIds.isEmpty ? null : teamById(teamIds.first)?['nameTeam'],
      'totalEvaluations': evs.length + dirs.length + sars.length,
      'avgEffectiveness': avg(effs),
      'completedSessions': completed,
      'totalSessions': mySessions.length,
      'strengthSummary': {
        'totalEvaluations': evs.length,
        'averageScore': avg(effs),
        'bestScore': effs.isEmpty ? 0.0 : effs.reduce(max),
        'trend': effs.length > 1 ? _r1(effs[0] - effs[1]) : 0.0,
      },
      'directionSummary': {
        'totalEvaluations': dirs.length,
        'averageScore': _r1(base - 4),
        'bestScore': _r1(base - 2),
        'trend': 4.0,
      },
      'saremasSummary': {
        'totalEvaluations': sars.length,
        'averageScore': _r1(base - 1.5),
        'bestScore': _r1(base),
        'trend': 3.0,
      },
      'macrocycleSummary': macro == null
          ? null
          : {
              'activeMacrocycles': 1,
              'currentPeriod': currentMicro?['periodName'],
              'currentMicrocycleType': currentMicro?['type'],
              'progressPercentage': macroProgress,
            },
      'recentEvaluations': recent.take(6).toList(),
    };
  }
}
