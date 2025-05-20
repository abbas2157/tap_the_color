import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.mudassarabbas.tap_the_color"
    compileSdk = flutter.compileSdkVersion
    
    // Use a properly installed NDK version or comment out if not needed
    // ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973" // Use this specific version which is commonly available

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        applicationId = "com.mudassarabbas.tap_the_color"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enables Multidex for large apps
        multiDexEnabled = true
    }

    // Add signing configuration for release
    signingConfigs {
        create("release") {
            // You'll need to create a key.properties file with these values
            // Or use environment variables for CI/CD
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (keystorePropertiesFile.exists()) {
                val keystoreProperties = Properties()
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Enable minification for smaller app size
            isMinifyEnabled = true
            // Enable resource shrinking
            isShrinkResources = true
            // Use the release signing config
            signingConfig = if (rootProject.file("key.properties").exists()) {
                signingConfigs.getByName("release") 
            } else {
                signingConfigs.getByName("debug")
            }
            // Configure ProGuard
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Configure bundle options
    bundle {
        language {
            // Include all language resources
            enableSplit = true
        }
        density {
            // Enable splitting by screen density
            enableSplit = true
        }
        abi {
            // Enable splitting by ABI
            enableSplit = true
        }
    }
}

dependencies {
    // Add any additional dependencies needed for your app
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}