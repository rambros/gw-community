# Facilitator reply attention

A facilitator sees a group message again when someone else comments after they last opened it. A member sees the comments they wrote and the replies under those comments. Another member's thread stays hidden and does not mark the message as new. A reply in the member's own thread does. Their own comments do not count as new for themselves.

## What they see

- The message leaves "Past messages" and shows "N new replies".
- The red badge on the group card counts that message once, together with messages never opened.
- The same message shows under New in the notification list.
- Opening the message sets `cc_sharing_reads.read_at` to the database clock. While the group stays open, the list refreshes about every 20 seconds. Leaving the message does not move that time forward, so a reply posted after the open still counts.
- Inside the message, replies from other people that arrived after the previous open keep the dark text. Replies already read use a quieter gray. Their own comments stay with the ones already read. Opening the message again clears that difference for replies that were already there.
- Comment time also comes from the database clock. A phone clock that is behind cannot hide a reply behind an earlier read.
- A small icon above the comments switches the list between conversation order, oldest first, and newest first.

## Push

Commenting on a group message calls the `notify-comment-reply` edge function. It pushes the facilitators of that group who can see the message, except the author, and also the person who was answered. A facilitator answering a member therefore reaches that member. Further replies within 15 minutes collapse into one ping. Creating a group message calls `notify-group-message`, which pushes every member who can see it, except the author. A private message pushes only its recipient.

The in-app badge still comes from the message and its visible replies if push is unavailable.

Email is not sent.
