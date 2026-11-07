# Facilitator notifications

Facilitators choose, per group, what reaches them. The screen is **Facilitator settings** in Profile, and it appears only for someone who facilitates at least one group.

Defaults when a group has no saved row:

- New experiences: on (push and in-app), both when a post waits for approval and when it is published
- Email for each published experience: off
- Messages for you: on (private messages, member notes to the facilitators, and new replies)
- Email when a member writes to the facilitators: on
- Daily summary: off
- Weekly summary: off

The global push and in-app switches still apply on top of these. Email does not.

A member who is not a facilitator sees **New message to the facilitator** on the group's messages tab. That message is stored on `cc_sharings` with `audience = 'facilitators'`. The author and every facilitator of that group can see it. Other members cannot. The view `cc_view_notifications_users` enforces that, and the app filters again.

Publishing or submitting an experience calls `notify-facilitator-experience`. Approving one does too, from the app and from the admin portal. A database trigger does the same when `moderation_status` becomes `awaiting_approval` or `approved`, so a write that skips the app still notifies. The log `cc_facilitator_notify_log` keeps a retry from sending twice. The author is not notified about their own post.

The daily email goes out at 08:00 America/Sao_Paulo (11:00 UTC). The weekly email goes out on Monday at the same hour. Each facilitator gets one email, with a section for every group that has that summary turned on.

## Before the summaries can send

Apply the migration in the admin repo:

`cott-portal-admin/supabase/migrations/20261104120000_facilitator_notifications.sql`

Enable `pg_cron` and `pg_net` on the Supabase project if the migration reports they are missing.

Store the service role key so cron and the database trigger can call the edge functions. Instant alerts from the app work without this, because the signed-in user calls the function. The summaries do not.

```sql
select vault.create_secret('<service_role_key>', 'service_role_key');
```

Deploy these functions from this repo:

- `notify-facilitator-experience`
- `facilitator-digest`
- `notify-group-message`
- `notify-comment-reply`
- `send-push-notification`
