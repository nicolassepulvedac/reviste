import '../../domain/entities/prenda.dart';

/// Contrato de acceso a datos de prendas.
///
/// Lo implementan [PrendaFirestoreRepository] (v0.4, el que usa la app) y
/// [PrendaLocalRepository] (datos en memoria). Se elige en el provider.
abstract class PrendaRepository {
  Future<List<Prenda>> obtenerPrendas();
  Future<Prenda> crearPrenda(Prenda prenda);
  Future<void> actualizarPrenda(Prenda prenda);
  Future<void> eliminarPrenda(String id);
}
