import '../domain/core_action_v5.dart';

enum ActionConfirmationPolicy { never, beforeWrite, beforeSend }

class ActionProviderResult {
  final bool succeeded;
  final String? externalId;
  final String? errorCode;

  const ActionProviderResult.success({this.externalId})
    : succeeded = true,
      errorCode = null;

  const ActionProviderResult.failure(this.errorCode)
    : succeeded = false,
      externalId = null;
}

abstract interface class ActionProvider {
  String get name;
  int get version;
  ActionConfirmationPolicy get confirmationPolicy;
  Set<String> get requiredArgumentKeys;
  Set<String> get requiredPermissions;

  List<String> validateArguments(Map<String, dynamic> arguments);

  Future<ActionProviderResult> execute(Map<String, dynamic> arguments);
}

class ActionProviderRegistry {
  final Map<String, ActionProvider> _providers = {};

  Iterable<ActionProvider> get providers => _providers.values;

  void register(ActionProvider provider) {
    if (!coreV5ToolForIntent.containsValue(provider.name)) {
      throw ArgumentError.value(
        provider.name,
        'provider.name',
        'not present in the Core v5 contract',
      );
    }
    if (_providers.containsKey(provider.name)) {
      throw StateError('Provider ${provider.name} is already registered.');
    }
    _providers[provider.name] = provider;
  }

  List<String> validateProposal(CoreV5Envelope envelope) {
    final name = envelope.proposedTool.name;
    if (name == null) return const [];
    final provider = _providers[name];
    if (provider == null) return ['No registered provider for $name'];
    final errors = <String>[];
    final missing = provider.requiredArgumentKeys.difference(
      envelope.proposedTool.arguments.keys.toSet(),
    );
    if (missing.isNotEmpty) {
      errors.add('Missing provider arguments: ${missing.join(', ')}');
    }
    errors.addAll(provider.validateArguments(envelope.proposedTool.arguments));
    return errors;
  }

  Future<ActionProviderResult> execute(
    CoreV5Envelope envelope, {
    required bool userConfirmed,
    required Set<String> grantedPermissions,
  }) async {
    final name = envelope.proposedTool.name;
    if (name == null) {
      return const ActionProviderResult.failure('no_proposed_tool');
    }
    final provider = _providers[name];
    if (provider == null) {
      return const ActionProviderResult.failure('provider_not_registered');
    }
    if (validateProposal(envelope).isNotEmpty) {
      return const ActionProviderResult.failure('invalid_arguments');
    }
    if (!grantedPermissions.containsAll(provider.requiredPermissions)) {
      return const ActionProviderResult.failure('permission_required');
    }
    final confirmationRequired =
        envelope.requiresConfirmation ||
        provider.confirmationPolicy != ActionConfirmationPolicy.never;
    if (confirmationRequired && !userConfirmed) {
      return const ActionProviderResult.failure('confirmation_required');
    }
    return provider.execute(envelope.proposedTool.arguments);
  }
}
