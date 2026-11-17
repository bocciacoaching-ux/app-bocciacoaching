import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/body_map_widget.dart';
import '../../../shared/widgets/body_muscle_shapes.dart'
    show kFrontMuscles, kBackMuscles, viewOfMuscle;

/// Pantalla interactiva del cuerpo humano.
///
/// Permite:
/// - Ver el cuerpo de frente o de espalda.
/// - Seleccionar los musculos principales tocandolos (con zoom para las
///   zonas pequenas) o desde una lista agrupada por region corporal.
/// - Revisar, enfocar y quitar las zonas marcadas.
class BodyMapScreen extends StatefulWidget {
  const BodyMapScreen({super.key});

  @override
  State<BodyMapScreen> createState() => _BodyMapScreenState();
}

/// Mensaje breve que confirma la ultima accion sobre un musculo.
class _TapFeedback {
  final String label;
  final bool added;
  const _TapFeedback(this.label, this.added);
}

class _BodyMapScreenState extends State<BodyMapScreen> {
  BodyView _view = BodyView.front;

  /// Muestra el contorno de las zonas disponibles para tocar.
  bool _showHints = true;

  /// Musculos seleccionados: id -> nombre legible (en orden de seleccion).
  final Map<String, String> _selected = {};

  /// Ultima zona tocada (se resalta en el mapa).
  String? _focused;
  _TapFeedback? _feedback;
  int _feedbackToken = 0;

  final TransformationController _zoom = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(_onZoomChanged);
  }

  @override
  void dispose() {
    _zoom
      ..removeListener(_onZoomChanged)
      ..dispose();
    super.dispose();
  }

  void _onZoomChanged() {
    final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _isZoomed) setState(() => _isZoomed = zoomed);
  }

  void _resetZoom() => _zoom.value = Matrix4.identity();

  // ── Seleccion ───────────────────────────────────────────────────────

  void _toggle(String id, String label) {
    HapticFeedback.selectionClick();
    final added = !_selected.containsKey(id);
    setState(() {
      if (added) {
        _selected[id] = label;
      } else {
        _selected.remove(id);
      }
      _focused = id;
      _feedback = _TapFeedback(label, added);
    });

    // Oculta el aviso despues de un momento (si no hubo otro toque).
    final token = ++_feedbackToken;
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted || token != _feedbackToken) return;
      setState(() {
        _feedback = null;
        _focused = null;
      });
    });
  }

  void _setView(BodyView view) {
    if (view == _view) return;
    setState(() => _view = view);
    _resetZoom();
  }

  void _flip() => _setView(
      _view == BodyView.front ? BodyView.back : BodyView.front);

  void _clear() {
    setState(() {
      _selected.clear();
      _focused = null;
      _feedback = null;
    });
  }

  /// Lleva el mapa a la vista donde esta la zona y la resalta.
  void _focusMuscle(String id) {
    final view = viewOfMuscle(id);
    if (view != null) _setView(view);
    setState(() => _focused = id);
    final token = ++_feedbackToken;
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted || token != _feedbackToken) return;
      setState(() => _focused = null);
    });
  }

  int _countFor(BodyView view) {
    final defs = view == BodyView.front ? kFrontMuscles : kBackMuscles;
    return defs.where((d) => _selected.containsKey(d.id)).length;
  }

  // ── Lista de musculos ───────────────────────────────────────────────

  Future<void> _openMuscleList() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => _MuscleListSheet(
          initialView: _view,
          selected: _selected,
          onToggle: (def) {
            _toggle(def.id, def.label);
            setSheetState(() {});
          },
        ),
      ),
    );
  }

  // ── UI ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isFront = _view == BodyView.front;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Mapa corporal',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            tooltip: 'Lista de músculos',
            onPressed: _openMuscleList,
            icon: const Icon(Icons.format_list_bulleted_rounded),
          ),
          IconButton(
            tooltip: _showHints ? 'Ocultar guías' : 'Mostrar guías',
            onPressed: () => setState(() => _showHints = !_showHints),
            icon: Icon(_showHints
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined),
          ),
          IconButton(
            tooltip: isFront ? 'Ver espalda' : 'Ver frente',
            onPressed: _flip,
            icon: const Icon(Icons.flip_camera_android_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(activeRoute: AppDrawerRoute.mapaCorporal),
      body: SafeArea(
        child: Column(
          children: [
            // ── Selector frente / espalda ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: _ViewToggle(
                isFront: isFront,
                frontCount: _countFor(BodyView.front),
                backCount: _countFor(BodyView.back),
                onChanged: (front) =>
                    _setView(front ? BodyView.front : BodyView.back),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Toca los músculos donde sientes molestia. '
                'Pellizca para hacer zoom.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.neutral4, fontSize: 13),
              ),
            ),

            // ── Cuerpo interactivo ─────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRect(
                      child: InteractiveViewer(
                        transformationController: _zoom,
                        minScale: 1,
                        maxScale: 4,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: HumanBodyMap(
                            view: _view,
                            selectedMuscles: _selected.keys.toSet(),
                            onMuscleTap: (m) => _toggle(m.id, m.label),
                            showHints: _showHints,
                            focusedMuscle: _focused,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Orientacion: lado del sujeto en cada borde.
                  Positioned(
                    left: 16,
                    bottom: 12,
                    child: _SideTag(isFront ? 'Der.' : 'Izq.'),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 12,
                    child: _SideTag(isFront ? 'Izq.' : 'Der.'),
                  ),

                  // Confirmacion del ultimo toque.
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          child: _feedback == null
                              ? const SizedBox.shrink()
                              : _FeedbackPill(
                                  key: ValueKey(_feedbackToken),
                                  feedback: _feedback!,
                                ),
                        ),
                      ),
                    ),
                  ),

                  // Restablecer zoom.
                  if (_isZoomed)
                    Positioned(
                      right: 12,
                      top: 8,
                      child: Material(
                        color: AppColors.surface,
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          tooltip: 'Restablecer zoom',
                          onPressed: _resetZoom,
                          icon: const Icon(Icons.zoom_out_map_rounded,
                              color: AppColors.primary),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Panel de zonas seleccionadas ───────────────────────────
            _SelectedPanel(
              selected: _selected,
              onRemove: (id) => setState(() => _selected.remove(id)),
              onTapChip: _focusMuscle,
              onClear: _clear,
              onOpenList: _openMuscleList,
            ),
          ],
        ),
      ),
    );
  }
}

/// Interruptor segmentado para alternar entre frente y espalda.
class _ViewToggle extends StatelessWidget {
  final bool isFront;
  final int frontCount;
  final int backCount;
  final ValueChanged<bool> onChanged;

  const _ViewToggle({
    required this.isFront,
    required this.frontCount,
    required this.backCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral8,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _segment('Frente', frontCount, isFront, () => onChanged(true)),
          _segment('Espalda', backCount, !isFront, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _segment(String label, int count, bool active, VoidCallback onTap) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.neutral3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
                    decoration: BoxDecoration(
                      color: active ? Colors.white : kMuscleSelectedColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? kMuscleSelectedColor : Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Etiqueta pequena que indica el lado del sujeto.
class _SideTag extends StatelessWidget {
  final String text;
  const _SideTag(this.text);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.neutral7),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral4,
          ),
        ),
      ),
    );
  }
}

/// Aviso flotante con el musculo agregado o quitado.
class _FeedbackPill extends StatelessWidget {
  final _TapFeedback feedback;
  const _FeedbackPill({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final color = feedback.added ? kMuscleSelectedColor : AppColors.neutral3;
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            feedback.added
                ? Icons.add_circle_rounded
                : Icons.remove_circle_outline_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              feedback.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Panel inferior con la lista de zonas marcadas.
class _SelectedPanel extends StatelessWidget {
  final Map<String, String> selected;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onTapChip;
  final VoidCallback onClear;
  final VoidCallback onOpenList;

  const _SelectedPanel({
    required this.selected,
    required this.onRemove,
    required this.onTapChip,
    required this.onClear,
    required this.onOpenList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.healing, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Zonas con molestia (${selected.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              if (selected.isNotEmpty)
                TextButton(
                  onPressed: onClear,
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          if (selected.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Aún no has seleccionado ninguna zona.',
                      style: TextStyle(color: AppColors.neutral5),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenList,
                    icon: const Icon(Icons.format_list_bulleted_rounded,
                        size: 18),
                    label: const Text('Elegir de la lista'),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selected.entries.map((e) {
                    final isBack = viewOfMuscle(e.key) == BodyView.back;
                    return InputChip(
                      onPressed: () => onTapChip(e.key),
                      backgroundColor: const Color(0x1AE53935),
                      side: const BorderSide(color: Color(0x33E53935)),
                      avatar: Icon(
                        isBack
                            ? Icons.flip_to_back_rounded
                            : Icons.flip_to_front_rounded,
                        size: 16,
                        color: const Color(0xFFB71C1C),
                      ),
                      tooltip: isBack ? 'Vista posterior' : 'Vista frontal',
                      label: Text(e.value),
                      labelStyle: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.w600,
                      ),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      deleteIconColor: const Color(0xFFB71C1C),
                      onDeleted: () => onRemove(e.key),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Hoja inferior con todos los musculos agrupados por region corporal.
class _MuscleListSheet extends StatefulWidget {
  final BodyView initialView;
  final Map<String, String> selected;
  final ValueChanged<MuscleDef> onToggle;

  const _MuscleListSheet({
    required this.initialView,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<_MuscleListSheet> createState() => _MuscleListSheetState();
}

class _MuscleListSheetState extends State<_MuscleListSheet> {
  late BodyView _view = widget.initialView;
  String _query = '';

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áà]'), 'a')
      .replaceAll(RegExp('[éè]'), 'e')
      .replaceAll(RegExp('[íì]'), 'i')
      .replaceAll(RegExp('[óò]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u');

  @override
  Widget build(BuildContext context) {
    final defs = _view == BodyView.front ? kFrontMuscles : kBackMuscles;
    final q = _normalize(_query.trim());
    final filtered =
        defs.where((d) => q.isEmpty || _normalize(d.label).contains(q));

    final byGroup = <BodyGroup, List<MuscleDef>>{};
    for (final d in filtered) {
      byGroup.putIfAbsent(d.group, () => []).add(d);
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral7,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Músculos principales',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Listo'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<BodyView>(
                segments: const [
                  ButtonSegment(value: BodyView.front, label: Text('Frente')),
                  ButtonSegment(value: BodyView.back, label: Text('Espalda')),
                ],
                selected: {_view},
                showSelectedIcon: false,
                onSelectionChanged: (s) => setState(() => _view = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded),
                  hintText: 'Buscar músculo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: byGroup.isEmpty
                  ? const Center(
                      child: Text(
                        'Sin resultados',
                        style: TextStyle(color: AppColors.neutral5),
                      ),
                    )
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        for (final group in BodyGroup.values)
                          if (byGroup[group] != null) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 14, 16, 4),
                              child: Text(
                                group.label.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 0.6,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            for (final d in byGroup[group]!)
                              CheckboxListTile(
                                dense: true,
                                value: widget.selected.containsKey(d.id),
                                activeColor: kMuscleSelectedColor,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: Text(d.label),
                                onChanged: (_) => widget.onToggle(d),
                              ),
                          ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}
