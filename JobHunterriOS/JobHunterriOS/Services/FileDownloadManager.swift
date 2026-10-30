//
//  FileDownloadManager.swift
//  JobHunterriOS
//
//  Handles file downloads (resumes, documents, job applications) with native iOS share & save sheet
//

import UIKit
import WebKit

public final class FileDownloadManager: NSObject {
    public static let shared = FileDownloadManager()
    
    private var documentController: UIDocumentInteractionController?
    
    private override init() {
        super.init()
    }
    
    /// Presents native iOS Share Sheet / Document preview for a downloaded file
    public func presentShareSheet(for fileURL: URL, from viewController: UIViewController) {
        DispatchQueue.main.async {
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            // iPad popover support
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            viewController.present(activityVC, animated: true)
        }
    }
    
    /// Determines destination URL in the application documents directory
    public func destinationURL(for suggestedFilename: String?) -> URL {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let name = suggestedFilename?.isEmpty == false ? suggestedFilename! : "jobhunterr_document_\(Int(Date().timeIntervalSince1970)).pdf"
        let destination = documentsURL.appendingPathComponent(name)
        
        // Remove existing file if present so WKDownload does not fail on destination collision
        if fileManager.fileExists(atPath: destination.path) {
            try? fileManager.removeItem(at: destination)
        }
        
        return destination
    }
}
