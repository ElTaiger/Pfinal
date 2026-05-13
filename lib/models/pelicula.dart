class Pelicula {
  final String id;
  final String titulo;
  final String director;
  final String sinopsis;
  final String urlImagen;
  final String anio;
  final String duracion;
  final String valoracion;
  final String reparto;

  final String genero;

  Pelicula({
    required this.id,
    required this.titulo,
    required this.director,
    required this.sinopsis,
    required this.urlImagen,
    required this.anio,
    required this.duracion,
    required this.valoracion,
    required this.reparto,
    required this.genero,
  });

  factory Pelicula.fromJson(Map<String, dynamic> json, {String langCode = 'es'}) {
    String getLocalized(dynamic field) {
      if (field is Map) {
        return field[langCode] ?? field['es'] ?? '';
      }
      return field?.toString() ?? '';
    }

    return Pelicula(
      id: json['id']?.toString() ?? '',
      titulo: getLocalized(json['titulo']),
      director: json['director'] ?? '',
      sinopsis: getLocalized(json['sinopsis']),
      urlImagen: json['urlImagen'] ?? '',
      anio: json['anio']?.toString() ?? '',
      duracion: json['duracion'] ?? 'Desconocida',
      valoracion: json['valoracion'] ?? 'N/A',
      reparto: json['reparto'] is List 
          ? (json['reparto'] as List).join(', ') 
          : (json['reparto']?.toString() ?? 'Desconocido'),
      genero: json['genero'] ?? 'General',
    );
  }
}