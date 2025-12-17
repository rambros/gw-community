# Supabase Views Migration: cc_users to cc_members

## Overview

The database table `cc_users` was renamed to `cc_members`. All views that reference `cc_users` need to be manually updated in Supabase to use `cc_members` instead.

## Views to Update

The following views are used in the Flutter application and need to be updated in Supabase:

### High Priority (Confirmed to use user data)

| View Name | Used In | Action Required |
|-----------|---------|-----------------|
| `cc_view_sharings_users` | `community_repository.dart`, `sharing_repository.dart` | Update JOIN from `cc_users` to `cc_members` |
| `cc_view_notifications_users` | `notification_repository.dart` | Update JOIN from `cc_users` to `cc_members` |
| `cc_view_ordered_comments` | `notification_repository.dart`, `sharing_repository.dart` | Update JOIN from `cc_users` to `cc_members` |
| `cc_view_group_facilitators` | `group_invitation_page.dart` | Update JOIN from `cc_users` to `cc_members` |
| `cc_view_user_journeys` | `journeys_repository.dart`, `home_repository.dart`, `user_profile_repository.dart` | Update JOIN from `cc_users` to `cc_members` |

### Medium Priority (May reference user data)

| View Name | Used In | Action Required |
|-----------|---------|-----------------|
| `cc_view_user_steps` | `journeys_repository.dart`, `step_activities_repository.dart` | Check if JOINs with `cc_users`, update if needed |
| `cc_view_user_activities` | `step_activities_repository.dart` | Check if JOINs with `cc_users`, update if needed |
| `cc_view_user_journal` | `user_profile_repository.dart` | Check if JOINs with `cc_users`, update if needed |

### Low Priority (Probably no user reference)

| View Name | Used In | Action Required |
|-----------|---------|-----------------|
| `cc_view_avail_journeys` | `journeys_repository.dart` | Verify - likely no changes needed |

## How to Update

1. Open Supabase Dashboard
2. Go to **Database** > **Views**
3. For each view listed above:
   - Click on the view name
   - View the SQL definition
   - Replace all occurrences of `cc_users` with `cc_members`
   - Save the updated view

### Example Change

**Before:**
```sql
SELECT
    s.id,
    s.title,
    s.text,
    u.display_name,
    u.photo_url
FROM cc_sharings s
JOIN cc_users u ON s.user_id = u.id
```

**After:**
```sql
SELECT
    s.id,
    s.title,
    s.text,
    m.display_name,
    m.photo_url
FROM cc_sharings s
JOIN cc_members m ON s.user_id = m.id
```

## Verification

After updating each view, verify that:
1. The view can be queried without errors
2. The Flutter app can fetch data from the view
3. User information (name, photo, etc.) is displayed correctly

## Related Code Changes

The following Dart files were updated to use `CcMembersTable` instead of `CcUsersTable`:

- `lib/data/services/supabase/database/tables/cc_members.dart` (renamed from `cc_users.dart`)
- `lib/data/repositories/user_profile_repository.dart`
- `lib/data/repositories/sharing_repository.dart`
- `lib/data/repositories/journeys_repository.dart`
- `lib/data/repositories/notification_repository.dart`
- `lib/data/repositories/group_repository.dart`
- `lib/data/repositories/home_repository.dart`
- `lib/data/repositories/event_repository.dart`
- `lib/app_state.dart`

## Date

Migration documented: December 2024
