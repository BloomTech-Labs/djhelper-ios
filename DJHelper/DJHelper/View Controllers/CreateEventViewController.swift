//
//  CreateEventViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/3/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {
    let myAlert = CustomAlert()
    var currentHost: Host?
    var eventController: EventController!
    var hostController: HostController!
    var event: Event? {
        didSet {
            updateViewsWithEvent()
        }
    }
    private var startTimeDatePicker: UIDatePicker?
    private var endTimeDatePicker: UIDatePicker?

    // MARK: - IBOutlets
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var eventDateTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViewsWithEvent()

        // tap anywhere on the screen to dismiss the date picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func eventDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy h:mm a"
    }

    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - IBActions
    @IBAction func saveEvent(_ sender: UIBarButtonItem) {
        print("Paste what's in the tempButton's body")
    }

    @IBAction func tempButton(_ sender: UIButton) {

        guard let currentHost = currentHost,
            let eventController = eventController,
            let name = eventNameTextField.text, !name.isEmpty,
            let dateString = eventDateTextField.text, !dateString.isEmpty,
            let description = descriptionTextField.text, !description.isEmpty,
            let type = typeTextField.text, !type.isEmpty,
            let notes = notesTextField.text, !notes.isEmpty else { unwrapTextFields() ; return }

        if let passedInEvent = event {

            // TODO: Need to make sure the date pickers are set to the curent values of the start time and end time
            // TODO: instead of this guard let, if the end is empty, that is fine because it is optional
            guard let dateFromString = dateString.dateFromString() else {
                print("Error on line: \(#line) in function: \(#function)\n")
                return
            }

            // here possibly only pass the data that actually changed?
            let updatedEvent = eventController.updateEvent(event: passedInEvent,
                                                           eventName: name,
                                                           eventDate: dateFromString,
                                                           description: description,
                                                           type: type,
                                                           notes: notes)
            self.activityIndicator(shouldStart: true)
            putUpdateEvent(with: updatedEvent, andEventController: eventController)
        } else {
            guard let dateFromString = dateString.dateFromString() else {
                print("Error on line: \(#line) in function: \(#function)\n")
                return
            }

            let event = Event(name: name,
                              eventType: type,
                              eventDescription: description,
                              eventDate: dateFromString,
                              hostID: currentHost.identifier,
                              imageURL: URL(string: "tewtststtt.com")!,
                              notes: notes,
                              eventID: nil)
            self.activityIndicator(shouldStart: true)
            authorizeEvent(event, withHost: currentHost, andEventController: eventController)
        }
//        self.activityIndicator(shouldStart: false)
    }

    private func unwrapTextFields() {
        print("this was hit")
        var textFieldArray = [UITextField]()

        textFieldArray.append(contentsOf: [eventNameTextField,
                                           descriptionTextField,
                                           eventDateTextField,
                                           typeTextField,
                                           notesTextField])

        for tField in textFieldArray {
            if tField.text == "" && tField.placeholder != nil {
                tField.shake()
                print("textfield: \(tField)")
                print("textField placeHolder: \(String(describing: tField.placeholder))")
            }
        }
    }
} // END OF CLASS

extension CreateEventViewController {

    // MARK: - PRIVATE FUNCTIONS
    
    ///this dismisses the custom alert controller
    @objc func dissmiss() {
         myAlert.dismissAlert()
       }
    
    private func updateViewsWithEvent() {
        guard let passedInEvent = event, isViewLoaded else { return }
        print("This is the event's id: \(passedInEvent.eventID)")

        self.title = passedInEvent.name
        eventNameTextField.text = passedInEvent.name
        descriptionTextField.text = passedInEvent.eventDescription
        eventDateTextField.text = passedInEvent.eventDate?.stringFromDate()
        typeTextField.text = passedInEvent.eventType
        notesTextField.text = passedInEvent.notes
    }

    // Had to add the following functions because SwiftLint was warning that the SaveEvent button function was longer than 40 lines
    private func authorizeEvent(_ event: Event, withHost currentHost: Host, andEventController eventController: EventController) {
        // NOTE: This next line is what causes the event to be linked with the current host in Core Data
        event.host = currentHost

        eventController.authorize(event: event) { (results) in
            switch results {
            case let .success(eventRep):
                print("successful attempt to create event in vc: \(eventRep.name)")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.activityIndicator(shouldStart: false)
                }
            case let .failure(error):
                self.activityIndicator(shouldStart: false)
                self.myAlert.showAlert(with: "Error Creating an Event", message: "\(error.localizedDescription)", on: self)
                print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
            }
        }
    }

    private func putUpdateEvent(with event: Event, andEventController eventContrller: EventController) {
        eventController.saveUpdateEvent(event) { (results) in
            switch results {

            case .success:
                print("successfully called the put function to update event on server")
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.activityIndicator(shouldStart: false)
                }

            case .failure(.errorUpdatingEventOnServer(let error)):
                self.activityIndicator(shouldStart: false)
                self.myAlert.showAlert(with: "Error Creating an Event", message: "\(error.localizedDescription)", on: self)
                print("Error on line: \(#line) in function: \(#function)\n")
            default:
                break
            }
        }
    }
}
