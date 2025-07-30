plugins {
    id("com.android.application") apply false  // Let Flutter manage version
    id("dev.flutter.flutter-gradle-plugin") apply false  // Flutter plugin
    id("com.google.gms.google-services") version "4.4.3" apply false  // Firebase plugin
    kotlin("android") version "2.1.0" apply false  // Match loaded Kotlin version
}


allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Optional custom build directory setup (if really needed)
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
