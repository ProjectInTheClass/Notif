//
//  TagCollectionTableViewCell.swift
//  Noti
//
//  Created by sejin on 2020/06/23.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class TagCollectionTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var TagCollectionView: UICollectionView!
    //let selectedChannel = 0
    var channels = [Channel]()
    
    func loaddata(){
        TagCollectionView.delegate = self
        TagCollectionView.dataSource = self
        TagCollectionView.reloadData()
        channels = CoreDataManager.shared.getChannels()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("entercollection")
        if(HistoryTableViewController.selectedChannel != 0){
            return channels[HistoryTableViewController.selectedChannel].channelTags!.count-1
        }
        else{
            return channels[HistoryTableViewController.selectedChannel].channelTags!.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tag", for: indexPath) as! TagCollectionViewCell
        if(HistoryTableViewController.selectedChannel != 0){
            cell.tagName.text = "#\( channels[HistoryTableViewController.selectedChannel].channelTags![indexPath.row+1])"
        }
        else{
            cell.tagName.text = "#\( channels[HistoryTableViewController.selectedChannel].channelTags![indexPath.row])"
        }
        if (HistoryTableViewController.selectedTag == indexPath.row) {
            cell.tagName.textColor = .black
        }else{
            cell.tagName.textColor = .sourceFont
        }
        //print(cell.tagName.text)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //        arr = arrList[indexPath.row]
        if(HistoryTableViewController.selectedTag == indexPath.row){
            HistoryTableViewController.selectedTag = -1
        }
        else{
            HistoryTableViewController.selectedTag = indexPath.row
                   print("\(HistoryTableViewController.selectedTag) is selectedTag")
        }
       
    //        print("Cell \(indexPath.row) sellected")
            //print(channels[indexPath.row].channelTags)
   //         selectedChannel = indexPath.row
   //         updateCardsAndTitle()
   //         channelCollection.reloadData()
   //         self.tableView.reloadData()
        TagCollectionView.reloadData()
        //HistoryTableViewController.updateCardsAndTitle()
        }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }
}
