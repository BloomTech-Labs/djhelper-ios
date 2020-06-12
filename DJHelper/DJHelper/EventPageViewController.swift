//
//  EventPageViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class EventPageViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var detailButtonProperties: UIButton!
    @IBOutlet weak var shareLinkButtonProperties: UIButton!

    @IBOutlet weak var segmentedControlProperties: UISegmentedControl!
    
    @IBOutlet weak var addSongButtonProperties: UIButton!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupButtons()
        detailButtonProperties.frame.size.width = 150
        shareLinkButtonProperties.frame.size.width = 150
    }

    // MARK: - IBActions
    @IBAction func detailButtonTapped(_ sender: UIButton) {
    }

    @IBAction func shareLinkButtonTapped(_ sender: UIButton) {
    }

    @IBAction func addSongButtonTapped(_ sender: UIButton) {
    }

    @IBAction func segueValueChanged(_ sender: UISegmentedControl) {
    }

    // MARK: - Private functions
    func setupButtons() {
        detailButtonProperties.colorTheme()
        shareLinkButtonProperties.colorTheme()
        addSongButtonProperties.colorTheme()
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
