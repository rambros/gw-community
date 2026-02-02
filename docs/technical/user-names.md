# User Names and Display Strategy

## Overview

This document explains how user names are handled throughout the application, including privacy settings, display strategies, and database implementation.

## Database Fields

### Table: `cc_members`

| Field | Type | Description | Nullable |
|-------|------|-------------|----------|
| `first_name` | `string` | User's first name | Yes |
| `last_name` | `string` | User's last name | Yes |
| `display_name` | `string` | Computed display name for UI | Yes |
| `hide_last_name` | `boolean` | Privacy flag to hide last name | Yes (default: false) |
| `photo_url` | `string` | URL to user's profile photo | Yes |

## Computed Fields in Views

### `full_name`
**Purpose**: Used primarily for generating avatar initials

**Logic**:
```sql
COALESCE(
  CASE
    WHEN hide_last_name = true OR last_name IS NULL OR TRIM(last_name) = ''
    THEN TRIM(COALESCE(first_name, ''))
    ELSE TRIM(CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, '')))
  END,
  NULLIF(TRIM(display_name), ''),
  'Anonymous User'
)
```

**Examples**:
- `first_name = 'John'`, `last_name = 'Doe'`, `hide_last_name = false` → `'John Doe'`
- `first_name = 'John'`, `last_name = 'Doe'`, `hide_last_name = true` → `'John'`
- `first_name = 'John'`, `last_name = NULL` → `'John'`
- `first_name = NULL`, `display_name = 'Johnny'` → `'Johnny'`
- All fields NULL → `'Anonymous User'`

### `display_name`
**Purpose**: Used for showing user name in the UI (cards, headers, comments)

**Logic**:
```sql
COALESCE(
  NULLIF(TRIM(display_name), ''),
  NULLIF(TRIM(first_name), ''),
  'User'
)
```

**Priority Order**:
1. Saved `display_name` from database
2. `first_name` as fallback
3. `'User'` as final fallback

**Examples**:
- `display_name = 'Johnny'` → `'Johnny'`
- `display_name = NULL`, `first_name = 'John'` → `'John'`
- All fields NULL → `'User'`

## Privacy Feature: `hide_last_name`

### Purpose
Allows users to protect their privacy by hiding their last name from public view.

### How It Works

**In Profile Edit** (`user_edit_profile_view_model.dart`):
```dart
void _updateDisplayName() {
  if (_hideLastName) {
    displayNameController.text = '${firstNameController.text} ';
  } else {
    displayNameController.text = '${firstNameController.text} ${lastNameController.text}';
  }
}
```

**In Database Views**:
- When `hide_last_name = true`, views automatically use only the first name
- This applies to all public-facing displays: sharings, notifications, comments

### UI Toggle Location
- **Settings**: User Edit Profile page
- **Label**: "Hide last name"
- **Default**: `false` (show full name)

## Implementation in Views

### Views Using User Names

All views that display user information implement the same naming logic:

1. **`cc_view_sharings_users`**
   - Displays: Sharing posts with author info
   - Uses: Both `full_name` (avatar) and `display_name` (UI)

2. **`cc_view_notifications_users`**
   - Displays: Notifications with creator info
   - Uses: Both `full_name` (avatar) and `display_name` (UI)

3. **`cc_view_ordered_comments`**
   - Displays: Hierarchical comments
   - Uses: `display_name` only (no avatar in comments)

### View Template Structure

```sql
DROP VIEW IF EXISTS public.cc_view_[name];

CREATE VIEW public.cc_view_[name]
WITH (security_invoker=on) AS
SELECT
  -- other fields...

  -- full_name: Respects hide_last_name, with fallback
  COALESCE(
    CASE
      WHEN cc_members.hide_last_name = true OR cc_members.last_name IS NULL OR TRIM(cc_members.last_name) = ''
      THEN TRIM(COALESCE(cc_members.first_name, ''))
      ELSE TRIM(CONCAT(COALESCE(cc_members.first_name, ''), ' ', COALESCE(cc_members.last_name, '')))
    END,
    NULLIF(TRIM(cc_members.display_name), ''),
    'Anonymous User'
  ) AS full_name,

  -- display_name: Uses saved display_name, with fallback
  COALESCE(
    NULLIF(TRIM(cc_members.display_name), ''),
    NULLIF(TRIM(cc_members.first_name), ''),
    'User'
  ) AS display_name

FROM table_name
LEFT JOIN cc_members ON table_name.user_id = cc_members.id
-- rest of query...
```

## Usage in Flutter Code

### Avatar Component

**File**: `lib/ui/core/widgets/user_avatar.dart`

```dart
UserAvatar(
  imageUrl: user.photoUrl,
  fullName: user.fullName,  // Used for initials generation
)
```

**Initials Generation** (`lib/utils/custom_functions.dart`):
```dart
String? getInitials(String fullName) {
  List<String> words = fullName.split(' ');
  List<String> initials = words.where((s) => s.isNotEmpty).toList();

  if (initials.isEmpty) {
    return null;  // Shows '?' in avatar
  }

  String firstLetter = initials.first.substring(0, 1);
  String secondLetter = (initials.length > 1 ? initials.last.substring(0, 1) : '');
  return firstLetter + secondLetter;
}
```

**Examples**:
- `full_name = 'John Doe'` → Initials: `'JD'`
- `full_name = 'John'` → Initials: `'J'`
- `full_name = ''` → Shows: `'?'`

### Display Name in UI

**File**: `lib/ui/community/community_page/widgets/sharing_card_widget.dart`

```dart
Text(
  valueOrDefault<String>(
    sharingRow.displayName,
    'User name',  // Fallback if display_name is null
  ),
  style: AppTheme.of(context).bodyMedium,
)
```

## Data Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ User Profile Form                                       │
│ - first_name: "John"                                    │
│ - last_name: "Doe"                                      │
│ - hide_last_name: [✓] Toggle                           │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│ cc_members Table                                        │
│ - first_name: "John"                                    │
│ - last_name: "Doe"                                      │
│ - display_name: "John " (auto-generated)                │
│ - hide_last_name: true                                  │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│ Database Views (cc_view_sharings_users, etc)            │
│ - full_name: "John" (hide_last_name applied)            │
│ - display_name: "John " (from saved value)              │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┴──────────────┐
        ▼                             ▼
┌──────────────────┐      ┌──────────────────────┐
│ UserAvatar       │      │ UI Display           │
│ getInitials()    │      │ Text Widget          │
│ Result: "J"      │      │ Shows: "John "       │
└──────────────────┘      └──────────────────────┘
```

## Best Practices

### 1. Always Use Views
✅ **DO**: Query from views (`cc_view_sharings_users`, etc.)
```dart
SupaFlow.client.from("cc_view_sharings_users").select()
```

❌ **DON'T**: Join tables manually in application code
```dart
// Don't do this - use views instead
SupaFlow.client.from("cc_sharings")
  .select("*, cc_members(*)")
```

### 2. Respect Privacy Settings
✅ **DO**: Let database views handle privacy logic
- Views automatically respect `hide_last_name`
- No need for application-level filtering

❌ **DON'T**: Override or bypass view logic
```dart
// Don't manually concatenate first + last name
// Use the display_name from the view
```

### 3. Handle Null Values
✅ **DO**: Use fallbacks in UI
```dart
valueOrDefault<String>(
  user.displayName,
  'User name',  // Fallback
)
```

✅ **DO**: Check for null in getInitials
```dart
if (initials.isEmpty) {
  return null;  // Avatar will show '?'
}
```

### 4. Update Views Together
When modifying name logic:
1. Update all 3 views simultaneously
2. Test with various privacy settings
3. Verify both avatar and display name
4. Check comments, sharings, and notifications

## Testing Checklist

### Profile Privacy
- [ ] Create user with full name, `hide_last_name = false`
  - [ ] Avatar shows initials from full name
  - [ ] Display shows full name
- [ ] Toggle `hide_last_name = true`
  - [ ] Avatar shows only first initial
  - [ ] Display shows only first name
- [ ] Create user without last name
  - [ ] Avatar shows single initial
  - [ ] Display shows first name only

### Edge Cases
- [ ] User with no names (all NULL)
  - [ ] Avatar shows '?'
  - [ ] Display shows fallback ('User' or 'Anonymous User')
- [ ] User with empty strings
  - [ ] Treated same as NULL (uses fallbacks)
- [ ] User with very long names
  - [ ] Truncation handled by UI components

### Integration
- [ ] Create sharing → Check author name displays correctly
- [ ] Create comment → Check commenter name displays correctly
- [ ] Create notification → Check creator name displays correctly
- [ ] Switch privacy setting → Verify real-time update

## Migration Notes

### From `users` to `cc_members` Table
When migrating existing data:

```sql
-- Update any records with missing display_name
UPDATE cc_members
SET display_name = CASE
  WHEN hide_last_name = true OR last_name IS NULL OR TRIM(last_name) = ''
  THEN TRIM(first_name)
  ELSE TRIM(CONCAT(first_name, ' ', last_name))
END
WHERE display_name IS NULL OR TRIM(display_name) = '';

-- Set default value for hide_last_name
UPDATE cc_members
SET hide_last_name = false
WHERE hide_last_name IS NULL;
```

## Related Files

### Database
- `lib/data/services/supabase/database/tables/cc_members.dart`
- `lib/data/services/supabase/database/tables/cc_view_sharings_users.dart`
- `lib/data/services/supabase/database/tables/cc_view_notifications_users.dart`
- `lib/data/services/supabase/database/tables/cc_view_ordered_comments.dart`

### UI Components
- `lib/ui/core/widgets/user_avatar.dart` - Avatar with initials
- `lib/ui/community/community_page/widgets/sharing_card_widget.dart` - Sharing cards
- `lib/ui/community/sharing_view_page/widgets/sharing_header_widget.dart` - Sharing headers
- `lib/ui/community/sharing_view_page/widgets/comment_item_widget.dart` - Comments

### View Models
- `lib/ui/profile/user_edit_profile/view_model/user_edit_profile_view_model.dart` - Profile editing
- `lib/ui/profile/user_create_profile/view_model/user_create_profile_view_model.dart` - Profile creation

### Utilities
- `lib/utils/custom_functions.dart` - `getInitials()` function

## SQL Scripts

See the complete SQL scripts for creating/updating views in:
- **Sharings**: Section 1 of this document
- **Notifications**: Section 2 of this document
- **Comments**: Section 3 of this document

Execute in order when making changes to naming logic.
