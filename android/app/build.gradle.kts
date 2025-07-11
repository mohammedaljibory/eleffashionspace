plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Add these for Firebase
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.eleffashionspace"
    compileSdk = 35  // Updated to latest
    ndkVersion = "29.0.13599879"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.eleffashionspace"
        minSdk = 21  // Required minimum for Firebase
        targetSdk = 34  // Updated to latest
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Add this for multidex support
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")

            // Add these for release build optimization
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Add Firebase BOM
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Add these for Firebase
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}