//
//  HistoryViewController.swift
//  Noti
//
//  Created by sejin on 2020/05/20.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController{
    //var channels = channelsDataSource.channels
    //var cards = cardsDataSource.cards
    var selectedChannel = 0
    @IBOutlet weak var historyTable: UITableView!
    var mangedObjectContext : NSManagedObjectContext!
    var cards = [Card]()
    var channels = [Channel]()
    var allTags = [Tags]()
    var date = [String]()
    func loadData(){
        if selectedChannel == 0 {
            cards = CoreDataManager.shared.getCards()
        }else{
            let channelToChange = channels[selectedChannel]
            let allCards = CoreDataManager.shared.getCards()
            cards = allCards.filter{ $0.channelName == channelToChange.category && $0.category!.contains(channelToChange.title!)}
            /*let title = channelToChange.title
            let predicate = NSPredicate(format: "category CONTAINS  %@", title!)
            fetchRequest.predicate = predicate
            cards = cardsData.filter{$0.channelName == channelToChange.category}
            do{
                cardsData = try mangedObjectContext.fetch(fetchRequest)
                cards = cardsData.filter{$0.channelName == channelToChange.category}
            }catch{
                fatalError("fetch error!")
            }*/
    
        }
        channels = CoreDataManager.shared.getChannels()
        allTags = CoreDataManager.shared.getTags()
        
        navigationItem.title = channels[selectedChannel].title
        date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by: >)
        let source = NSAttributedString(string: channels[selectedChannel].category!, attributes: [.font : UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.sourceFont])
               navigationController?.hidesBarsOnSwipe = true
               // 라이트 뷰 생성
               let rightView = UIView()
               rightView.frame = CGRect(x: 0, y: 0, width: .bitWidth, height: 70)
               let rItem = UIBarButtonItem(customView: rightView)
               self.navigationItem.leftBarButtonItem = rItem
               let somet = UILabel()
               somet.frame = CGRect(x:1, y:10, width: 400, height: 62)
               somet.attributedText=source
               rightView.addSubview(somet)
    }
    
    
    
    
   /* func updateCards(){
        if selectedChannel == 0{
            cards = cardsDataSource.cards
        }else{
            let channelToChange = channels[selectedChannel]
            
            cards = cardsDataSource.cards.filter{ $0.channelName == channelToChange.category && $0.category.contains(channelToChange.title)}
        }
        navigationItem.title = channels[selectedChannel].title
        
        let source = NSAttributedString(string: channels[selectedChannel].category!, attributes: [.font : UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.sourceFont])
        navigationController?.hidesBarsOnSwipe = true
        // 라이트 뷰 생성
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: .bitWidth, height: 70)
        let rItem = UIBarButtonItem(customView: rightView)
        self.navigationItem.leftBarButtonItem = rItem
        let somet = UILabel()
        somet.frame = CGRect(x:1, y:10, width: 400, height: 62)
        somet.attributedText=source
        rightView.addSubview(somet)
        
        
        
    }*/
    
    @objc func buttonClicked(){
        print("alarm button Clicked!")
//        channels[selectedChannel]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "전체"
        loadData()
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: 80, height: 40)
        // rItem이라는 UIBarButtonItem 객체 생성
        let rItem = UIBarButtonItem(customView: rightView)
        self.navigationItem.rightBarButtonItem = rItem
        // 새로고침 버튼 생성
        let refreshButton = UIButton(type:.system)
        refreshButton.frame = CGRect(x:50, y:10, width: 30, height: 30)
        refreshButton.setImage(UIImage(systemName: "bell"), for: .normal)
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

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let returnData = Array(Set(cards.map{$0.historyFormattedDate}))
        return returnData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(allTags.count == 0 ){
                   return 1
        }
        let returnData = cards.filter{$0.historyFormattedDate == date[section]}
        
        return returnData.count

    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}
        
        if (sectionCards[indexPath.row].url != ""){
          
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HomeTableViewCell
            
            cell.titleLabel.text = sectionCards[indexPath.row].title
            cell.sourceLabel.text = sectionCards[indexPath.row].source
            cell.dateLabel.text = sectionCards[indexPath.row].historyCardFormattedDate
            cell.sourceColorView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionCards[indexPath.row].color!)
            
            if (cards[indexPath.row].isVisited == true){
                cell.cellView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                cell.cellView.alpha = 0.67
            }else {
                cell.cellView.backgroundColor = .white
                cell.cellView.alpha = 1
            }

            // 그림자 부분
            cell.cellView.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
            cell.cellView.layer.masksToBounds = false
            cell.cellView.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
            cell.cellView.layer.shadowRadius = 8 // 반경?
            cell.cellView.layer.shadowOpacity = 0.2 //
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryCell
            
            cell.history.text = "#"+sectionCards[indexPath.row].title! + " 추가"
            cell.history.textColor = UIColor.first
            let attributedStr = NSMutableAttributedString(string: cell.history.text!)
            //위에서 만든 attributedStr에 addAttribute메소드를 통해 Attribute를 적용. kCTFontAttributeName은 value로 폰트크기와 폰트를 받을 수 있음.
            attributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.sourceFont, range: (cell.history.text! as NSString).range(of:"추가"))

            cell.history.attributedText = attributedStr
            cell.backLine.backgroundColor = .sourceFont
            return cell
        }
    }
    
    // 커스텀섹션헤더부분
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:17 ))
        let label = UILabel(frame: CGRect(x:20, y:17, width:tableView.frame.size.width, height:17))

        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.sectionFont
        label.text = date[section] //Array(Set(cards.map{$0.historyFormattedDate}))[section]//.sorted(by : >)[section]
        view.addSubview(label)
        view.backgroundColor = UIColor.white

        return view

    }
    
    // 섹션 헤더 높이 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }

}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! CustomCollectionViewCell
//        cell.backgroundColor = UIColor.blue
        cell.titleLabel.text = channels[indexPath.row].subtitle
        if selectedChannel==indexPath.row {
            cell.titleLabel.textColor = UIColor.navFont
            cell.colorImageView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString:channels[indexPath.row].color!) 
        }else{
            cell.titleLabel.textColor = .sourceFont
            cell.colorImageView.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        arr = arrList[indexPath.row]
        
//        print("Cell \(indexPath.row) sellected")
        selectedChannel = indexPath.row
        //updateCards()
        loadData()
        collectionView.reloadData()
        historyTable.reloadData()
    }
    

}

extension HistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 40)
    }
}

