import 'package:flutter/material.dart';

import '../main.dart';
import 'catalogo_screen.dart';

/// Pantalla 1 del wireframe: pantalla de inicio (home screen).
///
/// Sigue el procedimiento del tutorial "Layouts en Flutter":
/// 1. Se dibuja el layout como capas y secciones.
/// 2. Cada sección es un widget independiente (logo, título, bienvenida,
///    características y botones).
/// 3. Se apilan con un Stack: la Image de fondo abajo, una capa oscura
///    en medio y el contenido (Column) arriba.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image: imagen de fondo que cubre toda la pantalla.
          Image.asset(
            'assets/images/fondo_cine.jpg',
            fit: BoxFit.cover,
            semanticLabel: 'Sala de cine',
          ),
          // Capa oscura para que el texto blanco se lea sobre la imagen.
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  azulCine.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: const IntrinsicHeight(
                    child: Column(
                      children: [
                        Spacer(),
                        SeccionLogo(),
                        SizedBox(height: 20),
                        SeccionTitulo(),
                        SizedBox(height: 28),
                        SeccionCaracteristicas(),
                        Spacer(),
                        SeccionBotones(),
                        SizedBox(height: 16),
                        Text(
                          '© 2026 CineCatálogo',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                        SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo de la app: un Icon dentro de un círculo.
class SeccionLogo extends StatelessWidget {
  const SeccionLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.12),
        border: Border.all(color: rosaCine, width: 3),
      ),
      child: const Icon(Icons.movie_filter, size: 64, color: Colors.white),
    );
  }
}

/// Nombre de la app y mensaje de bienvenida.
class SeccionTitulo extends StatelessWidget {
  const SeccionTitulo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'CineCatálogo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Hello World',
          style: TextStyle(
            color: rosaCine,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4),
        Text(
          '¡Bienvenido!',
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        SizedBox(height: 10),
        Text(
          'Descubre y explora nuestro catálogo de películas',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ],
    );
  }
}

/// Fila de características, como la "button section" del tutorial:
/// una Row de columnas con un Icon y un Text cada una.
class SeccionCaracteristicas extends StatelessWidget {
  const SeccionCaracteristicas({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _columnaIcono(Icons.local_movies, 'Estrenos')),
        Expanded(child: _columnaIcono(Icons.theater_comedy, 'Géneros')),
        Expanded(child: _columnaIcono(Icons.star, 'Favoritas')),
      ],
    );
  }

  Column _columnaIcono(IconData icono, String etiqueta) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: Colors.white, size: 30),
        const SizedBox(height: 6),
        Text(
          etiqueta,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Botones "Registrarse" e "Ingresar" del wireframe.
class SeccionBotones extends StatelessWidget {
  const SeccionBotones({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('El registro estará disponible próximamente'),
              ),
            );
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Registrarse'),
          style: FilledButton.styleFrom(
            backgroundColor: rosaCine,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const CatalogoScreen()));
          },
          icon: const Icon(Icons.login),
          label: const Text('Ingresar'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Colors.white),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '¿Ya eres usuario? Ingresa con tu cuenta',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}
