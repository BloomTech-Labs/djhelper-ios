//
//  CreateEventViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/3/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class CreateEventViewController: UIViewController {

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
    @IBOutlet weak var startTimetextField: UITextField!
    @IBOutlet weak var endTimeTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var notesTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        updateViewsWithEvent()

        startTimeDatePicker = UIDatePicker()
        startTimeDatePicker?.datePickerMode = .dateAndTime
        startTimeDatePicker?.minuteInterval = 15
        startTimeDatePicker?.addTarget(self, action: #selector(self.eventDateChanged(datePicker:)), for: .valueChanged)

        endTimeDatePicker = UIDatePicker()
        endTimeDatePicker?.datePickerMode = .dateAndTime
        endTimeDatePicker?.minuteInterval = 15
        endTimeDatePicker?.date = startTimeDatePicker?.date ?? Date()  // unfortunately this doesn't default the picker to the start time
        endTimeDatePicker?.addTarget(self, action: #selector(self.endTimeChanged(datePicker:)), for: .valueChanged)

        eventDateTextField.inputView = startTimeDatePicker
        endTimeTextField.inputView = endTimeDatePicker

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    @objc func eventDateChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy h:mm a"
        startTimetextField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func endTimeChanged(datePicker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy h:mm a"
        endTimeTextField.text = dateFormatter.string(from: datePicker.date)
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
//            let date = eventDateTextField.text, !date.isEmpty,
            let description = descriptionTextField.text, !description.isEmpty,
            let startTime = startTimetextField.text, !startTime.isEmpty,
            let endTime = endTimeTextField.text, !endTime.isEmpty,
            let type = typeTextField.text, !type.isEmpty,
            let notes = notesTextField.text, !notes.isEmpty else { unwrapTextFields() ; return }

        if let passedInEvent = event {

            // TODO: instead of this guard let, if the end is empty, that is fine because it is optional
            guard let start = startTime.dateFromString(),
                let end = endTime.dateFromString() else { return }

            // here possibly only pass the data that actually changed?
            let updatedEvent = eventController.updateEvent(event: passedInEvent,
                                                           eventName: name,
                                                           eventDate: start,
                                                           description: description,
                                                           startTime: start,
                                                           endTime: end,
                                                           type: type,
                                                           notes: notes)

            putUpdateEvent(with: updatedEvent, andEventController: eventController)
        } else {
            guard let start = startTimeDatePicker?.date else { return }
            guard let end = endTimeDatePicker?.date else { return }
            let event = Event(name: name,
                              eventType: type,
                              eventDescription: description,
                              eventDate: start,
                hostID: currentHost.identifier,
                locationID: 1,
                startTime: start,
                endTime: end,
                imageURL: URL(string: "tewtststtt.com")!,
                notes: notes,
                eventID: 1)

            authorizeEvent(event, withHost: currentHost, andEventController: eventController)
        }
    }

    private func unwrapTextFields() {
        print("this was hit")
        var textFieldArray = [UITextField]()

        textFieldArray.append(contentsOf: [eventNameTextField,
                                           eventDateTextField,
                                           descriptionTextField,
                                           startTimetextField,
                                           endTimeTextField,
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
    private func updateViewsWithEvent() {
        guard let passedInEvent = event, isViewLoaded else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        self.title = passedInEvent.name
        eventNameTextField.text = passedInEvent.name
        eventDateTextField.text = passedInEvent.eventDate?.stringFromDate()
        descriptionTextField.text = passedInEvent.description
        startTimetextField.text = passedInEvent.startTime?.stringFromDate()
        endTimeTextField.text = passedInEvent.endTime?.stringFromDate()
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
                }
            case let .failure(error):
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
                self.navigationController?.popViewController(animated: true)
            case .failure:
                print("Error on line: \(#line) in function: \(#function)\n")
            }
        }
    }
}
