import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:ldsw_firebase/main.dart';
import 'package:ldsw_firebase/screens/personajes_screen.dart';
import 'package:ldsw_firebase/services/pokeapi_service.dart';

/// JSON con la misma forma que la respuesta real de GET /pokemon/{nombre}.
Map<String, dynamic> pokemonJson(String nombre, int id) => {
  'id': id,
  'name': nombre,
  'height': 4,
  'weight': 60,
  'types': [
    {
      'slot': 1,
      'type': {'name': 'electric'},
    },
  ],
  'sprites': {
    'front_default': null,
    'other': {
      'official-artwork': {'front_default': 'https://img.test/$id.png'},
    },
  },
  'stats': [
    {
      'base_stat': 35,
      'stat': {'name': 'hp'},
    },
    {
      'base_stat': 55,
      'stat': {'name': 'attack'},
    },
  ],
  'abilities': [
    {
      'ability': {'name': 'static'},
    },
  ],
};

final especieJson = {
  'genera': [
    {
      'genus': 'Mouse Pokémon',
      'language': {'name': 'en'},
    },
    {
      'genus': 'Pokémon Ratón',
      'language': {'name': 'es'},
    },
  ],
  'flavor_text_entries': [
    {
      'flavor_text': 'Almacena\nelectricidad.',
      'language': {'name': 'es'},
    },
  ],
};

/// Cliente HTTP falso: responde como PokéAPI y guarda las URL pedidas.
MockClient clienteFalso(List<Uri> peticiones) {
  return MockClient((request) async {
    peticiones.add(request.url);
    final partes = request.url.pathSegments;
    final recurso = partes[partes.length - 2];
    final valor = partes.last;

    if (recurso == 'pokemon-species') {
      return http.Response(
        jsonEncode(especieJson),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    }
    if (valor == 'noexiste') return http.Response('Not Found', 404);
    if (valor == 'error') return http.Response('Server error', 500);

    final id = PokeApiService.personajesDetectivePikachu.indexOf(valor) + 1;
    return http.Response(
      jsonEncode(pokemonJson(valor, id == 0 ? 133 : id)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

void main() {
  group('PokeApiService', () {
    test('GET /pokemon/{nombre} convierte el JSON en un Personaje', () async {
      final peticiones = <Uri>[];
      final servicio = PokeApiService(client: clienteFalso(peticiones));

      final p = await servicio.obtenerPersonaje(' Pikachu ');

      expect(
        peticiones.single.toString(),
        'https://pokeapi.co/api/v2/pokemon/pikachu',
      );
      expect(p.id, 1);
      expect(p.nombreVisible, 'Pikachu');
      expect(p.numero, '#001');
      expect(p.alturaM, 0.4);
      expect(p.pesoKg, 6.0);
      expect(p.tipos, ['electric']);
      expect(p.imagenUrl, 'https://img.test/1.png');
      expect(p.estadisticas, {'hp': 35, 'attack': 55});
      expect(p.habilidades, ['static']);
    });

    test('GET /pokemon-species/{id} toma los textos en español', () async {
      final servicio = PokeApiService(client: clienteFalso([]));

      final especie = await servicio.obtenerEspecie(25);

      expect(especie.categoria, 'Pokémon Ratón');
      expect(especie.descripcion, 'Almacena electricidad.');
    });

    test('Respuesta 404 lanza PersonajeNoEncontrado', () {
      final servicio = PokeApiService(client: clienteFalso([]));
      expect(
        servicio.obtenerPersonaje('noexiste'),
        throwsA(isA<PersonajeNoEncontrado>()),
      );
    });

    test('Respuesta 500 lanza PokeApiException', () {
      final servicio = PokeApiService(client: clienteFalso([]));
      expect(
        servicio.obtenerPersonaje('error'),
        throwsA(isA<PokeApiException>()),
      );
    });

    test('Sin conexión lanza PokeApiException con mensaje claro', () {
      final sinRed = MockClient(
        (_) async => throw http.ClientException('sin red'),
      );
      final servicio = PokeApiService(client: sinRed);
      expect(
        servicio.obtenerPersonaje('pikachu'),
        throwsA(
          isA<PokeApiException>().having(
            (e) => e.mensaje,
            'mensaje',
            contains('No hay conexión'),
          ),
        ),
      );
    });
  });

  group('Pantallas', () {
    testWidgets('Inicio muestra Hello World y lleva al catálogo', (
      tester,
    ) async {
      await tester.pumpWidget(const CineCatalogoApp());

      expect(find.text('Hello World'), findsOneWidget);
      await tester.tap(find.text('Ingresar'));
      await tester.pumpAndSettle();

      expect(find.text('Películas destacadas'), findsOneWidget);
      expect(find.text('Pokémon: Detective Pikachu'), findsOneWidget);
    });

    testWidgets('Personajes: carga, muestra la lista y abre el detalle', (
      tester,
    ) async {
      final peticiones = <Uri>[];
      final servicio = PokeApiService(client: clienteFalso(peticiones));
      await tester.pumpWidget(
        MaterialApp(home: PersonajesScreen(servicio: servicio)),
      );

      // Mientras llega la respuesta se muestra el indicador de carga.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(peticiones, hasLength(8));
      expect(find.text('Pikachu'), findsOneWidget);
      expect(find.text('Psyduck'), findsOneWidget);

      await tester.tap(
        find.ancestor(of: find.text('Pikachu'), matching: find.byType(InkWell)),
      );
      await tester.pumpAndSettle();

      expect(peticiones.last.path, '/api/v2/pokemon-species/1');
      expect(find.text('Pokémon Ratón'), findsOneWidget);
      expect(find.text('Almacena electricidad.'), findsOneWidget);
      expect(find.text('Estadísticas base'), findsOneWidget);
    });

    testWidgets('Buscar un personaje que existe y uno que no', (tester) async {
      final servicio = PokeApiService(client: clienteFalso([]));
      await tester.pumpWidget(
        MaterialApp(home: PersonajesScreen(servicio: servicio)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'eevee');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Eevee'), findsOneWidget);
      expect(find.text('Pikachu'), findsNothing);

      await tester.enterText(find.byType(TextField), 'noexiste');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(
        find.text('No se encontró el personaje "noexiste".'),
        findsOneWidget,
      );
      expect(find.text('Reintentar'), findsOneWidget);

      await tester.tap(find.text('Ver personajes de la película'));
      await tester.pumpAndSettle();
      expect(find.text('Pikachu'), findsOneWidget);
    });

    testWidgets('No hay desbordes en una pantalla pequeña', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final servicio = PokeApiService(client: clienteFalso([]));
      await tester.pumpWidget(
        MaterialApp(home: PersonajesScreen(servicio: servicio)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(
        find.ancestor(of: find.text('Pikachu'), matching: find.byType(InkWell)),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
