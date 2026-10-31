import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/executor/acp/acp_executor.dart';
import '../../../domain/executor/executor.dart';
import '../../../domain/profile/server_profile.dart';

part 'executor_factory.g.dart';

/// Builds the executor for a connected profile.
///
/// ACP is the only implementation today. Keeping construction behind this
/// function means the manager never names it, and a test can hand the manager a
/// scripted executor without touching the network.
typedef ExecutorFactory = Executor Function(ConnectedProfile profile);

@Riverpod(keepAlive: true)
ExecutorFactory executorFactory(Ref ref) =>
    (profile) => AcpExecutor(profile: profile);
