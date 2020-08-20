//
//  HelperExtensions.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/2/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// MARK: - Date Related Extensions

// Format dates into strings for most UI label elements
extension Date {
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
        return formatter.string(from: self)
    }
}

// Format dates into a string for the backend
extension Date {
    func jsonStringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.string(from: self)
    }
}

// Format JSON strings from the backend into dates
extension String {
    func dateFromString() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: self)
    }
}

// Format certain date strings used in the app back into dates
extension String {
    func eventDateFromString() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
        return formatter.date(from: self)
    }
}

// MARK: - UIVew Shake
// This extension was created to shake the view but is not curently used
extension UIView {
    func shake() {
        UIView.animate(withDuration: 0.3, delay: 0.0,
                       usingSpringWithDamping: 0.2,
                       initialSpringVelocity: 0.3,
                       options: [.curveEaseInOut], animations: {
            self.center.x += 8
            self.layer.borderWidth = 2
            self.layer.borderColor = UIColor.red.cgColor
        }) { _ in
            self.center.x -= 8
            self.layer.borderWidth = 0
        }
    }
}

// MARK: - UIButton
// Sets the color theme for the buttons used in the UI
extension UIButton {
     func colorTheme() {
        let button = self
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(named: "PurpleColor")
        button.layer.masksToBounds = true
        button.layer.cornerRadius = self.frame.size.height / 2
    }
}

// MARK: - Activity Indicator
// Used whenever there may be a delay from the user tap to a UI response (spinning wheel indicator)
extension UIViewController {
    func alertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    func activityIndicator(activityIndicatorView: UIActivityIndicatorView, shouldStart: Bool) {
        activityIndicatorView.center.x = self.view.bounds.width / 2
        activityIndicatorView.center.y = self.view.bounds.height / 2
        self.view.addSubview(activityIndicatorView)
        shouldStart == true ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating()
    }
}

// MARK: - EventController Extensions
// Created to delete events but not currently used
extension EventController {
    func deleteEvent(for event: Event) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(event)
        deleteEventFromServer(event) { (_) in
        }
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error deleting event from Core Data \(error)")
        }
    }

    func deleteEventFromServer(_ event: Event, completion: @escaping (Result<Int, EventErrors>) -> Void) {
        let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
        guard let bearer = Bearer.shared.token else {
            completion(.failure(.couldNotInitializeAnEvent))
            return
        }
        let requestURL = baseURL.appendingPathComponent("auth")
            .appendingPathComponent("event")
            .appendingPathComponent("\(event.eventID)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue

        request.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

        self.dataLoader.loadData(from: request) { (possibleData, possibleResponse, possibleError) in
            if let response = possibleResponse as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = possibleError {
                print("""
                    Error: \(error.localizedDescription) on line \(#line)
                    in function: \(#function)\n Technical error: \(error)
                    """)
                DispatchQueue.main.async {
                    completion(.failure(.noEventsInServerOrCoreData))
                }
            }

            guard possibleData != nil else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            DispatchQueue.main.async {
                print("success")
                completion(.success(1))
            }
        }
    }
}
