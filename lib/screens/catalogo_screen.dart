import 'package:flutter/material.dart';

import '../main.dart';
import '../models/pelicula.dart';
import 'pelicula_detalle_screen.dart';
import 'personajes_screen.dart';

/// Pantalla 4 del wireframe: catálogo de películas.
///
/// Está construida con los widgets básicos de Flutter:
/// - Text: todos los textos (títulos, géneros, año, calificación).
/// - Row: elementos en horizontal (filtros, fila de tarjetas, calificación).
/// - Column: elementos en vertical (cuerpo de la pantalla y cada tarjeta).
/// - Stack: elementos encimados (banner y póster con la etiqueta del año).
/// - Container: cajas con tamaño, color, bordes y márgenes.
class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CineCatálogo'),
        backgroundColor: azulCine,
        foregroundColor: Colors.white,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: SizedBox(
                width: 110,
                child: Text(
                  'Hola, usuario',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Column: acomoda las secciones de la pantalla de arriba hacia abajo.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BannerBienvenida(),
            const SizedBox(height: 20),
            const FiltrosGenero(),
            const SizedBox(height: 20),
            Text(
              'Películas destacadas',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: azulCine),
            ),
            const SizedBox(height: 2),
            Text(
              'Toca una película para ver y escribir reseñas',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 12),
            // Row: dos tarjetas por fila.
            Row(
              children: [
                Expanded(
                  child: TarjetaPelicula(pelicula: peliculasDestacadas[0]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TarjetaPelicula(pelicula: peliculasDestacadas[1]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TarjetaPelicula(pelicula: peliculasDestacadas[2]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TarjetaPelicula(pelicula: peliculasDestacadas[3]),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Personajes de película',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: azulCine),
            ),
            const SizedBox(height: 12),
            const TarjetaPersonajesPelicula(),
          ],
        ),
      ),
    );
  }
}

/// Banner superior: un Stack con un ícono grande de fondo y el texto encima.
class BannerBienvenida extends StatelessWidget {
  const BannerBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    // Container: caja con altura mínima, degradado y esquinas redondeadas.
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [azulCine, rosaCine],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      // Stack: el ícono queda detrás y los textos se dibujan encima.
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.movie_filter,
              size: 160,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Descubre y explora nuestro catálogo de películas',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Filtros por género: una Row de Containers con forma de píldora.
class FiltrosGenero extends StatelessWidget {
  const FiltrosGenero({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final genero in generos)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: genero == 'Todos' ? azulCine : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: azulCine),
              ),
              child: Text(
                genero,
                style: TextStyle(
                  color: genero == 'Todos' ? Colors.white : azulCine,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Tarjeta de una película: Column con el póster, el título y la calificación.
/// Al tocarla abre la ficha con las reseñas guardadas en Firebase.
class TarjetaPelicula extends StatelessWidget {
  const TarjetaPelicula({super.key, required this.pelicula});

  final Pelicula pelicula;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PeliculaDetalleScreen(pelicula: pelicula),
        ),
      ),
      child: _contenido(),
    );
  }

  Widget _contenido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stack: el póster de fondo y la etiqueta del año en la esquina.
        Stack(
          children: [
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: pelicula.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.movie, size: 56, color: Colors.white70),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pelicula.anio}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          pelicula.titulo,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          pelicula.genero,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        // Row: ícono de estrella junto a la calificación.
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              pelicula.calificacion.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

/// Acceso a los personajes de "Pokémon: Detective Pikachu", que se
/// obtienen con peticiones HTTP a PokéAPI.
class TarjetaPersonajesPelicula extends StatelessWidget {
  const TarjetaPersonajesPelicula({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFE0B21B),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const PersonajesScreen())),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.catching_pokemon, size: 48, color: Colors.white),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pokémon: Detective Pikachu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '2019 · Ver personajes (PokéAPI)',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
