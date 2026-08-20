# Flutter ProGuard szabályok
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.dynamic_feature.** { *; }
-keep class io.flutter.plugins.** { *; }

# Google Maps és Play Services megtartása
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.m4b.maps.** { *; }
-dontwarn com.google.android.m4b.maps.**

# Model osztályok megtartása a JSON szerializációhoz
-keepattributes *Annotation*
-keepattributes Signature