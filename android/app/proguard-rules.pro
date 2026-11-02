# Reglas de R8/ProGuard para el build de release.
#
# flutter_local_notifications (v17) usa Gson para guardar y leer los
# recordatorios programados. R8 elimina la información de tipos genéricos, y sin
# estas reglas `scheduleDailyReminder` y `cancelDailyReminder` fallan con
# "TypeToken must be created with a type argument". Son las reglas de
# https://github.com/MaikuB/flutter_local_notifications (example/android/app/proguard-rules.pro);
# dejan de ser necesarias al subir el plugin a la v19 o posterior.

## Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Retain generic signatures of TypeToken and its subclasses with R8 version 3.0 and higher.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
