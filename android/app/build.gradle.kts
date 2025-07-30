plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")  // Firebase plugin
    id("dev.flutter.flutter-gradle-plugin")  // Flutter plugin
}

android {
    namespace = "com.example.my_first_app"
    compileSdk = flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.example.my_first_app"  // Change this if needed
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
}

flutter {
    source = "../.."
}
