import 'prenda.dart';

/// Una línea del carrito: una prenda y cuántas unidades se llevan.
class CarritoItem {
  final Prenda prenda;
  final int cantidad;

  const CarritoItem({required this.prenda, required this.cantidad});

  int get subtotal => prenda.precio * cantidad;

  CarritoItem copyWith({Prenda? prenda, int? cantidad}) {
    return CarritoItem(
      prenda: prenda ?? this.prenda,
      cantidad: cantidad ?? this.cantidad,
    );
  }

  Map<String, dynamic> toMap() {
    return {'prenda': prenda.toMap(), 'cantidad': cantidad};
  }

  factory CarritoItem.fromMap(Map<String, dynamic> map) {
    return CarritoItem(
      prenda: Prenda.fromMap(Map<String, dynamic>.from(map['prenda'] as Map)),
      cantidad: ((map['cantidad'] ?? 1) as num).toInt(),
    );
  }
}
