//
//  EventPageViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import MessageUI

class EventPageViewController: UIViewController {

    // MARK: - Properties
    var event: Event? {
        didSet {
            updateViews()
        }
    }
    var hostController: HostController?
    var currentHost: Host?
    var eventController: EventController?

    // MARK: - IBOutlets
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var detailButtonProperties: UIButton!
    @IBOutlet weak var shareLinkButtonProperties: UIButton!

    @IBOutlet weak var segmentedControlProperties: UISegmentedControl!

    @IBOutlet weak var addSongButtonProperties: UIButton!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        setupButtons()

        detailButtonProperties.frame.size.width = 150
        shareLinkButtonProperties.frame.size.width = 150
        addSongButtonProperties.frame.size.width = view.frame.width - 40

        updateViews()

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
    }

    // MARK: - IBActions
    @IBAction func detailButtonTapped(_ sender: UIButton) {
    }

    @IBAction func shareLinkButtonTapped(_ sender: UIButton) {
        setupEmailForLink()
    }

    @IBAction func addSongButtonTapped(_ sender: UIButton) {
    }

    @IBAction func segueValueChanged(_ sender: UISegmentedControl) {
    }

    // MARK: - Private functions
    private func setupButtons() {
        detailButtonProperties.colorTheme()
        shareLinkButtonProperties.colorTheme()
        addSongButtonProperties.colorTheme()
    }

    // Provides feature to send a URL via the Mail app.
    // When testing, it only works on a device, not the simulator.
    private func setupEmailForLink() {
        guard MFMailComposeViewController.canSendMail(),
            event != nil else {
                return
        }
        guard let hostName = event?.host?.name else { return }

        let mailController = MFMailComposeViewController()
        mailController.mailComposeDelegate = self

        // Configure the fields of the interface.
        mailController.setSubject("You've Been Invited to a DJHelper Event!")
        mailController.setMessageBody("""
            \(hostName) has invited you to view a music playlist for an event they are hosting.
            You will be able to view the playlist, request additional songs, and upvote existing requests that you like.

            View the event playlist here: <insert FE web link here>.
            """,
            isHTML: false)

        // Present the view controller modally.
        self.present(mailController, animated: true, completion: nil)
    }

    private func updateViews() {
        guard isViewLoaded else { return }
        guard let event = event else { return }

        self.title = event.name
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
extension EventPageViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension EventPageViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

        guard error == nil else {
            print("Mail finished with error: \(String(describing: error))")
            return
        }

        switch result {

        case .cancelled:
            self.dismiss(animated: true, completion: nil)
        case .saved:
            return
        case .sent:
            self.dismiss(animated: true, completion: nil)
        case .failed:
            return
        @unknown default:
            print("A new feature in iOS has caused the mail controller to fail")
        }
    }
}
