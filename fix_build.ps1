Write-Host "This script will attempt to fix the Android build issue."
Write-Host "It will first fetch the updated dependencies and then try to build the application."
Write-Host "Please make sure you have Flutter installed and configured in your environment."

try {
    flutter pub get
    flutter build apk
    Write-Host "Build successful! The APK should be in build/app/outputs/flutter-apk/app-release.apk"
} catch {
    Write-Host "An error occurred. Please check the output above for details."
    exit 1
}
