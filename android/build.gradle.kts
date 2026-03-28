allprojects {
    repositories {
        // 添加以下阿里云镜像
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
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

subprojects {
    // 使用 plugins.withType 确保只有在 Android 插件加载后才执行
    plugins.withType<com.android.build.gradle.api.AndroidBasePlugin> {
        val android = extensions.findByName("android") as? com.android.build.gradle.BaseExtension
        if (android != null && android.namespace == null) {
            // 方案 A：从 Manifest 读取（最稳妥）
            val manifestFile = file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                try {
                    val parser = groovy.xml.XmlParser()
                    val node = parser.parse(manifestFile)
                    val packageName = node.attribute("package")?.toString()
                    if (!packageName.isNullOrEmpty()) {
                        android.namespace = packageName
                    }
                } catch (e: Exception) {
                    // 忽略 XML 解析错误
                }
            }

            // 方案 B：兜底方案，如果方案 A 没拿到，用 project.group
            if (android.namespace == null) {
                val fallbackNamespace = project.group.toString()
                if (fallbackNamespace.isNotEmpty()) {
                    android.namespace = fallbackNamespace
                } else {
                    // 最后的保命方案：用项目名拼凑
                    android.namespace = "com.wellcherish.flutter_text_editor"
                }
            }
        }
    }
}