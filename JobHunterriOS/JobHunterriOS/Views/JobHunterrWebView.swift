//
//  JobHunterrWebView.swift
//  JobHunterriOS
//
//  SwiftUI bridge for JobHunterrWebViewController
//

import SwiftUI

public struct JobHunterrWebView: UIViewControllerRepresentable {
    @Binding public var loadingProgress: Double
    @Binding public var hasNetworkError: Bool
    public var controllerRef: ((JobHunterrWebViewController) -> Void)?
    
    public init(
        loadingProgress: Binding<Double>,
        hasNetworkError: Binding<Bool>,
        controllerRef: ((JobHunterrWebViewController) -> Void)? = nil
    ) {
        self._loadingProgress = loadingProgress
        self._hasNetworkError = hasNetworkError
        self.controllerRef = controllerRef
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> JobHunterrWebViewController {
        let controller = JobHunterrWebViewController()
        controller.delegate = context.coordinator
        controllerRef?(controller)
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: JobHunterrWebViewController, context: Context) {
        // State updates handled via controller direct calls
    }
    
    public class Coordinator: NSObject, JobHunterrWebViewControllerDelegate {
        var parent: JobHunterrWebView
        
        init(_ parent: JobHunterrWebView) {
            self.parent = parent
        }
        
        public func webViewController(_ controller: JobHunterrWebViewController, didUpdateLoadingProgress progress: Double) {
            DispatchQueue.main.async {
                self.parent.loadingProgress = progress
                if progress >= 1.0 {
                    self.parent.hasNetworkError = false
                }
            }
        }
        
        public func webViewController(_ controller: JobHunterrWebViewController, didFailWithNetworkError error: Error) {
            DispatchQueue.main.async {
                self.parent.hasNetworkError = true
            }
        }
    }
}
