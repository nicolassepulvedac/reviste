import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/prenda.dart';
import 'prenda_local_repository.dart' show conFotoDeEjemplo, prendasEjemplo;
import 'prenda_repository.dart';

/// Implementación con Cloud Firestore (colección `prendas`).
///
/// Cumple el mismo contrato que [PrendaLocalRepository], por eso las pantallas
/// no cambian: solo se cambia el provider.
///
/// La primera vez que se usa con la colección vacía se cargan las prendas de
/// ejemplo (una sola vez, se deja una marca en `config/semilla`).
class PrendaFirestoreRepository implements PrendaRepository {
  PrendaFirestoreRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  /// Sin conexión Firestore deja las escrituras en cola y no responde.
  /// Con este límite la app muestra el error en vez de quedarse cargando.
  static const _limite = Duration(seconds: 15);

  CollectionReference<Map<String, dynamic>> get _coleccion =>
      _db.collection('prendas');

  DocumentReference<Map<String, dynamic>> get _marcaSemilla =>
      _db.collection('config').doc('semilla');

  /// Datos que se guardan en Firestore (el id es el del documento).
  Map<String, dynamic> _aDatos(Prenda prenda) {
    final datos = Map<String, dynamic>.from(prenda.toMap())..remove('id');
    // Las prendas de ejemplo no tienen dueña: no se escribe un campo vacío
    // (así comprar solo modifica el stock, como exigen las reglas).
    if (prenda.vendedorUid.isEmpty) datos.remove('vendedorUid');
    return datos;
  }

  Prenda _aPrenda(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return conFotoDeEjemplo(Prenda.fromMap({...doc.data(), 'id': doc.id}));
  }

  @override
  Future<List<Prenda>> obtenerPrendas() async {
    try {
      await _cargarEjemplosSiHaceFalta();
    } catch (_) {
      // Solo un administrador puede cargar los ejemplos (reglas de Firestore).
      // Si no hay permiso, se sigue y se leen las prendas que ya existan.
    }
    final consulta = await _coleccion.get().timeout(_limite);

    // Las más nuevas primero (las que no tienen fecha quedan al final).
    final docs = [...consulta.docs]..sort((a, b) {
        final fa = a.data()['creadaEn'];
        final fb = b.data()['creadaEn'];
        if (fa is Timestamp && fb is Timestamp) return fb.compareTo(fa);
        if (fa is Timestamp) return -1;
        if (fb is Timestamp) return 1;
        return 0;
      });
    return docs.map(_aPrenda).toList();
  }

  @override
  Future<Prenda> crearPrenda(Prenda prenda) async {
    // Si la prenda ya trae id (reintento de una publicación) se reutiliza.
    final doc = prenda.id.isEmpty ? _coleccion.doc() : _coleccion.doc(prenda.id);
    await doc
        .set({..._aDatos(prenda), 'creadaEn': FieldValue.serverTimestamp()})
        .timeout(_limite);
    return prenda.copyWith(id: doc.id);
  }

  @override
  Future<void> actualizarPrenda(Prenda prenda) async {
    // update (no set) para conservar campos como `creadaEn`.
    await _coleccion.doc(prenda.id).update(_aDatos(prenda)).timeout(_limite);
  }

  @override
  Future<void> eliminarPrenda(String id) async {
    await _coleccion.doc(id).delete().timeout(_limite);
  }

  @override
  Future<void> actualizarVendedor(String vendedorUid, String nombre) async {
    if (vendedorUid.isEmpty) return;
    final propias = await _coleccion
        .where('vendedorUid', isEqualTo: vendedorUid)
        .get()
        .timeout(_limite);
    if (propias.docs.isEmpty) return;

    final lote = _db.batch();
    for (final doc in propias.docs) {
      lote.update(doc.reference, {'vendedor': nombre});
    }
    await lote.commit().timeout(_limite);
  }

  /// Carga las prendas de ejemplo solo la primera vez (colección nueva).
  Future<void> _cargarEjemplosSiHaceFalta() async {
    final marca = await _marcaSemilla.get().timeout(_limite);
    if (marca.exists) return;

    final lote = _db.batch();
    final ahora = DateTime.now();
    for (var i = 0; i < prendasEjemplo.length; i++) {
      final p = prendasEjemplo[i];
      lote.set(_coleccion.doc(p.id), {
        ..._aDatos(p),
        // Fechas escalonadas para conservar el orden original de la lista.
        'creadaEn': Timestamp.fromDate(ahora.subtract(Duration(minutes: i))),
      });
    }
    lote.set(_marcaSemilla, {'cargada': true});
    await lote.commit().timeout(_limite);
  }
}
