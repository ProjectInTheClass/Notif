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
    var channelsInDB = ["학사-한양대학교":"hyhs", "입학-한양대학교":"hyih", "모집/채용-한양대학교":"hymjcy","사회봉사-한양대학교":"hyshbs", "일반-한양대학교":"hyib", "산학/연구-한양대학교":"hyshyg","행사-한양대학교":"hyhs2", "장학-한양대학교":"hyjh","학회/세미나-한양대학교":"hyhhsmn", "공지사항-기계공학부":"megjsh", "학사일반-컴퓨터소프트웨어학부":"cshsib", "취업정보-컴퓨터소프트웨어학부":"cscujb","공지사항-경영학부":"bsgjsh","공지사항-학생생활관":"dmgjsh", "모집안내-학생생활관":"dmmjan"]
    var feedbackGenerator : UIImpactFeedbackGenerator? = nil
    var popMessageFeedbackGenerator : UINotificationFeedbackGenerator? = nil
    private var enabled = false
    
    

    
    @IBOutlet weak var popMessage: PopMessage!
    @IBOutlet weak var popMessageBottomConstraint: NSLayoutConstraint!
    var underTheUI = CGFloat()
    
            @IBOutlet weak var historyTable: UITableView!
    func loadData(){
        channels = CoreDataManager.shared.getChannels().filter{ $0.title! != "전체"}
        channels = channels.sorted(by: {$0.group! < $1.group!})
        
        categories = Array(Set(channels.map{$0.group!})).sorted(by: <)
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
    private func reset(){
        enabled = false
    }
    func popMessage(message: NSAttributedString){
        let options: UIView.AnimationOptions = [.curveEaseInOut
        ]
        
        feedbackGenerator?.impactOccurred()
        popMessage.setLabel(messages: message)
        if(!enabled){
            enabled = true
            popMessageBottomConstraint.constant = 10
            UIView.animate(withDuration: 0.5,
                         delay: 0,
                         options: options,
                         animations: { [weak self] in
                          self?.view.layoutIfNeeded()

                }, completion: { finished in
                    self.popMessageBottomConstraint.constant = -100
                    UIView.animate(withDuration: 0.5,
                                 delay: 3,
                                 options: options,
                                 animations: { [weak self] in
                                  self?.view.layoutIfNeeded()
                                 }, completion: { finished in
                                    self.reset()
                                 })
            })
        }
        
//        UIView.animate(withDuration: 0.5,
//                     delay: 0,
//                     options: options,
//                     animations: { [weak self] in
//                      self?.view.layoutIfNeeded()
//
//            }, completion: nil)
//
//
//        popMessageBottomConstraint.constant = -100
//        UIView.animate(withDuration: 0.5,
//                     delay: 3,
//                     options: options,
//                     animations: { [weak self] in
//                      self?.view.layoutIfNeeded()
//        }, completion: nil)
    
    }
    
    @IBAction func notificationButton(_ sender: UIButton) {
             let contentView = sender.superview?.superview
             let cell =  contentView?.superview as! ChannelCollectionViewCell
             if (cell.isButtonEnabled)
             {
                feedbackGenerator?.impactOccurred()
                let indexPath = cell.indexPath
                let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }.sorted(by: {$0.source! < $1.source!})
                 CoreDataManager.shared.notificationChannel(subtitle: sectionChannels[indexPath.item].subtitle!, source: sectionChannels[indexPath.item].source!) { onSuccess in print("saved = \(onSuccess)")}
                 let tokenString = CoreDataManager.shared.getToken()
                 var urlString = String()

                 if (sectionChannels[indexPath.item].alarm) {
                     cell.notificationButton.setImage(UIImage(systemName: "bell.fill"), for: .normal)
                    urlString = "https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/channel/"+channelsInDB[sectionChannels[indexPath.item].subtitle!+"-"+sectionChannels[indexPath.item].source!]!+"/1/"+tokenString!
                 } else {
                     cell.notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
                     urlString = "https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/channel/"+channelsInDB[sectionChannels[indexPath.item].subtitle!+"-"+sectionChannels[indexPath.item].source!]!+"/0/"+tokenString!
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let options: UIView.AnimationOptions = [.curveEaseInOut
//        ]
//
//        popMessageBottomConstraint.constant = 10
//
//        UIView.animate(withDuration: 0.5,
//                     delay: 0,
//                     options: options,
//                     animations: { [weak self] in
//                      self?.view.layoutIfNeeded()
//        }, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        underTheUI = 10 - view.bounds.height
        feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedbackGenerator?.prepare()
        loadData()
        updateTitle(title: "채널센터")
        //네비게이션바 배경색 넣어주는 코드
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        popMessageBottomConstraint.constant = underTheUI
//        let underTheUI = 10 - view.bounds.height
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
        let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }.sorted(by: {$0.source! < $1.source!})

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! ChannelCollectionViewCell
        
        cell.indexPath = indexPath
        
        cell.titleLabel.text = sectionChannels[indexPath.item].title
        cell.categoryLabel.text = sectionChannels[indexPath.item].source
        cell.colorImageView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionChannels[indexPath.item].color!)
        
        //cell.backgroundColor = .white
        cell.cellView.backgroundColor = .cardFront
        cell.titleLabel.textColor = .navFont
        // 구독안하거 블러처리
        if (sectionChannels[indexPath.item].isSubscribed == false){
            cell.isButtonEnabled = false
            cell.cellView.alpha = 0.6
            cell.colorImageView.backgroundColor = .channelColor
        }else {
            cell.isButtonEnabled = true
            cell.cellView.alpha = 1

        }
        let backgrundView = UIView()
        let backView = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
        
        backView.backgroundColor = .cardBack
        backgrundView.addSubview(backView)
        cell.backgroundView = backgrundView
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
        let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }.sorted(by: {$0.source! < $1.source!})
        CoreDataManager.shared.subscribedChannel(subtitle: sectionChannels[indexPath.row].subtitle!, source: sectionChannels[indexPath.row].source!){ onSuccess in print("saved = \(onSuccess)")}
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! ChannelCollectionViewCell
        if (!sectionChannels[indexPath.item].isSubscribed && sectionChannels[indexPath.row].alarm) {
            CoreDataManager.shared.notificationChannel(subtitle: sectionChannels[indexPath.item].subtitle!, source: sectionChannels[indexPath.item].source!) { onSuccess in print("saved = \(onSuccess)")}
                cell.notificationButton.setImage(UIImage(systemName: "bell"), for: .normal)
         let tokenString = CoreDataManager.shared.getToken()
         let urlString = "https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/channel/"+channelsInDB[sectionChannels[indexPath.item].subtitle!+"-"+sectionChannels[indexPath.item].source!]!+"/0/"+tokenString!
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
        
        if (sectionChannels[indexPath.item].isSubscribed == false){
            let text = sectionChannels[indexPath.row].subtitle! + "게시판 구독을 취소했습니다"
            let atrStr = NSMutableAttributedString(string: text)
            atrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.sectionFont, range: (text as NSString).range(of:"구독을 취소했습니다"))

            popMessage(message: atrStr)

        }else {
            let text = sectionChannels[indexPath.row].subtitle! + "게시판 구독을 시작합니다"
            let atrStr = NSMutableAttributedString(string: text)
            atrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.sectionFont, range: (text as NSString).range(of:"구독을 시작합니다"))

            popMessage(message: atrStr)

        }
        
        print(sectionChannels[indexPath.row].subtitle!,sectionChannels[indexPath.row].source!)
        changeTagOrChannel.tagOrChannelModified = 1
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
                let sectionChannels = channels.filter{ $0.group! == categories[indexPath.section] }.sorted(by: {$0.source! < $1.source!})
                headerview.categoryLabel.text = sectionChannels[indexPath.item].group
                headerview.colorLabel.text =  sectionChannels[indexPath.item].group
//                if self.traitCollection.userInterfaceStyle == .dark{
//                    headerview.categoryLabel.textColor = .white
//                }
//
                headerview.categoryLabel.textColor = .navFont
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

}

extension ChannelCenterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width / 2) - 30, height: 86)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 17)
    }
}

