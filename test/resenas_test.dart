import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ldsw_firebase/models/pelicula.dart';
import 'package:ldsw_firebase/models/resena.dart';
import 'package:ldsw_firebase/screens/pelicula_detalle_screen.dart';
import 'package:ldsw_firebase/services/resenas_service.dart';

final dune = peliculasDestacadas.first;

/// Servicio que simula no tener internet: Firebase nunca confirma.
class ServicioSinRed extends ResenasService {
  ServicioSinRed(FirebaseFirestore firestore) : super(firestore: firestore);

  @override
  Future<String> agregarResena({
    required String peliculaId,
    required String autor,
    required int calificacion,
    required String comentario,
  }) async => throw const ResenaPendiente();
}

Future<void> abrirFicha(WidgetTester tester, ResenasService servicio) async {
  await tester.pumpWidget(
    MaterialApp(
      home: PeliculaDetalleScreen(pelicula: dune, servicio: servicio),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> llenarFormulario(WidgetTester tester) async {
  await tester.tap(find.text('Escribir reseña'));
  await tester.pumpAndSettle();
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Tu nombre'),
    'Tatiana',
  );
  await tester.tap(find.byTooltip('4 estrellas'));
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Tu reseña'),
    'Visualmente impresionante.',
  );
  await tester.pump();
}

void main() {
  group('ResenasService (Firestore simulado)', () {
    test('agregarResena crea el documento en peliculas/{id}/resenas', () async {
      final db = FakeFirebaseFirestore();
      final servicio = ResenasService(firestore: db);

      final id = await servicio.agregarResena(
        peliculaId: 'dune-parte-dos',
        autor: '  Tatiana ',
        calificacion: 5,
        comentario: ' Excelente ',
      );

      final doc = await db
          .collection('peliculas')
          .doc('dune-parte-dos')
          .collection('resenas')
          .doc(id)
          .get();
      expect(doc.exists, isTrue);
      expect(doc['autor'], 'Tatiana');
      expect(doc['calificacion'], 5);
      expect(doc['comentario'], 'Excelente');
      expect(doc['fecha'], isA<Timestamp>());
    });

    test(
      'escucharResenas devuelve la más nueva primero y solo de esa película',
      () async {
        final db = FakeFirebaseFirestore();
        final resenas = db
            .collection('peliculas')
            .doc('oppenheimer')
            .collection('resenas');
        await resenas.add({
          'autor': 'Ana',
          'calificacion': 3,
          'comentario': 'Larga',
          'fecha': Timestamp.fromDate(DateTime(2026, 10, 1)),
        });
        await resenas.add({
          'autor': 'Luis',
          'calificacion': 5,
          'comentario': 'Obra maestra',
          'fecha': Timestamp.fromDate(DateTime(2026, 10, 5)),
        });
        await db
            .collection('peliculas')
            .doc('dune-parte-dos')
            .collection('resenas')
            .add({
              'autor': 'Otra',
              'calificacion': 1,
              'comentario': 'x',
              'fecha': Timestamp.now(),
            });

        final lista = await ResenasService(firestore: db)
            .escucharResenas('oppenheimer')
            .first;

        expect(lista.map((r) => r.autor), ['Luis', 'Ana']);
        expect(lista.first.fecha, DateTime(2026, 10, 5));
        expect(promedioCalificacion(lista), 4.0);
      },
    );

    test('promedioCalificacion de una lista vacía es 0', () {
      expect(promedioCalificacion(const <Resena>[]), 0);
    });
  });

  group('Pantallas de reseñas', () {
    testWidgets('Sin reseñas muestra un mensaje para invitar a opinar', (
      tester,
    ) async {
      await abrirFicha(
        tester,
        ResenasService(firestore: FakeFirebaseFirestore()),
      );

      expect(find.text('Dune: Parte Dos'), findsWidgets);
      expect(
        find.text('Aún no hay reseñas.\n¡Sé la primera persona en opinar!'),
        findsOneWidget,
      );
    });

    testWidgets('El formulario no guarda si faltan datos', (tester) async {
      final db = FakeFirebaseFirestore();
      await abrirFicha(tester, ResenasService(firestore: db));

      await tester.tap(find.text('Escribir reseña'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar en Firebase'));
      await tester.pumpAndSettle();

      expect(find.text('Escribe tu nombre'), findsOneWidget);
      expect(find.text('Elige de 1 a 5 estrellas'), findsOneWidget);
      expect(find.text('Escribe tu opinión'), findsOneWidget);
      final guardadas = await db.collectionGroup('resenas').get();
      expect(guardadas.docs, isEmpty);
    });

    testWidgets('Agregar una reseña la guarda y aparece en la lista', (
      tester,
    ) async {
      final db = FakeFirebaseFirestore();
      await abrirFicha(tester, ResenasService(firestore: db));

      await llenarFormulario(tester);
      await tester.tap(find.text('Guardar en Firebase'));
      await tester.pumpAndSettle();

      // De vuelta en la ficha: mensaje de confirmación y la reseña en la lista.
      expect(find.text('¡Reseña guardada en Firebase!'), findsOneWidget);
      expect(find.text('Tatiana'), findsOneWidget);
      expect(find.text('Visualmente impresionante.'), findsOneWidget);
      expect(find.text('1 reseña'), findsOneWidget);
      expect(find.text('4.0'), findsOneWidget);

      final guardadas = await db
          .collection('peliculas')
          .doc('dune-parte-dos')
          .collection('resenas')
          .get();
      expect(guardadas.docs.single['calificacion'], 4);
    });

    testWidgets('Sin internet avisa que la reseña se enviará después', (
      tester,
    ) async {
      await abrirFicha(tester, ServicioSinRed(FakeFirebaseFirestore()));

      await llenarFormulario(tester);
      await tester.tap(find.text('Guardar en Firebase'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Sin conexión: la reseña se enviará a Firebase '
          'cuando vuelva internet.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('No hay desbordes en una pantalla pequeña', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final db = FakeFirebaseFirestore();
      await db
          .collection('peliculas')
          .doc('dune-parte-dos')
          .collection('resenas')
          .add({
            'autor': 'Persona con un nombre bastante largo para probar',
            'calificacion': 5,
            'comentario': 'Comentario ' * 30,
            'fecha': Timestamp.now(),
          });
      await abrirFicha(tester, ResenasService(firestore: db));
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Escribir reseña'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
