allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Gradle 9 compatibility: patch google_mobile_ads 'configurations.all' usage
    configurations.configureEach {
        // Ensures 'all' iteration works in subprojects using legacy Groovy build scripts
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
