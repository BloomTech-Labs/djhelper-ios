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
    var eventController: EventController?
    var hostController: HostController?
    var currentHost: Host?
    var hostEventCount: Int?
    var eventName: String = ""
    var eventDescription: String = ""
    var eventDate: Date = Date()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        slides = createSlides()
        setupSlideScrollView(slides: slides)

        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .lightGray
        view.bringSubviewToFront(pageControl)
    }

    func createSlides() -> [Slide] {

        // swiftlint:disable all
        let slide1: Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.titleLabel.text = "Welcome! \nLet's create your first event."
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

        if hostEventCount == nil {
            return [slide1, slide2, slide3, slide4]
        } else {
            return [slide2, slide3, slide4]
        }
    }

    func setupSlideScrollView(slides: [Slide]) {
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

        switch Int(pageIndex) {
        case 1:
            self.eventName = slides[1].textField.text ?? ""
        case 2:
            self.eventDescription = slides[2].textField.text ?? ""
        default:
            return
        }
    }
}
