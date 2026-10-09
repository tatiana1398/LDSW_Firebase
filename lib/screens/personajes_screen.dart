import 'package:flutter/material.dart';

import '../main.dart';
import '../models/personaje.dart';
import '../services/pokeapi_service.dart';
import '../widgets/tipo_chip.dart';
import 'personaje_detalle_screen.dart';

/// Personajes de "Pokémon: Detective Pikachu" obtenidos con peticiones HTTP
/// a PokéAPI, con un buscador para consultar cualquier otro personaje.
class PersonajesScreen extends StatefulWidget {
  const PersonajesScreen({super.key, this.servicio});

  final PokeApiService? servicio;

  @override
  State<PersonajesScreen> createState() => _PersonajesScreenState();
}

class _PersonajesScreenState extends State<PersonajesScreen> {
  late final PokeApiService _servicio = widget.servicio ?? PokeApiService();
  final _buscador = TextEditingController();

  /// La petición se guarda en initState para no repetirla en cada build().
  late Future<List<Personaje>> _futuro;
  String? _busqueda;

  @override
  void initState() {
    super.initState();
    _cargarPelicula();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  void _cargarPelicula() {
    _busqueda = null;
    _pedir(
      _servicio.obtenerPersonajes(PokeApiService.personajesDetectivePikachu),
    );
  }

  void _buscar(String texto) {
    if (texto.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busqueda = texto.trim();
      _pedir(_servicio.obtenerPersonaje(texto).then((p) => [p]));
    });
  }

  /// Guarda la petición. ignore() evita que un error que llegue antes del
  /// siguiente build se reporte como no manejado; el FutureBuilder lo
  /// recibe igual y muestra la vista de error.
  void _pedir(Future<List<Personaje>> peticion) {
    _futuro = peticion..ignore();
  }

  void _limpiar() {
    _buscador.clear();
    setState(_cargarPelicula);
  }

  void _reintentar() {
    setState(() {
      if (_busqueda == null) {
        _cargarPelicula();
      } else {
        _pedir(_servicio.obtenerPersonaje(_busqueda!).then((p) => [p]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personajes'),
        backgroundColor: azulCine,
        foregroundColor: Colors.white,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscador,
              textInputAction: TextInputAction.search,
              onSubmitted: _buscar,
              decoration: InputDecoration(
                hintText: 'Buscar personaje (ej. eevee)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _busqueda == null
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar búsqueda',
                        icon: const Icon(Icons.close),
                        onPressed: _limpiar,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              _busqueda == null
                  ? 'Pokémon: Detective Pikachu (2019)'
                  : 'Resultado de "$_busqueda"',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: azulCine),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'Datos obtenidos en tiempo real de PokéAPI',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Expanded(
            // FutureBuilder: muestra carga, error o los datos de la petición.
            child: FutureBuilder<List<Personaje>>(
              future: _futuro,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _VistaError(
                    mensaje: snapshot.error.toString(),
                    alReintentar: _reintentar,
                    alVolver: _busqueda == null ? null : _limpiar,
                  );
                }
                final personajes = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: personajes.length,
                  itemBuilder: (context, i) => _TarjetaPersonaje(
                    personaje: personajes[i],
                    alTocar: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PersonajeDetalleScreen(
                          personaje: personajes[i],
                          servicio: _servicio,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaPersonaje extends StatelessWidget {
  const _TarjetaPersonaje({required this.personaje, required this.alTocar});

  final Personaje personaje;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: alTocar,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  personaje.numero,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Expanded(child: ImagenPersonaje(url: personaje.imagenUrl)),
              const SizedBox(height: 6),
              Text(
                personaje.nombreVisible,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [for (final t in personaje.tipos) TipoChip(tipo: t)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Imagen descargada de internet con indicador de carga y respaldo si falla.
class ImagenPersonaje extends StatelessWidget {
  const ImagenPersonaje({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const respaldo = Center(
      child: Icon(Icons.catching_pokemon, size: 48, color: Colors.grey),
    );
    if (url == null) return respaldo;

    return Image.network(
      url!,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progreso) => progreso == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (context, error, stack) => respaldo,
    );
  }
}

class _VistaError extends StatelessWidget {
  const _VistaError({
    required this.mensaje,
    required this.alReintentar,
    this.alVolver,
  });

  final String mensaje;
  final VoidCallback alReintentar;
  final VoidCallback? alVolver;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 12),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: alReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
            if (alVolver != null)
              TextButton(
                onPressed: alVolver,
                child: const Text('Ver personajes de la película'),
              ),
          ],
        ),
      ),
    );
  }
}
