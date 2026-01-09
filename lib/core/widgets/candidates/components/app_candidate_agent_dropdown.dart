import 'package:flutter/material.dart';
import 'package:ats/core/utils/app_styles/app_text_styles.dart';
import 'package:ats/core/utils/app_colors/app_colors.dart';
import 'package:ats/domain/entities/admin_profile_entity.dart';

class AppCandidateAgentDropdown extends StatelessWidget {
  final String userId;
  final String currentAgentName;
  final String? assignedAgentProfileId;
  final List<AdminProfileEntity> availableAgents;
  final Future<void> Function(String userId, String? agentId) onAgentChanged;

  const AppCandidateAgentDropdown({
    super.key,
    required this.userId,
    required this.currentAgentName,
    this.assignedAgentProfileId,
    required this.availableAgents,
    required this.onAgentChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Use the assignedAgentProfileId directly from the candidate profile
    // This is the profileId of the admin profile assigned to this candidate
    String? currentAgentProfileId = assignedAgentProfileId;

    // Validate that the profileId exists in available agents
    if (currentAgentProfileId != null && currentAgentProfileId.isNotEmpty) {
      final agentExists = availableAgents.any(
        (a) => a.profileId == currentAgentProfileId,
      );
      if (!agentExists) {
        // If the assigned agent is not in the available list, reset to null
        currentAgentProfileId = null;
      }
    }

    // Build dropdown items
    final items = <DropdownMenuItem<String>>[
      // Add "None" option
      DropdownMenuItem<String>(
        value: null,
        child: Text(
          'None',
          style: AppTextStyles.bodyText(context),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];

    // Add all available agents
    if (availableAgents.isEmpty) {
      // If no agents available, show a message
      items.add(
        DropdownMenuItem<String>(
          value: '',
          enabled: false,
          child: Text(
            'No agents available',
            style: AppTextStyles.bodyText(context).copyWith(
              color: AppColors.secondary.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    } else {
      // Add available agents - use profileId as the value
      items.addAll(
        availableAgents.map((agent) {
          return DropdownMenuItem<String>(
            value: agent.profileId,
            child: Text(
              agent.name.isNotEmpty ? agent.name : 'Unknown Agent',
              style: AppTextStyles.bodyText(context),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
      );
    }

    return DropdownButton<String>(
      value: currentAgentProfileId,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      hint: Text(
        availableAgents.isEmpty ? 'Loading agents...' : 'Select Agent',
        style: AppTextStyles.bodyText(context),
        overflow: TextOverflow.ellipsis,
      ),
      items: items,
      onChanged: availableAgents.isEmpty
          ? null // Disable dropdown if no agents available
          : (String? newAgentProfileId) {
              if (newAgentProfileId != currentAgentProfileId &&
                  newAgentProfileId != '') {
                onAgentChanged(userId, newAgentProfileId);
              }
            },
    );
  }
}
