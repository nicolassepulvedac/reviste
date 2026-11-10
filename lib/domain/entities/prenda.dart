/// Entidad principal de ReViste: una prenda de ropa de segunda mano.
class Prenda {
  final String id;
  final String nombre;
  final int precio; // en pesos chilenos
  final String talla;
  final String categoria; // Mujer, Hombre, Accesorios
  final String estado; // Excelente, Bueno, Aceptable
  final int stock; // la mayoría de las prendas son únicas (stock 1)
  final String imagenUrl;
  final String descripcion;
  final String marca;
  final String vendedor;

  const Prenda({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.talla,
    required this.categoria,
    required this.estado,
    required this.stock,
    required this.imagenUrl,
    required this.descripcion,
    required this.marca,
    required this.vendedor,
  });

  bool get agotada => stock < 1;

  Prenda copyWith({
    String? id,
    String? nombre,
    int? precio,
    String? talla,
    String? categoria,
    String? estado,
    int? stock,
    String? imagenUrl,
    String? descripcion,
    String? marca,
    String? vendedor,
  }) {
    return Prenda(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      talla: talla ?? this.talla,
      categoria: categoria ?? this.categoria,
      estado: estado ?? this.estado,
      stock: stock ?? this.stock,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      descripcion: descripcion ?? this.descripcion,
      marca: marca ?? this.marca,
      vendedor: vendedor ?? this.vendedor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'talla': talla,
      'categoria': categoria,
      'estado': estado,
      'stock': stock,
      'imagenUrl': imagenUrl,
      'descripcion': descripcion,
      'marca': marca,
      'vendedor': vendedor,
    };
  }

  factory Prenda.fromMap(Map<String, dynamic> map) {
    return Prenda(
      id: (map['id'] ?? '') as String,
      nombre: (map['nombre'] ?? '') as String,
      precio: ((map['precio'] ?? 0) as num).toInt(),
      talla: (map['talla'] ?? '') as String,
      categoria: (map['categoria'] ?? 'Mujer') as String,
      estado: (map['estado'] ?? 'Bueno') as String,
      stock: ((map['stock'] ?? 1) as num).toInt(),
      imagenUrl: (map['imagenUrl'] ?? '') as String,
      descripcion: (map['descripcion'] ?? '') as String,
      marca: (map['marca'] ?? 'Sin marca') as String,
      vendedor: (map['vendedor'] ?? '') as String,
    );
  }
}
