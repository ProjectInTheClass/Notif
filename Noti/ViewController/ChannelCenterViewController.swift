//
//  ChannelCenterViewController.swift
//  Noti
//
//  Created by 이상윤 on 2020/06/12.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class ChannelCenterViewController: UIViewController {
    var channels = CoreDataManager.shared.getChannels().filter{ $0.title! != "전체"}
    
    lazy var categories = Array(Set(channels.map{$0.source!})).sorted(by: >)
    var selectedChannel: IndexPath = IndexPath()
    
    //        @IBOutlet weak var historyTable: UITableView!
    
    func updateChannels(){
        let source = Array(Set(channels.map{$0.source!})).sorted(by:>)
        print("\(selectedChannel)!!!")
        let sectionChannels = channels.filter{$0.source! == source[selectedChannel.section]}
        sectionChannels[selectedChannel.item].isSubscribed = !sectionChannels[selectedChannel.item].isSubscribed
    }
    
    @objc func buttonClicked(){
        print("alarm button Clicked!")
        //        channels[selectedChannel]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "채널센터"
        //updateChannels()
        //categories = Array(Set(channels.map{$0.source!})).sorted(by: >)
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        // rItem이라는 UIBarButtonItem 객체 생성
        let rItem = UIBarButtonItem(customView: rightView)
        self.navigationItem.rightBarButtonItem = rItem
        // 새로고침 버튼 생성
        let refreshButton = UIButton(type:.system)
        refreshButton.frame = CGRect(x:50, y:10, width: 30, height: 30)
        refreshButton.setImage(UIImage(systemName: "plus"), for: .normal)
        refreshButton.tintColor = .systemBlue
        refreshButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        // 라이트 뷰에 버튼 추가
        rightView.addSubview(refreshButton)
        
        //네비게이션바 배경색 넣어주는 코드
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor.navBack
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
        self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
        self.navigationController?.navigationBar.standardAppearance = coloredAppearance
        
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
        let source = Array(Set(channels.map{$0.source!})).sorted(by:>)
        
        return channels.filter{ $0.source == source[section] }.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let source = Array(Set(channels.map{$0.source!})).sorted(by: >)
        let sectionChannels = channels.filter{ $0.source! == source[indexPath.section] }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! ChannelCollectionViewCell
        
        cell.titleLabel.text = sectionChannels[indexPath.item].title
        cell.categoryLabel.text = sectionChannels[indexPath.item].category
        cell.colorImageView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionChannels[indexPath.item].color!)
        
        // 구독안하거 블러처리
        if (sectionChannels[indexPath.item].isSubscribed == false){
            cell.backView.backgroundColor = UIColor(white: 1, alpha: 1)
            cell.backView.alpha = 0.67
            cell.colorImageView.backgroundColor = .navBack
        }else {
            cell.backView.backgroundColor = .white
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
//        arr = arrList[indexPath.row]
        
        print("Cell \(indexPath.row) sellected")
        selectedChannel = indexPath
        
        updateChannels()

//        updateCards()
        collectionView.reloadData()
//        historyTable.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let returnNum = Array(Set(channels.map{$0.source!}))
        return returnNum.count
    }
//
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind : String, at indexPath : IndexPath) -> UICollectionReusableView{
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                
                let headerview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header", for: indexPath) as! ChannelCollectionViewHeader
                let source = Array(Set(channels.map{$0.source!})).sorted(by:>)
                //let sourceCell = source[indexPath.section]
                let sectionChannels = channels.filter{ $0.source! == source[indexPath.section] }
                headerview.categoryLabel.text = sectionChannels[indexPath.item].source
                headerview.colorLabel.text =  sectionChannels[indexPath.item].source
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

