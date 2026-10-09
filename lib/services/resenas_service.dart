import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/resena.dart';

/// Se lanza cuando Firebase no confirma la reseña porque no hay internet.
/// Firestore la deja guardada en el teléfono y la envía al volver la red.
class ResenaPendiente implements Exception {
  const ResenaPendiente();
}

/// Lee y agrega reseñas en Cloud Firestore.
class ResenasService {
  /// En las pruebas se pasa una base de datos falsa; en la app se usa la real.
  ResenasService({this.firestore});

  final FirebaseFirestore? firestore;

  /// Tiempo máximo para esperar la confirmación del servidor.
  static const espera = Duration(seconds: 10);

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  /// Colección de reseñas de una película: peliculas/{peliculaId}/resenas.
  CollectionReference<Map<String, dynamic>> _resenas(String peliculaId) =>
      _db.collection('peliculas').doc(peliculaId).collection('resenas');

  /// Reseñas de la película en tiempo real, de la más nueva a la más antigua.
  Stream<List<Resena>> escucharResenas(String peliculaId) {
    return _resenas(peliculaId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((consulta) => consulta.docs.map(Resena.fromDocument).toList());
  }

  /// Agrega una reseña a Firestore y devuelve el id del documento creado.
  ///
  /// Lanza [ResenaPendiente] si el servidor no responde a tiempo (sin internet).
  Future<String> agregarResena({
    required String peliculaId,
    required String autor,
    required int calificacion,
    required String comentario,
  }) async {
    final doc = _resenas(peliculaId).doc();
    final escritura = doc.set(
      Resena.nueva(
        autor: autor,
        calificacion: calificacion,
        comentario: comentario,
      ),
    );
    try {
      await escritura.timeout(espera);
    } on TimeoutException {
      debugPrint('[Firestore] ${doc.path} -> pendiente (sin conexión)');
      throw const ResenaPendiente();
    }
    debugPrint('[Firestore] add ${doc.path} -> guardada');
    return doc.id;
  }
}

/// Promedio de estrellas de una lista de reseñas (0 si no hay ninguna).
double promedioCalificacion(List<Resena> resenas) {
  if (resenas.isEmpty) return 0;
  final suma = resenas.fold<int>(0, (total, r) => total + r.calificacion);
  return suma / resenas.length;
}
