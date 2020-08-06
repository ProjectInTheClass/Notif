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
    var channelsInDB = ["학사-한양대학교":"hyhs", "입학-한양대학교":"hyih", "모집/채용-한양대학교":"hymjcy","사회봉사-한양대학교":"hyshbs", "일반-한양대학교":"hyib", "산학/연구-한양대학교":"hyshyg","행사-한양대학교":"hyhs2", "장학-한양대학교":"hyjh","학회/세미나-한양대학교":"hyhhsmn", "공지사항-기계공학부":"megjsh", "학사일반-컴퓨터소프트웨어학부":"cshsib", "취업정보-컴퓨터소프트웨어학부":"cscujb","공지사항-경영학부":"bsgjsh","공지사항-한양대학교 학생생활관":"dmgjsh", "모집안내-한양대학교 학생생활관":"dmmjan"]
    
    //        @IBOutlet weak var historyTable: UITableView!
    func loadData(){
        channels = CoreDataManager.shared.getChannels().filter{ $0.title! != "전체"}
        channels = channels.sorted(by: {$0.group! > $1.group!})
        
        categories = Array(Set(channels.map{$0.group!})).sorted(by: >)
    }
    
    func updateTitle(title: String){
        let longTitleLabel = UILabel()
        longTitleLabel.text = title
        longTitleLabel.font = .boldSystemFont(ofSize: 25)
        longTitleLabel.sizeToFit()
        longTitleLabel.textColor = .navFont

        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    @IBAction func notificationButton(_ sender: UIButton) {
             let contentView = sender.superview?.superview
             let cell =  contentView?.superview as! ChannelCollectionViewCell
             if (cell.isButtonEnabled)
             {
                 let indexPath = cell.indexPath
                 let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }
                 CoreDataManager.shared.notificationChannel(subtitle: sectionChannels[indexPath.item].subtitle!, source: sectionChannels[indexPath.item].source!) { onSuccess in print("saved = \(onSuccess)")}
                 let tokenString = CoreDataManager.shared.getToken()
                 var urlString = String()

                 if (sectionChannels[indexPath.item].alarm) {
                     cell.notificationButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
                     urlString = "https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/channel/"+channelsInDB[sectionChannels[indexPath.item].subtitle!+"-"+sectionChannels[indexPath.item].source!]!+"/1/"+tokenString
                 } else {
                     cell.notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
                     urlString = "https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/channel/"+channelsInDB[sectionChannels[indexPath.item].subtitle!+"-"+sectionChannels[indexPath.item].source!]!+"/0/"+tokenString
                 }
                  guard let url = URL(string: urlString) else {return }

                 var request = URLRequest(url: url)

                 request.httpMethod = "get"

                 let session = URLSession.shared
                 //URLSession provides the async request
                 let task = session.dataTask(with: request) { data, response, error in
                      if let error = error {
                          print("Error took place \(error)")
                          return
                      }
                      if let response = response as? HTTPURLResponse {
                          print(response)
                      }
                  }
                 // Check if Error took place
                 
                  task.resume()
             }
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
//        navigationItem.title = "채널센터"
        updateTitle(title: "채널센터")
        //updateChannels()
        //categories = Array(Set(channels.map{$0.source!})).sorted(by: >)
        let coloredAppearance = UINavigationBarAppearance()
       //coloredAppearance.configureWithOpaqueBackground()
       //coloredAppearance.backgroundColor = UIColor.navBack

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
        
        cell.indexPath = indexPath
        
        cell.titleLabel.text = sectionChannels[indexPath.item].title
        cell.categoryLabel.text = sectionChannels[indexPath.item].source
        cell.colorImageView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionChannels[indexPath.item].color!)
        
        //cell.backgroundColor = .white
        // 구독안하거 블러처리
        if (sectionChannels[indexPath.item].isSubscribed == false){
            if self.traitCollection.userInterfaceStyle == .dark{
                cell.backView.backgroundColor = UIColor(white: 0.5, alpha: 1)
                cell.titleLabel.textColor = .white
            }
            else{
                cell.backView.backgroundColor = .white
            }
            //cell.backView.backgroundColor = UIColor(white: 1, alpha: 1)
            cell.backView.alpha = 1
            //cell.colorImageView.backgroundColor = .navBack
        }else {
            cell.isButtonEnabled = true
            if self.traitCollection.userInterfaceStyle == .dark{
                cell.titleLabel.textColor = .white
                cell.backView.backgroundColor = .systemGray4
            }
            else{
                cell.backView.backgroundColor = .white
            }
            //cell.backView.backgroundColor = .white
            cell.backView.alpha = 1

        }
        
        // 그림자 부분

        cell.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        cell.layer.masksToBounds = false
        cell.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
        cell.layer.shadowRadius = 3 // 반경?
        cell.layer.shadowOpacity = 0.2 //
//                print(sectionChannels)
        if (sectionChannels[indexPath.item].alarm) {
                     cell.notificationButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
                 } else {
                     cell.notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
                 }
                 cell.notificationButton.isEnabled = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }
        CoreDataManager.shared.subscribedChannel(subtitle: sectionChannels[indexPath.row].subtitle!, source: sectionChannels[indexPath.row].source!){ onSuccess in print("saved = \(onSuccess)")}
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! ChannelCollectionViewCell
                 if (!sectionChannels[indexPath.item].isSubscribed && sectionChannels[indexPath.row].alarm) {
                        CoreDataManager.shared.notificationChannel(subtitle: sectionChannels[indexPath.item].subtitle!, source: sectionChannels[indexPath.item].source!) { onSuccess in print("saved = \(onSuccess)")}
                            cell.notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
                     let tokenString = CoreDataManager.shared.getToken()
                     let urlString = "https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/channel/"+channelsInDB[sectionChannels[indexPath.item].subtitle!+"-"+sectionChannels[indexPath.item].source!]!+"/0/"+tokenString
                     guard let url = URL(string: urlString) else {return }

                     var request = URLRequest(url: url)

                     request.httpMethod = "get"

                     let session = URLSession.shared
                     //URLSession provides the async request
                     let task = session.dataTask(with: request) { data, response, error in
                          if let error = error {
                              print("Error took place \(error)")
                              return
                          }
                          if let response = response as? HTTPURLResponse {
                              print(response)
                          }
                      }
                     // Check if Error took place
                     
                      task.resume()
                 }

        
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
                    headerview.categoryLabel.textColor = .white
                }
                
                headerview.colorLabel.textColor  =  .clear
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

