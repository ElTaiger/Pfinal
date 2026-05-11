import 'pelicula.dart';

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

class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  UserProfile? currentUser;
  List<Pelicula> carrito = [];
  List<List<Pelicula>> pedidosRealizados = [];
}
