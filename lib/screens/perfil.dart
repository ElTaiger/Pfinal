import 'package:flutter/material.dart';
import '../models/app_state.dart';
import '../utils/idiomas.dart';
import '../widgets/custom_app_bar.dart';
import 'detalle_pelicula.dart';

// Devuelve true si dos DateTime corresponden al mismo día
bool _mismodia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class PantallaPerfil extends StatefulWidget {
  const PantallaPerfil({super.key});

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  DateTime? _fechaFiltro;

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
                  Center(
                    
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.greenAccent,
                      backgroundImage: NetworkImage(user?.avatarUrl ?? 'https://picsum.photos/200'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      tr('nombre_usuario'),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      tr('bio_usuario'),
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
            if (AppState().pedidosRealizados.isNotEmpty) _buildFiltroFecha(),
            _buildListaPedidos(),
            const SizedBox(height: 30),
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

  Widget _buildFiltroFecha() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Text(tr('filtrar_por_fecha'),
              style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final seleccion = await showDatePicker(
                  context: context,
                  initialDate: _fechaFiltro ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  locale: Locale(idiomaActual.value.name),
                  builder: (context, child) => Theme(
                    data: ThemeData.dark().copyWith(
                      colorScheme: const ColorScheme.dark(
                        primary: Colors.greenAccent,
                        onPrimary: Colors.black,
                        surface: Color(0xFF1E1E1E),
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (seleccion != null) {
                  setState(() => _fechaFiltro = seleccion);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white24),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _fechaFiltro != null
                            ? formatearFecha(_fechaFiltro!)
                            : tr('todas_las_fechas'),
                        style: TextStyle(
                          color: _fechaFiltro != null ? Colors.white : Colors.white54,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (_fechaFiltro != null)
                      GestureDetector(
                        onTap: () => setState(() => _fechaFiltro = null),
                        child: const Icon(Icons.close, color: Colors.white54, size: 18),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaPedidos() {
    final todos = AppState().pedidosRealizados;

    if (todos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(tr('sin_pedidos'),
            style: const TextStyle(color: Colors.white70)),
      );
    }

    // Filtra por el día seleccionado si hay uno
    final filtrados = _fechaFiltro == null
        ? todos
        : todos.where((p) => _mismodia(p.fecha, _fechaFiltro!)).toList();

    if (filtrados.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(tr('sin_pedidos_fecha'),
            style: const TextStyle(color: Colors.white70)),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtrados.length,
      itemBuilder: (context, index) {
        final pedido = filtrados[index];
        return Card(
          color: Colors.white10,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(
              '${tr('pedido')} #${todos.indexOf(pedido) + 1}  ·  ${pedido.peliculas.length} ${tr('articulos')}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              formatearFecha(pedido.fecha),
              style: const TextStyle(color: Colors.greenAccent, fontSize: 13),
            ),
            children: pedido.peliculas
                .map((peli) => ListTile(
                      leading:
                          Image.asset(peli.urlImagen, width: 40, fit: BoxFit.cover),
                      title: Text(peli.titulo),
                      subtitle: Text(peli.director),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
