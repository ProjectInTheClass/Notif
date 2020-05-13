//
//  detailViewController.swift
//  Noti
//
//  Created by Junroot on 2020/05/13.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class detailViewController: UIViewController {
    
    var title2: String?
    var source: String?
    var date: String?
    var back2: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem?.title = back2
        
        titleLabel.text = title2
        sourceLabel.text = source
        dateLabel.text = date
        
        
        
        // Do any additional setup after loading the view.
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
