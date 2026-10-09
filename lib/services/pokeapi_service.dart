import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/personaje.dart';

/// Error cuando PokéAPI responde 404 (el personaje no existe).
class PersonajeNoEncontrado implements Exception {
  const PersonajeNoEncontrado(this.nombre);

  final String nombre;

  @override
  String toString() => 'No se encontró el personaje "$nombre".';
}

/// Error de red o respuesta inesperada del servidor.
class PokeApiException implements Exception {
  const PokeApiException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Hace las peticiones HTTP a PokéAPI (https://pokeapi.co).
///
/// Recibe un [http.Client] para poder usar uno falso en las pruebas.
class PokeApiService {
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const Duration _tiempoLimite = Duration(seconds: 15);

  final http.Client _client;

  /// Personajes que aparecen en la película "Pokémon: Detective Pikachu".
  static const List<String> personajesDetectivePikachu = [
    'pikachu',
    'psyduck',
    'charizard',
    'mewtwo',
    'bulbasaur',
    'jigglypuff',
    'mr-mime',
    'greninja',
  ];

  /// GET /pokemon/{nombre}
  Future<Personaje> obtenerPersonaje(String nombre) async {
    final limpio = nombre.trim().toLowerCase().replaceAll(' ', '-');
    final json = await _get('/pokemon/$limpio', nombre: limpio);
    return Personaje.fromJson(json);
  }

  /// Hace varias peticiones en paralelo y espera todas las respuestas.
  Future<List<Personaje>> obtenerPersonajes(List<String> nombres) {
    return Future.wait(nombres.map(obtenerPersonaje));
  }

  /// GET /pokemon-species/{id}
  Future<Especie> obtenerEspecie(int id) async {
    final json = await _get('/pokemon-species/$id', nombre: '$id');
    return Especie.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(
    String ruta, {
    required String nombre,
  }) async {
    final uri = Uri.parse('$baseUrl$ruta');
    final http.Response respuesta;
    try {
      respuesta = await _client.get(uri).timeout(_tiempoLimite);
    } on Exception catch (e) {
      debugPrint('[HTTP] GET $uri -> error de conexión: $e');
      throw const PokeApiException(
        'No hay conexión a internet. Revisa tu red e inténtalo de nuevo.',
      );
    }

    debugPrint('[HTTP] GET $uri -> ${respuesta.statusCode}');

    if (respuesta.statusCode == 200) {
      return jsonDecode(respuesta.body) as Map<String, dynamic>;
    }
    if (respuesta.statusCode == 404) {
      throw PersonajeNoEncontrado(nombre);
    }
    throw PokeApiException(
      'El servidor respondió con el código ${respuesta.statusCode}.',
    );
  }
}
