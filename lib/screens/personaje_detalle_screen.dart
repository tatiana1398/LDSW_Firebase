import 'package:flutter/material.dart';

import '../models/personaje.dart';
import '../services/pokeapi_service.dart';
import '../widgets/tipo_chip.dart';
import 'personajes_screen.dart';

/// Detalle de un personaje. Hace una segunda petición HTTP para obtener la
/// categoría y la descripción en español (GET /pokemon-species/{id}).
class PersonajeDetalleScreen extends StatefulWidget {
  const PersonajeDetalleScreen({
    super.key,
    required this.personaje,
    required this.servicio,
  });

  final Personaje personaje;
  final PokeApiService servicio;

  @override
  State<PersonajeDetalleScreen> createState() => _PersonajeDetalleScreenState();
}

class _PersonajeDetalleScreenState extends State<PersonajeDetalleScreen> {
  late final Future<Especie> _especie = widget.servicio.obtenerEspecie(
    widget.personaje.id,
  )..ignore();

  static const Map<String, String> _nombresEstadisticas = {
    'hp': 'PS',
    'attack': 'Ataque',
    'defense': 'Defensa',
    'special-attack': 'At. especial',
    'special-defense': 'Def. especial',
    'speed': 'Velocidad',
  };

  @override
  Widget build(BuildContext context) {
    final p = widget.personaje;
    final color = colorTipo(p.tipos.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(p.nombreVisible),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          Container(
            height: 240,
            color: color,
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    p.numero,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(child: ImagenPersonaje(url: p.imagenUrl)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nombreVisible,
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [for (final t in p.tipos) TipoChip(tipo: t)],
                ),
                const SizedBox(height: 16),
                FutureBuilder<Especie>(
                  future: _especie,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(
                        'No se pudo cargar la descripción: ${snapshot.error}',
                        style: const TextStyle(color: Colors.grey),
                      );
                    }
                    final especie = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (especie.categoria.isNotEmpty)
                          Text(
                            especie.categoria,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(especie.descripcion),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _Dato(etiqueta: 'Altura', valor: '${p.alturaM} m'),
                    _Dato(etiqueta: 'Peso', valor: '${p.pesoKg} kg'),
                    _Dato(
                      etiqueta: 'Habilidad',
                      valor: p.habilidades.isEmpty ? '-' : p.habilidades.first,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Estadísticas base',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                for (final e in p.estadisticas.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 110,
                          child: Text(_nombresEstadisticas[e.key] ?? e.key),
                        ),
                        SizedBox(
                          width: 36,
                          child: Text(
                            '${e.value}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (e.value / 255).clamp(0, 1),
                            color: color,
                            backgroundColor: color.withValues(alpha: 0.15),
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            valor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
