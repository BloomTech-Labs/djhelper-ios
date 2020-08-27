//
//  SceneDelegate.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/20/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let url = connectionOptions.urlContexts.first?.url, let scheme = url.scheme else {
              print("App opened by user: \(#line) in function: \(#function)\n")
              return
          }

          print("App opened by link: Here's the URL (from clicking a link): \(url) and the associated scheme: \(scheme)")

          let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
          //        let tempUrlToPass = URL(string: "djscheme://www.djhelper.com/guestLogin?eventId=\(1)")!

          guard let eventID = urlComponents?.queryItems?.first?.value, let eventInt32 = Int32(eventID) else {
              print("Error on line: \(#line) in function: \(#function)\n")
              return
          }
          print("eventID = \(eventInt32)")

          if scheme == "djscheme" {
            let eventController = EventController()
            let hostController = HostController()
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let guestLoginVC = storyboard.instantiateViewController(withIdentifier: "guestLoginVC") as! GuestLoginViewController
            guestLoginVC.eventID = eventInt32
            guestLoginVC.eventController = eventController
            guestLoginVC.hostController = hostController
              window?.rootViewController = guestLoginVC
          } else {
            print("scheme does not match our 'djscheme' scheme")
            return
        }

        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url, let scheme = url.scheme else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }

        print("App opened by link: Here's the URL (from clicking a link): \(url) and the associated scheme: \(scheme)")

        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        //        let tempUrlToPass = URL(string: "djscheme://www.djhelper.com/guestLogin?eventId=\(1)")!

        guard let eventID = urlComponents?.queryItems?.first?.value, let eventInt32 = Int32(eventID) else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        print("eventID = \(eventInt32)")

        if scheme == "djscheme" {
            let eventController = EventController()
            let hostController = HostController()
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let guestLoginVC = storyboard.instantiateViewController(withIdentifier: "guestLoginVC") as! GuestLoginViewController
            guestLoginVC.eventID = eventInt32
            guestLoginVC.eventController = eventController
            guestLoginVC.hostController = hostController
            window?.rootViewController = guestLoginVC
        }
    }
}
