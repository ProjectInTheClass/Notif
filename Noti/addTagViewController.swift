//
//  addTagViewController.swift
//  Noti
//
//  Created by sejin on 2020/05/29.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit
import CoreData

class addTagViewController: UIViewController, UITableViewDataSource, UITextFieldDelegate  {
    //var channelView = ChannelViewController()
    var allTagsNameList = [String]()
    //var cardView = CardDataSource()
    var mangedObjectContext : NSManagedObjectContext!
    @IBOutlet weak var tagTextField: UITextField!
    @IBOutlet weak var tagTableView: UITableView!
    var allTags = [Tags]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        allTags = CoreDataManager.shared.getTags()
        for i in 0..<allTags.count{
            allTagsNameList += [allTags[i].name!]
        }
        tagTableView.dataSource = self
        tagTextField.delegate = self
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
    private func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  allTags.count
      }
      
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allTagCell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = allTags[indexPath.row].name
        return cell
      }
    //공백과 10글자 이내로
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == ""{
            return false
        }
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in : currentText) else{ return false}
        let updateText = currentText.replacingCharacters(in: stringRange, with: string)
        return (updateText.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count <= 10 )
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(allTagsNameList.contains(textField.text!)){
            textField.text! = ""
            return false
        }
        else{
            allTagsNameList.append(textField.text!)
            let now = NSDate()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            CoreDataManager.shared.saveTags(name: textField.text!, time: now as Date){ onSuccess in print("saved = \(onSuccess)")}
           // channelsDataSource.allTags.append(Tag(name: textField.text!, time: now as Date ))
            //tableView(tagTableView, cellForRowAt: IndexPath)
            
           // cardView.cards.append(Card(title: textField.text!,channelName: "", category: "", time: now as Date, color: UIColor.first, url: ""))
            self.viewDidLoad()
            tagTableView.reloadData()
            CoreDataManager.shared.saveCards(title: textField.text!, source: "", category: "", tag :[], time: now as Date, color:UIColor.first, isVisited: false, url:"", json:["":""], isFavorite: false){ onSuccess in print("saved = \(onSuccess)")}
            textField.text! = ""
            
            return true
        }
        
    }

}
