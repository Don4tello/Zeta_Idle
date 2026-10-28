# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Play Billing
-keep class com.android.vending.billing.** { *; }
-keep class com.android.billingclient.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Google Sign-In / Play Services Auth
# Without these, R8 strips/optimizes the auth classes and rewrites an internal
# null-check into `getClass()`, crashing SignInHubActivity at launch with
# "NullPointerException: ... getClass() on a null object reference". Keep the
# auth + common + signin packages (and the Flutter plugin) intact.
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class com.google.android.gms.signin.** { *; }
-keep class io.flutter.plugins.googlesignin.** { *; }
-dontwarn com.google.android.gms.auth.**
-dontwarn com.google.android.gms.common.**

# WorkManager — Firebase Firestore uses this for offline sync scheduling.
# R8 strips WorkDatabase without these rules, crashing before Dart starts.
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# Room / SQLite (WorkManager's internal database)
-keep class androidx.room.** { *; }
-keep class androidx.sqlite.** { *; }
-dontwarn androidx.room.**
-dontwarn androidx.sqlite.**

# Gson / JSON
-keepattributes Signature
-keepattributes *Annotation*

# Play Core (deferred components / split install)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
