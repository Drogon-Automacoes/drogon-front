import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_portoes_app/features/auth/logic/logic_cubit.dart';
import 'core/network/api_client.dart';
import 'features/auth/data/auth_service.dart';
import 'features/portoes/data/portoes_service.dart'; // <--- Importar
import 'features/portoes/logic/portoes_cubit.dart';
import 'features/logs/data/logs_service.dart'; // <--- Importe
import 'features/logs/logic/logs_cubit.dart';
import 'features/usuarios/data/usuarios_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- Externos e Core ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => ApiClient());

  // --- Auth ---
  sl.registerLazySingleton(() => AuthService(sl(), sl()));
  
  // --- Cubit 
  sl.registerFactory(() => LoginCubit(sl()));

  // --- Portoes ---
  sl.registerLazySingleton(() => PortoesService(sl()));
  sl.registerFactory(() => PortoesCubit(sl()));

  // --- Logs ---
  sl.registerLazySingleton(() => LogsService(sl()));
  sl.registerFactory(() => LogsCubit(sl()));

  // Usuarios
  sl.registerLazySingleton(() => UsuariosService(sl()));
}