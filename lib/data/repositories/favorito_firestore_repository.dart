import 'package:cloud_firestore/cloud_firestore.dart';

import 'favorito_repository.dart';

/// Favoritas en Cloud Firestore: lista de ids en `usuarios/{uid}.favoritos`.
///
/// Se guardan en la cuenta (no en el teléfono), así acompañan a la persona si
/// inicia sesión en otro dispositivo. Las reglas ya permiten que cada cuenta
/// edite su propio documento, siempre que no cambie su rol.
class FavoritoFirestoreRepository implements FavoritoRepository {
  FavoritoFirestoreRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const _limite = Duration(seconds: 15);

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('usuarios').doc(uid);

  @override
  Future<Set<String>> obtener(String uid) async {
    final snap = await _doc(uid).get().timeout(_limite);
    final crudo = snap.data()?['favoritos'];
    if (crudo is List) return crudo.map((e) => e.toString()).toSet();
    return <String>{};
  }

  @override
  Future<void> guardar(String uid, Set<String> ids) async {
    await _doc(uid)
        .set({'favoritos': ids.toList()}, SetOptions(merge: true))
        .timeout(_limite);
  }
}
