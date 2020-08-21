//
//  HomeViewController.swift
//  Noti
//
//  Created by APPLE on 2020/08/06.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {

    var cards : [Card]?
    var saveCards : [Card]?
    var tagString : [String] = []
    var selectedTag = [Int]()
    

    @IBOutlet weak var HomeTableView: UITableView!
    @IBOutlet weak var TagCollectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    func updateTitle(title: String){
        let longTitleLabel = UILabel()
        longTitleLabel.text = title
        longTitleLabel.font = .boldSystemFont(ofSize: 27)
        longTitleLabel.sizeToFit()
        longTitleLabel.textColor = .navFont

        let leftItem = UIBarButtonItem(customView: longTitleLabel)
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    func loadData(){
        cards = [Card]()
        tagString = [String]()
        for i in 0..<HistoryViewController.allCards.count{
            if(HistoryViewController.allCards[i].isFavorite == true){
                cards!.append(HistoryViewController.allCards[i])
                for j in 0..<HistoryViewController.allCards[i].tag!.count{
                    if(!tagString.contains(HistoryViewController.allCards[i].tag![j]) && HistoryViewController.allCards[i].tag![j] != ""){
                        if(tagString.count == 1 && tagString[0] == ""){
                            tagString[0] = HistoryViewController.allCards[i].tag![j]
                        }
                        else{
                            tagString.append(HistoryViewController.allCards[i].tag![j])
                        }
                    }
                }
            }
        }
        saveCards = cards
    }
    func updateCard(){
        cards = saveCards
        var filteredCards = [Card]()
        if(selectedTag.count != 0){
            for i in 0..<selectedTag.count{
                let tmpCards = cards!.filter{$0.title!.contains(tagString[selectedTag[i]])}
                for j in 0..<tmpCards.count{
                    filteredCards.append(tmpCards[j])
                }
            }
            cards = Array(Set(filteredCards))
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "관심글"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.clear]
        updateTitle(title: "내가 찜한 소식")
        //네비게이션바 배경색 넣어주는 코드
        TagCollectionView.dataSource = self
        TagCollectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
        updateCard()
        if(saveCards?.count == 0){
            noDataLabel.isHidden = false
            noDataLabel.text = "아직 관심글이 없습니다.\n히스토리에서 카드를 스와이프해 추가해 보세요."
        }
        else{
            noDataLabel.isHidden = true
        }
        HomeTableView.reloadData()
        TagCollectionView.reloadData()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.clear]
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
extension HomeViewController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(cards == nil){
            return 0
        }
        else{
            return cards!.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HomeTableViewCell
        cell.titleLabel.text = cards![indexPath.row].title
        var tagText = ""
        if(cards![indexPath.row].tag!.count==1){
            tagText += cards![indexPath.row].formattedSource!
            cell.sourceLabel.textColor = .sourceFont
            cell.sourceLabel.text = tagText
        }
        else{
            for i in 1..<cards![indexPath.row].tag!.count{
                tagText += "#\(cards![indexPath.row].tag![i])"
            }
            cell.sourceLabel.text = tagText
            if(selectedTag.count != 0){
                let attributedStr = NSMutableAttributedString(string: tagText)
                for i in 0..<selectedTag.count{
                    for j in 0..<(cards?[indexPath.row].tag!.count)!{
                        if(cards![indexPath.row].tag![j] == tagString[selectedTag[i]]){
                            attributedStr.addAttribute(.foregroundColor, value: CoreDataManager.shared.colorWithHexString  (hexString:cards![indexPath.row].color!), range:(cell.sourceLabel.text! as NSString).range(of:"#\( tagString[selectedTag[i]])"))
                        }
                    }
                }
                cell.sourceLabel.attributedText = attributedStr
            }
            else{
                cell.sourceLabel.textColor = .sourceFont
            }
        }
        cell.dateLabel.text = cards![indexPath.row].homeFormattedDate
        cell.sourceColorView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: cards![indexPath.row].color!)
        cell.cellView.backgroundColor = .cardFront
        cell.cellView.layer.shadowColor = UIColor.black.cgColor
        cell.cellView.layer.masksToBounds = false
        cell.cellView.layer.shadowOffset = CGSize(width: 1, height: 2)
        cell.cellView.layer.shadowRadius = 3
        cell.cellView.layer.shadowOpacity = 0.2
        return cell
    }
    func resize(toTargetSize: CGSize, image : UIImage) -> UIImage? {
        let target = CGRect(x: 0, y: -9, width: toTargetSize.width, height: toTargetSize.height)

        UIGraphicsBeginImageContextWithOptions(target.size, false, UIScreen.main.scale)
        image.draw(in: target, blendMode: .normal, alpha: 1)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteCardUrl = cards![indexPath.row].url
        let deleteAction = UIContextualAction(style: .destructive, title:  "관심 삭제", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            CoreDataManager.shared.removeFavoriteCard(url: favoriteCardUrl!){ onSuccess in print("saved = \(onSuccess)")}
                    success(true)
//            sectionCards[indexPath.row].isFavorite = false
            self.loadData()
            self.updateCard()
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.HomeTableView.reloadData()
            self.TagCollectionView.reloadData()
            if(self.saveCards?.count == 0){
                self.noDataLabel.isHidden = false
                self.noDataLabel.text = "아직 관심글이 없습니다.\n히스토리에서 카드를 스와이프해 추가해 보세요."
            }

        })
        let image = UIImage(systemName: "heart.slash")
        deleteAction.image = image
        deleteAction.backgroundColor = .systemPink
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue") {
            let destination = segue.destination as! detailViewController
            if let cell = sender as? HomeTableViewCell {
                guard let indexPath = HomeTableView.indexPathForSelectedRow else {return}
                destination.title2 = cell.titleLabel.text
                destination.source = cards![indexPath.row].source
                destination.date = cards![indexPath.row].homeFormattedDate
                destination.back2 = title
                destination.url = cards![indexPath.row].url
                destination.json = cards![indexPath.row].json!
                
                // 방문할경우 비짓처리하고 테이블뷰 리로드
                cards![indexPath.row].isVisited = true
                CoreDataManager.shared.visitCards(url: cards![indexPath.row].url!){ onSuccess in print("saved = \(onSuccess)")}
                HomeTableView.reloadData()
            }
        }
    }
}
    
extension HomeViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tagString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tagCollectionCell", for: indexPath) as! TokenListCell
        cell.token = Tag(title: tagString[indexPath.row], time: NSDate())
        if(selectedTag.contains(indexPath.row)){
            cell.titleLabel.textColor = .fifth
        }
        else{
            cell.titleLabel.textColor = .sourceFont
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        if(selectedTag.contains(indexPath.row)){
            let index = selectedTag.firstIndex(of: indexPath.row)!
            selectedTag.remove(at: index)
        }
        else{
            selectedTag.append(indexPath.row)
        }
        updateCard()
        HomeTableView.reloadData()
        TagCollectionView.reloadData()
    }
}
extension HomeViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        var text = ""
        text = self.tagString[indexPath.row]
        let cellWidth = text.size(withAttributes:[.font: UIFont.boldSystemFont(ofSize:16.0)]).width + 30.0
        return CGSize(width: cellWidth, height: 30.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        
        return UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        
    }
}
