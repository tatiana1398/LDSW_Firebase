import 'package:flutter/material.dart';

import '../main.dart';
import '../models/pelicula.dart';
import '../services/resenas_service.dart';
import '../widgets/estrellas.dart';

/// Formulario para agregar una reseña a Cloud Firestore.
///
/// Al guardar, regresa a la ficha de la película con el mensaje que se
/// debe mostrar al usuario.
class NuevaResenaScreen extends StatefulWidget {
  const NuevaResenaScreen({
    super.key,
    required this.pelicula,
    required this.servicio,
  });

  final Pelicula pelicula;
  final ResenasService servicio;

  @override
  State<NuevaResenaScreen> createState() => _NuevaResenaScreenState();
}

class _NuevaResenaScreenState extends State<NuevaResenaScreen> {
  final _formulario = GlobalKey<FormState>();
  final _autor = TextEditingController();
  final _comentario = TextEditingController();
  int _calificacion = 0;
  bool _guardando = false;

  /// Después del primer intento, los errores se actualizan al escribir.
  AutovalidateMode _validar = AutovalidateMode.disabled;

  @override
  void dispose() {
    _autor.dispose();
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();
    if (!_formulario.currentState!.validate()) {
      setState(() => _validar = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _guardando = true);
    String mensaje;
    try {
      await widget.servicio.agregarResena(
        peliculaId: widget.pelicula.id,
        autor: _autor.text,
        calificacion: _calificacion,
        comentario: _comentario.text,
      );
      mensaje = '¡Reseña guardada en Firebase!';
    } on ResenaPendiente {
      mensaje =
          'Sin conexión: la reseña se enviará a Firebase '
          'cuando vuelva internet.';
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la reseña: $e')),
      );
      return;
    }
    if (mounted) Navigator.of(context).pop(mensaje);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva reseña'),
        backgroundColor: azulCine,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formulario,
        autovalidateMode: _validar,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.pelicula.titulo,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold, color: azulCine),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.pelicula.anio} · ${widget.pelicula.genero}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _autor,
              enabled: !_guardando,
              maxLength: 40,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Tu nombre',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'Escribe tu nombre'
                  : null,
            ),
            const SizedBox(height: 8),
            FormField<int>(
              initialValue: _calificacion,
              validator: (_) =>
                  _calificacion == 0 ? 'Elige de 1 a 5 estrellas' : null,
              builder: (campo) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calificación',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Estrellas(
                    valor: _calificacion,
                    tamano: 36,
                    alCambiar: (valor) {
                      if (_guardando) return;
                      setState(() => _calificacion = valor);
                      campo.didChange(valor);
                    },
                  ),
                  if (campo.hasError)
                    Text(
                      campo.errorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _comentario,
              enabled: !_guardando,
              maxLength: 500,
              minLines: 4,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Tu reseña',
                hintText: '¿Qué te pareció la película?',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'Escribe tu opinión'
                  : null,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              style: FilledButton.styleFrom(
                backgroundColor: rosaCine,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: _guardando
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload),
              label: Text(_guardando ? 'Guardando…' : 'Guardar en Firebase'),
            ),
          ],
        ),
      ),
    );
  }
}
