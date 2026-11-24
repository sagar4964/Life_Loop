# LifeLoop - Aayush's Sprint 2

This implementation is based on `sagar4964/Life_Loop`, commit
`4296bede723ce91d29bd729a03c3bf694a9ebefa`. The supplied `main` branch and the
`aayush` branch both pointed to this starter project when inspected.

## What is included

| Backlog item | Implementation |
| --- | --- |
| US09: Text posts | Write and publish text; reject blank posts; show the author and date. |
| US12: Personal experiences and event recaps | Choose Experience or Event recap; enter a title and story; recaps include the event date. |
| US13: Post likes | Like and unlike; one like per user ID; display the count. |
| US14: Post comments | Open a post's comments, add a comment, and update the count. |
| US15: Post sharing | Open Android's share menu with the post text, title, author, and event date when applicable. |

The list on the launch screen is a small runner for testing these five features.
It is not a replacement for Sakina's community home feed. Photo posts, progress
updates, bookmarks, saved collections, personal history, visibility settings,
login, AI and the other sprints are outside this change.

## Important current limitation

The provided branch had only the Flutter counter app and no authentication or
backend configuration. This is therefore an **Android, single-device prototype**.
Posts, likes and comments are saved in an app-private JSON file on that device.
They are restored when the app restarts, but are not synchronized between phones.
Uninstalling the app or clearing its application data removes this local data.

`demo-aayush` is a clearly identified preview user, not a real signed-in account.
Do not treat a user ID passed by the client as proof of authentication.

Sharing exports the post text to an app the user chooses. There is no fabricated
public URL, in-app repost, or share counter. Opening/cancelling the share menu
does not claim that a message was delivered. Comment text is not exported.

The preview limits are implementation choices, because the backlog supplies
story titles rather than detailed acceptance criteria: 2,000 characters per post,
100 per title, 500 per comment, and a 5 MiB local storage cap. Event recaps require
a title and a date no later than today. Experiences require a title.

## Run in Android Studio

1. Extract the download to a normal folder, for example
   `C:\Users\user\StudioProjects\LifeLoop_Aayush_Sprint2`.
2. In Android Studio choose **File > Open** and select the included `Life_Loop`
   folder containing `pubspec.yaml`. Open the Flutter project root, not its
   `android` subfolder.
3. Use your installed Flutter SDK. The existing project requires Dart 3.13.4 or
   newer compatible Dart 3.x; keep the Flutter and Dart plugins enabled.
4. Open Android Studio's **Terminal** and run:

   ```powershell
   flutter pub get
   flutter analyze
   flutter test
   flutter devices
   flutter run
   ```

5. Choose an Android emulator or a connected Android phone when prompted.
   This version uses native Android storage/sharing, so Chrome, Windows desktop,
   and iOS are not supported targets for this feature runner.
6. Tap **New post**. Test each post type, then Like, Comment and Share.
7. Stop and reopen the app to check that your saved content returns.

If Android Studio asks for Android SDK packages, use its SDK Manager. This
project inherits the existing Flutter/Gradle configuration. Kotlin changes need
a full stop and run; hot reload alone does not reload native Android code.

The archive excludes machine-specific `local.properties`, build outputs and
`.dart_tool`. Flutter/Android Studio recreate these on your computer.

## Put the changes into your existing college Git repository

The downloadable folder does not contain `.git`, and nothing has been pushed
to GitHub. Keep your existing clone for your college commit history.

1. In your existing project terminal run `git status`. Commit or otherwise save
   any work already in progress before switching branches or copying files.
2. Switch to your work branch, then create a branch for these changes:

   ```powershell
   git switch aayush
   git switch -c aayush-sprint-2
   ```

   If `aayush` only exists remotely, first run `git fetch origin`, then
   `git switch --track origin/aayush`.
3. Copy only these changed paths from the supplied `Life_Loop` folder into the
   matching paths in your existing project:

   | Path | Action |
   | --- | --- |
   | `lib/features/posts/` | Add this new folder. |
   | `lib/main.dart` | Replace the starter counter runner, or merge the app entry point if yours has changed. |
   | `android/app/src/main/kotlin/com/example/life_loop/SprintTwoBridge.kt` | Add this new Kotlin file. |
   | `android/app/src/main/kotlin/com/example/life_loop/MainActivity.kt` | Merge the bridge setup and cleanup methods. |
   | `test/widget_test.dart` | Replace the old counter test. |
   | `test/posts_controller_test.dart` | Add. |
   | `test/post_platform_test.dart` | Add. |
   | `test/support/` | Add. |
   | `SPRINT_2_AAYUSH.md` | Add this guide. |
   | `VALIDATION.md` | Add the validation record. |

4. Run `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter run` in
   the existing project. Inspect `git diff` before committing.
5. Commit the reviewed feature files on your own branch. Push that branch when
   you are ready for your team's review; do not overwrite a teammate's changes.

If your local `main.dart` already has login or navigation that is not in GitHub,
keep that code and integrate the feature classes instead of replacing it.

## Understand the code

| File | Role |
| --- | --- |
| `lib/main.dart` | App theme, preview user and dependency setup. |
| `models/post.dart` | Data structures for a post, author and comment; JSON encoding. |
| `posts_controller.dart` | Validation and create/like/comment operations; notifies screens after successful saves. |
| `data/post_storage.dart` | Dart calls to Android's read and write methods. |
| `screens/create_post_page.dart` | Form shared by text, experience and event recap posts. |
| `screens/comments_page.dart` | Comment list and reply form. |
| `screens/posts_preview_page.dart` | Small runner used to exercise your five stories. |
| `widgets/post_card.dart` | Reusable display card and action buttons. |
| `services/post_sharer.dart` | Prepares share text and calls Android. |
| `SprintTwoBridge.kt` | Performs file work off the UI thread and opens Android's share chooser. |

Paths without a prefix in the table above are under `lib/features/posts/`.
Kotlin is only used for the two native Android capabilities; all interface and
post logic is Dart. No extra Dart dependency or Android permission is required.

Writes are queued, so a comment and a like cannot overwrite each other locally.
The on-screen data changes only after persistence succeeds. A failed save keeps
the typed draft available to retry. A malformed saved file causes an error and
blocks writes rather than silently erasing old posts. AtomicFile provides file
replacement and crash recovery; the application does not claim cloud backups.

## Integration with the team's later work

Use `CreatePostPage`, `CommentsPage` and `PostCard` in the team's navigation/feed.
Create the controller once for the feature lifetime, pass it to these widgets,
and dispose it when the feature is removed. Pass the authenticated user's ID
and display name after login is integrated.

For real shared posts, replace the local application/data implementation with
the team's chosen backend. Implement per-post operations and server-side
authorization; do not upload the entire local snapshot as a shared database.
Likes should use a unique `(postId, userId)` relationship or equivalent atomic
operation. Comments need their own IDs and server timestamps. Load only posts
the authenticated user may view.

US19 owns post visibility. Before connecting private posts, apply that policy to
both reads and share actions. `PostCard` has a `canShare` input so the feed owner
can hide sharing when required. This preview contains only locally authored demo
posts and does not implement visibility or access control.

## Validation

Automated checks cover the core data operations, draft retention, errors,
concurrent local mutations, persistence reload, the Dart/native message contract,
post form interactions and narrow layouts with enlarged text. Native Android
execution must also be checked on a phone/emulator, because mocked channel tests
cannot prove the Android share menu or actual filesystem behavior.

Manual Android checks:

1. Publish all three post types; check title/date rules and blank submissions.
2. Like twice (like then unlike); verify the count and state.
3. Add two comments and return to the post; verify the count.
4. Restart the app; verify the posts, likes, comments and event dates.
5. Share to an installed app and check the supplied text; cancel the chooser
   once and verify that no success count/message is invented.
6. Open a keyboard on a small emulator and check the composer/comment forms.
7. Increase Android font size and check that action buttons wrap correctly.

See `VALIDATION.md` for the checks actually completed for this delivery.

## Official references

- [Flutter platform channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [Flutter JSON serialization](https://docs.flutter.dev/data-and-backend/serialization/json)
- [Android sharing](https://developer.android.com/training/sharing/send)
- [Android AtomicFile](https://developer.android.com/reference/android/util/AtomicFile)
