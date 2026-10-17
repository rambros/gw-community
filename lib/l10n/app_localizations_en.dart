// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navLibrary => 'Library';

  @override
  String get navJourney => 'Journey';

  @override
  String get navCommunity => 'Community';

  @override
  String get navProfile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get journeyContents => 'Contents';

  @override
  String get start => 'Start';

  @override
  String get resume => 'Resume';

  @override
  String get startUpper => 'START';

  @override
  String get learnMore => 'Learn more';

  @override
  String get resumeUpper => 'RESUME';

  @override
  String get completedUpper => 'COMPLETED';

  @override
  String get viewAgain => 'VIEW AGAIN';

  @override
  String get viewMore => 'View more';

  @override
  String get seeAllJourneys => 'See all';

  @override
  String get seeAllGroups => 'See all';

  @override
  String get journeys => 'Journeys';

  @override
  String get myJourneys => 'My Journeys';

  @override
  String get otherJourneys => 'Other Journeys';

  @override
  String get untitledJourney => 'Untitled Journey';

  @override
  String get noJourneysStarted => 'No journeys started yet';

  @override
  String get noJourneysStartedYet => 'You haven\'t started any journeys yet';

  @override
  String get noOtherJourneys => 'No other journeys available';

  @override
  String stepsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steps',
      one: '1 step',
    );
    return '$_temp0';
  }

  @override
  String stepsProgress(int completed, int total) {
    return 'Completed $completed of $total steps';
  }

  @override
  String get publicLabel => 'public';

  @override
  String get privateLabel => 'private';

  @override
  String get groupPrivacyPublic => 'Public';

  @override
  String get groupPrivacyPrivate => 'Private';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get lastPostJustNow => 'Last post just now';

  @override
  String lastPostMinutesAgo(int minutes) {
    return 'Last post $minutes min ago';
  }

  @override
  String lastPostHoursAgo(int hours) {
    return 'Last post $hours h ago';
  }

  @override
  String lastPostDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last post $count days ago',
      one: 'Last post 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String lastPostOn(String date) {
    return 'Last post $date';
  }

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String groupMetaLine(String privacy, String members) {
    return '$privacy - $members';
  }

  @override
  String groupMetaDetails(String privacy, String members) {
    return '$privacy group - $members';
  }

  @override
  String get deleteGroup => 'Delete Group';

  @override
  String confirmDeleteGroup(String name) {
    return 'Confirm deletion of group named $name';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get groupDeleted => 'Group deleted with success';

  @override
  String get welcomeComma => 'Welcome,';

  @override
  String get communityTagline =>
      'A community that shares good wishes\nto create a better world';

  @override
  String get splashWelcomeTitle => 'Welcome to Good Wishes';

  @override
  String get splashWelcomeSubtitle =>
      'A community that shares good wishes to create a better world';

  @override
  String get myGroups => 'My Groups';

  @override
  String get otherGroups => 'Other Groups';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get profile => 'Profile';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changePassword => 'Change Password';

  @override
  String get setNotifications => 'Set Notifications';

  @override
  String get editGuidelines => 'Edit Guidelines';

  @override
  String get viewAsUser => 'View as user';

  @override
  String get viewAsSearchHint => 'Name or email';

  @override
  String get viewAsSearchMin => 'Type at least 3 characters.';

  @override
  String get viewAsNoResults => 'No members found.';

  @override
  String get viewAsReadOnlyNote =>
      'You can look at this member\'s groups and journeys. Nothing will be created or changed.';

  @override
  String viewingAs(String name) {
    return 'Viewing as $name';
  }

  @override
  String get exitViewAs => 'Exit';

  @override
  String get resetTips => 'Reset Tips';

  @override
  String get tipsReset => 'Tips reset — switching tabs will show them again.';

  @override
  String get myFavorites => 'My Favorites';

  @override
  String get myJournal => 'My Journal';

  @override
  String get myExperiences => 'My Experiences';

  @override
  String get askAQuestion => 'Ask a Question';

  @override
  String get communityGuidelines => 'Community Guidelines';

  @override
  String get logOut => 'Log Out';

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get library => 'Library';

  @override
  String get community => 'Community';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get yourEmail => 'Your email';

  @override
  String get yourPassword => 'Your password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get enterValidEmail => 'Enter a valid email';

  @override
  String get fieldRequired => 'Field is required';

  @override
  String get accessAccountBelow => 'Access your account below.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get sendAccessLink => 'Send Access Link';

  @override
  String get magicLinkHint =>
      'Enter your email to receive a secure access link.';

  @override
  String get emailNotRegistered =>
      'Email not registered. Contact your administrator.';

  @override
  String get errorSendingLink => 'Error sending link. Please try again.';

  @override
  String get checkYourEmail => 'Check your email!';

  @override
  String magicLinkSentTo(String email) {
    return 'We sent an access link to $email. Tap it to sign in.';
  }

  @override
  String get linkSentAgain => 'Link sent again. Check your inbox.';

  @override
  String get resendLink => 'Resend link';

  @override
  String get signInWithPassword => 'Sign in with password →';

  @override
  String get signInWithoutPassword => '← Sign in without password';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotificationsYet => 'No notifications yet';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get deleteRead => 'Delete read';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get notificationsNew => 'New';

  @override
  String get notificationsRead => 'Read';

  @override
  String get deleteReadNotifications => 'Delete read notifications';

  @override
  String get confirmDeleteReadNotifications =>
      'Are you sure you want to delete all read notifications?';

  @override
  String get deleteAllNotifications => 'Delete all notifications';

  @override
  String get confirmDeleteAllNotifications =>
      'Are you sure you want to delete all system notifications? This cannot be undone.';

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgoShort(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String hoursAgoShort(int hours) {
    return '${hours}h ago';
  }

  @override
  String daysAgoShort(int days) {
    return '${days}d ago';
  }

  @override
  String get yourProfile => 'Your Profile';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get displayName => 'Display Name';

  @override
  String get hideMyLastName => 'Hide my last name';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get nameFallback => 'Name';

  @override
  String get signUp => 'Sign Up';

  @override
  String get hideLastNameHint =>
      'You can hide your last name in your profile if you like.';

  @override
  String get agreeToTermsPrefix =>
      'By creating an account, you are agreeing to our ';

  @override
  String get termsAndConditions => 'Terms & Conditions ';

  @override
  String get andWord => 'and ';

  @override
  String get privacyPolicy => 'Privacy Policy.';

  @override
  String get completeSetup => 'Complete Setup';

  @override
  String get resetOnboardingTitle => 'Reset onboarding experience';

  @override
  String get resetOnboardingDescription =>
      'We will clear your onboarding progress so you can go through the introduction again.';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get onboardingResetSuccess => 'Onboarding reset successfully.';

  @override
  String errorResettingOnboarding(String error) {
    return 'Error resetting onboarding: $error';
  }

  @override
  String errorLoggingOut(String error) {
    return 'Error logging out: $error';
  }

  @override
  String get yourJournalEntry => 'Your Journal Entry';

  @override
  String get journalEntriesPrivate =>
      'Your journal entries are private and secure.';

  @override
  String get noJournalEntries => 'No journal entries found.';

  @override
  String get journalEntryNotFound => 'Journal entry not found.';

  @override
  String get journeyLabel => 'Journey';

  @override
  String get journalSaved => 'Journal saved';

  @override
  String get saving => 'Saving...';

  @override
  String get edit => 'Edit';

  @override
  String get deletionOfJournalEntry => 'Deletion of journal entry';

  @override
  String get confirmDeleteJournalEntry => 'Confirm deletion of this entry?';

  @override
  String get clearing => 'Clearing...';

  @override
  String get clearEntry => 'Clear entry';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get noExperiencesYet => 'No experiences yet';

  @override
  String get group => 'Group';

  @override
  String get allGroups => 'All Groups';

  @override
  String get status => 'Status';

  @override
  String get allStatus => 'All Status';

  @override
  String get published => 'Published';

  @override
  String get inReflection => 'In Reflection';

  @override
  String get awaitingApproval => 'Awaiting Approval';

  @override
  String get notPublished => 'Not Published';

  @override
  String get refinementSuggested => 'Refinement Suggested';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get deleteExperience => 'Delete Experience';

  @override
  String get confirmDeleteExperience =>
      'Are you sure you want to delete this experience? This action cannot be undone.';

  @override
  String get experienceDeleted => 'Experience deleted successfully';

  @override
  String get publishExperience => 'Publish Experience';

  @override
  String get confirmPublishExperience =>
      'Are you sure you want to publish this experience? It will be sent for moderation review.';

  @override
  String get experiencePublished => 'Experience published successfully';

  @override
  String get view => 'View';

  @override
  String get submit => 'Submit';

  @override
  String get revise => 'Revise';

  @override
  String get publish => 'Publish';

  @override
  String get visibleForEveryone => 'Visible for everyone';

  @override
  String get groupOnly => 'Group only';

  @override
  String get userFallback => 'User';

  @override
  String get enterNewPasswordBelow => 'Enter your new password below.';

  @override
  String get newPassword => 'New Password';

  @override
  String get enterNewPassword => 'Enter new password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordUpdated => 'Password updated successfully';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsSubtitle =>
      'Receive alerts on your device even when the app is closed.';

  @override
  String get inAppNotifications => 'In-App Notifications';

  @override
  String get inAppNotificationsSubtitle =>
      'Show the notification bell and alerts inside the app.';

  @override
  String get startSharingExperiences =>
      'Share your experiences with the community!';

  @override
  String visibleOnlyFor(String group) {
    return 'Visible only for $group';
  }

  @override
  String get save => 'Save';

  @override
  String get markdownSupported =>
      'Markdown supported: **bold**, *italic*, # heading, - list';

  @override
  String get enterGuidelinesHint => 'Enter community guidelines here...';

  @override
  String get enterEnglishGuidelinesHint =>
      'Enter the English guidelines here...';

  @override
  String get enterPortugueseGuidelinesHint =>
      'Enter the Portuguese guidelines here...';

  @override
  String get guidelinesVersionsHint =>
      'The app shows the version that matches the participant\'s language. If Portuguese is empty, English is used.';

  @override
  String get noGuidelinesYet => 'No guidelines available yet.';

  @override
  String get guidelinesSaved => 'Guidelines saved successfully!';

  @override
  String failedToSaveGuidelines(String error) {
    return 'Failed to save guidelines: $error';
  }

  @override
  String get myQuestions => 'My Questions';

  @override
  String get supportFilterAll => 'All';

  @override
  String get supportFilterOpen => 'Open';

  @override
  String get supportFilterCompleted => 'Completed';

  @override
  String get failedToLoadQuestions => 'Failed to load questions';

  @override
  String get noQuestionsYet => 'No questions yet';

  @override
  String get noQuestionsFound => 'No questions found';

  @override
  String get haveAQuestionHelp => 'Have a question? We\'re here to help!';

  @override
  String get tryChangingFilter => 'Try changing your filter';

  @override
  String get deleteQuestion => 'Delete Question';

  @override
  String get confirmDeleteQuestion =>
      'Are you sure you want to delete this question? This action cannot be undone.';

  @override
  String get questionDeleted => 'Question deleted successfully';

  @override
  String get subject => 'Subject';

  @override
  String get description => 'Description';

  @override
  String get subjectHint => 'Brief summary of your question';

  @override
  String get descriptionHint => 'Please provide as much detail as possible...';

  @override
  String get submitQuestion => 'Submit Question';

  @override
  String get questionAbout => 'Question about:';

  @override
  String get questionSubmitted => 'Question submitted successfully!';

  @override
  String get pleaseEnterSubject => 'Please enter a subject for your question';

  @override
  String get subjectMinLength => 'Subject must be at least 5 characters';

  @override
  String get pleaseDescribeQuestion => 'Please describe your question';

  @override
  String get descriptionMinLength =>
      'Description must be at least 20 characters';

  @override
  String get failedToCreateQuestion =>
      'Failed to create question. Please try again.';

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get question => 'Question';

  @override
  String get questionNotFound => 'Question not found';

  @override
  String get markAsCompleted => 'Mark as Completed';

  @override
  String get reopenQuestion => 'Reopen Question';

  @override
  String askedOn(String date) {
    return 'Asked on $date';
  }

  @override
  String referenceNumber(String number) {
    return 'Reference $number';
  }

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get sendMessageToStart => 'Send a message to start the conversation';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get questionHasBeenCompleted => 'This question has been completed';

  @override
  String get reopen => 'Reopen';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get takeAPhoto => 'Take a Photo';

  @override
  String get confirmMarkCompleted =>
      'Are you sure your question has been answered? You can reopen it later if needed.';

  @override
  String get questionMarkedCompleted => 'Question marked as completed';

  @override
  String get confirmReopenQuestion =>
      'Do you need further assistance with this question?';

  @override
  String get questionReopened => 'Question reopened';

  @override
  String get supportTeam => 'Support';

  @override
  String get supportStatusOpen => 'Open';

  @override
  String get supportStatusReviewed => 'Being Reviewed';

  @override
  String get supportStatusNeedsResponse => 'Needs Your Response';

  @override
  String get supportStatusCompleted => 'Completed';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get failedToSendMessage => 'Failed to send message';

  @override
  String errorSendingMessage(String error) {
    return 'Error sending message: $error';
  }

  @override
  String get noFavoritesYet => 'No favorites yet';

  @override
  String get tapHeartToCollectPrefix => 'Tap ';

  @override
  String get tapHeartToCollectSuffix =>
      ' throughout the app to collect your favorites';

  @override
  String get failedToLoadFavorites => 'Failed to load favorites';

  @override
  String get fromLibrary => 'From Library';

  @override
  String get fromJourney => 'From Journey';

  @override
  String fromSource(String title) {
    return 'From $title';
  }

  @override
  String stepWithTitle(int number, String title) {
    return 'Step $number: $title';
  }

  @override
  String journeyStepHeader(int number) {
    return 'Step $number';
  }

  @override
  String get journeyActivityInspiration => 'Inspiration';

  @override
  String get journeyActivityMeditation => 'Meditation';

  @override
  String get journeyActivityPractices => 'Practices';

  @override
  String get optionalActivity => 'Optional';

  @override
  String get mediaAudio => 'Audio';

  @override
  String get mediaVideo => 'Video';

  @override
  String get mediaText => 'Text';

  @override
  String get mediaJournal => 'Journal';

  @override
  String get untitled => 'Untitled';

  @override
  String get activityFallback => 'Activity';

  @override
  String get communityHintTitle => 'The power of community';

  @override
  String get communityHintMessage =>
      'Join a community to connect and share experiences, encouraging thoughts, ideas, and content for self-development.';

  @override
  String get libraryHintTitle => 'Explore and grow';

  @override
  String get libraryHintMessage =>
      'Access a growing collection of reflections, meditations, and resources to deepen your practice and support your spiritual development.';

  @override
  String get journeyHintTitle => 'Welcome to a wonderful journey!';

  @override
  String get journeyHintMessage =>
      'Learn, create, and share good wishes that make a real impact. Discover inspiration, meditations, and daily practices for personal and world transformation.';

  @override
  String get onboardingJourneyTitle => 'Journey';

  @override
  String get onboardingJourneyBody =>
      'Welcome to a wonderful journey! A journey to learn, create and share good wishes that have an impact. Good wishes are a way for self-transformation and world transformation. You will find inspirations, meditations, daily practices and companionship…';

  @override
  String get onboardingLearnTitle => 'Learn';

  @override
  String get onboardingLearnBody =>
      'When you feel that you would like to learn more, clarify or deepen your understanding and experience, new content and references are available to help you with your practice and personal progress…';

  @override
  String get onboardingCommunityTitle => 'Community';

  @override
  String get onboardingCommunityBody =>
      'Collective good wishes are powerful. As you move along you will be part of a community of good wishers, available to help one another through the exchange of a heart-felt feelings that gives hope, strength and support… the basis for a new world.';

  @override
  String get onboardingBeginsTitle => 'Your Journey Begins';

  @override
  String get onboardingBeginsSubtitle =>
      'Sign up below in order to get started!';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get searchAllContent => 'Search all content...';

  @override
  String get filter => 'Filter';

  @override
  String get listOfAllContent => 'List of All Content';

  @override
  String get listOfContents => 'List of Contents';

  @override
  String get clearFilter => 'Clear Filter';

  @override
  String get noContentFound => 'No content found';

  @override
  String get tryAdjustingFilters =>
      'Try adjusting your filters or search terms';

  @override
  String get transcript => 'Transcript';

  @override
  String get contentFilter => 'Content Filter';

  @override
  String get author => 'Author';

  @override
  String get event => 'Event';

  @override
  String get year => 'Year';

  @override
  String get topics => 'Topics';

  @override
  String get selectAuthor => 'Select Author';

  @override
  String get selectEvent => 'Select Event';

  @override
  String get selectYear => 'Select Year';

  @override
  String get selectTopics => 'Select Topics';

  @override
  String get searchAuthor => 'Search for an author...';

  @override
  String get searchEvent => 'Search for an event...';

  @override
  String get searchYear => 'Search for a year...';

  @override
  String get searchTapOutsideToClose => 'Search... (tap outside to close)';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortByRelevance => 'Relevance';

  @override
  String get sortByDateNewest => 'Date (newest first)';

  @override
  String get sortByDateOldest => 'Date (oldest first)';

  @override
  String get sortByTitleAZ => 'Title (A-Z)';

  @override
  String get sortByTitleZA => 'Title (Z-A)';

  @override
  String clearNamedFilter(String label) {
    return 'Clear $label filter';
  }

  @override
  String get portalContentLibrary => 'Portal Content Library';

  @override
  String get portalHubTitle => 'The Call of the Time Portal';

  @override
  String get portalDialoguesRetreats => 'Dialogues & Retreats';

  @override
  String get portalHeartToHeart => 'Heart to Heart Conversations';

  @override
  String get libraryHeaderHeartToHeart => 'Heart to Heart';

  @override
  String get libraryHeaderMeditation => 'Meditation';

  @override
  String get portalMessages => 'Messages';

  @override
  String get wordsOfWisdom => 'Words of Wisdom';

  @override
  String get portalDadiJanki => 'Dadi Janki';

  @override
  String get portalMeditations => 'Meditations';

  @override
  String get portalListOfAllMessages => 'List of All Messages';

  @override
  String get portalListOfAllMeditations => 'List of All Meditations';

  @override
  String get portalListOfAllDadiJanki => 'List of All Content with Dadi Janki';

  @override
  String get portalListOfAllDialogues => 'List of All Dialogues & Retreats';

  @override
  String get portalListOfAllHeartToHeart =>
      'List of All Heart to Heart Conversations';

  @override
  String get portalEventContents => 'Event contents';

  @override
  String get searchForADialogue => 'Search for a dialogue...';

  @override
  String get searchForAConversation => 'Search for a conversation...';

  @override
  String get searchForAMessage => 'Search for a message...';

  @override
  String get searchForAMeditation => 'Search for a meditation...';

  @override
  String get searchForContent => 'Search for content...';

  @override
  String speakers(String names) {
    return 'Speakers: $names';
  }

  @override
  String mainSpeakers(String names) {
    return 'Main Speakers: $names';
  }

  @override
  String locationValue(String value) {
    return 'Location: $value';
  }

  @override
  String eventStartEnd(String start, String end) {
    return 'Start $start - End $end';
  }

  @override
  String get listOfRecordings => 'List of Recordings';

  @override
  String get eventFilter => 'Event Filter';

  @override
  String messageYear(String year) {
    return 'Message - $year';
  }

  @override
  String fromAuthors(String names) {
    return 'From $names';
  }

  @override
  String filterByLocation(String value) {
    return 'Location: $value';
  }

  @override
  String filterByEventType(String value) {
    return 'Event type: $value';
  }

  @override
  String messageFromAuthors(String authors) {
    return 'Message from $authors';
  }

  @override
  String get shareContent => 'Share';

  @override
  String get location => 'Location';

  @override
  String get eventType => 'Event Type';

  @override
  String get selectLocation => 'Select location';

  @override
  String get selectEventType => 'Select event type';

  @override
  String get orSeparator => 'or';

  @override
  String withAuthors(String names) {
    return 'With $names';
  }

  @override
  String atEvent(String event) {
    return 'at $event';
  }

  @override
  String get linkToGroups => 'Link to Groups';

  @override
  String get linkToJourneys => 'Link to Journeys';

  @override
  String get activityLinkedToStep => 'Activity added to the step.';

  @override
  String get failedToLinkActivity => 'Could not add the activity.';

  @override
  String get couldNotLoadLinkActivity => 'Could not load.';

  @override
  String get noJourneysToLink =>
      'No journeys are linked to the groups you manage.';

  @override
  String get noJourneysAvailable => 'No journeys available.';

  @override
  String noJourneysMatch(String query) {
    return 'No journeys match \"$query\".';
  }

  @override
  String get searchJourneys => 'Search journeys…';

  @override
  String get selectJourney => 'Select a journey';

  @override
  String get selectStep => 'Select a step';

  @override
  String get noStepsInJourney => 'This journey has no steps.';

  @override
  String noStepsMatch(String query) {
    return 'No steps match \"$query\".';
  }

  @override
  String get searchSteps => 'Search steps…';

  @override
  String get activityLabel => 'Activity label';

  @override
  String get activityLabelCustom => 'Custom label';

  @override
  String get customActivityLabel => 'Custom';

  @override
  String get activityTypeLabel => 'Type';

  @override
  String get activityTypeAudio => 'Audio';

  @override
  String get activityTypeVideo => 'Video';

  @override
  String get activityTypePdf => 'PDF';

  @override
  String get activityTypeText => 'Text';

  @override
  String get activityPromptLabel => 'Prompt';

  @override
  String get activityOrder => 'Order in step';

  @override
  String get activityRequiredHelp =>
      'Must be finished before the next step can open.';

  @override
  String get activityOptionalHelp =>
      'Optional. It does not count toward opening the next step.';

  @override
  String get activityAudioUrl => 'Audio URL';

  @override
  String get activityAudioFilename => 'File name';

  @override
  String get activityAudioDuration => 'Duration';

  @override
  String get activityVideoUrl => 'Video URL';

  @override
  String get activityPdfUrl => 'PDF URL';

  @override
  String get activityTextBody => 'Text';

  @override
  String get activityLibraryTextCopied =>
      'The library text is copied into this activity.';

  @override
  String get activityLibraryTextMissing =>
      'This library item has no text to copy.';

  @override
  String get activityMediaMissing =>
      'Add the file or text for this activity type.';

  @override
  String get activityLabelRequired => 'Choose a label.';

  @override
  String get activityLabelTooLong => 'Label must be 40 characters or less.';

  @override
  String get activityPromptRequired => 'Write a prompt.';

  @override
  String get activityPromptTooLong => 'Prompt must be 130 characters or less.';

  @override
  String get activityOrderInvalid => 'Order must be 1 or more.';

  @override
  String get addActivity => 'Add activity';

  @override
  String stepNumberLabel(int number) {
    return 'Step $number';
  }

  @override
  String get groupLinksUpdated => 'Group links updated.';

  @override
  String get failedToUpdateLinks => 'Failed to update links.';

  @override
  String get noGroupsAvailable => 'No groups available.';

  @override
  String noGroupsMatch(String query) {
    return 'No groups match \"$query\".';
  }

  @override
  String get searchGroups => 'Search groups…';

  @override
  String get willBeUnlinked => 'Will be unlinked';

  @override
  String get willBeLinked => 'Will be linked';

  @override
  String get noFilter => 'No filter';

  @override
  String filteredBySearch(String query) {
    return 'Filtered by Search Field → $query';
  }

  @override
  String filtersApplied(String filters) {
    return 'Filters → $filters';
  }

  @override
  String filterByAuthor(String value) {
    return 'Author: $value';
  }

  @override
  String filterByEvent(String value) {
    return 'Event: $value';
  }

  @override
  String filterByYear(String value) {
    return 'Year: $value';
  }

  @override
  String filterByJourney(String value) {
    return 'Journey: $value';
  }

  @override
  String filterByGroup(String value) {
    return 'Group: $value';
  }

  @override
  String filterByTopics(String value) {
    return 'Topics: $value';
  }

  @override
  String get about => 'About';

  @override
  String get aboutGroup => 'About Group';

  @override
  String get aboutThisGroup => 'About this group';

  @override
  String get leaveGroup => 'Leave Group';

  @override
  String get leaveTheGroup => 'Leave the Group';

  @override
  String get leave => 'Leave';

  @override
  String get confirmLeaveGroup => 'Are you sure you want to leave this group?';

  @override
  String get leftGroupSuccessfully => 'Left the group successfully';

  @override
  String get editGroup => 'Edit Group';

  @override
  String get newGroup => 'New Group';

  @override
  String get createGroup => 'Create Group';

  @override
  String get updateGroup => 'Update Group';

  @override
  String get joinGroup => 'Join Group';

  @override
  String get joinedGroupSuccessfully =>
      'You have joined the group successfully';

  @override
  String get groupNotFound => 'Group Not Found';

  @override
  String get groupInformationMissing => 'Group information is missing.';

  @override
  String get privateGroupInviteOnly =>
      'This is a private group. You need an invitation to join and see the content.';

  @override
  String get facilitators => 'Facilitators';

  @override
  String get members => 'Members';

  @override
  String get noMembersFound => 'No members found.';

  @override
  String get noMembersInGroup => 'No members in this group';

  @override
  String get unknown => 'Unknown';

  @override
  String get tabExperiences => 'Experiences';

  @override
  String get tabEvents => 'Events';

  @override
  String get tabMessages => 'Messages';

  @override
  String get tabResources => 'Resources';

  @override
  String get newExperience => 'New experience';

  @override
  String get shareExperiencesSpace =>
      'A space to share your experiences, inspire others, and receive good wishes from the community';

  @override
  String get experienceUnpublished => 'Experience unpublished';

  @override
  String get experiencesInspire => 'Experience experiences that inspire';

  @override
  String get errorLoadingExperiences => 'Error loading experiences';

  @override
  String get beFirstToShareExperience =>
      'Be the first to share an experience with everyone';

  @override
  String get noExperiencesYetPeriod => 'No experiences yet.';

  @override
  String fromGroup(String name) {
    return 'From group $name';
  }

  @override
  String get likedShareExperience => 'How about sharing your experience?';

  @override
  String get shareInGroups => 'Share in';

  @override
  String get chooseGroups => 'Choose groups';

  @override
  String get chooseOneOrMoreGroups =>
      'Choose one or more groups where you want to share your experience.';

  @override
  String get noGroupsToShare => 'Join a group to share your experience.';

  @override
  String get shareYourExperience => 'Share your experience';

  @override
  String get writeAboutExperience => 'Write about your experience...';

  @override
  String get enableComments => 'Enable comments';

  @override
  String get draft => 'Draft';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get experienceNotFound => 'Experience not found';

  @override
  String get editExperience => 'Edit Experience';

  @override
  String get draftNotPublishedYet => 'Draft - Not published yet';

  @override
  String get update => 'Update';

  @override
  String get noCommentsYet => 'No comments yet';

  @override
  String get noCommentsYetPeriod => 'No comments yet.';

  @override
  String get confirmDeleteThisExperience =>
      'Confirm deletion of this experience?';

  @override
  String get confirmDeleteThisComment => 'Confirm deletion of this comment?';

  @override
  String get withdrawExperienceTitle => 'Withdraw this experience?';

  @override
  String get withdrawExperienceMessage =>
      'It will be permanently removed from the group and cannot be restored.';

  @override
  String get unpublish => 'Unpublish';

  @override
  String get unpublishExperienceTitle => 'Unpublish this experience?';

  @override
  String get unpublishExperienceMessage =>
      'The experience will be removed from public view.';

  @override
  String get welcomeToReviseExperience =>
      'You’re welcome to revise and share again whenever you feel ready.';

  @override
  String get suggestionsSharedToRefine =>
      'Suggestions were shared to help refine this experience.';

  @override
  String get newEvent => 'New Event';

  @override
  String get editEvent => 'Edit Event';

  @override
  String get eventDetails => 'Event Details';

  @override
  String facilitatedBy(String name) {
    return 'Facilitated by $name';
  }

  @override
  String get openForEveryone => 'Open for everyone';

  @override
  String get openOnlyForThisGroup => 'Open only for this group';

  @override
  String get eventLink => 'Event Link';

  @override
  String get noRegistrationsYet => 'No registrations yet.';

  @override
  String get registeredSuccessfully => 'You are registered with success';

  @override
  String get processing => 'Processing...';

  @override
  String get register => 'Register';

  @override
  String get registered => 'Registered';

  @override
  String get unsubscribedSuccessfully => 'You are unsubscribed with success';

  @override
  String get unsubscribe => 'Unsubscribe';

  @override
  String get deleteThisEvent => 'Delete this event?';

  @override
  String get eventDeletedSuccessfully => 'Event deleted with success';

  @override
  String get eventCreatedSuccessfully => 'Event created with success';

  @override
  String get eventUpdatedSuccessfully => 'Event updated with success';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get recorded => 'Recorded';

  @override
  String get noUpcomingEvents => 'No upcoming events found';

  @override
  String get noRecordedEvents => 'No recorded events found';

  @override
  String get noEventsYet => 'No events yet.';

  @override
  String get pastEvents => 'Past events';

  @override
  String get noDate => 'No date';

  @override
  String get title => 'Title';

  @override
  String get facilitator => 'Facilitator';

  @override
  String get required => 'Required';

  @override
  String get singleDay => 'Single Day';

  @override
  String get multiDay => 'Multi-day';

  @override
  String get repeats => 'Repeats';

  @override
  String get doesNotRepeat => 'Does not repeat';

  @override
  String get repeatsWeekly => 'Weekly';

  @override
  String get repeatsEveryTwoWeeks => 'Every 2 weeks';

  @override
  String get repeatsMonthly => 'Monthly';

  @override
  String get repeatUntilOptional => 'Repeat until (optional)';

  @override
  String get clearDate => 'Clear';

  @override
  String get recurrenceShowsNext =>
      'The home and the event list show only the next date. When that day passes, the following one appears.';

  @override
  String get repeatsWeeklyDetail => 'Repeats every week';

  @override
  String get repeatsEveryTwoWeeksDetail => 'Repeats every 2 weeks';

  @override
  String get repeatsMonthlyDetail => 'Repeats every month';

  @override
  String get durationMinutes => 'Duration (minutes)';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get registrationUrlOptional => 'Registration URL (optional)';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select time';

  @override
  String get time => 'Time';

  @override
  String get saveEvent => 'Save Event';

  @override
  String get eventHeaderImage => 'Event image';

  @override
  String get eventHeaderImageSize => 'Recommended: 600 × 600 px';

  @override
  String get changeImage => 'Change Image';

  @override
  String get uploadImage => 'Upload Image';

  @override
  String get activityImageTitle => 'Photo';

  @override
  String get activityPdfUnavailable => 'This PDF is not available.';

  @override
  String get pdfViewPage => 'Page';

  @override
  String get pdfViewReading => 'Reading';

  @override
  String get pdfReadingEmpty =>
      'This PDF has no text that can be enlarged. Use the page view.';

  @override
  String get pdfReadingFailed => 'Could not read the text of this PDF.';

  @override
  String get pdfDecreaseTextSize => 'Decrease text size';

  @override
  String get pdfIncreaseTextSize => 'Increase text size';

  @override
  String get usingGroupImage => 'Using the group image';

  @override
  String get useGroupImage => 'Use group image';

  @override
  String get onlyThisGroup => 'Only this group';

  @override
  String get everyone => 'Everyone';

  @override
  String get date => 'Date';

  @override
  String get messagesByFacilitator =>
      'Messages from facilitators. Replies viewed by facilitators only';

  @override
  String get newMessage => 'New message';

  @override
  String get editMessage => 'Edit Message';

  @override
  String get details => 'Details';

  @override
  String get message => 'Message';

  @override
  String get sendTo => 'Send to';

  @override
  String get allMembersBroadcast => 'All members (broadcast)';

  @override
  String get member => 'Member';

  @override
  String get messageUpdatedSuccessfully => 'Message updated with success';

  @override
  String get messageCreatedSuccessfully => 'Message created with success';

  @override
  String get saveMessage => 'Save Message';

  @override
  String get addMessage => 'Add Message';

  @override
  String get pinMessage => 'Pin message';

  @override
  String get pinMessageHint => 'Stays at the top, even after it has been read.';

  @override
  String get pinnedMessage => 'Pinned by the facilitator';

  @override
  String get newComment => 'New';

  @override
  String get commentsOldestFirst => 'Oldest first';

  @override
  String get commentsNewestFirst => 'Newest first';

  @override
  String get commentsConversationOrder => 'Conversation order';

  @override
  String newReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new replies',
      one: '1 new reply',
    );
    return '$_temp0';
  }

  @override
  String commentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
    );
    return '$_temp0';
  }

  @override
  String get confirmDeleteThisMessage => 'Confirm deletion of this message?';

  @override
  String get newResource => 'New resource';

  @override
  String get addResource => 'Add Resource';

  @override
  String get editResource => 'Edit Resource';

  @override
  String get noResourcesYetAddFirst =>
      'No resources yet.\nTap + to add the first one.';

  @override
  String get noResourcesAvailable => 'No resources available yet.';

  @override
  String get unlinkFromGroup => 'Unlink from Group';

  @override
  String get unlink => 'Unlink';

  @override
  String confirmUnlinkResource(String title) {
    return 'Remove \"$title\" from this group\'s Resources tab?\n\nThe original content will remain in the Library.';
  }

  @override
  String get deleteResource => 'Delete Resource';

  @override
  String confirmRemoveResource(String title) {
    return 'Remove \"$title\" from this group?';
  }

  @override
  String get titleRequired => 'Title is required.';

  @override
  String get urlRequired => 'URL / address is required.';

  @override
  String get failedToSaveTryAgain => 'Failed to save. Please try again.';

  @override
  String get optionalDescription => 'Optional description';

  @override
  String get urlAddress => 'URL / Address';

  @override
  String get resourceTitle => 'Resource title';

  @override
  String get type => 'Type';

  @override
  String get youtubeVideoUrl => 'YouTube video URL *';

  @override
  String get youtubeUrl => 'YouTube URL';

  @override
  String get pleaseEnterYoutubeUrl => 'Please enter a YouTube URL.';

  @override
  String get pleaseSelectFile => 'Please select a file.';

  @override
  String get uploadFailed => 'Upload failed. Please try again.';

  @override
  String get failedToSaveResource => 'Failed to save resource.';

  @override
  String get tapToSelectFile => 'Tap to select file';

  @override
  String get fileRequired => 'File *';

  @override
  String get enterTextRequired => 'Enter text *';

  @override
  String get pleaseEnterText => 'Please enter the text.';

  @override
  String get preview => 'Preview';

  @override
  String get markdownPlaceholder => 'Write in Markdown...';

  @override
  String get noContentAvailable => 'No content available.';

  @override
  String get noContentFoundInResources => 'No content found in resources.';

  @override
  String get writeSomething => 'Write something...';

  @override
  String get close => 'Close';

  @override
  String get posting => 'Posting...';

  @override
  String get post => 'Post';

  @override
  String get name => 'Name';

  @override
  String get moreInformation => 'More information';

  @override
  String get groupManagers => 'Group managers';

  @override
  String get selectManagers => 'Select Managers/ facilitators';

  @override
  String get privateGroup => 'Private Group';

  @override
  String get onlyMembersCanSee => 'Only members can see content.';

  @override
  String get anyoneCanSee => 'Anyone can see content.';

  @override
  String managersFacilitatorsCount(int count) {
    return 'Managers / Facilitators ($count)';
  }

  @override
  String get searchByNameOrEmail => 'Search by name or email (min 3 chars)...';

  @override
  String get searchToFindUsers => 'Search to find users';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get groupImage => 'Group Image';

  @override
  String get noJourneysFoundForGroup => 'No journeys found for this group.';

  @override
  String get noExperiencesToModerate => 'No experiences to moderate';

  @override
  String noFilteredExperiences(String filter) {
    return 'No $filter experiences';
  }

  @override
  String get noPendingExperiences => 'No Pending Experiences';

  @override
  String get confirmApproveExperience =>
      'Are you sure you want to approve this experience?';

  @override
  String get setAsNotPublished => 'Set as Not Published';

  @override
  String get explainNotPublished =>
      'Explain why this experience is not being published...';

  @override
  String get suggestRefinement => 'Suggest Refinement';

  @override
  String get provideRefinementFeedback =>
      'Provide feedback on what refinement is suggested...';

  @override
  String get pleaseProvideReason => 'Please provide a reason';

  @override
  String get provideAReason => 'Provide a reason...';

  @override
  String confirmRemoveMemberNamed(String name) {
    return 'Are you sure you want to remove \"$name\" from this group?';
  }

  @override
  String confirmMemberAction(String action, String name) {
    return 'Are you sure you want to $action \"$name\"?';
  }

  @override
  String get noEmailRegistered => 'No email registered';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get moderation => 'Moderation';

  @override
  String get moderationFilterAwaiting => 'Awaiting';

  @override
  String get moderationFilterRefinement => 'Refinement';

  @override
  String get approved => 'Approved';

  @override
  String get approve => 'Approve';

  @override
  String get approveExperience => 'Approve Experience';

  @override
  String get experienceApproved => 'Experience approved successfully';

  @override
  String get revert => 'Revert';

  @override
  String get refine => 'Refine';

  @override
  String get reject => 'Reject';

  @override
  String errorJoiningGroup(String error) {
    return 'Error joining group: $error';
  }

  @override
  String get noPermissionToDeleteExperience =>
      'You do not have permission to delete this experience';

  @override
  String get noPermissionToLockExperience =>
      'You do not have permission to lock this experience';

  @override
  String get messageNotFound => 'Message not found.';

  @override
  String get messageDeletedSuccessfully => 'Message deleted successfully';

  @override
  String welcomeBack(String name) {
    return 'Welcome back, $name';
  }

  @override
  String get journeyResources => 'Journey resources';

  @override
  String get restartJourney => 'Restart journey';

  @override
  String get aboutThisJourney => 'About this journey';

  @override
  String aboutNamed(String title) {
    return 'About $title';
  }

  @override
  String get resetJourneyTitle => 'Reset this journey';

  @override
  String get resetJourneyDescription =>
      'Resetting your journey will delete all progress made so far. This action cannot be undone.';

  @override
  String get resetJourneyConfirm => 'Reset journey';

  @override
  String get journeyResetSuccess => 'Journey reset successfully';

  @override
  String errorResettingJourney(String error) {
    return 'Error resetting journey: $error';
  }
}
