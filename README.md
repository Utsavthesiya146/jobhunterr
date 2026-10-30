# Job Hunterr – Mobile Platform

Official mobile applications for **Job Hunterr** ([jobhunterr.com](https://jobhunterr.com/)), supporting both **Android** and **iOS** with complete visual, functional, and backend parity.

---

## 1. Project Overview

Job Hunterr connects job seekers with top employers and staffing services. The platform offers seamless candidate registration, job discovery, recruiter job postings, and interactive resume building.

### Application Architecture

| Dimension | Android (`jobhunterr20`) | iOS (`JobHunterriOS`) |
| :--- | :--- | :--- |
| **Language** | Java (Android SDK 36, minSdk 24) | Swift 5.9+ (iOS 15.0+) |
| **Framework** | Android Native (`WebView`, AndroidX) | iOS Native (`WebKit`, `SwiftUI`, `UIKit`) |
| **Target Domain** | `jobhunterr.com` (`ALLOWED_DOMAIN`) | `jobhunterr.com` (`AppConfiguration.allowedDomain`) |
| **Package / Bundle ID** | `com.jobhunterr.jobhunterr20` | `com.jobhunterr.jobhunterr20` |
| **Brand Primary Color** | `#ed2d7b` (Deep Pink) | `Theme.primary` (`#ed2d7b`) |
| **Status Bar Color** | `#3A262E` (Dark Wine) | `Theme.statusBar` (`#3A262E`) |
| **Session Persistence** | Android CookieManager | `SessionCookieManager` (`WKHTTPCookieStore`) |
| **Offline Handling** | System WebView fallback | Native `OfflineErrorView` with Retry trigger |
| **Push Notifications** | FCM Ready | APNs Ready (`NotificationService`) |

---

## 2. Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── ios-build.yml           # CI: Simulator build & automated smoke tests
│       └── ios-release.yml         # CD: Signed IPA archive & TestFlight preparation
├── JobHunterriOS/                  # Complete Native iOS Project
│   ├── JobHunterriOS.xcodeproj/    # Xcode project configuration & build phases
│   ├── JobHunterriOS/
│   │   ├── App/                    # App entry & AppDelegate (APNs lifecycle)
│   │   ├── Core/                   # Configuration, Theme (#ed2d7b), Cookie & Network
│   │   ├── Views/                  # WebViewController, OfflineView, Progress bar
│   │   ├── Services/               # Download, Notification, and Share managers
│   │   └── Resources/              # Info.plist, PrivacyInfo, LaunchScreen, Assets
│   ├── build_ios.sh                # macOS CLI build script
│   ├── ExportOptions.plist         # IPA export options
│   └── Podfile                     # CocoaPods specification
├── jobhunterr20/                   # Existing Android Application (Untouched)
│   ├── app/                        # Android application source & resources
│   └── build.gradle.kts            # Android Gradle build configuration
├── JOB_HUNTERR_IOS_FINAL_AUDIT.md  # Comprehensive QA & Architecture Audit
├── .gitignore                      # Git ignore rules for Android, iOS & macOS
└── README.md                       # Project documentation
```

---

## 3. GitHub Actions CI/CD Automation

This repository includes fully automated GitHub Actions workflows running on Apple Silicon macOS runners (`macos-14`):

### 1. iOS Simulator Build & Test (`ios-build.yml`)
* **Triggers**: Automatic on every `push` to `main`, `pull_request`, or manual `workflow_dispatch`.
* **Execution**:
  * Verifies Xcode environment (Xcode 15.4 / 16.0).
  * Compiles `JobHunterriOS.xcodeproj` for iOS Simulator (`generic/platform=iOS Simulator`) without requiring Apple Developer signing credentials.
  * Boots an iOS Simulator, installs the `.app` bundle, and launches it to perform automated smoke testing.
  * Captures diagnostics and uploads the built `.app` bundle as an artifact.

### 2. Signed IPA & TestFlight Pipeline (`ios-release.yml`)
* **Triggers**: Manual trigger only (`workflow_dispatch`).
* **Execution**:
  * Decodes Apple Distribution Certificate and Provisioning Profile from GitHub Secrets into a temporary keychain.
  * Archives the project (`xcodebuild ... archive`).
  * Exports the signed `.ipa` file using `ExportOptions.plist`.
  * Uploads the `.ipa` artifact and cleans up the temporary keychain.

---

## 4. Local Building Instructions

### iOS (macOS with Xcode 15+)
```bash
cd JobHunterriOS
chmod +x build_ios.sh
./build_ios.sh
```
* Option `1`: Build for iOS Simulator.
* Option `3`: Build and Export IPA package.

### Android (Android Studio / Gradle)
```bash
cd jobhunterr20
./gradlew assembleRelease
```
