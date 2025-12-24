# Fix R8 BackEvent issue (Flutter + InAppWebView)
-dontwarn android.window.BackEvent
-keep class android.window.BackEvent { *; }
