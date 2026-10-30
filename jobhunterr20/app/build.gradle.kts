plugins {
    alias(libs.plugins.android.application)
}

android {
    namespace = "com.jobhunterr.jobhunterr20"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.jobhunterr.jobhunterr20"
        minSdk = 24
        targetSdk = 36

        versionCode = 8      // ✅ Must be an integer
        versionName = "1.1"  // ✅ String
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86", "x86_64")
        }

    }

    buildTypes {
        release {
            // ✅ Enable shrinking for smaller APK
            isMinifyEnabled = true
            isShrinkResources = true

            // ✅ Correct proguard configuration
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }

        debug {
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation(libs.appcompat)
    implementation(libs.material)
    implementation(libs.activity)
    implementation(libs.constraintlayout)

    testImplementation(libs.junit)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)
}
