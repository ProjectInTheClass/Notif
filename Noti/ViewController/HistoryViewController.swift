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
    //var cards : [Card]?
    var cards = [Card].init()
    //var cards = [Card]()
    var allChannels : [Channel]?
    var channels : [Channel]?
    var allTags : [Tags]?
    var date = [String]()
    var cardsHistoryDate = [String]()
    func loadData(){
        cards = CoreDataManager.shared.getCards()
        let allCards = CoreDataManager.shared.getCards()
        allChannels = CoreDataManager.shared.getChannels()
        selectedTag = [Int]()
        
        //channels = allChannels.filter{ $0.isSubscribed == true }.sorted(by: {$0.source! < $1.source!}).sorted{ $0.group! < $1.group!}
        channels = allChannels!.filter{ $0.isSubscribed == true }.sorted{ $0.group!.count < $1.group!.count }

        allTags = CoreDataManager.shared.getTags()
        date = Array(Set(allCards.map{$0.historyFormattedDate!})).sorted(by : {$0.compare($1) == .orderedDescending})
    }
    
    
    func updateTitle(title: String){
        let longTitleLabel = UILabel()
        longTitleLabel.text = title
        longTitleLabel.font = .boldSystemFont(ofSize: 27)
        longTitleLabel.sizeToFit()
        longTitleLabel.textColor = .navFont

        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    func updateSubTitle(subTitle: String,color: UIColor = .history){
        let title = UILabel()
        title.text = subTitle
        title.font = .boldSystemFont(ofSize: 17)
        title.textColor = color
        let spacer = UIView()
        let constraint = spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat.greatestFiniteMagnitude)
        constraint.isActive = true
        constraint.priority = .defaultLow

        let stack = UIStackView(arrangedSubviews: [title, spacer])
        stack.axis = .horizontal
    
        navigationItem.titleView = stack
    }
    func updateCardsAndTitle(){
        let allCards = CoreDataManager.shared.getCards()
        var filterWithTagCards : [Card] = []
        //filterWithTagCards
        if selectedChannel == 0 {
            if(selectedTag.count == 0){
                filterWithTagCards = allCards
            }
            else{
                for i in 0..<selectedTag.count{
                    let tmpCards = allCards.filter{$0.title!.contains(channels![selectedChannel].channelTags![selectedTag[i]])}
                    for j in 0..<tmpCards.count{
                        filterWithTagCards.append(tmpCards[j])
                    }
                }
                let tmp = Array(Set(filterWithTagCards))
                filterWithTagCards = tmp
            }
            
            let channelToChange = channels![selectedChannel]
                cards = filterWithTagCards.filter{(card) -> Bool in
                return channels!.filter{(channel) -> Bool in
                    return channel.source == card.source && card.formattedSource!.contains(channel.subtitle!)}.count != 0}
//            navigationItem.title = channelToChange.title
            updateTitle(title: channelToChange.title!)
            updateSubTitle(subTitle: channelToChange.source!)

        }else{
            if(selectedTag.count == 0){
                filterWithTagCards = allCards
            }
           else{
                for i in 0..<selectedTag.count{
                    let tmpCards = allCards.filter{$0.title!.contains(channels![selectedChannel].channelTags![selectedTag[i]+1])}
                    for j in 0..<tmpCards.count{
                        filterWithTagCards.append(tmpCards[j])
                    }
                }
                let tmp = Array(Set(filterWithTagCards))
                filterWithTagCards = tmp
            }
            let channelToChange = channels![selectedChannel]
            cards = filterWithTagCards.filter{ $0.source == channelToChange.source && $0.formattedSource!.contains(channelToChange.subtitle!)}
//            navigationItem.title = channelToChange.title
            updateTitle(title: channelToChange.title!)
            updateSubTitle(subTitle: channelToChange.source!)
        }
        var tmpCardsHistoryDate = [String]()
        for i in 0..<cards.count{
            tmpCardsHistoryDate.append(cards[i].historyFormattedDate!)
        }
        cardsHistoryDate = Array(Set(tmpCardsHistoryDate))
        date = cardsHistoryDate.sorted(by: {$0.compare($1) == .orderedDescending})
        //date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by : {$0.compare($1) == .orderedDescending})
    }

    override func viewDidLoad() {
        navigationItem.title = nil
        updateTitle(title: "전체")
        loadData()
        tagCollection.dataSource = self
        tagCollection.delegate = self
        updateSubTitle(subTitle: "전체")
//        navigationController?.hidesBarsOnSwipe = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(changeTagOrChannel.tagOrChannelModified == 1){
            loadData()
            updateCardsAndTitle()
            selectedTag = [Int]()
            channelCollection.reloadData()
            tagCollection.reloadData()
            historyTable.reloadData()
            changeTagOrChannel.tagOrChannelModified = 0
        }
        
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
        //let returnData = Array(Set(cards)) Array(Set(cards.map{$0.historyFormattedDate}))
        return cardsHistoryDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(allTags!.count == 0 ){
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
            var tagText = ""
            if(sectionCards[indexPath.row].tag!.count == 1){
                tagText += sectionCards[indexPath.row].formattedSource!
                cell.sourceLabel.textColor = .sourceFont
                cell.sourceLabel.text = tagText
            }
            else{
                for i in 1..<sectionCards[indexPath.row].tag!.count{
                               tagText += "#\(sectionCards[indexPath.row].tag![i]) "

                    }
                cell.sourceLabel.text = tagText
                if(selectedTag.count != 0){
                    let attributedStr = NSMutableAttributedString(string: tagText)
                    if(selectedChannel==0){
                        for j in 1..<(selectedTag.count+1){
                            if(((sectionCards[indexPath.row].tag?.contains(channels![selectedChannel].channelTags![selectedTag[j-1]]))!)){
                                attributedStr.addAttribute(.foregroundColor, value: CoreDataManager.shared.colorWithHexString  (hexString:sectionCards[indexPath.row].color!), range:(cell.sourceLabel.text! as NSString).range(of:"#\( channels![selectedChannel].channelTags![selectedTag[j-1]])"))
                            }
                        }
                    }
                    else{
                        for j in 1..<(selectedTag.count+1){
                            if(((sectionCards[indexPath.row].tag?.contains(channels![selectedChannel].channelTags![selectedTag[j-1]+1]))!)){
                                attributedStr.addAttribute(.foregroundColor, value: CoreDataManager.shared.colorWithHexString  (hexString:sectionCards[indexPath.row].color!), range:(cell.sourceLabel.text! as NSString).range(of:"#\( channels![selectedChannel].channelTags![selectedTag[j-1]+1])"))
                            }
                        }
                    }
                    cell.sourceLabel.attributedText = attributedStr
                }
            }
            //cell.sourceLabel.text = tagText
            
//            cell.dateLabel.text = sectionCards[indexPath.row].historyCardFormattedDate
            cell.dateLabel.text = ""
            cell.sourceColorView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: sectionCards[indexPath.row].color!)
            cell.cellView?.backgroundColor = .cardFront
            if (sectionCards[indexPath.row].isVisited == true){
                cell.cellView.alpha = 0.6
            }else {
                cell.cellView.alpha = 1
            }
            let backgrundView = UIView()
            let backView = UIView(frame: CGRect(x: 17, y: 0, width: view.frame.width-34, height: 86))
            
            backView.backgroundColor = .cardBack
            backgrundView.addSubview(backView)
            cell.backgroundView = backgrundView
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
    //swipe시 버튼에 추가되는 image의 resize를 위한 함수
    func resize(toTargetSize: CGSize, image : UIImage) -> UIImage? {
        let target = CGRect(x: 0, y: 0, width: toTargetSize.width, height: toTargetSize.height)

        UIGraphicsBeginImageContextWithOptions(target.size, false, UIScreen.main.scale)
        image.draw(in: target, blendMode: .normal, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    //swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}
        let favoriteCardUrl = sectionCards[indexPath.row].url
        let addAction = UIContextualAction(style: .normal, title:  "추가", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            CoreDataManager.shared.addFavoriteCard(url: favoriteCardUrl!){ onSuccess in print("saved = \(onSuccess)")}
                    success(true)
            
                })
        
        
        if(self.traitCollection.userInterfaceStyle == .dark){
            addAction.backgroundColor = .black
            let image = UIImage(imageLiteralResourceName: "heart.png")
            let size = CGSize(width: 50, height: 50)
            let new_image = resize(toTargetSize: size, image: image)
            addAction.image = new_image
        }
        else{
            addAction.backgroundColor = .white
            let image = UIImage(imageLiteralResourceName: "heart.png")
            let size = CGSize(width: 30, height: 30)
            let new_image = resize(toTargetSize: size, image: image)
            addAction.image = new_image
        }
        return UISwipeActionsConfiguration(actions: [addAction])
    }
    
    
    // 커스텀섹션헤더부분
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:17 ))
        let label = UILabel(frame: CGRect(x:20, y:17, width:tableView.frame.size.width, height:17))

        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.sectionFont
        label.text = date[section] //Array(Set(cards.map{$0.historyFormattedDate}))[section]//.sorted(by : >)[section]
        view.addSubview(label)
        if self.traitCollection.userInterfaceStyle == .dark{
            view.backgroundColor = UIColor.black
        }
        else{
            view.backgroundColor = UIColor.white

        }
        
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
                let date = cardsHistoryDate.sorted(by : >)
                //let date = Array(Set(cards.map{$0.historyFormattedDate!})).sorted(by: >)
                let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}
                destination.title2 = cell.titleLabel.text
                destination.source = sectionCards[indexPath.row].source
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
            return channels!.count
        }
        else{
            if(selectedChannel == 0){
                return channels![selectedChannel].channelTags!.count
            }
            else{
                return channels![selectedChannel].channelTags!.count-1
            }
            
        }
    }

   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.channelCollection){
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! CustomCollectionViewCell
             ////        cell.backgroundColor = UIColor.blue
            cell.titleLabel.text = channels![indexPath.row].subtitle
            cell.colorLabel.text = channels![indexPath.row].subtitle
                     cell.colorLabel.textColor = .clear
            cell.colorDot.textColor = CoreDataManager.shared.colorWithHexString(hexString:channels[indexPath.row].color!)
                    if selectedChannel==indexPath.row {
                        cell.titleLabel.textColor = .navFont
                        cell.colorLabel.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString:channels[indexPath.row].color!)
                     }else{
                        if self.traitCollection.userInterfaceStyle == .dark{
                            cell.titleLabel.textColor = UIColor.systemGray4
                        }
                        else{
                            cell.titleLabel.textColor = UIColor.sourceFont
                        }
                         cell.colorLabel.backgroundColor = .clear
                  }
                   
                     return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCollectionCell", for: indexPath) as! TokenListCell
            if(selectedChannel == 0){
//                cell.titleLabel.text = "#\( channels[selectedChannel].channelTags![indexPath.row])"

                cell.token =  Tag(title: channels![selectedChannel].channelTags![indexPath.row], time: NSDate())
                           cell.titleLabel.textColor = .black
                if selectedTag.contains(indexPath.row){
                    cell.titleLabel.textColor = CoreDataManager.shared.colorWithHexString(hexString:channels![selectedChannel].color!)
                   }else{
                       cell.titleLabel.textColor = .sourceFont
                }
            }
            else{
                cell.token = Tag(title: channels![selectedChannel].channelTags![indexPath.row+1], time: NSDate())
                if selectedTag.contains(indexPath.row){
                    cell.titleLabel.textColor = CoreDataManager.shared.colorWithHexString(hexString:channels![selectedChannel].color!)
                              }else{
                                  cell.titleLabel.textColor = .sourceFont
                           }
            }
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
                selectedTag.remove(at: index)
            }
            else{
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
            text = self.channels![selectedChannel].channelTags![indexPath.row]
            let cellWidth = text.size(withAttributes:[.font: UIFont.boldSystemFont(ofSize:16.0)]).width + 30.0
            return CGSize(width: cellWidth, height: 30.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        return UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 24)
        
    }
    
}
struct changeTagOrChannel{
    static var tagOrChannelModified = 0
}
