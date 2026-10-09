import 'package:flutter/material.dart';

import '../main.dart';
import '../models/pelicula.dart';
import '../models/resena.dart';
import '../services/resenas_service.dart';
import '../widgets/estrellas.dart';
import 'nueva_resena_screen.dart';

/// Ficha de una película con sus reseñas guardadas en Cloud Firestore.
///
/// Las reseñas se escuchan en tiempo real con un StreamBuilder: cuando
/// alguien agrega una, aparece en la lista sin recargar la pantalla.
class PeliculaDetalleScreen extends StatefulWidget {
  const PeliculaDetalleScreen({
    super.key,
    required this.pelicula,
    this.servicio,
  });

  final Pelicula pelicula;
  final ResenasService? servicio;

  @override
  State<PeliculaDetalleScreen> createState() => _PeliculaDetalleScreenState();
}

class _PeliculaDetalleScreenState extends State<PeliculaDetalleScreen> {
  late final ResenasService _servicio = widget.servicio ?? ResenasService();

  /// El stream se crea una sola vez para no abrir una consulta en cada build().
  late Stream<List<Resena>> _resenas;

  @override
  void initState() {
    super.initState();
    _escuchar();
  }

  void _escuchar() {
    _resenas = _servicio.escucharResenas(widget.pelicula.id);
  }

  Future<void> _escribirResena() async {
    final mensaje = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            NuevaResenaScreen(pelicula: widget.pelicula, servicio: _servicio),
      ),
    );
    if (!mounted || mensaje == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  Widget build(BuildContext context) {
    final pelicula = widget.pelicula;
    return Scaffold(
      appBar: AppBar(
        title: Text(pelicula.titulo),
        backgroundColor: azulCine,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _escribirResena,
        backgroundColor: rosaCine,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.rate_review),
        label: const Text('Escribir reseña'),
      ),
      body: StreamBuilder<List<Resena>>(
        stream: _resenas,
        builder: (context, snapshot) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _Encabezado(pelicula: pelicula),
              const SizedBox(height: 24),
              Text(
                'Reseñas de la comunidad',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: azulCine),
              ),
              const SizedBox(height: 4),
              Text(
                'Guardadas en Cloud Firestore · se actualizan en tiempo real',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ..._contenido(snapshot),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _contenido(AsyncSnapshot<List<Resena>> snapshot) {
    if (snapshot.hasError) {
      return [
        _Aviso(
          icono: Icons.cloud_off,
          texto: 'No se pudieron cargar las reseñas.\n${snapshot.error}',
          boton: TextButton.icon(
            onPressed: () => setState(_escuchar),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ),
      ];
    }
    if (!snapshot.hasData) {
      return const [
        Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final resenas = snapshot.data!;
    if (resenas.isEmpty) {
      return const [
        _Aviso(
          icono: Icons.forum_outlined,
          texto: 'Aún no hay reseñas.\n¡Sé la primera persona en opinar!',
        ),
      ];
    }
    return [
      _Resumen(resenas: resenas),
      const SizedBox(height: 12),
      for (final resena in resenas) _TarjetaResena(resena: resena),
    ];
  }
}

/// Póster, título y datos de la película.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.pelicula});

  final Pelicula pelicula;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            color: pelicula.color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.movie, size: 48, color: Colors.white70),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pelicula.titulo,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: azulCine,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${pelicula.anio} · ${pelicula.genero}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, size: 18, color: Colors.amber),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${pelicula.calificacion.toStringAsFixed(1)} en el catálogo',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Promedio de estrellas y número de reseñas guardadas en Firestore.
class _Resumen extends StatelessWidget {
  const _Resumen({required this.resenas});

  final List<Resena> resenas;

  @override
  Widget build(BuildContext context) {
    final promedio = promedioCalificacion(resenas);
    final total = resenas.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBEAF5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            promedio.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: rosaCine,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Estrellas(valor: promedio.round()),
                const SizedBox(height: 2),
                Text('$total ${total == 1 ? 'reseña' : 'reseñas'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Una reseña: autor, estrellas, fecha y comentario.
class _TarjetaResena extends StatelessWidget {
  const _TarjetaResena({required this.resena});

  final Resena resena;

  @override
  Widget build(BuildContext context) {
    final inicial = resena.autor.isEmpty
        ? '?'
        : resena.autor.characters.first.toUpperCase();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: azulCine,
              foregroundColor: Colors.white,
              child: Text(inicial),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resena.autor,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Estrellas(valor: resena.calificacion, tamano: 16),
                      Text(
                        formatearFecha(resena.fecha),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(resena.comentario),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mensaje centrado con ícono (lista vacía o error).
class _Aviso extends StatelessWidget {
  const _Aviso({required this.icono, required this.texto, this.boton});

  final IconData icono;
  final String texto;
  final Widget? boton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icono, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          if (boton != null) ...[const SizedBox(height: 8), boton!],
        ],
      ),
    );
  }
}

/// Fecha en formato dd/mm/aaaa hh:mm.
String formatearFecha(DateTime? fecha) {
  if (fecha == null) return 'Enviando…';
  String dos(int n) => n.toString().padLeft(2, '0');
  final f = fecha.toLocal();
  return '${dos(f.day)}/${dos(f.month)}/${f.year} ${dos(f.hour)}:${dos(f.minute)}';
}
