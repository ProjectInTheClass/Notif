//
//  ChannelCenterViewController.swift
//  Noti
//
//  Created by 이상윤 on 2020/06/12.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class ChannelCenterViewController: UIViewController {
    var channels = [Channel]()
    
    var categories = [String]()
    
    //        @IBOutlet weak var historyTable: UITableView!
    func loadData(){
        channels = CoreDataManager.shared.getChannels().filter{ $0.title! != "전체"}
        channels = channels.sorted(by: {$0.group! > $1.group!})
        
        categories = Array(Set(channels.map{$0.group!})).sorted(by: >)
    }
//    func updateChannels(){
//        let source = Array(Set(channels.map{$0.source!})).sorted(by:<)
//        //print("\(selectedChannel)!!!")
//        let sectionChannels = channels.filter{$0.source! == source[selectedChannel.section]}
//        sectionChannels[selectedChannel.item].isSubscribed = !sectionChannels[selectedChannel.item].isSubscribed
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        navigationItem.title = "채널센터"
        //updateChannels()
        //categories = Array(Set(channels.map{$0.source!})).sorted(by: >)
        let coloredAppearance = UINavigationBarAppearance()
       coloredAppearance.configureWithOpaqueBackground()
       coloredAppearance.backgroundColor = UIColor.navBack

        if self.traitCollection.userInterfaceStyle == .dark{
            coloredAppearance.configureWithOpaqueBackground()
            self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
            self.navigationController?.navigationBar.standardAppearance = coloredAppearance
        }
        else{
            coloredAppearance.configureWithOpaqueBackground()
            coloredAppearance.backgroundColor = UIColor.navBack
            coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
            coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
            self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
            self.navigationController?.navigationBar.standardAppearance = coloredAppearance
        }
        //네비게이션바 배경색 넣어주는 코드
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

extension ChannelCenterViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return channels.count
//        let source = Array(Set(channels.map{$0.source!})).sorted(by:>)
        
        return channels.filter{ $0.group == categories[section] }.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let source = Array(Set(channels.map{$0.source!})).sorted(by: >)
        let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! ChannelCollectionViewCell
        
        cell.titleLabel.text = sectionChannels[indexPath.item].title
        cell.categoryLabel.text = sectionChannels[indexPath.item].source
        cell.colorImageView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionChannels[indexPath.item].color!)
        
        // 구독안하거 블러처리
        if (sectionChannels[indexPath.item].isSubscribed == false){
            cell.backView.backgroundColor = UIColor(white: 1, alpha: 1)
            cell.backView.alpha = 0.67
            cell.colorImageView.backgroundColor = .navBack
        }else {
            if self.traitCollection.userInterfaceStyle == .dark{
                cell.backView.backgroundColor = .clear
                               
                           }
                           else{
                cell.backView.backgroundColor = .white
                           }
            //cell.backView.backgroundColor = .white
            cell.backView.alpha = 1
            cell.colorImageView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionChannels[indexPath.item].color!)
        }
        
        // 그림자 부분

        cell.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
        cell.layer.shadowRadius = 3 // 반경?
        cell.layer.shadowOpacity = 0.2 //
//                print(sectionChannels)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell \(indexPath.row) sellected")
        let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }
        CoreDataManager.shared.subscribedChannel(subtitle: sectionChannels[indexPath.row].subtitle!, source: sectionChannels[indexPath.row].source!){ onSuccess in print("saved = \(onSuccess)")}
        loadData()
        collectionView.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        let returnNum = Array(Set(channels.map{$0.source!}))
        return categories.count
    }
//
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind : String, at indexPath : IndexPath) -> UICollectionReusableView{
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                
                let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ChannelCollectionViewHeader
                let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }
                headerview.categoryLabel.text = sectionChannels[indexPath.item].group
                headerview.colorLabel.text =  sectionChannels[indexPath.item].group
                if self.traitCollection.userInterfaceStyle == .dark{
                    headerview.colorLabel.textColor  =  .white
                    
                }
                else{
                    headerview.colorLabel.textColor  =  .clear
                }
                headerview.colorLabel.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionChannels[0].color!)
                
                
                return headerview
                
            default:
                let footerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ChannelCollectionViewHeader
                footerview.categoryLabel.text = nil
                footerview.colorLabel.text = nil
                return footerview
        }
    }
    
    
    
    @IBAction func buttonPressed(_ sender: Any){
        print("button Pressed!")
        performSegue(withIdentifier: "tagSegue", sender: self)
    }

}

extension ChannelCenterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2) - 30, height: 86)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
    }
}

