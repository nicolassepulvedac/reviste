import 'carrito_item.dart';

/// Una prenda dentro de un pedido. Se guarda una copia de los datos (nombre,
/// precio...) para que el historial no cambie si la prenda se edita después.
class PedidoItem {
  final String prendaId;
  final String nombre;
  final String talla;
  final int precio;
  final int cantidad;
  final String imagenUrl;

  const PedidoItem({
    required this.prendaId,
    required this.nombre,
    required this.talla,
    required this.precio,
    required this.cantidad,
    this.imagenUrl = '',
  });

  int get subtotal => precio * cantidad;

  factory PedidoItem.desdeCarrito(CarritoItem item) {
    return PedidoItem(
      prendaId: item.prenda.id,
      nombre: item.prenda.nombre,
      talla: item.prenda.talla,
      precio: item.prenda.precio,
      cantidad: item.cantidad,
      imagenUrl: item.prenda.imagenUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prendaId': prendaId,
      'nombre': nombre,
      'talla': talla,
      'precio': precio,
      'cantidad': cantidad,
      'imagenUrl': imagenUrl,
    };
  }

  factory PedidoItem.fromMap(Map<String, dynamic> map) {
    return PedidoItem(
      prendaId: (map['prendaId'] ?? '').toString(),
      nombre: (map['nombre'] ?? '').toString(),
      talla: (map['talla'] ?? '').toString(),
      precio: ((map['precio'] ?? 0) as num).toInt(),
      cantidad: ((map['cantidad'] ?? 1) as num).toInt(),
      imagenUrl: (map['imagenUrl'] ?? '').toString(),
    );
  }
}

/// Compra confirmada por una cuenta (aparece en "Mis compras").
class Pedido {
  final String id;
  final String uid;
  final List<PedidoItem> items;
  final int total;
  final String nombre;
  final String direccion;
  final String ciudad;
  final String estado;
  final DateTime fecha;

  const Pedido({
    required this.id,
    required this.uid,
    required this.items,
    required this.total,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.fecha,
    this.estado = 'Confirmado',
  });

  /// Cantidad de unidades compradas en el pedido.
  int get unidades => items.fold(0, (suma, e) => suma + e.cantidad);

  Pedido copyWith({String? id, DateTime? fecha}) {
    return Pedido(
      id: id ?? this.id,
      uid: uid,
      items: items,
      total: total,
      nombre: nombre,
      direccion: direccion,
      ciudad: ciudad,
      estado: estado,
      fecha: fecha ?? this.fecha,
    );
  }

  /// Datos que se guardan (el id y la fecha los pone el repositorio).
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
      'estado': estado,
    };
  }

  factory Pedido.fromMap(
    Map<String, dynamic> map, {
    required String id,
    required DateTime fecha,
  }) {
    final crudos = (map['items'] ?? const []) as List;
    return Pedido(
      id: id,
      uid: (map['uid'] ?? '').toString(),
      items: [
        for (final e in crudos)
          PedidoItem.fromMap(Map<String, dynamic>.from(e as Map)),
      ],
      total: ((map['total'] ?? 0) as num).toInt(),
      nombre: (map['nombre'] ?? '').toString(),
      direccion: (map['direccion'] ?? '').toString(),
      ciudad: (map['ciudad'] ?? '').toString(),
      estado: (map['estado'] ?? 'Confirmado').toString(),
      fecha: fecha,
    );
  }
}
