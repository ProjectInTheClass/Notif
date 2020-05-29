//
//  ChannelCollectionViewController.swift
//  Noti
//
//  Created by sejin on 2020/05/28.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ChannelCell"

class ChannelCollectionViewController: UICollectionViewController {
    var channels = channelsDataSource.channels
    var channelsForServer = channelsDataSource.channelForServer
    let cellSpacing :CGFloat = 5
    let sectionSpacing :CGFloat = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //collectionView.backgroundColor = .white
        //let width = (view.frame.size.width-20)/2
        //let height = width - 100
        let layout = self.collectionViewLayout as! UICollectionViewFlowLayout
        //layout.itemSize = CGSize(width: width, height: height)
        layout.minimumLineSpacing = 50
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: cellSpacing, bottom: 0, right: cellSpacing)
        layout.sectionInset.top = sectionSpacing
        layout.sectionInset.bottom = sectionSpacing
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.allowsMultipleSelection = true
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChannelCollectionViewCell
        
        // Configure the cell
        if(indexPath.section == 0){
            cell.channelTitle.text = channels[indexPath.item].title
            cell.channelSubTitle.text = channels[indexPath.item].category
            cell.channelColor.layer.backgroundColor = UIColor.first.cgColor
        }
        
        else{
            cell.channelTitle.text = channels[indexPath.item + 2].title
            cell.channelSubTitle.text = channels[indexPath.item + 2].category
            cell.channelColor.layer.backgroundColor = UIColor.second.cgColor
        }
        
        //cell.ChannelController = self
        cell.layer.backgroundColor = UIColor.white.cgColor
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)//CGSizeMake(0, 2.0);
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect:cell.bounds, cornerRadius:cell.contentView.layer.cornerRadius).cgPath
        //첫셀은 무조건 선택됨
        if(indexPath.section==0 && indexPath.item == 0){
            return cell
        }
        else{
            cell.channelColor.layer.backgroundColor = UIColor.darkGray.cgColor
            cell.channelTitle.textColor = .darkGray
            cell.channelSubTitle.textColor = .darkGray
            cell.channelCell.backgroundColor = .systemGray6
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

      return CGSize(width: 150, height: 100)

    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind : String, at indexPath : IndexPath) -> UICollectionReusableView{
        //let header = ChannelCollectionViewHeader()
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerCell", for: indexPath) as! ChannelCollectionViewHeader
        if(indexPath.section == 0) {
            header.titleForChannelList.text = "학부사이트"
        }
        else {
            header.titleForChannelList.text = "포털"
        }
            return header
        
    }
    //지정된 채널 저장하는 변수 만들기
    
    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ChannelCollectionViewCell
        if(indexPath.section == 0 ){
            cell.channelColor.layer.backgroundColor = UIColor.first.cgColor
        }
        else{
            cell.channelColor.layer.backgroundColor = UIColor.second.cgColor
        }
        cell.channelTitle.textColor = .black
        cell.channelSubTitle.textColor = .black
        cell.channelCell.backgroundColor = .white
        channelsForServer.append(Channel(title: cell.channelTitle.text!, category:  cell.channelSubTitle.text!))
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! ChannelCollectionViewCell
        cell.channelColor.layer.backgroundColor = UIColor.darkGray.cgColor
        cell.channelTitle.textColor = .darkGray
        cell.channelSubTitle.textColor = .darkGray
        cell.channelCell.backgroundColor = .systemGray6
        //channelView.channelForserver
    }
        
    func buttonTouched(_ cell : UICollectionViewCell){
        let path = collectionView.indexPath(for: cell)
        let addChannelCell = collectionView.cellForItem(at: path!) as! ChannelCollectionViewCell
        channelsForServer.append(Channel(title: addChannelCell.channelTitle.text!, category:  addChannelCell.channelSubTitle.text!))
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
