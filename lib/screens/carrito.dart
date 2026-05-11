import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/app_state.dart';
import '../models/pelicula.dart';
import '../utils/idiomas.dart';
import '../widgets/custom_app_bar.dart';
import 'detalle_pelicula.dart';

class PantallaCarrito extends StatefulWidget {
  const PantallaCarrito({super.key});

  @override
  State<PantallaCarrito> createState() => _PantallaCarritoState();
}

class _PantallaCarritoState extends State<PantallaCarrito> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    idiomaActual.addListener(_actualizarIdioma);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.offset > 20 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 20 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  void _actualizarIdioma() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    idiomaActual.removeListener(_actualizarIdioma);
    super.dispose();
  }

  void _mostrarDialogoAnadir(BuildContext context) async {
    final String respuesta = await rootBundle.loadString('Data/peliculas.json');
    final List<dynamic> data = json.decode(respuesta);
    final todas = data.map((j) => Pelicula.fromJson(j, langCode: idiomaActual.value.name)).toList();
    final disponibles = todas.where((p) => !AppState().carrito.any((c) => c.id == p.id)).toList();
    final Set<String> seleccionadas = {};

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tr('anadir_carrito'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: disponibles.length,
                      itemBuilder: (ctx, i) {
                        final p = disponibles[i];
                        final isSelected = seleccionadas.contains(p.id);
                        return ListTile(
                          leading: Image.asset(p.urlImagen, width: 50, fit: BoxFit.cover),
                          title: Text(p.titulo, style: const TextStyle(color: Colors.white)),
                          trailing: Icon(
                            isSelected ? Icons.check_circle : Icons.circle_outlined, 
                            color: isSelected ? Colors.greenAccent : Colors.white54
                          ),
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                seleccionadas.remove(p.id);
                              } else {
                                seleccionadas.add(p.id);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
                      onPressed: () {
                        if (seleccionadas.isEmpty) return;
                        setState(() {
                          for (var id in seleccionadas) {
                            AppState().carrito.add(disponibles.firstWhere((p) => p.id == id));
                          }
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text('${tr('anadir_seleccionadas')} (${seleccionadas.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  void _comprar() {
    if (AppState().carrito.isEmpty) return;
    
    // aqui uso un dialog para confirmar la compra que tambien pedian en los requisitos
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(tr('confirmar_compra'), style: const TextStyle(color: Colors.greenAccent)),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: tr('direccion_envio'), labelStyle: const TextStyle(color: Colors.white54)),
                style: const TextStyle(color: Colors.white),
                validator: (val) => (val == null || val.isEmpty) ? tr('campo_requerido') : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: tr('telefono'), labelStyle: const TextStyle(color: Colors.white54)),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => (val == null || val.isEmpty) ? tr('campo_requerido') : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr('cancelar'), style: const TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent, foregroundColor: Colors.black),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(ctx); // Cierra el formulario
                
                // Mostrar animación de tick gigante
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctxAnim) => Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 150),
                        );
                      },
                    ),
                  )
                );

                await Future.delayed(const Duration(milliseconds: 1500));
                if (mounted) {
                  Navigator.pop(context); // Cierra el dialog de animacion
                  setState(() {
                    AppState().pedidosRealizados.add(List.from(AppState().carrito));
                    AppState().carrito.clear();
                  });
                }
              }
            },
            child: Text(tr('confirmar_pedido')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final carrito = AppState().carrito;

    return ValueListenableBuilder<String>(
      valueListenable: DetallePelicula.activeRouteIdNotifier,
      builder: (context, activeId, child) {
        return HeroMode(
          enabled: activeId == 'carrito',
          child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FloatingAppBar(
        isScrolled: _isScrolled,
        centerTitle: true,
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
                    icon: const Icon(Icons.arrow_back, color: Colors.greenAccent, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        title: SequentialFadeHero(
          tag: 'appbar_title_hero',
          child: Text(tr('mi_carrito'), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 24)),
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
            Positioned(
              right: 78,
              top: 11,
              child: Hero(
                tag: 'cart_icon_floating',
                child: Material(
                  type: MaterialType.transparency,
                  child: SizedBox(width: 48, height: 48),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // La lista ocupa todo el espacio pero tiene padding interno para los topes
          carrito.isEmpty
              ? Center(child: Text(tr('carrito_vacio'), style: const TextStyle(fontSize: 18, color: Colors.white54)))
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 120, bottom: 120, left: 50, right: 50),
                  itemCount: carrito.length,
                  itemBuilder: (ctx, i) {
                    final p = carrito[i];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Card(
                        color: Colors.white10,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Image.asset(p.urlImagen, width: 50, fit: BoxFit.cover),
                          title: Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          subtitle: Text(p.director, style: const TextStyle(color: Colors.white70)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              setState(() => AppState().carrito.removeAt(i));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
          
          // Botones inferiores flotantes
          Positioned(
            bottom: 30,
            left: 50,
            right: 50,
            child: carrito.isNotEmpty
                ? Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shadowColor: Colors.black54,
                        ),
                        onPressed: () => _mostrarDialogoAnadir(context),
                        icon: const Icon(Icons.add),
                        label: Text(tr('anadir_mas'), style: const TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.greenAccent,
                            foregroundColor: Colors.black,
                            elevation: 8,
                            shadowColor: Colors.greenAccent.withOpacity(0.5),
                          ),
                          onPressed: _comprar,
                          icon: const Icon(Icons.shopping_cart_checkout),
                          label: Text(tr('comprar_ahora'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shadowColor: Colors.greenAccent.withOpacity(0.5),
                      ),
                      onPressed: () => _mostrarDialogoAnadir(context),
                      icon: const Icon(Icons.add),
                      label: Text(tr('anadir_peliculas'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
          ),
        ],
      ),
    ),
        );
      },
    );
  }
}
