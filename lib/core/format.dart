/// Formatea un monto en pesos chilenos: 4500 -> $4.500
String formatearPrecio(int valor) {
  final digitos = valor.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digitos.length; i++) {
    if (i > 0 && (digitos.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digitos[i]);
  }
  final signo = valor < 0 ? '-' : '';
  return '$signo\$${buffer.toString()}';
}
