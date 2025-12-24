# R8 configuration to fix missing class error
-dontwarn android.window.BackEvent

# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /Users/hardikpatel/Library/Android/sdk/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the Consumer ProGuard
# file settings in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any custom keep rules here:

#-dontwarn android.window.BackEvent
#
## Fix R8 missing BackEvent class
#-keep class android.window.BackEvent { *; }

#-dontwarn android.window.BackEvent

-keep class com.pichillilorenzo.flutter_inappwebview.** { *; }
-keep class android.window.BackEvent { *; }

#keep ffmpeg-kit classes
#-keep class com.antonkarpenko.ffmpegkit.** { *; }

-dontwarn com.google.devtools.build.android.desugar.runtime.ThrowableExtension
