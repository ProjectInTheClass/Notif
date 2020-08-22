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
    @IBOutlet weak var noDataLabel: UILabel!
    
    var listUnread = false
    var mangedObjectContext : NSManagedObjectContext!
    var cards = [Card].init()
    var channels : [Channel]?
    var date = [String]()
    var cardsHistoryDate = [String]()
    static var allCards = [Card].init()
    static var allChannels : [Channel]?
    
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
    
    func loadData(){
        print("@@loadData")
        cards = CoreDataManager.shared.getCards()
        HistoryViewController.allCards = cards.reversed()
        HistoryViewController.allChannels = CoreDataManager.shared.getChannels()
        selectedTag = [Int]()
        
        channels = HistoryViewController.allChannels!.filter{ $0.isSubscribed == true }.sorted(by: {$0.source! < $1.source!}).sorted{ $0.group! < $1.group!}
        //channels = HistoryViewController.allChannels!.filter{ $0.isSubscribed == true }.sorted{$0.group!.count < $1.group!.count}
        date = Array(Set(HistoryViewController.allCards.map{$0.historyFormattedDate!})).sorted(by : {$0.compare($1) == .orderedDescending})
    }
    
    func updateCardsAndTitle(){
        print("@@updateCardsAndTitle")
        var filterWithTagCards : [Card] = []
        if selectedChannel == 0 {
            if(selectedTag.count == 0){
                filterWithTagCards = HistoryViewController.allCards
            }
            else{
                for i in 0..<selectedTag.count{
                    let tmpCards = HistoryViewController.allCards.filter{$0.title!.contains(channels![selectedChannel].channelTags![selectedTag[i]])}
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
            updateTitle(title: channelToChange.title!)
            updateSubTitle(subTitle: channelToChange.source!)

        }else{
            if(selectedTag.count == 0){
                filterWithTagCards = HistoryViewController.allCards
            }
           else{
                for i in 0..<selectedTag.count{
                    let tmpCards = HistoryViewController.allCards.filter{$0.title!.contains(channels![selectedChannel].channelTags![selectedTag[i]])}
                    for j in 0..<tmpCards.count{
                        filterWithTagCards.append(tmpCards[j])
                    }
                }
                let tmp = Array(Set(filterWithTagCards))
                filterWithTagCards = tmp
            }
            let channelToChange = channels![selectedChannel]
            cards = filterWithTagCards.filter{ $0.source == channelToChange.source && $0.formattedSource!.contains(channelToChange.subtitle!)}
            updateTitle(title: channelToChange.title!)
            updateSubTitle(subTitle: channelToChange.source!)
        }
        var tmpCardsHistoryDate = [String]()
        for i in 0..<cards.count{
            tmpCardsHistoryDate.append(cards[i].historyFormattedDate!)
        }
        cardsHistoryDate = Array(Set(tmpCardsHistoryDate))
        date = cardsHistoryDate.sorted(by: {$0.compare($1) == .orderedDescending})
        if cards.count == 0 {
            if channels!.count == 1{
                noDataLabel.text = "채널센터에서 새로운 채널을 추가해보세요."
            }else{
                noDataLabel.text = "아직 올라온 새글이 없어요."
            }
            noDataLabel.isHidden = false
        }else{
            noDataLabel.isHidden = true
        }
        if (listUnread){
            cards = cards.filter{ $0.isVisited == false }
            var tmpCardsHistoryDate = [String]()
            for i in 0..<cards.count{
                tmpCardsHistoryDate.append(cards[i].historyFormattedDate!)
            }
            cardsHistoryDate = Array(Set(tmpCardsHistoryDate))
            date = cardsHistoryDate.sorted(by: {$0.compare($1) == .orderedDescending})
        }
    }

    override func viewDidLoad() {
        print("@뷰가 처음 로드됨")
        CoreDataManager.shared.setData()
        navigationItem.title = "히스토리"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.clear]
        updateTitle(title: "전체")
        updateSubTitle(subTitle: "전체")
        loadData()
        updateCardsAndTitle()
        tagCollection.dataSource = self
        tagCollection.delegate = self
    
        
        // unReadButton 만들기
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let rItem = UIBarButtonItem(customView: rightView)
        navigationItem.rightBarButtonItem = rItem
        let unreadButton = UIButton(type:.system)
        unreadButton.frame = CGRect(x:0, y:0, width: 30, height: 30)
        unreadButton.setImage(UIImage(systemName: "envelope.badge"), for: .normal)
        unreadButton.addTarget(self, action: #selector(unreadButtonIsSelected), for: .touchUpInside)
        rightView.addSubview(unreadButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadData(_:)), name: NSNotification.Name("ReloadHistoryView"), object: nil)
    }
    
    @objc func reloadData(_ notification: Notification?) {
        CoreDataManager.shared.setData()
        loadData()
        updateCardsAndTitle()
        historyTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("@뷰가 어피어됨")
        if(changeTagOrChannel.tagOrChannelModified == 1){
            print("@@modified")
            loadData()
            updateCardsAndTitle()
            selectedTag = [Int]()
            channelCollection.reloadData()
            tagCollection.reloadData()
            changeTagOrChannel.tagOrChannelModified = 0
        }
        historyTable.reloadData()
        
    }
    
    @IBAction func unreadButtonIsSelected(_ sender: UIButton) {
        listUnread.toggle()
        if listUnread{
            sender.setImage(UIImage(systemName: "envelope.badge.fill"), for: .normal)
            cards = cards.filter{ $0.isVisited == false }
            var tmpCardsHistoryDate = [String]()
            for i in 0..<cards.count{
                tmpCardsHistoryDate.append(cards[i].historyFormattedDate!)
            }
            cardsHistoryDate = Array(Set(tmpCardsHistoryDate))
            date = cardsHistoryDate.sorted(by: {$0.compare($1) == .orderedDescending})
        }
        else{
            sender.setImage(UIImage(systemName: "envelope.badge"), for: .normal)
//            loadData()
            updateCardsAndTitle()
        }
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

        return cardsHistoryDate.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(CoreDataManager.allTags!.count == 0 ){
                   return 1
        }
        let returnData = cards.filter{$0.historyFormattedDate == date[section]}
        
        return returnData.count

    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}.sorted(by: {$0.time! > $1.time!})
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
                        if(((sectionCards[indexPath.row].tag?.contains(channels![selectedChannel].channelTags![selectedTag[j-1]]))!)){
                            attributedStr.addAttribute(.foregroundColor, value: CoreDataManager.shared.colorWithHexString  (hexString:sectionCards[indexPath.row].color!), range:(cell.sourceLabel.text! as NSString).range(of:"#\( channels![selectedChannel].channelTags![selectedTag[j-1]])"))
                        }
                    }
                }
                cell.sourceLabel.attributedText = attributedStr
            }
        }
            //cell.sourceLabel.text = tagText
            
//            cell.dateLabel.text = sectionCards[indexPath.row].historyCardFormattedDate
            
        if (sectionCards[indexPath.row].isFavorite){
            cell.favoriteHeart.isHidden = false
        }else{
            cell.favoriteHeart.isHidden = true
        }
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
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}
//        let favoriteCardUrl = sectionCards[indexPath.row].url
//        let addAction = UIContextualAction(style: .normal, title:  "추가", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
//            CoreDataManager.shared.addFavoriteCard(url: favoriteCardUrl!){ onSuccess in print("saved = \(onSuccess)")}
//                    success(true)
//
//                })
//
//
//        if(self.traitCollection.userInterfaceStyle == .dark){
//            addAction.backgroundColor = .black
//            let image = UIImage(named: "heart.png")!
//            let size = CGSize(width: 50, height: 50)
//            let new_image = resize(toTargetSize: size, image: image)
//            addAction.image = new_image
//        }
//        else{
//            addAction.backgroundColor = .white
//            let image = UIImage(named: "heart.png")!
//            let size = CGSize(width: 30, height: 30)
//            let new_image = resize(toTargetSize: size, image: image)
//            addAction.image = new_image
//        }
//        return UISwipeActionsConfiguration(actions: [addAction])
//    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}
        let favoriteCardUrl = sectionCards[indexPath.row].url
        
        let swipeTitile = sectionCards[indexPath.row].isFavorite ? "관심 삭제" : "관심 추가"
        let addAction = UIContextualAction(style: .normal, title:  swipeTitile, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            CoreDataManager.shared.addFavoriteCard(url: favoriteCardUrl!){ onSuccess in print("saved = \(onSuccess)")}
                    success(true)
            self.historyTable.reloadData()
        
                })
        let deleteAction = UIContextualAction(style: .destructive, title:  swipeTitile, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
        
        CoreDataManager.shared.removeFavoriteCard(url: favoriteCardUrl!){ onSuccess in print("saved = \(onSuccess)")}
                success(true)
            self.historyTable.reloadData()
        })
        let resultAction = sectionCards[indexPath.row].isFavorite ? deleteAction : addAction
        resultAction.backgroundColor = .systemPink
        let image = sectionCards[indexPath.row].isFavorite ? UIImage(systemName: "heart.slash.fill") : UIImage(systemName: "heart.fill")
        resultAction.image = image
        
        return UISwipeActionsConfiguration(actions: [resultAction])
    }
    
    
    // 커스텀섹션헤더부분
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:17 ))
        let label = UILabel(frame: CGRect(x:20, y:17, width:tableView.frame.size.width, height:17))

        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.sectionFont
        label.text = date[section] //Array(Set(cards.map{$0.historyFormattedDate}))[section]//.sorted(by : >)[section]
        view.addSubview(label)
        view.backgroundColor = .cardBack
        
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
                return channels![selectedChannel].channelTags!.count
        }
    }

   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if(collectionView == self.channelCollection){
             let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "channel", for: indexPath) as! CustomCollectionViewCell
             ////        cell.backgroundColor = UIColor.blue
            cell.titleLabel.text = channels![indexPath.row].subtitle
            cell.colorLabel.text = channels![indexPath.row].subtitle
                     cell.colorLabel.textColor = .clear
            cell.colorDot.textColor = CoreDataManager.shared.colorWithHexString(hexString:channels![indexPath.row].color!)
                    if selectedChannel==indexPath.row {
                        cell.titleLabel.textColor = .navFont
                        cell.colorLabel.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString:channels![indexPath.row].color!)
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
                cell.token =  Tag(title: channels![selectedChannel].channelTags![indexPath.row], time: NSDate())
                           cell.titleLabel.textColor = .black
                if selectedTag.contains(indexPath.row){
                    cell.titleLabel.textColor = CoreDataManager.shared.colorWithHexString(hexString:channels![selectedChannel].color!)
                   }else{
                       cell.titleLabel.textColor = .sourceFont
                }
            }
            else{
                cell.token = Tag(title: channels![selectedChannel].channelTags![indexPath.row], time: NSDate())
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
            if(indexPath.row == 0){
                let alertController = UIAlertController(title: "태그 추가하기", message: "추가할 태그의 이름을 입력해주세요", preferredStyle: .alert)
                alertController.addTextField{(textField) in textField.placeholder = "태그 이름 입력"}
                
                let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                    let textField = alertController.textFields![0]
                    if let newTag = textField.text, newTag != "" {
                        if(newTag.contains(" ")){
                            return
                        }
                        for i in 0..<CoreDataManager.allTags!.count{
                            if(CoreDataManager.allTags![i].name == newTag){
                                return
                            }
                        }
                        CoreDataManager.shared.saveTags(name: newTag, time: NSDate() as Date){onSuccess in print("saved = \(onSuccess)")}
                        CoreDataManager.shared.addCardsTag(tag: newTag){onSuccess in print("saved = \(onSuccess)")}
                        CoreDataManager.shared.addChannelTag(subtitle: "전체", source: "전체", tag: newTag){onSuccess in print("saved = \(onSuccess)")}
                        self.updateCardsAndTitle()
                        self.channelCollection.reloadData()
                        self.historyTable.reloadData()
                        self.tagCollection.reloadData()
                        self.tagCollection.collectionViewLayout.invalidateLayout()
                        changeTagOrChannel.tagOrChannelModified = 1
                    }

                }
                let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            else if(selectedTag.contains(indexPath.row)){
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
