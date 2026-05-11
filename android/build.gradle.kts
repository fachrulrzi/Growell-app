import com.android.build.gradle.BaseExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Ensure all Android library/application subprojects compile with a modern SDK
// so plugin resources referencing framework attributes (e.g. android:lStar)
// are available during resource merging.
subprojects {
    afterEvaluate {
        val android = extensions.findByType(com.android.build.gradle.BaseExtension::class.java)
        if (android != null) {
            android.setCompileSdkVersion(36)
        }
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
