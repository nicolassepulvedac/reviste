# ReViste

App móvil de compra y venta de ropa de segunda mano, hecha en Flutter para el
ramo Desarrollo de Aplicaciones Móviles (DAM, UTFSM).

**Idea del proyecto:** ReViste es una tienda para darle una segunda vida a la
ropa. Cualquier persona puede registrarse, publicar las prendas que ya no usa,
explorar las de otras personas, guardarlas como favoritas y comprarlas desde un
carrito. Un administrador puede revisar y moderar todas las publicaciones.

## Funcionalidades

- Registro, inicio y cierre de sesión (Firebase Authentication).
- Explorar prendas con búsqueda y filtro por categoría, y ver su detalle.
- Carrito con subtotales, total, control de stock, sin duplicados y guardado
  en el teléfono (`shared_preferences`).
- Checkout con formulario validado y descuento de stock al comprar.
- Historial de compras ("Mis compras") guardado en Firestore por cuenta.
- Favoritos con pantalla propia, guardados en la cuenta (`usuarios/{uid}.favoritos`).
- Publicar, editar y eliminar prendas propias (CRUD sobre Cloud Firestore).
- Roles: **usuario** (gestiona solo lo suyo) y **administrador** (gestiona todo).
- Estados de carga, error con "Reintentar" y pantallas vacías.

## Arquitectura

Capas separadas y patrón MVVM con Riverpod:

```
lib/
├── core/            tema, colores, formato y utilidades de interfaz
├── data/
│   ├── repositories/  contrato PrendaRepository + versión local y versión Firestore
│   └── services/      autenticación (Firebase Auth)
├── domain/
│   └── entities/      Prenda, CarritoItem y Pedido
├── presentation/
│   ├── providers/     estado (Riverpod): prendas, carrito, pedidos, favoritos, sesión, rol, filtros
│   ├── screens/       pantallas
│   ├── widgets/       componentes reutilizables
│   └── router.dart    navegación con go_router
└── main.dart
```

Para cambiar de origen de datos basta con cambiar el repositorio en
`prendas_provider.dart` (`PrendaFirestoreRepository` o `PrendaLocalRepository`).

## Roles y seguridad

- El rol de cada cuenta vive en Firestore: `usuarios/{uid}.rol`.
- Todas las cuentas nuevas parten como `usuario`. El rol `admin` se asigna a
  mano en la consola de Firebase, para que nadie pueda darse ese permiso.
- Las reglas de Firestore están en [`firestore.rules`](firestore.rules) y hacen
  cumplir los permisos también en el servidor.

## Cómo ejecutarlo

Requisitos: Flutter 3.x, Android Studio con un emulador (o un celular Android) y
el archivo `android/app/google-services.json` del proyecto de Firebase.

```
flutter pub get
flutter run
```

## Pruebas

```
flutter test
```

Cubren la lógica del carrito, la navegación Explorar → Detalle, el CRUD del
repositorio, la serialización de la entidad, la compra, el historial de pedidos y los permisos por rol.

## Versiones

| Versión | Contenido |
| --- | --- |
| v0.1 | Diseño en Figma y documento de la idea |
| v0.2 | App con datos locales, carrito y CRUD |
| v0.3 | Login y registro con Firebase Authentication |
| v0.4 | Prendas en Cloud Firestore |
| v0.4.1 | Paleta de colores y arreglos de sesión |
| v0.5 | Roles de administrador y usuario, reglas de Firestore |
| v0.6 | Pruebas, README y pulido |
| v0.7 | Historial "Mis compras" (colección `pedidos`) y favoritos guardados en la cuenta |

Las capturas de cada versión están en `docs/`.
