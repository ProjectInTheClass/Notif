//
//  HistoryTableViewController.swift
//  Noti
//
//  Created by Junroot on 2020/06/19.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit
import CoreData

class HistoryTableViewController: UITableViewController {
    var selectedChannel = 0
    var selectedTag = [Int]()
    @IBOutlet weak var channelCollection: UICollectionView!
    
    @IBOutlet weak var tagCollectionView: UICollectionView!
        var cards = [Card]()
        var allChannels = [Channel]()
        var channels = [Channel]()
        var allTags = [Tags]()
        var date = [String]()
        var rItem = UIBarButtonItem()
        func loadData(){
            cards = CoreDataManager.shared.getCards()
            allChannels = CoreDataManager.shared.getChannels()
            
            channels = allChannels.filter{ $0.isSubscribed == true }.sorted{ $0.group!.count < $1.group!.count }
//            print(allChannels)
            allTags = CoreDataManager.shared.getTags()
            date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by: >)
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
                    
                    date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by: >)
            // Source label 추가
            let source = NSAttributedString(string: channels[selectedChannel].source!, attributes: [.font : UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.sourceFont])
            let rightView = UIView()
            rightView.frame = CGRect(x: 0, y: 0, width: .bitWidth, height: 70)
            rItem = UIBarButtonItem(customView: rightView)
            self.navigationItem.leftBarButtonItem = rItem
            let somet = UILabel()
            somet.frame = CGRect(x:1, y:10, width: 400, height: 62)
            somet.attributedText=source
            rightView.addSubview(somet)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        navigationItem.title = "전체"
        //네비게이션바 배경색 넣어주는 코드
        navigationItem.largeTitleDisplayMode = .always
        
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor.navBack
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
        self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
        self.navigationController?.navigationBar.standardAppearance = coloredAppearance
        self.navigationController?.navigationBar.compactAppearance = coloredAppearance
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        updateCardsAndTitle()
        channelCollection.reloadData()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        let returnData = Array(Set(cards.map{$0.historyFormattedDate}))
        return returnData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(allTags.count == 0 ){
            return 1
        }
        if(section == 0){
            return 1
        }
        else{
            let returnData = cards.filter{$0.historyFormattedDate == date[section-1]}
            //print("numberofrawinsection\(returnData.count)")
            return returnData.count
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section-1]}
        //print(indexPath.section)
            if (sectionCards[indexPath.row].url != ""){
                let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HomeTableViewCell
                
                cell.titleLabel.text = sectionCards[indexPath.row].title
                cell.sourceLabel.text = sectionCards[indexPath.row].formattedSource
    //            cell.dateLabel.text = sectionCards[indexPath.row].historyCardFormattedDate
                cell.dateLabel.text = ""
                cell.sourceColorView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionCards[indexPath.row].color!)
                
//                cell의 backgroudView 수정
                let backgrundView = UIView()
                let backView = UIView(frame: CGRect(x: 17, y: 0, width: view.frame.width-34, height: 86))
                backView.backgroundColor = .white
                backgrundView.addSubview(backView)
                cell.backgroundView = backgrundView
                
//                cell의 selectedBackgroudView 수정
                let selectedBackgrundView = UIView()
                let selectView = UIView(frame: CGRect(x: 17, y: 0, width: view.frame.width-34, height: 86))
                selectView.backgroundColor = .selected
                selectedBackgrundView.addSubview(selectView)
                cell.selectedBackgroundView = selectedBackgrundView
                
                if (sectionCards[indexPath.row].isVisited == true){
                    cell.cellView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                    cell.cellView.alpha = 0.67
                }else {
                    cell.cellView.backgroundColor = .clear
                    cell.cellView.alpha = 1
                }
                // 그림자 부분
                cell.backgroundView?.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
                cell.backgroundView?.layer.masksToBounds = false
                cell.backgroundView?.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
                cell.backgroundView?.layer.shadowRadius = 3 // 반경?
                cell.backgroundView?.layer.shadowOpacity = 0.2 //
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
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if(section == 0){
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:0 ))
            return view
        }
            let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:17 ))
            let label = UILabel(frame: CGRect(x:20, y:17, width:tableView.frame.size.width, height:17))

        
            label.font = UIFont.boldSystemFont(ofSize: 17)
            label.textColor = UIColor.sectionFont
            label.text = date[section-1] //Array(Set(cards.map{$0.historyFormattedDate}))[section]//.sorted(by : >)[section]
            view.addSubview(label)
            view.backgroundColor = UIColor.white

            return view

        }
        
        // 섹션 헤더 높이 설정
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0 ){
            return 0
        }
        return 40;
        }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95;
    }
        
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if (segue.identifier == "detailSegue") {
                let destination = segue.destination as! detailViewController
                if let cell = sender as? HomeTableViewCell {
                    guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
                    let date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by: >)
                    let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section-1]}
                    destination.title2 = cell.titleLabel.text
                    destination.source = cell.sourceLabel.text
                    destination.date = sectionCards[indexPath.row].homeFormattedDate
                    destination.back2 = title

                    destination.url = sectionCards[indexPath.row].url
                    destination.json = sectionCards[indexPath.row].json!
                    
                    // 방문할경우 비짓처리하고 테이블뷰 리로드
                    sectionCards[indexPath.row].isVisited = true
                    CoreDataManager.shared.visitCards(url: sectionCards[indexPath.row].url!){ onSuccess in print("saved = \(onSuccess)")}
                    self.tableView.reloadData()
                    
                }
            }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y <= -120 {

            navigationItem.leftBarButtonItem = rItem

        }

        else if scrollView.contentOffset.y > -120 {

            navigationItem.leftBarButtonItem = nil

        }

    }
    
}
extension HistoryTableViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! CustomCollectionViewCell
//        cell.backgroundColor = UIColor.blue
        cell.titleLabel.text = channels[indexPath.row].subtitle
        cell.colorLabel.text = channels[indexPath.row].subtitle
        cell.colorLabel.textColor = .clear
        if (selectedChannel==indexPath.row) {
            cell.titleLabel.textColor = UIColor.navFont
            cell.colorLabel.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString:channels[indexPath.row].color!)

        }else{
            cell.titleLabel.textColor = .sourceFont
            cell.colorLabel.backgroundColor = .clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
        loadData()
        updateCardsAndTitle()
        channelCollection.reloadData()
        self.tableView.reloadData()
    }
    

}

extension HistoryTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    }
}
