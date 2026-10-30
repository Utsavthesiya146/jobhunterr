//
//  JobHunterrWebViewController.swift
//  JobHunterriOS
//
//  Native WebKit Controller matching Android MainActivity.java functionality:
//  - Domain restriction for jobhunterr.com
//  - External intent handling via SFSafariViewController / system open
//  - Session cookie persistence
//  - Native pull-to-refresh
//  - File uploads & downloads
//  - Edge-to-edge layout & status bar color matching #3A262E
//

import UIKit
import WebKit
import SafariServices

public protocol JobHunterrWebViewControllerDelegate: AnyObject {
    func webViewController(_ controller: JobHunterrWebViewController, didUpdateLoadingProgress progress: Double)
    func webViewController(_ controller: JobHunterrWebViewController, didFailWithNetworkError error: Error)
}

public class JobHunterrWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, WKDownloadDelegate {
    
    // MARK: - Properties
    public private(set) var webView: WKWebView!
    public weak var delegate: JobHunterrWebViewControllerDelegate?
    
    private let refreshControl = UIRefreshControl()
    private var progressObserver: NSKeyValueObservation?
    private var activeDownloads = [WKDownload: URL]()
    
    // MARK: - Status Bar Appearance
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.statusBarColor
        
        setupWebView()
        setupRefreshControl()
        setupProgressObserver()
        
        // Restore session cookies and load initial URL
        SessionCookieManager.shared.restoreCookies(to: webView) { [weak self] in
            self?.loadInitialURL()
        }
    }
    
    deinit {
        progressObserver?.invalidate()
    }
    
    // MARK: - WebView Setup
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        // Enable JavaScript and modern preferences
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = webpagePreferences
        
        // Persistent process pool for shared authentication cookies
        configuration.processPool = WKProcessPool()
        
        webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true // Native swipe back/forward
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        webView.backgroundColor = Theme.statusBarColor
        webView.isOpaque = true
        
        // Append custom user agent
        let currentUA = webView.customUserAgent ?? ""
        webView.customUserAgent = currentUA.isEmpty ? AppConfiguration.customUserAgentSuffix : "\(currentUA) \(AppConfiguration.customUserAgentSuffix)"
        
        view.addSubview(webView)
        
        // Pin edge-to-edge matching Android's EdgeToEdge.enable(this)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Pull to Refresh
    private func setupRefreshControl() {
        refreshControl.tintColor = Theme.primaryColor
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }
    
    @objc private func handleRefresh() {
        webView.reload()
    }
    
    // MARK: - Progress Tracking
    private func setupProgressObserver() {
        progressObserver = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            self.delegate?.webViewController(self, didUpdateLoadingProgress: webView.estimatedProgress)
        }
    }
    
    // MARK: - URL Navigation
    public func loadInitialURL() {
        let request = URLRequest(
            url: AppConfiguration.initialURL,
            cachePolicy: .useProtocolCachePolicy,
            timeoutInterval: 30.0
        )
        webView.load(request)
    }
    
    public func load(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    public func reloadCurrentPage() {
        webView.reload()
    }
    
    public func goBackIfPossible() -> Bool {
        if webView.canGoBack {
            webView.goBack()
            return true
        }
        return false
    }
    
    // MARK: - WKNavigationDelegate
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }
        
        #if DEBUG
        print("[JobHunterr Navigation] Request URL: \(url.absoluteString)")
        #endif
        
        // 1. External native app schemes (tel:, mailto:, sms:, whatsapp:)
        if AppConfiguration.isExternalScheme(url: url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        
        // 2. Allowed domain or safe web engine schemes: keep inside WKWebView
        if AppConfiguration.isInternal(url: url) {
            decisionHandler(.allow)
            return
        }
        
        // 3. External web domain (e.g., social login, external job links):
        // Open via SFSafariViewController (for HTTP/HTTPS) or system browser matching Android Intent.ACTION_VIEW
        if let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" {
            let safariVC = SFSafariViewController(url: url)
            safariVC.preferredBarTintColor = Theme.statusBarColor
            safariVC.preferredControlTintColor = Theme.primaryColor
            safariVC.modalPresentationStyle = .pageSheet
            present(safariVC, animated: true)
            decisionHandler(.cancel)
            return
        } else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
    }
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse,
        decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
    ) {
        // Handle file downloads if content-disposition indicates attachment
        if #available(iOS 14.5, *) {
            if navigationResponse.canShowMIMEType == false {
                decisionHandler(.download)
                return
            }
        }
        decisionHandler(.allow)
    }
    
    // MARK: - WKDownload Delegation Hook
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationResponse: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    @available(iOS 14.5, *)
    public func webView(_ webView: WKWebView, navigationAction: WKNavigationAction, didBecome download: WKDownload) {
        download.delegate = self
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        SessionCookieManager.shared.saveCookies(from: webView)
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        handleNavigationError(error)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        handleNavigationError(error)
    }
    
    private func handleNavigationError(_ error: Error) {
        let nsError = error as NSError
        // Ignore cancelled requests
        if nsError.domain == NSURLErrorDomain && nsError.code == NSURLErrorCancelled {
            return
        }
        
        // Notify delegate of connectivity loss
        if nsError.code == NSURLErrorNotConnectedToInternet ||
           nsError.code == NSURLErrorTimedOut ||
           nsError.code == NSURLErrorCannotFindHost ||
           nsError.code == NSURLErrorCannotConnectToHost {
            delegate?.webViewController(self, didFailWithNetworkError: error)
        }
    }
    
    // MARK: - WKUIDelegate (JS Dialogs & Windows)
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: AppConfiguration.appName, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        let alert = UIAlertController(title: AppConfiguration.appName, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(false)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(true)
        })
        present(alert, animated: true)
    }
    
    public func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        let alert = UIAlertController(title: AppConfiguration.appName, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        present(alert, animated: true)
    }
    
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        // Handle window.open and <a target="_blank"> inside the current webView
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    // MARK: - WKDownloadDelegate (File Downloads for Resumes / Documents)
    
    @available(iOS 14.5, *)
    public func download(
        _ download: WKDownload,
        decideDestinationUsing response: URLResponse,
        suggestedFilename: String,
        completionHandler: @escaping (URL?) -> Void
    ) {
        let destination = FileDownloadManager.shared.destinationURL(for: suggestedFilename)
        activeDownloads[download] = destination
        completionHandler(destination)
    }
    
    @available(iOS 14.5, *)
    public func downloadDidFinish(_ download: WKDownload) {
        if let fileURL = activeDownloads[download] {
            FileDownloadManager.shared.presentShareSheet(for: fileURL, from: self)
            activeDownloads.removeValue(forKey: download)
        }
    }
    
    @available(iOS 14.5, *)
    public func download(_ download: WKDownload, didFailWithError error: Error, resumeData: Data?) {
        activeDownloads.removeValue(forKey: download)
        #if DEBUG
        print("[JobHunterr Download] Failed with error: \(error.localizedDescription)")
        #endif
    }
}
