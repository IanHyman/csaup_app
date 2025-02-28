plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.hyman.csaup_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // ✅ Enable desugaring
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.hyman.csaup_app"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            storeFile = file(System.getenv("HOME") + "/csaup_app/android/app/csaup_app.keystore")
            storePassword = System.getenv("STORE_PASSWORD") ?: "Hymans@2794"
            keyAlias = System.getenv("KEY_ALIAS") ?: "csaup_app"
            keyPassword = System.getenv("KEY_PASSWORD") ?: "Hymans@2794"
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true  // Enables code shrinking
            isShrinkResources = true // Removes unused resources
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            signingConfig = signingConfigs.getByName("release") // 🔥 Reference pre-defined signing config
        }
    }
}


flutter {
    source = "../.."
}

dependencies {
    // ✅ Required for Java 8+ desugaring (fixes flutter_local_notifications issue)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation("com.google.android.material:material:1.9.0")
}
