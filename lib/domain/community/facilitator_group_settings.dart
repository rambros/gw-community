/// Notification choices for one group this person facilitates.
class FacilitatorGroupSettings {
  const FacilitatorGroupSettings({
    required this.groupId,
    required this.groupName,
    this.notifyNewExperiences = true,
    this.notifyMessages = true,
    this.emailEachExperience = false,
    this.emailMemberMessage = true,
    this.emailDailySummary = false,
    this.emailWeeklySummary = false,
  });

  final int groupId;
  final String groupName;
  final bool notifyNewExperiences;
  final bool notifyMessages;
  final bool emailEachExperience;
  final bool emailMemberMessage;
  final bool emailDailySummary;
  final bool emailWeeklySummary;

  FacilitatorGroupSettings copyWith({
    bool? notifyNewExperiences,
    bool? notifyMessages,
    bool? emailEachExperience,
    bool? emailMemberMessage,
    bool? emailDailySummary,
    bool? emailWeeklySummary,
  }) {
    return FacilitatorGroupSettings(
      groupId: groupId,
      groupName: groupName,
      notifyNewExperiences: notifyNewExperiences ?? this.notifyNewExperiences,
      notifyMessages: notifyMessages ?? this.notifyMessages,
      emailEachExperience: emailEachExperience ?? this.emailEachExperience,
      emailMemberMessage: emailMemberMessage ?? this.emailMemberMessage,
      emailDailySummary: emailDailySummary ?? this.emailDailySummary,
      emailWeeklySummary: emailWeeklySummary ?? this.emailWeeklySummary,
    );
  }

  Map<String, dynamic> toRow(String userId) {
    return {
      'user_id': userId,
      'group_id': groupId,
      'notify_new_experiences': notifyNewExperiences,
      'notify_messages': notifyMessages,
      'email_each_experience': emailEachExperience,
      'email_member_message': emailMemberMessage,
      'email_daily_summary': emailDailySummary,
      'email_weekly_summary': emailWeeklySummary,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}
