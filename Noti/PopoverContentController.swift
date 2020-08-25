//
//  PopoverContentController.swift
//  Noti
//
//  Created by APPLE on 2020/08/25.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

protocol PopoverContentControllerDelegate: class {
    func popoverContent(controller: PopoverContentController, didselectItem name: String)
}



class PopoverContentController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var popupContentTable: UITableView!
    let moreButtonArray = ["공유하기","사파리로 열기"]
    static let popoverCellId = "PopoverCell"
    var delegate : PopoverContentControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        popupContentTable.separatorStyle = UITableViewCell.SeparatorStyle.none
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: PopoverContentController.popoverCellId)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: PopoverContentController.popoverCellId)
        }
        cell?.textLabel?.text = moreButtonArray[indexPath.row]
        cell?.textLabel?.textAlignment = .center
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAction = moreButtonArray[indexPath.row]
        self.delegate?.popoverContent(controller: self, didselectItem: selectedAction)
        self.dismiss(animated: true, completion: nil)
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

