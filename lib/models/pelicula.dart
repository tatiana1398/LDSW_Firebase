import 'package:flutter/material.dart';

/// Datos de una película del catálogo.
class Pelicula {
  const Pelicula({
    required this.id,
    required this.titulo,
    required this.anio,
    required this.genero,
    required this.calificacion,
    required this.color,
  });

  /// Identificador del documento de la película en Firestore.
  final String id;
  final String titulo;
  final int anio;
  final String genero;
  final double calificacion;

  /// Color del póster de referencia (mientras no hay imágenes reales).
  final Color color;
}

/// Películas de ejemplo para mostrar en el catálogo.
const List<Pelicula> peliculasDestacadas = [
  Pelicula(
    id: 'dune-parte-dos',
    titulo: 'Dune: Parte Dos',
    anio: 2024,
    genero: 'Ciencia ficción',
    calificacion: 4.6,
    color: Color(0xFFB7791F),
  ),
  Pelicula(
    id: 'oppenheimer',
    titulo: 'Oppenheimer',
    anio: 2023,
    genero: 'Drama',
    calificacion: 4.5,
    color: Color(0xFF2D3748),
  ),
  Pelicula(
    id: 'intensamente-2',
    titulo: 'Intensamente 2',
    anio: 2024,
    genero: 'Animación',
    calificacion: 4.3,
    color: Color(0xFFC0399A),
  ),
  Pelicula(
    id: 'top-gun-maverick',
    titulo: 'Top Gun: Maverick',
    anio: 2022,
    genero: 'Acción',
    calificacion: 4.4,
    color: Color(0xFF14477E),
  ),
];

const List<String> generos = ['Todos', 'Acción', 'Drama', 'Comedia'];
