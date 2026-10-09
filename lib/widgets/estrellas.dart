import 'package:flutter/material.dart';

/// Muestra una calificación de 1 a 5 con estrellas.
///
/// Si se pasa [alCambiar], las estrellas se pueden tocar para elegir.
class Estrellas extends StatelessWidget {
  const Estrellas({
    super.key,
    required this.valor,
    this.tamano = 18,
    this.alCambiar,
  });

  final int valor;
  final double tamano;
  final ValueChanged<int>? alCambiar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          if (alCambiar == null)
            Icon(
              i <= valor ? Icons.star : Icons.star_border,
              size: tamano,
              color: Colors.amber,
            )
          else
            IconButton(
              tooltip: '$i ${i == 1 ? 'estrella' : 'estrellas'}',
              onPressed: () => alCambiar!(i),
              iconSize: tamano,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              icon: Icon(
                i <= valor ? Icons.star : Icons.star_border,
                color: Colors.amber,
              ),
            ),
      ],
    );
  }
}
