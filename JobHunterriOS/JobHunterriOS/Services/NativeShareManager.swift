//
//  NativeShareManager.swift
//  JobHunterriOS
//
//  Native iOS sharing integration for job postings and candidate profiles
//

import UIKit

public final class NativeShareManager {
    public static let shared = NativeShareManager()
    
    private init() {}
    
    /// Presents the iOS native share sheet for a job listing
    public func share(
        title: String?,
        url: URL,
        from viewController: UIViewController
    ) {
        var items: [Any] = [url]
        if let title = title, !title.isEmpty {
            items.insert(title, at: 0)
        }
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // iPad support
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityVC, animated: true)
    }
}
