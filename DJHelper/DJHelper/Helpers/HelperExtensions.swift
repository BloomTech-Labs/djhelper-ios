//
//  HelperExtensions.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/2/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

extension Date {
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
        return formatter.string(from: self)
    }
}

extension String {
    func dateFromString() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
        return formatter.date(from: self)
    }
}

extension String {
    func eventDateFromString() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter.date(from: self)
    }
}

extension UIView {
    func shake() {
        let view = self
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.2) {
            view.layer.borderColor = UIColor.red.cgColor
            //move it left by 8 pix
            view.transform = CGAffineTransform(translationX: -8, y: 0)
        }
        propertyAnimator.addAnimations({
            //return it back to its original position
            view.transform = CGAffineTransform(translationX: 3, y: 0)
            view.layer.borderColor = UIColor.green.cgColor
        }, delayFactor: 0.4)
        propertyAnimator.startAnimation()
    }
}

extension UIViewController {
    func alertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    func activityIndicator(shouldStart: Bool) {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        shouldStart == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}

extension EventController {
    func deleteEvent(for event: Event) {
        let moc = CoreDataStack.shared.mainContext
        moc.delete(event)
        deleteEventFromServer(event) { (result) in
            switch result {
            case .success:
                print("\(event.eventID)")
            case .failure:
                return
            }
        }
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("Error deleting event from Core Data \(error)")
        }
    }

    func deleteEventFromServer(_ event: Event, completion: @escaping (Result<Int, EventErrors>) -> Void) {
        let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
        let requestURL = baseURL.appendingPathComponent("auth").appendingPathComponent("event").appendingPathComponent("\(event.eventID)")
        var request = URLRequest(url: requestURL)
        request.httpMethod = HTTPMethod.delete.rawValue

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

            guard let data = possibleData else {
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
