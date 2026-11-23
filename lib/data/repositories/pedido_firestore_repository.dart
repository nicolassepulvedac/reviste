import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pedido.dart';
import 'pedido_repository.dart';

/// Historial de compras en Cloud Firestore (colección `pedidos`).
///
/// Cada pedido guarda el `uid` de quien compró; las reglas de Firestore solo
/// permiten leer y crear pedidos propios, y nadie puede editarlos ni borrarlos.
class PedidoFirestoreRepository implements PedidoRepository {
  PedidoFirestoreRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _limite = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      _db.collection('pedidos');

  @override
  Future<List<Pedido>> obtenerPedidos(String uid) async {
    // Se filtra por uid (lo que exigen las reglas) y se ordena aquí, así no
    // hace falta crear un índice en Firestore.
    final consulta =
        await _coleccion.where('uid', isEqualTo: uid).get().timeout(_limite);

    final pedidos = consulta.docs.map((doc) {
      final datos = doc.data();
      final creada = datos['creadaEn'];
      final fecha = creada is Timestamp ? creada.toDate() : DateTime.now();
      return Pedido.fromMap(datos, id: doc.id, fecha: fecha);
    }).toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
    return pedidos;
  }

  @override
  Future<Pedido> crearPedido(Pedido pedido) async {
    final doc = _coleccion.doc();
    await doc
        .set({...pedido.toMap(), 'creadaEn': FieldValue.serverTimestamp()})
        .timeout(_limite);
    return pedido.copyWith(id: doc.id, fecha: DateTime.now());
  }
}
