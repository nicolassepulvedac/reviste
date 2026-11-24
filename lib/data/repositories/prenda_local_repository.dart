import '../../domain/entities/prenda.dart';
import 'prenda_repository.dart';

/// Implementación en memoria con prendas de ejemplo.
/// Simula la latencia de una API para poder ver el estado de carga.
class PrendaLocalRepository implements PrendaRepository {
  final List<Prenda> _prendas = [...prendasEjemplo];

  @override
  Future<List<Prenda>> obtenerPrendas() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return List<Prenda>.from(_prendas);
  }

  @override
  Future<Prenda> crearPrenda(Prenda prenda) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final nueva =
        prenda.copyWith(id: DateTime.now().microsecondsSinceEpoch.toString());
    _prendas.insert(0, nueva);
    return nueva;
  }

  @override
  Future<void> actualizarPrenda(Prenda prenda) async {
    final i = _prendas.indexWhere((p) => p.id == prenda.id);
    if (i != -1) _prendas[i] = prenda;
  }

  @override
  Future<void> eliminarPrenda(String id) async {
    _prendas.removeWhere((p) => p.id == id);
  }

  @override
  Future<void> actualizarVendedor(String vendedorUid, String nombre) async {
    if (vendedorUid.isEmpty) return;
    for (var i = 0; i < _prendas.length; i++) {
      if (_prendas[i].vendedorUid == vendedorUid) {
        _prendas[i] = _prendas[i].copyWith(vendedor: nombre);
      }
    }
  }
}

/// Prendas de ejemplo (también se usan para cargar Firestore la primera vez).
const List<Prenda> prendasEjemplo = [
  Prenda(
    id: '1',
    nombre: 'Chaqueta de Cuero',
    precio: 4500,
    talla: 'M',
    categoria: 'Hombre',
    estado: 'Excelente',
    stock: 1,
    imagenUrl: 'https://images.unsplash.com/photo-1727515546577-f7d82a47b51d?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Espectacular chaqueta de cuero genuino, súper suave al tacto y con forro abrigado. Sin detalles de uso, prácticamente nueva. El color es un café hermoso, ideal para cualquier look vintage.',
    marca: "Levi's Colección",
    vendedor: 'Pedro Fernández',
  ),
  Prenda(
    id: '2',
    nombre: 'Chaleco de Lana Tejido',
    precio: 2200,
    talla: 'L',
    categoria: 'Mujer',
    estado: 'Bueno',
    stock: 1,
    imagenUrl: 'assets/images/chaleco_lana.jpg',
    descripcion:
        'Chaleco tejido a mano en lana gruesa, muy calentito. Tiene un par de bolitas mínimas por el uso, pero queda perfecto sobre una polera o camisa.',
    marca: 'Artesanal',
    vendedor: 'Pedro Fernández',
  ),
  Prenda(
    id: '3',
    nombre: 'Jeans Retro 501',
    precio: 2800,
    talla: '32',
    categoria: 'Hombre',
    estado: 'Aceptable',
    stock: 1,
    imagenUrl: 'https://images.unsplash.com/photo-1624378440847-4a64ee1a889d?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Jeans de corte clásico y recto, tela resistente. Tienen desgaste natural en las rodillas y el dobladillo, justo el look retro que buscas.',
    marca: "Levi's",
    vendedor: 'Pedro Fernández',
  ),
  Prenda(
    id: '4',
    nombre: 'Mochila',
    precio: 1800,
    talla: 'Única',
    categoria: 'Accesorios',
    estado: 'Excelente',
    stock: 1,
    imagenUrl: 'https://images.unsplash.com/photo-1681334921874-5bafe8acf433?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Mochila resistente con varios compartimentos y espacio para notebook. Cierres y correas en perfecto estado.',
    marca: 'Sin marca',
    vendedor: 'Pedro Fernández',
  ),
  Prenda(
    id: '5',
    nombre: 'Vestido Floral de Verano',
    precio: 3500,
    talla: 'S',
    categoria: 'Mujer',
    estado: 'Excelente',
    stock: 1,
    imagenUrl: 'assets/images/vestido_floral.jpg',
    descripcion:
        'Vestido liviano con estampado floral, ideal para días de calor. Usado solo una vez, sin manchas ni arreglos.',
    marca: 'Sin marca',
    vendedor: 'Camila Rojas',
  ),
  Prenda(
    id: '6',
    nombre: 'Polera Básica de Algodón',
    precio: 1500,
    talla: 'M',
    categoria: 'Mujer',
    estado: 'Bueno',
    stock: 3,
    imagenUrl: 'https://images.unsplash.com/photo-1564859228273-274232fdb516?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Polera básica de algodón suave, en buen estado. Hay tres unidades disponibles en la misma talla.',
    marca: 'Sin marca',
    vendedor: 'Camila Rojas',
  ),
  Prenda(
    id: '7',
    nombre: 'Zapatillas Urbanas',
    precio: 5200,
    talla: '41',
    categoria: 'Hombre',
    estado: 'Bueno',
    stock: 1,
    imagenUrl: 'https://images.unsplash.com/photo-1547053295-bb530ab5af2c?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Zapatillas cómodas para el día a día, suela con buen agarre. Limpias y listas para usar.',
    marca: 'Sin marca',
    vendedor: 'Diego Soto',
  ),
  Prenda(
    id: '8',
    nombre: 'Bufanda de Lana',
    precio: 1200,
    talla: 'Única',
    categoria: 'Accesorios',
    estado: 'Excelente',
    stock: 1,
    imagenUrl: 'assets/images/bufanda_lana.jpg',
    descripcion: 'Bufanda larga y abrigadora en tonos grises. Como nueva.',
    marca: 'Sin marca',
    vendedor: 'Javiera Muñoz',
  ),
  Prenda(
    id: '9',
    nombre: 'Camisa de Lino',
    precio: 2900,
    talla: 'L',
    categoria: 'Hombre',
    estado: 'Excelente',
    stock: 1,
    imagenUrl: 'https://images.unsplash.com/photo-1602810318660-d2c46b750f88?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Camisa de lino fresca y ligera, perfecta para el verano. Sin detalles.',
    marca: 'Sin marca',
    vendedor: 'Diego Soto',
  ),
  Prenda(
    id: '10',
    nombre: 'Falda Plisada',
    precio: 2400,
    talla: 'S',
    categoria: 'Mujer',
    estado: 'Bueno',
    stock: 1,
    imagenUrl: 'assets/images/falda_plisada.jpg',
    descripcion:
        'Falda plisada midi con cintura elástica. Muy cómoda y fácil de combinar.',
    marca: 'Sin marca',
    vendedor: 'Javiera Muñoz',
  ),
  Prenda(
    id: '11',
    nombre: 'Cinturón de Cuero',
    precio: 1600,
    talla: 'Única',
    categoria: 'Accesorios',
    estado: 'Aceptable',
    stock: 2,
    imagenUrl: 'https://images.unsplash.com/photo-1667284152843-024e91829ad3?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Cinturón de cuero con hebilla metálica. Marcas de uso normales. Hay dos unidades.',
    marca: 'Sin marca',
    vendedor: 'Diego Soto',
  ),
  Prenda(
    id: '12',
    nombre: 'Polerón Canguro',
    precio: 3200,
    talla: 'L',
    categoria: 'Hombre',
    estado: 'Bueno',
    stock: 1,
    imagenUrl: 'https://images.unsplash.com/photo-1593979189584-cb269cecc9ad?auto=format&fit=crop&w=600&q=70',
    descripcion:
        'Polerón con capucha y bolsillo canguro, interior afelpado. Muy abrigado.',
    marca: 'Sin marca',
    vendedor: 'Camila Rojas',
  ),
];

/// Las prendas de ejemplo que se guardaron en Firestore antes de tener fotos
/// quedaron sin imagen. Aquí se les pone la foto de ejemplo (solo a las que no
/// tienen dueña ni foto), así se ven bien sin tener que editarlas una por una.
Prenda conFotoDeEjemplo(Prenda prenda) {
  if (prenda.imagenUrl.isNotEmpty || prenda.vendedorUid.isNotEmpty) {
    return prenda;
  }
  final ejemplo = prendasEjemplo.where((e) => e.id == prenda.id).firstOrNull;
  if (ejemplo == null) return prenda;
  return prenda.copyWith(imagenUrl: ejemplo.imagenUrl);
}
