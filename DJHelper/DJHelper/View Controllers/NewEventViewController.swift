//
//  NewEventViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/18/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class NewEventViewController: UIViewController, UIScrollViewDelegate {

    var slides: [Slide] = []
    var myAlert = CustomAlert()
    var eventController: EventController?
    var hostController: HostController?
    var currentHost: Host?
    var hostEventCount: Int?
    var eventName: String = ""
    var eventDescription: String = ""
    var eventDate: Date = Date()

    private var eventTimeDatePicker: UIDatePicker?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    // MARK: - View Control Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        eventTimeDatePicker = UIDatePicker()
        eventTimeDatePicker?.datePickerMode = .dateAndTime
        eventTimeDatePicker?.minuteInterval = 15
        eventTimeDatePicker?.addTarget(self, action: #selector(self.eventDateChanged(datePicker:)), for: .valueChanged)

        scrollView.delegate = self
        slides = createSlides()
        setupSlideScrollView(slides: slides)

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

        // Here I want to make sure that it is presenting the first slide on screen
        // I think the way to do that is to make sure it is at the left-most point of the frame?
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .lightGray
        view.bringSubviewToFront(pageControl)
    }

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
    @IBAction func saveNewEvent(_ sender: UIButton) {
        guard let eventController = eventController,
            let currentHost = currentHost,
            !eventName.isEmpty,
            !eventDescription.isEmpty else { return }

/*
         I haven't been able to figure out how to use this code.
         It continues on to the authorizeEvent method instead of stopping like I need it to.

        if eventName.isEmpty {
            let alertController = UIAlertController(title: "Missing Field", message: "Please enter in a value for Event Name", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                return
            }
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        } else if eventDescription.isEmpty {
            let alertController = UIAlertController(title: "Missing Field", message: "Please enter in a value for Event Description", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
                return
            }
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
        }
 */

        let newEvent = Event(name: eventName,
                             eventType: "default",
                             eventDescription: eventDescription,
                             eventDate: eventDate,
                             hostID: currentHost.identifier,
                             eventID: nil)
        self.activityIndicator(shouldStart: true)
        authorizeEvent(newEvent, withHost: currentHost, andEventController: eventController)

    }

    // MARK: - Methods for New Event
    func authorizeEvent(_ event: Event, withHost currentHost: Host, andEventController eventController: EventController) {

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
                        self.performSegue(withIdentifier: "unwindToEventList", sender: self)
                    }
                    alertController.addAction(alertAction)
                    self.present(alertController, animated: true)
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    self.activityIndicator(shouldStart: false)
                    self.myAlert.showAlert(with: "Error Creating Event", message: "\(error.localizedDescription)", on: self)
                }
                print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
            }
        }
    }

    private func resetForm() {
        self.activityIndicator(shouldStart: false)
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
    private func createSlides() -> [Slide] {

        // swiftlint:disable all
        let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.titleLabel.text = "Welcome!\nLet's create your first event."
        slide1.titleLabel.textAlignment = .center
        slide1.titleLabel.adjustsFontSizeToFitWidth = true
        slide1.subtitleLabel.text = "Our goal is to get the audience to participate in your setlist by requesting tracks and reacting to what you play."
        slide1.textField.isHidden = true
        slide1.saveEvent.isHidden = true

        let slide2: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.titleLabel.text = "Give your event a Title."
        slide2.subtitleLabel.text = "What is your event called?"
        slide2.textField.placeholder = "Event title"
        slide2.saveEvent.isHidden = true

        let slide3: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.titleLabel.text = "Give your event a Description."
        slide3.subtitleLabel.text = "What genre of music are you playing? \nAny special details to share?"
        slide3.textField.placeholder = "Event description"
        slide3.saveEvent.isHidden = true

        let slide4: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide4.titleLabel.text = "When is your Event \nHappening?"
        slide4.subtitleLabel.isHidden = true
        slide4.textField.placeholder = "Event date     🗓"
        slide4.textField.inputView = eventTimeDatePicker

        if hostEventCount == nil {
            return [slide1, slide2, slide3, slide4]
        } else {
            return [slide2, slide3, slide4]
        }
    }

    private func setupSlideScrollView(slides: [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 88, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count),
                                        height: view.frame.height - 150)
        scrollView.isPagingEnabled = true

        for identifier in 0..<slides.count {
            slides[identifier].frame = CGRect(x: scrollView.frame.width * CGFloat(identifier),
                                              y: 0,
                                              width: scrollView.frame.width,
                                              height: scrollView.frame.height)
            scrollView.addSubview(slides[identifier])
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageControl.currentPage = Int(pageIndex)

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
