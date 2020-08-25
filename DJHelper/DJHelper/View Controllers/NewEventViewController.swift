//
//  NewEventViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/18/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// The protocol/delegate method is used so the HostEventViewController can display a new event immediately after one is created.
protocol newEventCreatedDelegate {
    func loadNewEvent()
}

class NewEventViewController: UIViewController, UIScrollViewDelegate {

    var slides: [Slide] = []
    var myAlert = CustomAlert()
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    var eventController: EventController?
    var hostController: HostController?
    var currentHost: Host?
    var hostEventCount: Int?
    var eventName: String = ""
    var eventDescription: String = ""
    var eventDate: Date = Date()
    var delegate: newEventCreatedDelegate?

    private var eventTimeDatePicker: UIDatePicker?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    // MARK: - View Control Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Instantiates a UIDatePicker to be used to sent the event date in the appropriate Slide.
        eventTimeDatePicker = UIDatePicker()
        eventTimeDatePicker?.datePickerMode = .dateAndTime
        eventTimeDatePicker?.minuteInterval = 15
        eventTimeDatePicker?.addTarget(self, action: #selector(self.eventDateChanged(datePicker:)), for: .valueChanged)

        scrollView.delegate = self
        slides = createSlides()
        setupSlideScrollView(slides: slides)

        // Sets up and displays the circles on the bottom part of the screen to indicate the number of pages and the current page.
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .lightGray
        view.bringSubviewToFront(pageControl)

        // tap anywhere on the screen to dismiss the date picker
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewTapped(gestureRecognizer:)))
        view.addGestureRecognizer(tapGesture)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .lightGray
        view.bringSubviewToFront(pageControl)
    }

    /// Set the event date to the date indicated by the date picker.
    @objc func eventDateChanged(datePicker: UIDatePicker) {
        eventDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d/yyyy h:mm a"
        slides[slides.count - 1].textField.text = dateFormatter.string(from: datePicker.date)
    }

    @objc func viewTapped(gestureRecognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Actions
    /*
     When the save button is tapped:
        - Make sure all text fields have content
        - If a text field is empty, display an alert notifying the user to enter a value in that text field
        - Otherwise, create a new event based on the text field contents and call the method to post the event to the server
     */
    @IBAction func saveNewEvent(_ sender: UIButton) {
        guard let eventController = eventController,
            let currentHost = currentHost,
            !eventName.isEmpty,
            !eventDescription.isEmpty else {

                if eventName.isEmpty {
                    let alertController = UIAlertController(title: "Missing Field",
                                                            message: "Please enter in a value for Event Name",
                                                            preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                        return
                    }
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                } else if eventDescription.isEmpty {
                    let alertController = UIAlertController(title: "Missing Field",
                                                            message: "Please enter in a value for Event Description",
                                                            preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                        return
                    }
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                }
                return
        }

        let newEvent = Event(name: eventName,
                             isExplicit: true,
                             eventDescription: eventDescription,
                             eventDate: eventDate,
                             hostID: currentHost.identifier,
                             eventID: nil)
        self.activityIndicator(activityIndicatorView: activityIndicatorView, shouldStart: true)
        authorizeEvent(newEvent, withHost: currentHost, andEventController: eventController)

    }

    // MARK: - Methods for New Event
    /**
     Calls the authorize(event:) method in EventController. If successful, posts the event to the server and saves it to Core Data.

     - Parameter event: the newly created Event
     - Parameter currentHost: the currently logged-in host
     - Parameter eventController: the current instance of the EventController
     */
    func authorizeEvent(_ event: Event, withHost currentHost: Host, andEventController eventController: EventController) {

        // In Core Data, set the Host associated with the event equal to the currentHost
        event.host = currentHost

        eventController.authorize(event: event) { (results) in
            switch results {
            case .success:
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Event Created",
                                                            message: "Congratulations! Your event has been created.",
                                                            preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                        self.resetForm()
                        self.delegate?.loadNewEvent()
                        self.performSegue(withIdentifier: "unwindToEventList", sender: self)
                    }
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.activityIndicator(activityIndicatorView: self.activityIndicatorView, shouldStart: false)
                    self.myAlert.showAlert(with: "Error Creating Event", message: "\(error.localizedDescription)", on: self)
                }
                print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
            }
        }
    }

    // After an event is created, resets the form to empty text fields
    // The first slide, slides[0], contains instructions and is only visible when no events have been created.
    private func resetForm() {
        self.activityIndicator(activityIndicatorView: activityIndicatorView, shouldStart: false)
        eventName = ""
        eventDescription = ""
        eventDate = Date()

        if slides.count == 4 {
            slides[1].textField.text = nil
            slides[2].textField.text = nil
            slides[3].textField.text = nil
            scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), animated: false)

        } else {
            slides[0].textField.text = nil
            slides[1].textField.text = nil
            slides[2].textField.text = nil
            scrollView.scrollRectToVisible(CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), animated: false)
        }
    }

    // MARK: - Methods for Slides
    /**
     Creates an array of Slide UIViews to be displayed as pages in the scroll view.
     Includes an introductory Slide if no events have been created yet.

     - Returns: an array of type Slide
     */
    private func createSlides() -> [Slide] {

        // swiftlint:disable all
        // slide1 is the introduction providing the user some guidance.
        let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.titleLabel.text = "Welcome!\nLet's create your first event."
        slide1.titleLabel.textAlignment = .center
        slide1.titleLabel.adjustsFontSizeToFitWidth = true
        slide1.subtitleLabel.text = "Our goal is to get the audience to participate in your setlist by requesting tracks and reacting to what you play."
        slide1.textField.isHidden = true
        slide1.saveEvent.isHidden = true

        // slide2 includes a text field for the event name
        let slide2: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.titleLabel.text = "Give your event a Title."
        slide2.subtitleLabel.text = "What is your event called?"
        slide2.textField.placeholder = "Event title"
        slide2.saveEvent.isHidden = true

        // slide3 includes a text field for the event description
        let slide3: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.titleLabel.text = "Give your event a Description."
        slide3.subtitleLabel.text = "What genre of music are you playing? \nAny special details to share?"
        slide3.textField.placeholder = "Event description"
        slide3.saveEvent.isHidden = true

        // slide4 includes a date picker for the event date
        let slide4: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide4.titleLabel.text = "When is your Event \nHappening?"
        slide4.subtitleLabel.isHidden = true
        slide4.textField.placeholder = "Event date     🗓"
        slide4.textField.inputView = eventTimeDatePicker

        // if the count of events is 0, no events have been created yet and the first slide is shown,
        // otherwise the first slide is skipped.
        if hostEventCount == 0 {
            return [slide1, slide2, slide3, slide4]
        } else {
            return [slide2, slide3, slide4]
        }
    }

    /**
     Sets up the position and size of the scroll view frame and the scroll view content.
     The scroll view frame is the size of its super view, offset in the y-axis to lower the top.
     The scroll view content size is as wide as the total number of slides presented, and the height is 150 px less than the frame size
     */
    private func setupSlideScrollView(slides: [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 88, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count),
                                        height: view.frame.height - 150)
        scrollView.isPagingEnabled = true

        // based on the current slide number, the position is offset on the x-axis to show that current slide view.
        for identifier in 0..<slides.count {
            slides[identifier].frame = CGRect(x: scrollView.frame.width * CGFloat(identifier),
                                              y: 0,
                                              width: scrollView.frame.width,
                                              height: scrollView.frame.height)
            scrollView.addSubview(slides[identifier])
        }
    }

    // A method used by the scroll view delegate to inform when the page has been advanced.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // calculates the current page based on the offset of the content.
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)

        // sets the eventName and eventDescription properties after they have been entered and user swipes to next page
        if slides.count == 4 {
            switch Int(pageIndex) {
            case 1:
                self.eventName = slides[1].textField.text ?? ""
            case 2:
                self.eventDescription = slides[2].textField.text ?? ""
            default:
                return
            }
        } else {
            switch Int(pageIndex) {
            case 1:
                self.eventName = slides[0].textField.text ?? ""
            case 2:
                self.eventDescription = slides[1].textField.text ?? ""
            default:
                return
            }
        }
    }
}
