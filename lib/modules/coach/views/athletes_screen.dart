import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/team_member.dart';
import '../../../shared/widgets/notifications_bottom_sheet.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/profile_menu_button.dart';
import '../../../shared/widgets/team_selector_chip.dart';
import '../../../shared/widgets/team_end_drawer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/team_provider.dart';

// ---------------------------------------------------------------------------
// Modelo UI de atleta (construido a partir de TeamMember de la API)
// ---------------------------------------------------------------------------
class Athlete {
  final String id;
  final String name;
  final String classification; // BC1, BC2, BC3, BC4
  final String nationality;
  final String flag;
  final int age;
  final String position;
  final String status; // 'Activo' | 'Inactivo'
  final double avgScore;
  final String? image;

  const Athlete({
    required this.id,
    required this.name,
    required this.classification,
    required this.nationality,
    this.flag = '',
    this.age = 0,
    this.position = '',
    required this.status,
    this.avgScore = 0.0,
    this.image,
  });

  /// Crea un [Athlete] a partir de un [TeamMember] de la API.
  factory Athlete.fromTeamMember(TeamMember m) {
    return Athlete(
      id: m.userId.toString(),
      name: m.fullName,
      classification: m.category ?? '',
      nationality: m.country ?? '',
      status: m.statusLabel,
      image: m.image,
    );
  }
}

// ---------------------------------------------------------------------------
// Colores de estado
// ---------------------------------------------------------------------------
Color _statusColor(String status) {
  switch (status) {
    case 'Lesionado':
      return AppColors.warning;
    case 'Inactivo':
      return AppColors.error;
    default:
      return AppColors.success;
  }
}

Color _statusBg(String status) => _statusColor(status).withAlpha(28);

// ---------------------------------------------------------------------------
// Pantalla principal
// ---------------------------------------------------------------------------
class AthletesScreen extends StatefulWidget {
  final String teamName;
  final String teamFlag;
  final String teamSubtitle;

  const AthletesScreen({
    super.key,
    required this.teamName,
    required this.teamFlag,
    required this.teamSubtitle,
  });

  @override
  State<AthletesScreen> createState() => _AthletesScreenState();
}

enum _ViewMode { cards, table }

class _AthletesScreenState extends State<AthletesScreen> {
  _ViewMode _viewMode = _ViewMode.cards;
  String _search = '';
  String? _filterStatus; // null = todos
  int _notificationCount = 3;

  // Equipo activo (puede cambiar desde el endDrawer)
  late String _selectedTeam;
  late String _selectedFlag;
  late String _selectedSubtitle;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _selectedTeam    = widget.teamName;
    _selectedFlag    = widget.teamFlag;
    _selectedSubtitle = widget.teamSubtitle;

    // Si aún no se han cargado los miembros, cargarlos del equipo seleccionado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tp = context.read<TeamProvider>();
      if (tp.selectedTeam != null && tp.members.isEmpty && !tp.isMembersLoading) {
        tp.fetchMembers(tp.selectedTeam!.teamId);
      }
    });
  }

  /// Convierte los miembros del provider en la lista UI [Athlete] filtrada.
  List<Athlete> get _filtered {
    final tp = context.read<TeamProvider>();
    final all = tp.members.map(Athlete.fromTeamMember).toList();
    return all.where((a) {
      final matchSearch = _search.isEmpty ||
          a.name.toLowerCase().contains(_search.toLowerCase()) ||
          a.classification.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _filterStatus == null || a.status == _filterStatus;
      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = context.watch<TeamProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      drawer: AppDrawer(
        activeRoute: AppDrawerRoute.atletas,
        teamName: _selectedTeam,
        teamFlag: _selectedFlag,
      ),
      endDrawer: TeamEndDrawer(
        onTeamSelected: (team) {
          context.read<TeamProvider>().selectTeam(team);
          setState(() {
            _selectedTeam     = team.nameTeam;
            _selectedFlag     = '';
            _selectedSubtitle = team.country ?? '';
            _search       = '';
            _filterStatus = null;
          });
        },
        showAdminSection: false,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _buildToolbar(),
            Expanded(
              child: teamProvider.isMembersLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : teamProvider.hasMembersError
                      ? _buildMembersError(teamProvider)
                      : _filtered.isEmpty
                          ? _buildEmpty()
                          : _viewMode == _ViewMode.cards
                              ? _buildCardsView()
                              : _buildTableView(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Agregar atleta — en desarrollo')),
          );
        },
        backgroundColor: AppColors.actionPrimaryDefault,
        foregroundColor: AppColors.actionPrimaryInverted,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Agregar atleta', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildMembersError(TeamProvider tp) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.errorBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.wifi_off_rounded, size: 32, color: AppColors.error),
            ),
            const SizedBox(height: 16),
            Text(
              tp.membersErrorMessage ?? 'No se pudieron cargar los atletas.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                final selected = tp.selectedTeam;
                if (selected != null) tp.fetchMembers(selected.teamId);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar con hamburguesa (drawer) + chip de equipo (endDrawer) ─────────
  PreferredSizeWidget _buildAppBar() {
    final selectedTeamModel = context.watch<TeamProvider>().selectedTeam;
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.textSecondary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: TeamSelectorChip(
          teamName: _selectedTeam,
          teamFlag: _selectedFlag,
          teamSubtitle: _selectedSubtitle,
          teamImageUrl: selectedTeamModel?.image,
          onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
      actions: [
        _buildNotificationButton(),
        const ProfileMenuButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: () => showNotificationsBottomSheet(context),
          icon: const Icon(Icons.notifications_none, color: AppColors.textSecondary),
        ),
        if (_notificationCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: Text(
                '$_notificationCount',
                style: const TextStyle(color: AppColors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );
  }

  // ── Barra de búsqueda + filtros + toggle de vista ────────────────────────
  Widget _buildToolbar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              const Icon(Icons.group, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Atletas · $_selectedTeam',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Contador de atletas filtrados
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filtered.length} atletas',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Barra de búsqueda + toggle
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  decoration: InputDecoration(
                    hintText: 'Buscar atleta o clasificación…',
                    hintStyle: const TextStyle(fontSize: 13, color: AppColors.textDisabled),
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.neutral5),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.neutral7),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.neutral7),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Toggle de vista
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.neutral7),
                ),
                child: Row(
                  children: [
                    _viewToggleBtn(Icons.grid_view_rounded, _ViewMode.cards),
                    _viewToggleBtn(Icons.table_rows_rounded, _ViewMode.table),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Chips de filtro por estado
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(null, 'Todos'),
                const SizedBox(width: 8),
                _filterChip('Activo', 'Activos'),
                const SizedBox(width: 8),
                _filterChip('Lesionado', 'Lesionados'),
                const SizedBox(width: 8),
                _filterChip('Inactivo', 'Inactivos'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewToggleBtn(IconData icon, _ViewMode mode) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, size: 20, color: active ? AppColors.actionPrimaryInverted : AppColors.neutral5),
      ),
    );
  }

  Widget _filterChip(String? status, String label) {
    final active = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.neutral7,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? AppColors.actionPrimaryInverted : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // ── Vista en tarjetas ────────────────────────────────────────────────────
  Widget _buildCardsView() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        mainAxisExtent: 210,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => _AthleteCard(athlete: _filtered[i]),
    );
  }

  // ── Vista en tabla ───────────────────────────────────────────────────────
  Widget _buildTableView() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(AppColors.background),
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.neutral2,
            ),
            dataTextStyle: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            columnSpacing: 18,
            horizontalMargin: 16,
            dividerThickness: 0.8,
            columns: const [
              DataColumn(label: Text('Atleta')),
              DataColumn(label: Text('Clasificación')),
              DataColumn(label: Text('Posición')),
              DataColumn(label: Text('Edad')),
              DataColumn(label: Text('Prom.')),
              DataColumn(label: Text('Estado')),
            ],
            rows: _filtered.map((a) {
              return DataRow(
                onSelectChanged: (_) =>
                    Navigator.of(context).pushNamed('/athlete-profile', arguments: a),
                cells: [
                // Nombre con avatar
                DataCell(Row(children: [
                  _miniAvatar(a),
                  const SizedBox(width: 8),
                  Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ])),
                DataCell(_ClassBadge(classification: a.classification)),
                DataCell(Text(a.position)),
                DataCell(Text('${a.age} a')),
                DataCell(Text(a.avgScore.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                DataCell(_StatusChip(status: a.status)),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _miniAvatar(Athlete a) {
    return CircleAvatar(
      radius: 15,
      backgroundColor: AppColors.primary10,
      child: Text(
        a.name.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join(),
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }

  // ── Estado vacío ─────────────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 60, color: AppColors.neutral7),
          const SizedBox(height: 12),
          const Text('Sin resultados', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.neutral5, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Intenta con otro nombre o ajusta los filtros',
              style: TextStyle(fontSize: 12, color: AppColors.neutral6)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget: tarjeta de atleta
// ---------------------------------------------------------------------------
class _AthleteCard extends StatelessWidget {
  final Athlete athlete;
  const _AthleteCard({required this.athlete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/athlete-profile', arguments: athlete);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar con iniciales
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary10,
              child: Text(
                athlete.name.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              athlete.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.black),
            ),
            const SizedBox(height: 4),
            Text(
              '${athlete.flag}  ${athlete.nationality}',
              style: const TextStyle(fontSize: 11, color: AppColors.neutral5),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ClassBadge(classification: athlete.classification),
                _StatusChip(status: athlete.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.accent2),
                  const SizedBox(width: 2),
                  Text(
                    athlete.avgScore.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.black),
                  ),
                ]),
                Text(
                  athlete.position,
                  style: const TextStyle(fontSize: 10, color: AppColors.neutral5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Badges reutilizables
// ---------------------------------------------------------------------------
class _ClassBadge extends StatelessWidget {
  final String classification;
  const _ClassBadge({required this.classification});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        classification,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _statusBg(status),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(status)),
      ),
    );
  }
}
