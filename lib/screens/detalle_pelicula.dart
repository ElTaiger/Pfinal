import 'package:flutter/material.dart';
import '../models/pelicula.dart';
import '../models/app_state.dart';
import '../utils/idiomas.dart';
import '../utils/animaciones.dart';
import '../widgets/custom_app_bar.dart';
import 'carrito.dart';

class DetallePelicula extends StatefulWidget {
  static final ValueNotifier<String> activeRouteIdNotifier =
      ValueNotifier<String>('');

  final Pelicula pelicula;
  final bool esFavoritoInicial;
  final VoidCallback onToggleFavorito;

  const DetallePelicula({
    super.key,
    required this.pelicula,
    required this.esFavoritoInicial,
    required this.onToggleFavorito,
  });

  @override
  State<DetallePelicula> createState() => _DetallePeliculaState();
}

class _DetallePeliculaState extends State<DetallePelicula> {
  late bool esFavorito;
  final GlobalKey cartKey = GlobalKey();
  bool _mostrarInfo = false;
  double _valoracionUsuario = 0;

  @override
  void initState() {
    super.initState();
    esFavorito = widget.esFavoritoInicial;
    _valoracionUsuario =
        AppState().valoracionesUsuario[widget.pelicula.id] ?? 0;
    idiomaActual.addListener(_actualizarIdioma);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _mostrarInfo = true);
    });
  }

  void _actualizarIdioma() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    idiomaActual.removeListener(_actualizarIdioma);
    super.dispose();
  }

  void _toggleFavorito() {
    setState(() {
      esFavorito = !esFavorito;
    });
    widget.onToggleFavorito();
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (index) {
        if (rating >= index + 1) {
          return const Icon(
            Icons.star,
            color: Colors.greenAccent,
            size: 28,
            shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
          );
        } else if (rating > index && rating < index + 1) {
          double fraction = rating - index;
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [Colors.greenAccent, Colors.white30],
                stops: [fraction, fraction],
              ).createShader(bounds);
            },
            child: const Icon(
              Icons.star,
              color: Colors.white,
              size: 28,
              shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
            ),
          );
        } else {
          return const Icon(
            Icons.star,
            color: Colors.white30,
            size: 28,
            shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
          );
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: DetallePelicula.activeRouteIdNotifier,
      builder: (context, activeId, child) {
        return HeroMode(
          enabled: activeId == widget.pelicula.id,
          child: Scaffold(
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Stack(
                        children: [
                          Hero(
                            tag: widget.pelicula.id,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(30),
                              ),
                              child: Image.asset(
                                widget.pelicula.urlImagen,
                                height: 350,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 350,
                                    color: Colors.white,
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.movie_creation_outlined,
                                            size: 100,
                                            color: Colors.black38,
                                          ),
                                          const SizedBox(height: 20),
                                          Text(
                                            widget.pelicula.titulo,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: AnimatedOpacity(
                              opacity: _mostrarInfo ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 800),
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(30),
                                  ),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(1.0),
                                      Colors.black.withOpacity(0.6),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 50,
                            right: 50,
                            child: AnimatedOpacity(
                              opacity: _mostrarInfo ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 800),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: _buildStars(
                                      double.tryParse(
                                            widget.pelicula.valoracion
                                                .toString()
                                                .split('/')
                                                .first
                                                .trim()
                                                .replaceAll(',', '.'),
                                          ) ??
                                          0.0,
                                    ),
                                  ),
                                  const SizedBox(width: 15),
                                  Builder(
                                    builder: (ctxBtn) {
                                      bool enCarrito = AppState().carrito.any(
                                        (p) => p.id == widget.pelicula.id,
                                      );
                                      return GestureDetector(
                                        onTap: () {
                                          if (!enCarrito) {
                                            setState(
                                              () => AppState().carrito.add(
                                                widget.pelicula,
                                              ),
                                            );
                                            animarHaciaCarrito(
                                              context,
                                              cartKey,
                                              ctxBtn,
                                              widget.pelicula.urlImagen,
                                            );
                                          }
                                        },
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          transitionBuilder: (child, anim) =>
                                              ScaleTransition(
                                                scale: anim,
                                                child: child,
                                              ),
                                          child: Container(
                                            key: ValueKey<bool>(enCarrito),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.6,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              enCarrito
                                                  ? Icons.check
                                                  : Icons.add_shopping_cart,
                                              color: enCarrito
                                                  ? Colors.greenAccent
                                                  : Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: _toggleFavorito,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(
                                              scale: animation,
                                              child: child,
                                            ),
                                        child: Icon(
                                          esFavorito
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          key: ValueKey(esFavorito),
                                          color: esFavorito
                                              ? Colors.greenAccent
                                              : Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50.0,
                          vertical: 30.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _crearFilaDato(
                              Icons.movie,
                              tr('director'),
                              widget.pelicula.director,
                            ),
                            _crearFilaDato(
                              Icons.calendar_today,
                              tr('fecha_estreno'),
                              widget.pelicula.fechaEstreno != null
                                  ? formatearFecha(
                                      widget.pelicula.fechaEstreno!,
                                    )
                                  : widget.pelicula.anio,
                            ),
                            _crearFilaDato(
                              Icons.star,
                              tr('valoracion'),
                              widget.pelicula.valoracion,
                            ),
                            _crearFilaDato(
                              Icons.timer,
                              tr('duracion'),
                              widget.pelicula.duracion,
                            ),
                            _crearFilaDato(
                              Icons.people,
                              tr('reparto'),
                              widget.pelicula.reparto,
                            ),

                            const SizedBox(height: 30),
                            _buildUserRating(),

                            const SizedBox(height: 30),
                            Text(
                              tr('sinopsis'),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              widget.pelicula.sinopsis,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: FloatingAppBar(
                    isScrolled: true,
                    centerTitle: true,
                    title: SequentialFadeHero(
                      tag: 'appbar_title_hero',
                      child: Text(
                        widget.pelicula.titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Colors.greenAccent,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    titleSpacing: 0,
                    leadingWidth: 126,
                    leading: Builder(
                      builder: (context) => Container(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 20),
                            SequentialFadeHero(
                              tag: 'appbar_leading_hero',
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.greenAccent,
                                  size: 28,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    flexibleSpace: Stack(
                      children: [
                        Positioned(
                          left: 78,
                          top: 11,
                          child: const SequentialFadeHero(
                            tag: 'appbar_search_hero',
                            child: SizedBox(width: 48, height: 48),
                          ),
                        ),
                        Positioned(
                          right: 20,
                          top: 11,
                          child: const SequentialFadeHero(
                            tag: 'appbar_profile_hero',
                            child: SizedBox(width: 48, height: 48),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Hero(
                        tag: 'cart_icon_floating',
                        child: Material(
                          type: MaterialType.transparency,
                          child: IconButton(
                            key: cartKey,
                            icon: const Icon(
                              Icons.shopping_cart,
                              color: Colors.greenAccent,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const PantallaCarrito(),
                                  transitionsBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                        child,
                                      ) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                  transitionDuration: const Duration(
                                    milliseconds: 400,
                                  ),
                                  reverseTransitionDuration: const Duration(
                                    milliseconds: 400,
                                  ),
                                ),
                              ).then((_) {
                                // aquí refresco el icono por si se ha quitado desde el carrito
                                if (mounted) setState(() {});
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('tu_valoracion'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...List.generate(10, (index) {
              final estrella = index + 1;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_valoracionUsuario == estrella.toDouble()) {
                      // aquí si toco la misma estrella quito la valoracion
                      _valoracionUsuario = 0;
                      AppState().valoracionesUsuario.remove(widget.pelicula.id);
                    } else {
                      _valoracionUsuario = estrella.toDouble();
                      AppState().valoracionesUsuario[widget.pelicula.id] =
                          _valoracionUsuario;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      estrella <= _valoracionUsuario
                          ? Icons.star
                          : Icons.star_border,
                      key: ValueKey(
                        'star_${widget.pelicula.id}_${estrella}_${estrella <= _valoracionUsuario}',
                      ),
                      color: estrella <= _valoracionUsuario
                          ? Colors.amber
                          : Colors.white38,
                      size: 30,
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(width: 12),
            Text(
              _valoracionUsuario > 0
                  ? '${_valoracionUsuario.toInt()} / 10'
                  : tr('sin_valorar'),
              style: TextStyle(
                color: _valoracionUsuario > 0 ? Colors.amber : Colors.white38,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _crearFilaDato(IconData icono, String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Text(
            '$titulo: ',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
