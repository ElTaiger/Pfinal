import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../utils/idiomas.dart';
import '../widgets/custom_app_bar.dart';
import 'detalle_pelicula.dart';

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
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

  @override
  Widget build(BuildContext context) {
    final user = AppState().currentUser;

    return ValueListenableBuilder<String>(
      valueListenable: DetallePelicula.activeRouteIdNotifier,
      builder: (context, activeId, child) {
        return HeroMode(
          enabled: activeId == 'perfil',
          child: Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FloatingAppBar(
        isScrolled: _isScrolled,
        centerTitle: true,
        title: SequentialFadeHero(
          tag: 'appbar_title_hero',
          child: Text(tr('mi_perfil'), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 24)),
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
                    icon: const Icon(Icons.arrow_back, color: Colors.greenAccent, size: 28),
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
              right: 60,
              top: 11,
              child: const Hero(
                tag: 'cart_icon_floating',
                child: SizedBox(width: 48, height: 48),
              ),
            ),
          ],
        ),
        actions: [
          SequentialFadeHero(
            tag: 'appbar_profile_hero',
            child: Material(
              type: MaterialType.transparency,
              child: IconButton(
                icon: const Icon(Icons.person, color: Colors.greenAccent, size: 28),
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.only(left: 50.0, right: 50.0, top: 120.0, bottom: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.greenAccent.withOpacity(0.2), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Center(
                    // aqui pongo la imagen cargada desde la red para cumplir el requisito
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.greenAccent,
                      backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://picsum.photos/200'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      user?.nombre ?? 'Usuario',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      user?.biografia ?? '',
                      style: const TextStyle(fontSize: 16, color: Colors.white70, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(tr('datos_cuenta'), style: const TextStyle(fontSize: 22, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.white70),
              title: const Text('Email', style: TextStyle(color: Colors.white70)),
              subtitle: Text(user?.email ?? 'usuario@ejemplo.com', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 30),
            Text(tr('historial_pedidos'), style: const TextStyle(fontSize: 22, color: Colors.greenAccent, fontWeight: FontWeight.bold)),
            const Divider(color: Colors.white24),
            if (AppState().pedidosRealizados.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Aún no has realizado ningún pedido.', style: TextStyle(color: Colors.white70)),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: AppState().pedidosRealizados.length,
                itemBuilder: (context, index) {
                  final pedido = AppState().pedidosRealizados[index];
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ExpansionTile(
                      title: Text('Pedido #${index + 1} - ${pedido.length} artículos', style: const TextStyle(color: Colors.white)),
                      children: pedido.map((peli) => ListTile(
                        leading: Image.asset(peli.urlImagen, width: 40, fit: BoxFit.cover),
                        title: Text(peli.titulo),
                        subtitle: Text(peli.director),
                      )).toList(),
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                icon: const Icon(Icons.logout),
                label: Text(tr('cerrar_sesion'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
        );
      },
    );
  }
}
