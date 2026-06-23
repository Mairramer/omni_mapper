import 'package:omni_mapper/omni_mapper.dart';

part 'collection_strategies.g.dart';

class SystemConfig {
  final Map<String, String> environmentVars;
  final Set<String> activeRoles;
  final List<String> errorLogs;

  SystemConfig({
    required this.environmentVars,
    required this.activeRoles,
    required this.errorLogs,
  });
}

@OmniMapper(
  target: SystemConfig,
  generateUpdateMethod: true,
)
class ConfigUpdatePayload {
  // Uses 'append' to merge new map entries without deleting existing environment variables
  @OmniField(collectionUpdateStrategy: CollectionUpdateStrategy.append)
  final Map<String, String> environmentVars;

  // Uses 'clearAndAddAll' to completely replace the active roles set
  @OmniField(collectionUpdateStrategy: CollectionUpdateStrategy.clearAndAddAll)
  final Set<String> activeRoles;

  // Uses 'append' to add new logs to the end of the existing error logs list
  @OmniField(collectionUpdateStrategy: CollectionUpdateStrategy.append)
  final List<String> errorLogs;

  ConfigUpdatePayload({
    required this.environmentVars,
    required this.activeRoles,
    required this.errorLogs,
  });
}
