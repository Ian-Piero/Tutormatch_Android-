# TutorMatch — Flutter App

App móvil Android/iOS para encontrar tutores. Convertida del prototipo HTML a Flutter con Provider.

---

## Estructura del proyecto

```
lib/
├── main.dart                     ← Punto de entrada
├── theme/
│   └── app_theme.dart            ← Colores, tipografía, ThemeData
├── models/
│   └── models.dart               ← Tutor, Reserva, Usuario, DemoData
├── providers/
│   └── app_provider.dart         ← Estado global (auth, tutores, reservas)
├── screens/
│   ├── login_screen.dart         ← Pantalla de login/registro
│   ├── home_screen.dart          ← Shell con BottomNavigationBar
│   ├── inicio_tab.dart           ← Tab Inicio (stats + tutores destacados)
│   ├── tutores_tab.dart          ← Tab Buscar (búsqueda + filtros)
│   └── reservas_tab.dart         ← Tab Mis Reservas
└── widgets/
    ├── tutor_card.dart           ← Card reutilizable de tutor
    └── modal_reserva.dart        ← BottomSheet de crear reserva
```

---

## ¿Cómo abrir en Android Studio?

### 1. Requisitos previos
- Flutter SDK instalado (https://flutter.dev/docs/get-started/install)
- Android Studio con plugin Flutter y Dart instalados
- Un emulador Android o dispositivo físico

### 2. Pasos

```bash
# 1. Copia la carpeta tutormatch_flutter a tu máquina

# 2. Abre Android Studio → File → Open → selecciona la carpeta tutormatch_flutter

# 3. Instala dependencias (en la terminal de Android Studio)
flutter pub get

# 4. Ejecuta la app
flutter run
```

### 3. Si usas emulador Android
- Tools → AVD Manager → crea un emulador (API 33+ recomendado)
- Corre `flutter run` o presiona el botón ▶️

---

## Credenciales demo

| Usuario       | Email                   | Contraseña |
|---------------|-------------------------|------------|
| Carlos Mendoza| carlos@uni.edu          | 123456     |
| Sofía López   | sofia@uni.edu           | 123456     |
| Admin General | admin@tutormatch.pe     | admin123   |

---

## Dependencias usadas

| Paquete        | Versión | Para qué sirve                      |
|----------------|---------|--------------------------------------|
| provider       | ^6.1.2  | Manejo de estado global              |
| google_fonts   | ^6.2.1  | Fuentes Nunito + Space Mono          |
| intl           | ^0.19.0 | Formateo de fechas                   |

---

## Flujo de la app

```
LoginScreen
    │
    └──► HomeScreen (BottomNav: Inicio / Buscar / Reservas)
              ├── InicioTab      → Stats + tutores destacados
              ├── TutoresTab     → Búsqueda con filtro disponibles
              │        └── TutorCard → onTap → ModalReserva (BottomSheet)
              └── ReservasTab    → Lista con filtros de estado
                       └── Acciones: Cancelar / Marcar completada
```

---

## Para conectar el backend Node.js (cuando esté listo)

En `lib/providers/app_provider.dart`, reemplaza los métodos `login()`, `cargarTutores()`, etc.
con llamadas HTTP usando el paquete `http` o `dio`:

```dart
// pubspec.yaml: agrega  http: ^1.2.0

import 'package:http/http.dart' as http;
import 'dart:convert';

const _base = 'http://10.0.2.2:3000/api'; // 10.0.2.2 = localhost en emulador Android

Future<void> cargarTutores() async {
  final res = await http.get(
    Uri.parse('$_base/tutores'),
    headers: {'Authorization': 'Bearer $token'},
  );
  final data = jsonDecode(res.body);
  _tutores = (data['tutores'] as List).map((j) => Tutor.fromJson(j)).toList();
  notifyListeners();
}
```
