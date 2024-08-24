import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(asExtension: false)
Future<void> initDi(String flavor) async {
  init(
    getIt,
    environmentFilter: NoEnvOrContains(flavor),
  );
  return getIt.allReady();
}
