import 'package:flutter/material.dart';

/// Nombre en español y color de cada tipo de Pokémon.
const Map<String, (String, Color)> _tipos = {
  'normal': ('Normal', Color(0xFF9E9E7A)),
  'fire': ('Fuego', Color(0xFFE8642C)),
  'water': ('Agua', Color(0xFF4A86D9)),
  'electric': ('Eléctrico', Color(0xFFE0B21B)),
  'grass': ('Planta', Color(0xFF5DA845)),
  'ice': ('Hielo', Color(0xFF5BBFCF)),
  'fighting': ('Lucha', Color(0xFFB7372D)),
  'poison': ('Veneno', Color(0xFF9346A0)),
  'ground': ('Tierra', Color(0xFFC59A4B)),
  'flying': ('Volador', Color(0xFF8C8FD9)),
  'psychic': ('Psíquico', Color(0xFFE8508A)),
  'bug': ('Bicho', Color(0xFF8FA524)),
  'rock': ('Roca', Color(0xFFAD9645)),
  'ghost': ('Fantasma', Color(0xFF6A5596)),
  'dragon': ('Dragón', Color(0xFF6440E0)),
  'dark': ('Siniestro', Color(0xFF6B5547)),
  'steel': ('Acero', Color(0xFF8E8EA8)),
  'fairy': ('Hada', Color(0xFFD883A5)),
};

String nombreTipo(String tipo) => _tipos[tipo]?.$1 ?? tipo;

Color colorTipo(String tipo) => _tipos[tipo]?.$2 ?? Colors.grey;

/// Etiqueta de color con el tipo del personaje.
class TipoChip extends StatelessWidget {
  const TipoChip({super.key, required this.tipo});

  final String tipo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: colorTipo(tipo),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        nombreTipo(tipo),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
