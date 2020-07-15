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

    var selectedChannel = 0
    var selectedTag = [Int]()
    @IBOutlet weak var historyTable: UITableView!
    @IBOutlet weak var channelCollection: UICollectionView!
    @IBOutlet weak var tagCollection: UICollectionView!
    
    var mangedObjectContext : NSManagedObjectContext!
    var cards = [Card]()
    var allChannels = [Channel]()
    var channels = [Channel]()
    var allTags = [Tags]()
    var date = [String]()
    func loadData(){
        cards = CoreDataManager.shared.getCards()
        allChannels = CoreDataManager.shared.getChannels()
        selectedTag = [Int]()
        channels = allChannels.filter{ $0.isSubscribed == true }.sorted{ $0.group!.count < $1.group!.count }
        allTags = CoreDataManager.shared.getTags()
        date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by : {$0.compare($1) == .orderedDescending})
    }
    
    
    
    
    func updateCardsAndTitle(){
        let allCards = CoreDataManager.shared.getCards()
        var filterWithTagCards = [Card]()
        
        if selectedChannel == 0 {
            if(selectedTag.count == 0){
                filterWithTagCards = allCards
            }
            else{
                for i in 0..<selectedTag.count{
                    let tmpCards = allCards.filter{$0.title!.contains(channels[selectedChannel].channelTags![selectedTag[i]])}
                    for j in 0..<tmpCards.count{
                        filterWithTagCards.append(tmpCards[j])
                    }
                }
                
            }
            let channelToChange = channels[selectedChannel]
//            cards = CoreDataManager.shared.getCards()
            
            cards = filterWithTagCards.filter{(card) -> Bool in
                return channels.filter{(channel) -> Bool in
                    return channel.source == card.source && card.formattedSource!.contains(channel.subtitle!)}.count != 0}
            navigationItem.title = channelToChange.title
        }else{
            if(selectedTag.count == 0){
                filterWithTagCards = allCards
            }
           else{
                for i in 0..<selectedTag.count{
                    let tmpCards = allCards.filter{$0.title!.contains(channels[selectedChannel].channelTags![selectedTag[i]+1])}
                     print(channels[selectedChannel].channelTags![selectedTag[i]+1])
                    for j in 0..<tmpCards.count{
                        filterWithTagCards.append(tmpCards[j])
                    }
                }
            }
            let channelToChange = channels[selectedChannel]
            //let allCards = CoreDataManager.shared.getCards()
            cards = filterWithTagCards.filter{ $0.source == channelToChange.source && $0.formattedSource!.contains(channelToChange.subtitle!)}
            navigationItem.title = channelToChange.title
        }
        date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by : {$0.compare($1) == .orderedDescending})
    }

    override func viewDidLoad() {
        navigationItem.title = "전체"
        //네비게이션바 배경색 넣어주는 코드
        navigationItem.largeTitleDisplayMode = .always
        loadData()
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor.navBack
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
        self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
        self.navigationController?.navigationBar.standardAppearance = coloredAppearance
        self.navigationController?.navigationBar.compactAppearance = coloredAppearance
        historyTable.isScrollEnabled = true
        historyTable.delegate = self
        channelCollection.dataSource = self
        channelCollection.delegate = self
        tagCollection.dataSource = self
        tagCollection.delegate = self
//        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        updateCardsAndTitle()
        selectedTag = [Int]()
        channelCollection.reloadData()
        tagCollection.reloadData()
        historyTable.reloadData()
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
            //cell.sourceLabel.text = sectionCards[indexPath.row].formattedSource
            var tagText = ""
            if(sectionCards[indexPath.row].tag!.count == 1){
                tagText += sectionCards[indexPath.row].formattedSource!
                cell.sourceLabel.textColor = .sourceFont
            }
            else{
                for i in 1..<sectionCards[indexPath.row].tag!.count{
                               tagText += "#\(sectionCards[indexPath.row].tag![i]) "

                           }
                cell.sourceLabel.textColor = CoreDataManager.shared.colorWithHexString(hexString:sectionCards[indexPath.row].color!)
            }
           
            cell.sourceLabel.text = tagText
            
//            cell.dateLabel.text = sectionCards[indexPath.row].historyCardFormattedDate
            cell.dateLabel.text = ""
            cell.sourceColorView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionCards[indexPath.row].color!)
            
            if (sectionCards[indexPath.row].isVisited == true){
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
            cell.cellView.layer.shadowRadius = 3 // 반경?
            cell.cellView.layer.shadowOpacity = 0.2 //
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "history", for: indexPath) as! HistoryCell

            cell.history.text = "  #"+sectionCards[indexPath.row].title! + " 추가  "
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue") {
            let destination = segue.destination as! detailViewController
            if let cell = sender as? HomeTableViewCell {
                guard let indexPath = historyTable.indexPathForSelectedRow else {return}
                let date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by: >)
                let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}
                destination.title2 = cell.titleLabel.text
                destination.source = cell.sourceLabel.text
                destination.date = sectionCards[indexPath.row].homeFormattedDate
                destination.back2 = title

                destination.url = sectionCards[indexPath.row].url

                destination.json = sectionCards[indexPath.row].json!
                
                // 방문할경우 비짓처리하고 테이블뷰 리로드
                sectionCards[indexPath.row].isVisited = true
                CoreDataManager.shared.visitCards(url: sectionCards[indexPath.row].url!){ onSuccess in print("saved = \(onSuccess)")}
                historyTable.reloadData()
                
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
//
////        performSegue(withIdentifier: "detailSegue", sender: cell)
//    }
    

}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(collectionView == self.channelCollection){
             return channels.count
        }
        else{
            if(selectedChannel == 0){
                return channels[selectedChannel].channelTags!.count
            }
            else{
                return channels[selectedChannel].channelTags!.count-1
            }
            
        }
    }

   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.channelCollection){
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! CustomCollectionViewCell
             ////        cell.backgroundColor = UIColor.blue
                     cell.titleLabel.text = channels[indexPath.row].subtitle
                     cell.colorLabel.text = channels[indexPath.row].subtitle
                     cell.colorLabel.textColor = .clear
                    if selectedChannel==indexPath.row {
                     cell.titleLabel.textColor = UIColor.navFont
                     cell.colorLabel.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString:channels[indexPath.row].color!)

                     }else{
                         cell.titleLabel.textColor = .sourceFont
                         cell.colorLabel.backgroundColor = .clear
                  }
                   
                     return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCollectionCell", for: indexPath) as! TokenListCell
            if(selectedChannel == 0){
//                cell.titleLabel.text = "#\( channels[selectedChannel].channelTags![indexPath.row])"

                cell.token =  Tag(title: channels[selectedChannel].channelTags![indexPath.row], time: NSDate())
                           cell.titleLabel.textColor = .black
                if selectedTag.contains(indexPath.row){
                    cell.titleLabel.textColor = CoreDataManager.shared.colorWithHexString(hexString:channels[selectedChannel].color!)
                   }else{
                       cell.titleLabel.textColor = .sourceFont
                }
            }
            else{
//                cell.titleLabel.text = "#\( channels[selectedChannel].channelTags![indexPath.row+1])"
                cell.token = Tag(title: channels[selectedChannel].channelTags![indexPath.row+1], time: NSDate())
                if selectedTag.contains(indexPath.row){
                              cell.titleLabel.textColor = CoreDataManager.shared.colorWithHexString(hexString:channels[selectedChannel].color!)
                              }else{
                                  cell.titleLabel.textColor = .sourceFont
                           }
            }
           
           /* if (HistoryTableViewController.selectedTag == indexPath.row) {
                cell.tagName.textColor = .black
            }else{
                cell.tagName.textColor = .sourceFont
            }*/
            //print(cell.tagName.text)
            return cell
    }
    
}
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        arr = arrList[indexPath.row]
//
////        print("Cell \(indexPath.row) sellected")
        if(collectionView == self.channelCollection){
            selectedChannel = indexPath.row
            selectedTag = [Int]()
        }
        else{
            if(selectedTag.contains(indexPath.row)){
                let index = selectedTag.firstIndex(of: indexPath.row)!
                print("\(selectedTag[index]) remove!")
                selectedTag.remove(at: index)
            }
            else{
                print("\(indexPath.row) add!")
                selectedTag.append(indexPath.row)
                
            }
           
        }
        updateCardsAndTitle()
        channelCollection.reloadData()
        tagCollection.reloadData()
        historyTable.reloadData()
   }
  

}

extension HistoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView == self.channelCollection){
            return CGSize(width: 80, height: 40)
        }
        else{
            var text = ""
            text = self.channels[selectedChannel].channelTags![indexPath.row]
            let cellWidth = text.size(withAttributes:[.font: UIFont.boldSystemFont(ofSize:16.0)]).width + 30.0
            return CGSize(width: cellWidth, height: 30.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
    }
    
}
