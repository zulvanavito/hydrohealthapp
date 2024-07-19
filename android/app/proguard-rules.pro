# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services rules
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Gson rules (if you're using Gson)
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**

# WorkManager rules
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**