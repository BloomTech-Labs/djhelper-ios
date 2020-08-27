//
//  GuestLoginViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/16/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class GuestLoginViewController: ShiftableViewController {

    var eventID: Int32? {
        didSet {
            loadViewIfNeeded()
            updateView()
        }
    }

    var currentHost: Host?
    var allHosts: [Host]?
    var allEvents: [Event]?
    var event: Event? {
        didSet {
            //fetch dj for said event - called in the didset
            self.setHost()
        }
    }

    var isGuest: Bool?
    var eventController: EventController?
    var hostController: HostController?
    var customAlert = CustomAlert()

    // MARK: - Outlets
    @IBOutlet weak var eventCodeTextField: UITextField!
    @IBOutlet weak var viewEventButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
        setupButtons()
        setUpSubviews()
        eventCodeTextField.delegate = self

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
    }

    // I added the network calls to a viewWillAppear override in order to be called
    // after the scene delegate navigates to this scene. When they are only in the
    // viewDidLoad, they are called before the scene delegate navigates here.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    private func updateView() {
        guard let eventID = eventID else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }

        eventCodeTextField.text = "\(eventID)"

    }

    // MARK: - Actions
    /**
     Use the hostID associated with the passed-in event to fetch all events for that host from the server.
     If successful, segues to the eventPlaylistViewController
     */
    func setHost() {
        guard let event = event else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }

        hostController?.fetchHostFromServer(with: event.hostID, completion: { (result) in
            switch result {
            case let .success(host):
                self.currentHost = host
                print("this is the currentHost: \(self.currentHost?.name)")
                DispatchQueue.main.async {
                    // Perform segue to eventPlaylistViewController
                    self.performSegue(withIdentifier: "EventPlaylistSegue", sender: self)
                }
            case let .failure(error):
                print("this is the error: \(error)")
                DispatchQueue.main.async {
                    self.customAlert.showAlert(with: "Network call error: no host for event", message: error.localizedDescription, on: self)
                }
            }
        })
    }

    // Take the eventID in the text field and called the fetchEvent(withEventID:) method in EventController. If successful, set the view controller's event property, which in turn calls the setHost() method.
    @IBAction func viewEvents(_ sender: UIButton) {
        print("view event button pressed.")
        // check to see if there is something in the textbox
        guard let eventCode = eventCodeTextField.text,
            !eventCode.isEmpty else {
                self.view.backgroundColor = .red  // for debugging
                return
        }

        guard let eventId = Int(eventCode) else {
            self.view.backgroundColor = .red  // for debugging
            let inputAlert = CustomAlert()
            inputAlert.showAlert(with: "Invalid Entry",
                                 message: "The event code must be a whole number only. Please check the input and try again.",
                                 on: self)
            self.view.backgroundColor = .yellow  // for debugging
            return
        }

        guard let eventController = eventController else {
            print("Error on line: \(#line) in function: \(#function)\n")
            self.view.backgroundColor = .magenta  // for debugging
            return
        }

        //fetch event based on the eventId in the textfield
        eventController.fetchEvent(withEventID: Int32(eventId), completion: { (results) in
            switch results {
            case let .success(event):
                self.event = event
            case let .failure(error):
                print("error: \(error)")
                DispatchQueue.main.async {
                    self.customAlert.showAlert(with: "Network call error fetching event", message: error.localizedDescription, on: self)
                }
            }
        })
    }

    @objc func dismissAlert() {
        customAlert.dismissAlert()
    }

    // MARK: - Methods
    private func setupButtons() {
        viewEventButton.colorTheme()
    }

    // Programmatically setting up the Sign In button in the view.
    func setUpSubviews() {
        let backToSignIn = UIButton(type: .system)
        backToSignIn.translatesAutoresizingMaskIntoConstraints = false
        backToSignIn.setTitle("Sign In", for: .normal)
        backToSignIn.addTarget(self, action: #selector(self.backToSignIn), for: .touchUpInside)

        let customButtonTitle = NSMutableAttributedString(string: "Sign In", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(named: "customTextColor")!
        ])

        backToSignIn.setAttributedTitle(customButtonTitle, for: .normal)

        view.addSubview(backToSignIn)

        backToSignIn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        backToSignIn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    }

    @objc private func backToSignIn() {
        if isGuest == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let djLogInVC = storyboard.instantiateViewController(identifier: "DJLogIn") as! DJLoginViewController
            djLogInVC.modalPresentationStyle = .fullScreen
            present(djLogInVC, animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventPlaylistSegue" {
            guard let eventPlaylistVC = segue.destination as? EventPlaylistViewController else { fatalError() }
            eventPlaylistVC.modalPresentationStyle = .fullScreen
            eventPlaylistVC.currentHost = currentHost
            eventPlaylistVC.event = event
            eventPlaylistVC.hostController = hostController
            eventPlaylistVC.eventController = eventController
            eventPlaylistVC.isGuest = true
        } else {
            return
        }
    }
}

// Extensions
extension GuestLoginViewController {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
