/// Personaje (Pokémon) obtenido de PokéAPI: GET /pokemon/{nombre}.
class Personaje {
  const Personaje({
    required this.id,
    required this.nombre,
    required this.alturaM,
    required this.pesoKg,
    required this.tipos,
    required this.imagenUrl,
    required this.estadisticas,
    required this.habilidades,
  });

  final int id;
  final String nombre;
  final double alturaM;
  final double pesoKg;
  final List<String> tipos;
  final String? imagenUrl;

  /// Estadísticas base, por ejemplo {'hp': 35, 'attack': 55}.
  final Map<String, int> estadisticas;
  final List<String> habilidades;

  /// Convierte el JSON de la respuesta HTTP en un objeto Dart.
  factory Personaje.fromJson(Map<String, dynamic> json) {
    final sprites = json['sprites'] as Map<String, dynamic>;
    final artwork =
        (sprites['other'] as Map<String, dynamic>?)?['official-artwork']
            as Map<String, dynamic>?;

    return Personaje(
      id: json['id'] as int,
      nombre: json['name'] as String,
      // PokéAPI entrega la altura en decímetros y el peso en hectogramos.
      alturaM: (json['height'] as int) / 10,
      pesoKg: (json['weight'] as int) / 10,
      tipos: [
        for (final t in json['types'] as List)
          (t['type'] as Map<String, dynamic>)['name'] as String,
      ],
      imagenUrl:
          (artwork?['front_default'] ?? sprites['front_default']) as String?,
      estadisticas: {
        for (final s in json['stats'] as List)
          (s['stat'] as Map<String, dynamic>)['name'] as String:
              s['base_stat'] as int,
      },
      habilidades: [
        for (final h in json['abilities'] as List)
          (h['ability'] as Map<String, dynamic>)['name'] as String,
      ],
    );
  }

  /// Nombre para mostrar: "mr-mime" -> "Mr Mime".
  String get nombreVisible => nombre
      .split('-')
      .map((p) => p.isEmpty ? p : p[0].toUpperCase() + p.substring(1))
      .join(' ');

  /// Número con formato de Pokédex: 25 -> "#025".
  String get numero => '#${id.toString().padLeft(3, '0')}';
}

/// Datos de la especie: GET /pokemon-species/{id}.
class Especie {
  const Especie({required this.categoria, required this.descripcion});

  final String categoria;
  final String descripcion;

  /// Toma los textos en español; si no hay, usa los de inglés.
  factory Especie.fromJson(Map<String, dynamic> json) {
    String? buscar(List lista, String campo, String idioma) {
      for (final e in lista) {
        if ((e['language'] as Map<String, dynamic>)['name'] == idioma) {
          return e[campo] as String;
        }
      }
      return null;
    }

    final generos = json['genera'] as List;
    final textos = json['flavor_text_entries'] as List;
    final descripcion =
        buscar(textos, 'flavor_text', 'es') ??
        buscar(textos, 'flavor_text', 'en') ??
        'Sin descripción disponible.';

    return Especie(
      categoria:
          buscar(generos, 'genus', 'es') ??
          buscar(generos, 'genus', 'en') ??
          '',
      // Los textos traen saltos de línea y caracteres de control.
      descripcion: descripcion.replaceAll(RegExp(r'[\n\f\r]+'), ' '),
    );
  }
}
