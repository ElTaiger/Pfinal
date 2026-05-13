import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pelicula.dart';
import '../models/app_state.dart';
import '../utils/idiomas.dart';
import '../utils/animaciones.dart';
import '../widgets/custom_app_bar.dart';
import 'detalle_pelicula.dart';
import 'carrito.dart';
import 'perfil.dart';

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  // primero de todo, voy a declarar las variables que necesito
  List<Pelicula> todasLasPeliculas = [];
  List<dynamic>? _jsonData;
  bool estaBuscando = false;
  final TextEditingController _controladorBusqueda = TextEditingController();
  final GlobalKey cartKey = GlobalKey();

  Set<String> peliculasFavoritas = {};
  bool viendoFavoritos = false;
  
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  // aqui meto un future para cargar el json de peliculas sin que se trabe la app
  late Future<List<Pelicula>> _peliculasFuture;

  @override
  void initState() {
    super.initState();
    // cargo el json nada mas empezar
    _peliculasFuture = cargarPeliculas();
    
    // Retrasamos el efecto para que el cristal aparezca de forma natural al bajar un poco mas
    _scrollController.addListener(() {
      if (_scrollController.offset > 80 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 80 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
    
    idiomaActual.addListener(_actualizarIdioma);
  }

  void _actualizarIdioma() {
    if (mounted) {
      setState(() {
        // recargo las pelis si el idioma cambia
        _peliculasFuture = cargarPeliculas();
      });
    }
  }

  @override
  void dispose() {
    idiomaActual.removeListener(_actualizarIdioma);
    _scrollController.dispose();
    _controladorBusqueda.dispose();
    super.dispose();
  }

  Future<List<Pelicula>> cargarPeliculas() async {
    // pillo el json y lo decodifico
    final String respuesta = await rootBundle.loadString('Data/peliculas.json');
    _jsonData = await json.decode(respuesta) as List;
    final langCode = idiomaActual.value.name;
    // devuelvo la lista ya parseada
    return _jsonData!.map((json) => Pelicula.fromJson(json, langCode: langCode)).toList();
  }

  void toggleFavorito(String id) {
    setState(() {
      if (peliculasFavoritas.contains(id)) {
        peliculasFavoritas.remove(id);
        // muestro un snackbar si lo quito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eliminado de favoritos'), 
            duration: Duration(seconds: 1),
            backgroundColor: Colors.greenAccent,
          ),
        );
      } else {
        peliculasFavoritas.add(id);
        // muestro un snackbar si lo meto
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Añadido a favoritos'), 
            duration: Duration(seconds: 1),
            backgroundColor: Colors.greenAccent,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      drawer: Drawer(
        backgroundColor: const Color(0xFF1E1E1E),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_movierent.png', 
              height: 100,
              color: Colors.greenAccent,
              colorBlendMode: BlendMode.srcIn,
            ),
            const SizedBox(height: 10),
            const Text('MovieRent', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 24, letterSpacing: 2)),
            const SizedBox(height: 5),
            Text(tr('menu_principal'), style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 40),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: Text(tr('catalogo_completo'), style: const TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  viendoFavoritos = false;
                  estaBuscando = false;
                  _controladorBusqueda.clear();
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.white),
              title: Text(tr('mis_favoritos'), style: const TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  viendoFavoritos = true;
                  estaBuscando = false;
                  _controladorBusqueda.clear();
                });
              },
            ),
            const Divider(color: Colors.white24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.white),
                  const SizedBox(width: 16),
                  Text(tr('idioma'), style: const TextStyle(fontSize: 16, color: Colors.white)),
                  const Spacer(),
                  DropdownButton<Idioma>(
                    value: idiomaActual.value,
                    dropdownColor: const Color(0xFF1E1E1E),
                    underline: const SizedBox(),
                    iconEnabledColor: Colors.greenAccent,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    onChanged: (Idioma? nuevoIdioma) {
                      if (nuevoIdioma != null) {
                        idiomaActual.value = nuevoIdioma;
                      }
                    },
                    items: const [
                      DropdownMenuItem(value: Idioma.es, child: Text('🇪🇸 ES')),
                      DropdownMenuItem(value: Idioma.en, child: Text('🇬🇧 EN')),
                      DropdownMenuItem(value: Idioma.fr, child: Text('🇫🇷 FR')),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(tr('cerrar_sesion'), style: const TextStyle(fontSize: 16, color: Colors.redAccent)),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Pelicula>>(
        future: _peliculasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // si esta cargando muestro la ruedita
            return const Center(child: CircularProgressIndicator(color: Colors.greenAccent));
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar', style: TextStyle(color: Colors.white)));
          }

          todasLasPeliculas = snapshot.data ?? [];
          List<Pelicula> peliculasAmostrar = todasLasPeliculas;

          if (viendoFavoritos) {
            // aqui filtro si le han dado a favoritos
            peliculasAmostrar = peliculasAmostrar.where((p) => peliculasFavoritas.contains(p.id)).toList();
          }

          if (_controladorBusqueda.text.isNotEmpty) {
            peliculasAmostrar = peliculasAmostrar
                .where((p) => p.titulo.toLowerCase().contains(_controladorBusqueda.text.toLowerCase()))
                .toList();
          }

          return Stack(
            children: [
              // Logotipo de fondo decorativo
              Positioned(
                right: -100,
                bottom: -50,
                child: Opacity(
                  opacity: 0.05,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Image.asset(
                      'assets/logo_movierent.png',
                      width: 600,
                      color: Colors.greenAccent,
                      colorBlendMode: BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              peliculasAmostrar.isEmpty
                  ? Center(child: Text(viendoFavoritos ? tr('sin_favoritos') : tr('sin_peliculas'), style: const TextStyle(color: Colors.greenAccent, fontSize: 18)))
                  : (!viendoFavoritos && !estaBuscando) 
                      ? _buildGenreSliders(peliculasAmostrar)
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.only(left: 40.0, right: 40.0, top: 130.0, bottom: 40.0), 
                          clipBehavior: Clip.none, 
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 240, 
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 35, 
                            mainAxisSpacing: 35,  
                          ),
                          itemCount: peliculasAmostrar.length,
                          itemBuilder: (context, index) {
                            final peli = peliculasAmostrar[index];
                            return TarjetaPelicula(
                              pelicula: peli,
                              esFavorito: peliculasFavoritas.contains(peli.id),
                              cartKey: cartKey,
                              onToggleFavorito: () => toggleFavorito(peli.id),
                            );
                          },
                        ),
          Positioned(
            top: 0, left: 0, right: 0,
            child: FloatingAppBar(
              isScrolled: _isScrolled,
              centerTitle: true,
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
                          icon: const Icon(Icons.menu, color: Colors.greenAccent, size: 28),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (estaBuscando)
                        SequentialFadeHero(
                          tag: 'appbar_search_hero',
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.greenAccent, size: 28),
                            onPressed: () {
                              setState(() {
                                estaBuscando = false;
                                _controladorBusqueda.clear();
                              });
                            },
                          ),
                        )
                      else
                        SequentialFadeHero(
                          tag: 'appbar_search_hero',
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.greenAccent, size: 28),
                            onPressed: () {
                              setState(() {
                                estaBuscando = true;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              title: estaBuscando
                  ? TextField(
                      controller: _controladorBusqueda,
                      autofocus: true,
                      textAlign: TextAlign.left,
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: tr('buscar'),
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Colors.white54),
                      ),
                      cursorColor: Colors.greenAccent,
                      onChanged: (text) => setState(() {}),
                    )
                  : SequentialFadeHero(
                      tag: 'appbar_title_hero',
                      child: Text(
                        viendoFavoritos ? tr('favoritos') : tr('catalogo'), 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.greenAccent, letterSpacing: 1.5),
                      ),
                    ),
              actions: [
                Hero(
                  tag: 'cart_icon_floating',
                  child: Material(
                    type: MaterialType.transparency,
                    child: IconButton(
                      key: cartKey,
                      icon: const Icon(Icons.shopping_cart, color: Colors.greenAccent, size: 28),
                      onPressed: () {
                        DetallePelicula.activeRouteIdNotifier.value = 'carrito';
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const PantallaCarrito(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 400),
                            reverseTransitionDuration: const Duration(milliseconds: 400),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SequentialFadeHero(
                  tag: 'appbar_profile_hero',
                  child: IconButton(
                    icon: const Icon(Icons.person, color: Colors.greenAccent, size: 28),
                    onPressed: () {
                      DetallePelicula.activeRouteIdNotifier.value = 'perfil';
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const PantallaPerfil(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                          transitionDuration: const Duration(milliseconds: 400),
                          reverseTransitionDuration: const Duration(milliseconds: 400),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      );
        },
      ),
    );
  }
  Widget _buildGenreSliders(List<Pelicula> peliculas) {
    // Agrupamos por género
    Map<String, List<Pelicula>> porGenero = {};
    for (var p in peliculas) {
      if (!porGenero.containsKey(p.genero)) {
        porGenero[p.genero] = [];
      }
      porGenero[p.genero]!.add(p);
    }

    List<String> generos = porGenero.keys.toList()..sort();

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 130.0, bottom: 40.0),
      clipBehavior: Clip.none, // Evita que las filas corten el hover de las tarjetas
      itemCount: generos.length,
      itemBuilder: (context, index) {
        final genero = generos[index];
        final pelisDelGenero = porGenero[genero]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    genero.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${pelisDelGenero.length})',
                    style: const TextStyle(color: Colors.greenAccent, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 400,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none, // Evita que se corten las tarjetas al hacer hover
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                itemCount: pelisDelGenero.length,
                itemBuilder: (context, pIndex) {
                  final peli = pelisDelGenero[pIndex];
                  return Container(
                    width: 220,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TarjetaPelicula(
                      pelicula: peli,
                      esFavorito: peliculasFavoritas.contains(peli.id),
                      cartKey: cartKey,
                      onToggleFavorito: () => toggleFavorito(peli.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}

class TarjetaPelicula extends StatefulWidget {
  final Pelicula pelicula;
  final bool esFavorito;
  final VoidCallback onToggleFavorito;
  final GlobalKey cartKey;

  const TarjetaPelicula({
    super.key, 
    required this.pelicula,
    required this.esFavorito,
    required this.onToggleFavorito,
    required this.cartKey,
  });

  @override
  State<TarjetaPelicula> createState() => _TarjetaPeliculaState();
}

class _TarjetaPeliculaState extends State<TarjetaPelicula> {
  bool _isHovered = false;
  bool _ocultarInfo = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          DetallePelicula.activeRouteIdNotifier.value = widget.pelicula.id;
          setState(() => _ocultarInfo = true);
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1200),
              reverseTransitionDuration: const Duration(milliseconds: 1200),
              pageBuilder: (context, animation, secondaryAnimation) => DetallePelicula(
                pelicula: widget.pelicula,
                esFavoritoInicial: widget.esFavorito,
                onToggleFavorito: widget.onToggleFavorito,
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ).then((_) {
            if (mounted) {
              Future.delayed(const Duration(milliseconds: 1200), () {
                if (mounted) {
                  setState(() => _ocultarInfo = false);
                }
              });
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: _isHovered ? (Matrix4.identity()..scale(1.08)) : Matrix4.identity(),
          transformAlignment: FractionalOffset.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isHovered
                ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 20, spreadRadius: 3)]
                : [const BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: widget.pelicula.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      widget.pelicula.urlImagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.movie_creation_outlined, size: 50, color: Colors.black38),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                widget.pelicula.titulo,
                                style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _ocultarInfo ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 800),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 180,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Colors.black.withOpacity(1.0), Colors.black.withOpacity(0.6), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 15, left: 15, right: 15,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.pelicula.titulo,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                widget.pelicula.sinopsis,
                                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10, left: 10,
                          child: GestureDetector(
                            onTap: () {
                              if (!AppState().carrito.any((p) => p.id == widget.pelicula.id)) {
                                setState(() => AppState().carrito.add(widget.pelicula));
                                animarHaciaCarrito(context, widget.cartKey, context, widget.pelicula.urlImagen);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: Icon(
                                  AppState().carrito.any((p) => p.id == widget.pelicula.id) ? Icons.check : Icons.add_shopping_cart,
                                  key: ValueKey(AppState().carrito.any((p) => p.id == widget.pelicula.id)),
                                  color: AppState().carrito.any((p) => p.id == widget.pelicula.id) ? Colors.greenAccent : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 10, right: 10,
                          child: GestureDetector(
                            onTap: widget.onToggleFavorito,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                child: Icon(
                                  widget.esFavorito ? Icons.favorite : Icons.favorite_border,
                                  key: ValueKey(widget.esFavorito),
                                  color: widget.esFavorito ? Colors.greenAccent : Colors.white,
                                  size: 20,
                                ),
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
          ),
        ),
      ),
    );
  }
}