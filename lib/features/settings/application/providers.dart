import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/providers.dart';
import '../data/profile_repository.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
ProfileRepository profileRepository(Ref ref) => ProfileRepository(
  ref.watch(preferencesProvider),
  ref.watch(secureStoreProvider),
);
