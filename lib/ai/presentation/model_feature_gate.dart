import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../infrastructure/model_availability_service.dart';
import 'ai_model_settings_page.dart';

Future<bool> requireQwenModel(
  BuildContext context, {
  required String featureName,
  String? basicAlternative,
}) async {
  await ModelAvailabilityService.instance.refresh();
  if (ModelAvailabilityService.instance.qwen.isReady) return true;
  if (!context.mounted) return false;

  final install = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.elevation2,
      title: Text('$featureName needs the local AI model'),
      content: Text(
        'Download Qwen3 to use $featureName fully on this device.'
        '${basicAlternative == null ? '' : '\n\n$basicAlternative'}',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('View download'),
        ),
      ],
    ),
  );
  if (install == true && context.mounted) {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AiModelSettingsPage()));
    await ModelAvailabilityService.instance.refresh();
  }
  return false;
}

class ModelUpgradeNotice extends StatelessWidget {
  final String availableNow;
  final String enhancedWithModel;
  final VoidCallback onTap;

  const ModelUpgradeNotice({
    super.key,
    required this.availableNow,
    required this.enhancedWithModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$availableNow. $enhancedWithModel. Open model downloads.',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.elevation1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorderBright),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('$availableNow\n$enhancedWithModel')),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
