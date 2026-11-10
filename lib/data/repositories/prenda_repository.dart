import '../../domain/entities/prenda.dart';

/// Contrato de acceso a datos de prendas.
///
/// Hoy lo implementa [PrendaLocalRepository] (datos en memoria). Más adelante
/// se agrega una implementación con Firestore y solo se cambia el provider.
abstract class PrendaRepository {
  Future<List<Prenda>> obtenerPrendas();
  Future<Prenda> crearPrenda(Prenda prenda);
  Future<void> actualizarPrenda(Prenda prenda);
  Future<void> eliminarPrenda(String id);
}
