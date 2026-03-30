import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/training_session.dart';
import '../../../data/providers/athlete_session_provider.dart';
import '../../../data/providers/session_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/profile_menu_button.dart';

/// Pantalla de calendario de sesiones para el atleta.
///
/// Muestra un calendario con vista semanal o mensual donde se
/// marcan los días que tienen sesiones planificadas. Al seleccionar
/// un día, se muestran las sesiones correspondientes en una lista.
///
/// Cuando [embedded] es `true`, se omite el Scaffold y se muestra
/// solo el contenido para embeberse dentro de otro Scaffold
/// (como el dashboard).
class AthleteSessionCalendarScreen extends StatefulWidget {
  final bool embedded;
  const AthleteSessionCalendarScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<AthleteSessionCalendarScreen> createState() =>
      _AthleteSessionCalendarScreenState();
}

class _AthleteSessionCalendarScreenState
    extends State<AthleteSessionCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSessions();
    });
  }

  Future<void> _loadSessions() async {
    final session = context.read<SessionProvider>().session;
    if (session == null) return;
    await context
        .read<AthleteSessionProvider>()
        .loadAthletesSessions(session.userId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AthleteSessionProvider>();
    final sessionsForDay = _selectedDay != null
        ? provider.sessionsForDay(_selectedDay!)
        : <AthleteSessionSummary>[];

    final body = provider.isLoading
        ? const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          )
        : Column(
            children: [
              // ── Calendario ──────────────────────────────────────
              _buildCalendar(provider),

              // ── Formato toggle ──────────────────────────────────
              _buildFormatToggle(),

              const SizedBox(height: 8),

              // ── Lista de sesiones del día seleccionado ──────────
              Expanded(
                child: sessionsForDay.isEmpty
                    ? _buildEmptyDay()
                    : _buildSessionList(sessionsForDay),
              ),
            ],
          );

    // Modo embebido: sin Scaffold
    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Mi Calendario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.black,
          ),
        ),
        actions: const [
          ProfileMenuButton(),
          SizedBox(width: 8),
        ],
      ),
      drawer: AppDrawer(
        activeRoute: AppDrawerRoute.miCalendario,
        teamName: '',
        teamFlag: '',
      ),
      body: body,
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // CALENDARIO
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildCalendar(AthleteSessionProvider provider) {
    final daysWithSessions = provider.daysWithSessions;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar<AthleteSessionSummary>(
        locale: 'es_ES',
        firstDay: DateTime.utc(2024, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        startingDayOfWeek: StartingDayOfWeek.monday,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          setState(() {
            _calendarFormat = format;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader: (day) {
          return provider.sessionsForDay(day);
        },
        calendarStyle: CalendarStyle(
          // Día de hoy
          todayDecoration: BoxDecoration(
            color: AppColors.primary20,
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          // Día seleccionado
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
          // Marcadores de eventos
          markerDecoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 3,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
          // Weekend
          weekendTextStyle: const TextStyle(color: AppColors.neutral5),
          outsideDaysVisible: false,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.black,
          ),
          leftChevronIcon: const Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.neutral4,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.neutral5,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            final normalizedDay =
                DateTime(day.year, day.month, day.day);
            final hasSession = daysWithSessions.contains(normalizedDay);
            if (!hasSession && events.isEmpty) return null;

            return Positioned(
              bottom: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  events.length.clamp(0, 3),
                  (i) => Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: events[i].isCompleted
                          ? AppColors.success
                          : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // TOGGLE SEMANA / MES
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildFormatToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _formatChip(
            label: 'Semana',
            isSelected: _calendarFormat == CalendarFormat.week,
            onTap: () => setState(() {
              _calendarFormat = CalendarFormat.week;
            }),
          ),
          const SizedBox(width: 8),
          _formatChip(
            label: 'Mes',
            isSelected: _calendarFormat == CalendarFormat.month,
            onTap: () => setState(() {
              _calendarFormat = CalendarFormat.month;
            }),
          ),
          const Spacer(),
          // Botón para ir al día de hoy
          GestureDetector(
            onTap: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary10,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.today, size: 16, color: AppColors.primary),
                  SizedBox(width: 4),
                  Text(
                    'Hoy',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral7,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.white : AppColors.neutral4,
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // LISTA DE SESIONES DEL DÍA
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildSessionList(List<AthleteSessionSummary> sessions) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session);
      },
    );
  }

  Widget _buildSessionCard(AthleteSessionSummary session) {
    final statusColor = _statusColor(session.status);
    final statusLabel = _statusLabel(session.status);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          '/training-session-detail',
          arguments: session.trainingSessionId,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral8),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Ícono de estado ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                session.isCompleted
                    ? Icons.check_circle_outline
                    : Icons.fitness_center_rounded,
                color: statusColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // ── Info de la sesión ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.dayOfWeek ?? 'Sesión',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    session.macrocycleName ?? 'Macrociclo',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 13, color: AppColors.neutral5),
                      const SizedBox(width: 3),
                      Text(
                        '${session.duration} min',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.neutral5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.sports_handball_outlined,
                          size: 13, color: AppColors.neutral5),
                      const SizedBox(width: 3),
                      Text(
                        '${session.maxThrows} lanz.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.neutral5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Chip de estado ──
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════════════════════

  Widget _buildEmptyDay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary10,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.event_available_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sin sesiones este día',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral4,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selecciona otro día para ver tus\nsesiones planificadas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.neutral5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ════════════════════════════════════════════════════════════════════════════

  Color _statusColor(String? status) {
    switch (status) {
      case 'Terminada':
      case 'Finalizada':
        return AppColors.success;
      case 'EnProceso':
        return AppColors.warning;
      case 'Cancelada':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _statusLabel(String? status) {
    switch (status) {
      case 'Terminada':
        return 'Terminada';
      case 'Finalizada':
        return 'Finalizada';
      case 'EnProceso':
        return 'En proceso';
      case 'Cancelada':
        return 'Cancelada';
      default:
        return 'Programada';
    }
  }
}
