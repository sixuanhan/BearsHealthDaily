//
//  Application.swift
//  Flex
//
//  Created by Kevin Cao on 2/18/25.
//

import SwiftUI
import UIKit

final class Application_utility {
    
    static var rootViewController: UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
    static func resetRootViewController() {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return }
        
        let rootViewController = window.rootViewController
        window.rootViewController = UIViewController()
        window.rootViewController = rootViewController
        
        window.makeKeyAndVisible()
    }
    
}
