import 'package:cloud_firestore/cloud_firestore.dart';

/// Reseña que una persona escribe sobre una película.
///
/// Se guarda en Cloud Firestore en `peliculas/{peliculaId}/resenas/{id}`.
class Resena {
  const Resena({
    required this.id,
    required this.autor,
    required this.calificacion,
    required this.comentario,
    this.fecha,
  });

  final String id;
  final String autor;

  /// Estrellas de 1 a 5.
  final int calificacion;
  final String comentario;

  /// Fecha en que la guardó el servidor. Es null solo un instante,
  /// mientras la reseña recién escrita llega a Firebase.
  final DateTime? fecha;

  /// Convierte un documento de Firestore en una Resena.
  factory Resena.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final datos = doc.data() ?? const {};
    final fecha = datos['fecha'];
    return Resena(
      id: doc.id,
      autor: datos['autor'] as String? ?? 'Anónimo',
      calificacion: (datos['calificacion'] as num?)?.toInt() ?? 0,
      comentario: datos['comentario'] as String? ?? '',
      fecha: fecha is Timestamp ? fecha.toDate() : null,
    );
  }

  /// Datos que se envían a Firestore al agregar una reseña nueva.
  /// La fecha la pone el servidor para que no dependa del reloj del teléfono.
  static Map<String, dynamic> nueva({
    required String autor,
    required int calificacion,
    required String comentario,
  }) {
    return {
      'autor': autor.trim(),
      'calificacion': calificacion,
      'comentario': comentario.trim(),
      'fecha': FieldValue.serverTimestamp(),
    };
  }
}
