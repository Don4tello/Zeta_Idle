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
