# 保留 Conscrypt 相关类
-keep class com.android.org.conscrypt.** { *; }

# 保留 BouncyCastle 相关类
-keep class org.bouncycastle.** { *; }

# 保留 OpenJSSE 相关类
-keep class org.openjsse.** { *; }

## 保留 VMStack 相关类（仅用于兼容旧版 Android）
#-keep class dalvik.system.VMStack { *; }


# 保留Conscrypt和OpenJSSE相关类
-keep class org.conscrypt.** { *; }
-keep class org.openjsse.** { *; }

# 其他缺失类的保留规则（参考build输出的missing_rules.txt）
# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
# ========== Play Core保留规则 ==========
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.** { *; }

# ========== X5 WebView保留规则 ==========
-keep class dalvik.system.VMStack { *; }
-keep class com.tencent.smtt.** { *; }
-keep class com.tencent.tbs.** { *; }
-keep class com.tencent.mtt.** { *; }

# 保留所有X5内部使用的注解
-keepattributes *Annotation*
-keepattributes InnerClasses

# 保留X5使用的JNI方法
-keepclasseswithmembernames class * {
    native <methods>;
}