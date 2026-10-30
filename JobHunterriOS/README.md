# Job Hunterr – iOS Application

Official iOS native implementation of **Job Hunterr**, developed from the reference Android application (`jobhunterr20`).

---

## 1. Project Overview & Architecture

### Android Source Code Audit
The existing Android application (`jobhunterr20`) was audited:
* **Framework**: Native Android (Java) targeting Android SDK 36 (minSdk 24).
* **Architecture**: Single Activity (`MainActivity.java`) hosting an edge-to-edge configured `WebView` (`R.id.webView`).
* **Target Domain**: Restricted to `https://jobhunterr.com` (`ALLOWED_DOMAIN = "jobhunterr.com"`).
* **Security**: Local file URL access disabled; external links delegated to system browser (`Intent.ACTION_VIEW`).
* **Navigation**: Back stack dispatches `webView.canGoBack()` / `webView.goBack()`.
* **Theme & Colors**:
  * Primary Pink: `#ed2d7b`
  * Primary Variant: `#c51f65`
  * Status Bar / Background: `#3A262E`
  * Content: `#FFFFFF`
* **Backend & Auth**: Centralized web platform at `https://jobhunterr.com` with cookie-based sessions, candidate logins (`/Login`, `/register`), recruiter portals (`/recruiter_login`, `/recruiter_register`), and multipart resume upload forms.

### iOS Development Approach
To ensure **100% UI/UX parity**, reuse existing backend APIs and databases, and strictly adhere to Apple's App Review Guidelines:
* **Approach**: **Native iOS (Swift 5.9+ / SwiftUI + WebKit `WKWebView`)**.
* **Zero Overhead**: Does not inject heavy 40MB+ cross-platform engines (Flutter/React Native) over a web container.
* **Apple Compliance (Guideline 4.2)**: Includes native iOS pull-to-refresh (`UIRefreshControl`), network monitoring (`NWPathMonitor`), native offline recovery state (`OfflineErrorView`), smooth progress bars, native file download delegates (`WKDownloadDelegate`), native push notifications (`UserNotifications`), and Apple Privacy Manifest (`PrivacyInfo.xcprivacy`).

---

## 2. iOS Project Structure

```
JobHunterriOS/
├── JobHunterriOS.xcodeproj/
│   ├── project.pbxproj                     # Complete Xcode project configuration
│   ├── project.xcworkspace/
│   │   └── contents.xcworkspacedata        # Workspace metadata
│   └── xcshareddata/xcschemes/
│       └── JobHunterr.xcscheme             # Shared build and run scheme
├── JobHunterriOS/
│   ├── App/
│   │   ├── JobHunterrApp.swift             # SwiftUI main entry point
│   │   └── AppDelegate.swift               # Push notification and lifecycle management
│   ├── Core/
│   │   ├── AppConfiguration.swift          # Domain restriction & constants
│   │   ├── Theme.swift                     # Brand color palette (#ed2d7b, #3A262E)
│   │   ├── NetworkMonitor.swift            # NWPathMonitor real-time connectivity
│   │   └── SessionCookieManager.swift      # Persistent login session sync
│   ├── Views/
│   │   ├── MainContentView.swift          # Edge-to-edge container & state router
│   │   ├── JobHunterrWebView.swift         # SwiftUI UIViewControllerRepresentable
│   │   ├── JobHunterrWebViewController.swift # Core WebKit engine & navigation delegate
│   │   ├── LoadingProgressBar.swift        # Animated progress indicator
│   │   └── OfflineErrorView.swift          # Native error screen with retry
│   ├── Services/
│   │   ├── FileDownloadManager.swift       # Resume & document sharing/downloading
│   │   ├── NotificationService.swift       # APNs registration & deep linking
│   │   └── NativeShareManager.swift        # Native iOS share sheet integration
│   └── Resources/
│       ├── Info.plist                      # Permissions & bundle metadata
│       ├── PrivacyInfo.xcprivacy           # Mandatory Apple Privacy Manifest
│       ├── LaunchScreen.storyboard         # Native launch screen (#3A262E theme)
│       └── Assets.xcassets/
│           ├── AppIcon.appiconset/         # Full icon suite (1024, 180, 120, etc.)
│           ├── AccentColor.colorset/       # #ed2d7b
│           ├── BrandPrimary.colorset/      # #ed2d7b
│           └── BrandBackground.colorset/   # #3A262E
├── ExportOptions.plist                     # IPA archive export settings
├── Podfile                                 # Optional CocoaPods spec
├── build_ios.sh                            # macOS automated CLI build script
└── README.md                               # Project documentation
```

---

## 3. Key Feature Implementations

| Feature | Android (`jobhunterr20`) | iOS (`JobHunterriOS`) |
| :--- | :--- | :--- |
| **Framework** | Java / Android SDK 36 | Swift 5.9+ / iOS 15.0+ |
| **Web Container** | Android `WebView` | WebKit `WKWebView` |
| **Domain Whitelist** | `jobhunterr.com` (`ALLOWED_DOMAIN`) | `jobhunterr.com` (`AppConfiguration.allowedDomain`) |
| **External Links** | `Intent.ACTION_VIEW` (Default browser) | `SFSafariViewController` / `UIApplication.open` |
| **Back Navigation** | `OnBackPressedCallback` | `allowsBackForwardNavigationGestures = true` & swipe gesture |
| **File Uploads** | WebChromeClient file chooser | Native `UIDocumentPickerViewController` / Photos / Camera |
| **File Downloads** | Android DownloadManager | `WKDownloadDelegate` + `UIActivityViewController` |
| **Brand Color** | `#ed2d7b` (Deep Pink) | `Theme.primary` (`#ed2d7b`) |
| **Status Bar Color** | `#3A262E` | `Theme.statusBar` (`#3A262E`) |
| **Session Persistence** | Android CookieManager | `SessionCookieManager` (`WKHTTPCookieStore`) |
| **Offline State** | Web error page | Native `OfflineErrorView` with retry button |

---

## 4. Setup & Xcode Configuration Instructions

### Prerequisites
* A Mac running **macOS Sonoma (14.0+)** or **macOS Sequoia (15.0+)**.
* **Xcode 15.0+** or **Xcode 16.0+** installed from the Mac App Store.
* Apple Developer Account (Individual or Organization) for device deployment and TestFlight.

### Step 1: Open the Project in Xcode
1. Transfer the `JobHunterriOS` folder to your Mac (via Git, USB, or AirDrop).
2. Double-click `JobHunterriOS.xcodeproj` to launch Xcode.

### Step 2: Configure Code Signing
1. Select the top-level **JobHunterriOS** project in the Project Navigator (left sidebar).
2. Select the **JobHunterriOS** target under *Targets*.
3. Go to the **Signing & Capabilities** tab.
4. Check **Automatically manage signing**.
5. In the **Team** dropdown, select your Apple Developer Team.
6. Verify the **Bundle Identifier**:
   `com.jobhunterr.jobhunterr20` (or change to your registered App ID).

### Step 3: Verify Capabilities
The project is pre-configured with:
* **Background Modes**: Remote notifications.
* **Push Notifications**: APNs readiness.

---

## 5. Testing & Running

### Running on iOS Simulator
1. In the top toolbar scheme dropdown, select `JobHunterr` and choose a simulator target (e.g., **iPhone 15 Pro** or **iPhone 16**).
2. Press **Cmd + R** or click the **Play** button.
3. The simulator will boot and launch Jobhunterr with the branded launch screen, status bar, and edge-to-edge layout.

### Running on a Physical iPhone
1. Connect your iPhone to your Mac via USB or Wi-Fi.
2. Unlock your iPhone and trust your Mac if prompted.
3. In Xcode, select your connected device from the scheme target dropdown.
4. Press **Cmd + R**.
5. If running for the first time, on your iPhone go to **Settings > General > VPN & Device Management** and trust your Developer certificate.

---

## 6. Building the IPA and Submitting to TestFlight

### Method A: Automated CLI Build (Fastest)
On your Mac, open Terminal in the `JobHunterriOS` directory and run:
```bash
chmod +x build_ios.sh
./build_ios.sh
```
Choose option **3** to automatically build the Release Archive and export `Jobhunterr.ipa`.

### Method B: Xcode GUI Archive & TestFlight Upload
1. Select **Any iOS Device (arm64)** from the device target list in Xcode.
2. In the top menu, select **Product > Archive**.
3. Once the archive completes, the **Organizer** window opens.
4. Select the latest archive and click **Distribute App**.
5. Select **TestFlight & App Store** -> click **Distribute**.
6. Follow the prompts: Xcode will automatically validate signatures, upload symbols, and upload the build directly to **App Store Connect**.

### Step-by-Step TestFlight Distribution
1. Log in to [App Store Connect](https://appstoreconnect.apple.com).
2. Navigate to **Apps > Jobhunterr > TestFlight**.
3. Under **Internal Testing**, add internal team members (build becomes available immediately upon processing).
4. Under **External Testing**, add external beta testers (requires a brief standard Apple beta review, usually approved within 24 hours).
5. Testers install the **TestFlight** app from the App Store and accept the invite to test on iPhone and iPad.

---

## 7. App Store Review Guidelines Compliance Checklist

Job Hunterr iOS has been built to comply with all Apple App Review Guidelines:
* **Guideline 4.2 (Minimum Functionality)**: Apple requires web-based apps to provide native features beyond a simple browser bookmark. This app provides:
  * Native pull-to-refresh
  * Real-time network monitoring and dedicated native offline error recovery screen
  * Native file upload picker (camera/photos) and native download sheet
  * Push notification architecture
  * Edge-to-edge layout with Dynamic Island and notch safe-area handling
* **Guideline 5.1.1 (Data Collection & Privacy)**:
  * Camera, Photo Library, and Photo Add permissions in `Info.plist` include clear, human-readable usage explanations.
  * Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) is included with `NSPrivacyTracking = false` and UserDefaults declaration (`CA92.1`).
* **Export Compliance**: `ITSAppUsesNonExemptEncryption` is set to `false` in `Info.plist`, eliminating encryption questionnaire delays.

---

## 8. Summary of Android to iOS Deliverables

1. **Complete Native Source Code**: Swift 5.9+ / WebKit / SwiftUI.
2. **Branding & Assets**: Launcher icons generated in all required resolutions (1024x1024 down to 40x40) from the Android play store asset.
3. **Themes**: Exact color matching (`#ed2d7b`, `#3A262E`).
4. **Zero Backend Modifications**: All existing authentication, candidate dashboards, recruiter flows, and job postings work seamlessly.
