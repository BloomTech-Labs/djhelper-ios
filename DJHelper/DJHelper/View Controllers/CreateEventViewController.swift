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
    }

    // MARK: - IBActions
    @IBAction func saveEvent(_ sender: UIBarButtonItem) {
        //        let text = unwrapAllTextFields()
    }

    @IBAction func tempButton(_ sender: UIButton) {
        print("button pressed: \(sender)")

        guard let name = eventNameTextField.text, !name.isEmpty,
            let date = eventDateTextField.text, !date.isEmpty,
            let description = descriptionTextField.text, !description.isEmpty,
            let start = startTimetextField.text, !start.isEmpty,
            let end = endTimeTextField.text, !end.isEmpty,
            let type = typeTextField.text, !type.isEmpty,
            let notes = notesTextField.text, !notes.isEmpty else { unwrapTextFields() ; return }

//        guard let dateFromString = date.dateFromString(),
//            let startTimeDate = start.dateFromString(),
//            let endTimeDate = end.dateFromString(),
//            let hostId = currentHost?.identifier else { return }

        let event = Event(name: name,
                          eventType: type,
                          eventDescription: description,
                          eventDate: Date() /*dateFromString*/,
                          hostID: 1, locationID: 1,
                          startTime: Date() /*startTimeDate*/,
                          endTime: Date() /*endTimeDate*/,
                          imageURL: URL(string: "tewtststtt.com")!,
                          notes: notes,
                          eventID: 1)

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

    private func unwrapTextFields() {
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
                print("textfield: \(tField)")
                print("textField placeHolder: \(String(describing: tField.placeholder))")
            }
        }
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
}
