import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'pantalla_principal.dart';

// pantalla de inicio de sesion con un diseno minimalista y centrado
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final _formKey = GlobalKey<FormState>();
  String _usuario = '';
  String _password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            // limitamos el ancho a 400 para que no se estire en el navegador
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_filter_rounded, size: 80, color: Colors.tealAccent),
                  const SizedBox(height: 20),
                  const Text(
                    'Entrar al Catálogo', 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Falta el usuario';
                      }
                      if (!value.contains('@')) {
                        return 'Debe ser un correo electrónico válido (con @)';
                      }
                      return null;
                    },
                    onSaved: (value) => _usuario = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.black26,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Falta la contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                    onSaved: (value) => _password = value!,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // validamos y pasamos a la pantalla del grid
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          
                          // Guardamos el usuario en el estado global
                          AppState().currentUser = UserProfile(
                            email: _usuario,
                            password: _password,
                            nombre: 'Usuario de Prueba',
                            biografia: 'Amante del cine de ciencia ficción y los clásicos de culto.',
                            avatarUrl: 'https://picsum.photos/seed/${DateTime.now().millisecondsSinceEpoch}/200',
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
                          );
                        }
                      },
                      child: const Text('ACCEDER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}