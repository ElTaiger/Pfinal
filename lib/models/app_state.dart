import 'dart:convert';
import 'package:flutter/services.dart';

import 'pelicula.dart';
import '../utils/idiomas.dart';

class UserProfile {
  String email;
  String password;
  String nombre;
  String biografia;
  String avatarUrl;

  UserProfile({
    required this.email,
    required this.password,
    required this.nombre,
    required this.biografia,
    required this.avatarUrl,
  });
}

class Pedido {
  final List<Pelicula> peliculas;
  final DateTime fecha;

  Pedido({required this.peliculas, required this.fecha});
}

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  UserProfile? currentUser;
  List<Pelicula> carrito = [];
  List<Pedido> pedidosRealizados = [];
  Map<String, double> valoracionesUsuario = {};

  Future<Map<String, Pelicula>> _peliculasPorIdiomaActual() async {
    final respuesta = await rootBundle.loadString('Data/peliculas.json');
    final data = json.decode(respuesta) as List;
    final peliculas = data
        .map((j) => Pelicula.fromJson(j, langCode: idiomaActual.value.name))
        .toList();

    return {for (var p in peliculas) p.id: p};
  }

  Future<void> actualizarCarritoIdioma() async {
    if (carrito.isEmpty) return;

    // aquí guardo los ids para no perder el orden del carrito
    final idsCarrito = carrito.map((p) => p.id).toList();
    final peliculasPorId = await _peliculasPorIdiomaActual();

    // ahora para cada id busco la peli con el idioma que esta activo
    carrito = idsCarrito
        .where((id) => peliculasPorId.containsKey(id))
        .map((id) => peliculasPorId[id]!)
        .toList();
  }

  Future<void> actualizarPedidosIdioma() async {
    if (pedidosRealizados.isEmpty) return;

    final peliculasPorId = await _peliculasPorIdiomaActual();

    // aquí reconstruyo cada pedido para que el historial cambie de idioma
    pedidosRealizados = pedidosRealizados.map((pedido) {
      final peliculasTraducidas = pedido.peliculas
          .map((p) => peliculasPorId[p.id] ?? p)
          .toList();

      return Pedido(peliculas: peliculasTraducidas, fecha: pedido.fecha);
    }).toList();
  }
}
