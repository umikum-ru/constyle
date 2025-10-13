allprojects {
    repositories {
        google()
        mavenCentral()
        maven("https://maven.pkg.jetbrains.space/public/p/kotlinx-html/maven")
    }
//    dependencies {
//        implementation(kotlin("com.android.tools.build:gradle:7.3.1"))
////        implementation("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version");
//        "implementation"("com.google.gms:google-services:4.4.2")
//    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

plugins {
    // ...

    // Add the dependency for the Google services Gradle plugin
    id("com.google.gms.google-services") version "4.4.2" apply false
//    id("com.android.tools.build:gradle") version "7.3.1" apply false
    //        implementation(kotlin(":"))

}