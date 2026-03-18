def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) flutterVersionCode = '1'

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) flutterVersionName = '1.0'

apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'dev.flutter.flutter-gradle-plugin'
apply plugin: 'com.google.gms.google-services'   // Firebase

android {
    namespace "com.preparepro.app"
    compileSdk flutter.compileSdkVersion
            ndkVersion flutter.ndkVersion

            compileOptions {
                sourceCompatibility JavaVersion.VERSION_1_8
                        targetCompatibility JavaVersion.VERSION_1_8
            }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    defaultConfig {
        applicationId "com.priyanshu.preparepro"
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
                versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
                multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
                    minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
    implementation 'androidx.multidex:multidex:2.0.1'
}