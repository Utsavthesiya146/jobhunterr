//
//  LoadingProgressBar.swift
//  JobHunterriOS
//
//  Smooth animated progress bar matching Jobhunterr pink #ed2d7b
//

import SwiftUI

public struct LoadingProgressBar: View {
    public var progress: Double
    
    public init(progress: Double) {
        self.progress = progress
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 3)
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.primary, Theme.primaryVariant],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(max(0, min(1, progress))), height: 3)
                    .animation(.easeInOut(duration: 0.2), value: progress)
            }
        }
        .frame(height: 3)
    }
}
