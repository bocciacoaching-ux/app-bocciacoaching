import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive_utils.dart';

/// Anchos maximos de contenido recomendados para pantallas grandes.
abstract final class AppContentWidth {
  /// Formularios, ajustes y pantallas de lectura (una sola columna).
  static const double compact = 760;

  /// Listas y detalles.
  static const double medium = 1040;

  /// Dashboards, paneles y vistas con varias columnas.
  static const double wide = 1320;
}

/// Ancho del menu lateral cuando se muestra fijo (escritorio).
const double kPersistentDrawerWidth = 280;

/// Indica a [AppDrawer] que se esta mostrando fijo al lado del contenido
/// (no como cajon modal), para que no intente cerrarse con `pop()`.
class AppDrawerScope extends InheritedWidget {
  final bool embedded;

  const AppDrawerScope({
    super.key,
    required this.embedded,
    required super.child,
  });

  static bool isEmbedded(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppDrawerScope>()?.embedded ??
      false;

  @override
  bool updateShouldNotify(AppDrawerScope oldWidget) =>
      oldWidget.embedded != embedded;
}

/// Limita el ancho del contenido y lo centra cuando hay espacio de sobra.
///
/// A diferencia de `Center + ConstrainedBox`, mantiene restricciones
/// "tight" en el ancho, por lo que el hijo se comporta igual que en movil
/// (no se encoge a su ancho intrinseco).
class ResponsiveContent extends StatelessWidget {
  final double? maxWidth;
  final Widget child;

  const ResponsiveContent({super.key, required this.maxWidth, required this.child});

  @override
  Widget build(BuildContext context) {
    final limit = maxWidth;
    if (limit == null) return child;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.hasBoundedWidth || constraints.maxWidth <= limit) {
          return child;
        }
        final side = (constraints.maxWidth - limit) / 2;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: side),
          child: child,
        );
      },
    );
  }
}

/// `Scaffold` adaptable a pantallas grandes.
///
/// - Movil / tablet: identico a un `Scaffold` normal.
/// - Escritorio (>= [ResponsiveUtils.desktopBreakpoint]): si la pantalla
///   tiene [drawer], el menu se muestra fijo a la izquierda en lugar de como
///   cajon oculto.
/// - Cualquier tamano: si se define [maxContentWidth], el cuerpo se centra
///   con ese ancho maximo para que no se estire en monitores anchos.
///
/// Acepta los mismos parametros que usan las pantallas de la app, por lo
/// que basta con reemplazar `Scaffold(` por `AppScaffold(`. El [key] se
/// reenvia al `Scaffold` interno, asi que los `GlobalKey<ScaffoldState>`
/// existentes siguen funcionando (`openDrawer`, `openEndDrawer`...).
class AppScaffold extends StatelessWidget {
  final Key? _scaffoldKey;
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Color? backgroundColor;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;
  final bool extendBodyBehindAppBar;

  /// Ancho maximo del cuerpo. `null` = sin limite (la pantalla gestiona su
  /// propio ancho).
  final double? maxContentWidth;

  // ignore: use_key_in_widget_constructors
  const AppScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.backgroundColor,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.maxContentWidth,
  }) : _scaffoldKey = key;

  /// `true` si el menu lateral debe mostrarse fijo con este ancho.
  static bool usesPersistentDrawer(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= ResponsiveUtils.desktopBreakpoint;

  /// Ancho disponible para el contenido (descontando el menu fijo).
  static double availableWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return usesPersistentDrawer(context)
        ? width - kPersistentDrawerWidth - 1
        : width;
  }

  @override
  Widget build(BuildContext context) {
    final persistent = drawer != null && usesPersistentDrawer(context);

    final scaffold = Scaffold(
      key: _scaffoldKey,
      appBar: appBar,
      body: body == null
          ? null
          : ResponsiveContent(maxWidth: maxContentWidth, child: body!),
      backgroundColor: backgroundColor,
      drawer: persistent ? null : drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );

    if (!persistent) return scaffold;

    return Material(
      color: backgroundColor ?? AppColors.background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: kPersistentDrawerWidth,
            child: AppDrawerScope(embedded: true, child: drawer!),
          ),
          const VerticalDivider(
              width: 1, thickness: 1, color: AppColors.neutral8),
          Expanded(child: scaffold),
        ],
      ),
    );
  }
}
