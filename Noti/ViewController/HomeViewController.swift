//
//  HomeViewController.swift
//  Noti
//
//  Created by 이상윤 on 2020/08/27.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    var arr = [Tag]()
    var recommendTags = [Tag]()
    var cards : [Card]?
    var coreDataTag = CoreDataManager.shared.getTags()
    
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagCollection: DynmicHeightCollectionView!
    @IBOutlet weak var recommendTagCollection: DynmicHeightCollectionView!
    
    func updateTagSubTitle(){
        if arr.count == 0{
            tagLabel.text = "태그를 추가해 보세요"
        }else{
            tagLabel.text = "총 \(arr.count)개의 태그"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.title = "홈"
//        navigationController?.navigationBar.backgroundColor = .clear
        for num in 0..<coreDataTag.count {
            arr.append(Tag(title: coreDataTag[num].name!, time: coreDataTag[num].time! as NSDate, selected: false))
        }
        
        cards = [Card]()
        let allCards = CoreDataManager.shared.getCards()
        for i in 0...4{
            cards?.append(allCards[i])
        }
        
        recommendTags = arr
        
        // unReadButton 만들기
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let rItem = UIBarButtonItem(customView: rightView)
        navigationItem.rightBarButtonItem = rItem
        let unreadButton = UIButton(type:.system)
        unreadButton.frame = CGRect(x:0, y:0, width: 30, height: 30)
        unreadButton.setImage(UIImage(systemName: "plus"), for: .normal)
        unreadButton.addTarget(self, action: #selector(addPressed), for: .touchUpInside)
        rightView.addSubview(unreadButton)
        
        
        updateTagSubTitle()
        
        otherView.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        otherView.layer.masksToBounds = false
        otherView.layer.shadowOffset = CGSize(width: 1, height: -2) //반경
        otherView.layer.shadowRadius = 4 // 반경?
        otherView.layer.shadowOpacity = 0.2 //

    }
    
    // 추가버튼 눌렸을때
    @IBAction func addPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "태그 추가하기", message: "추가할 태그의 이름을 입력해주세요", preferredStyle: .alert)
        alertController.addTextField{(textField) in textField.placeholder = "태그 이름 입력"}
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            let textField = alertController.textFields![0]
            if let newTag = textField.text, newTag != "" {
                if(newTag.contains(" ")){
                    return
                }
                else if(newTag.count >= 10){
                    return
                }
                for i in 0..<self.arr.count{
                    if self.arr[i].title == newTag{
                        return
                    }
                }
                self.arr.append(Tag(title: newTag, time: NSDate(), selected: false))
                CoreDataManager.shared.saveTags(name: newTag, time: NSDate() as Date){onSuccess in print("saved = \(onSuccess)")}
                CoreDataManager.shared.addCardsTag(tag: newTag){onSuccess in print("saved = \(onSuccess)")}
                CoreDataManager.shared.addChannelTag(subtitle: "전체", source: "전체", tag: newTag){onSuccess in print("saved = \(onSuccess)")}
                let indexPath = IndexPath(row: self.arr.count - 1, section: 0)
                self.tagCollection.insertItems(at: [indexPath])
                self.coreDataTag = CoreDataManager.shared.getTags()
                self.tagCollection.reloadData()
                self.tagCollection.collectionViewLayout.invalidateLayout()
                self.updateTagSubTitle()
                changeTagOrChannel.tagOrChannelModified = 1
            }

        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)

    }
    @IBAction func cancelPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func donePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.tagCollection{
            return arr.count
        }else{
            return recommendTags.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.tagCollection{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tag", for: indexPath) as! TokenMainCell
            cell.token = arr[indexPath.item]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recommendTag", for: indexPath) as! TokenListCell
            cell.token = recommendTags[indexPath.item]
            cell.titleLabel.textColor = .white
            cell.backgroundColor = .blueSelected
            return cell
        }
        
    }
    
    // 셀눌렸을떄, 삭제할때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.tagCollection{
            var token = arr[indexPath.item]
            token.selected = false
            arr.remove(at: indexPath.item)
            CoreDataManager.shared.removeChannelTag(tag: coreDataTag[indexPath.item].name!){onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.removeCardsTag(tag: coreDataTag[indexPath.item].name!){onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.removeTag(object: coreDataTag[indexPath.item])
            tagCollection.deleteItems(at: [indexPath])
            tagCollection.reloadData()
            tagCollection.collectionViewLayout.invalidateLayout()
            coreDataTag = CoreDataManager.shared.getTags()
            changeTagOrChannel.tagOrChannelModified = 1
            updateTagSubTitle()
        }else{
            let token = recommendTags[indexPath.item]
            let alertController = UIAlertController(title: "태그 추가", message: "#\(token.title) 태그를 추가합니다", preferredStyle: .alert)
//            alertController.addTextField{(textField) in textField.placeholder = "태그 이름 입력"}
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                for i in 0..<self.arr.count{
                    if self.arr[i].title == token.title{
                        return
                    }
                }
                self.arr.append(token)
                CoreDataManager.shared.saveTags(name: token.title, time: NSDate() as Date){onSuccess in print("saved = \(onSuccess)")}
                CoreDataManager.shared.addCardsTag(tag: token.title){onSuccess in print("saved = \(onSuccess)")}
                CoreDataManager.shared.addChannelTag(subtitle: "전체", source: "전체", tag: token.title){onSuccess in print("saved = \(onSuccess)")}
                let indexPath = IndexPath(row: self.arr.count - 1, section: 0)
                self.tagCollection.insertItems(at: [indexPath])
                self.coreDataTag = CoreDataManager.shared.getTags()
                self.tagCollection.reloadData()
                self.tagCollection.collectionViewLayout.invalidateLayout()
                self.updateTagSubTitle()
                changeTagOrChannel.tagOrChannelModified = 1
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }

}

// cell 사이즈 지정
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text = ""

        text = self.arr[indexPath.item].title


        let cellWidth = text.size(withAttributes:[.font: UIFont.boldSystemFont(ofSize:16.0)]).width + 30.0

        if collectionView == tagCollection {
          return CGSize(width: cellWidth + 35, height: 30.0)
        } else {
          return CGSize(width: cellWidth+35, height: 30.0)
        }
        
    }

}

// 컬렉션뷰플로우레이아웃
class TagCollViewFlowLayout: UICollectionViewFlowLayout {

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    let attributesForElementsInRect = super.layoutAttributesForElements(in: rect)
    var newAttributesForElementsInRect = [UICollectionViewLayoutAttributes]()

    var leftMargin: CGFloat = self.sectionInset.left

    for attributes in attributesForElementsInRect! {
      if (attributes.frame.origin.x == self.sectionInset.left) {
        leftMargin = self.sectionInset.left
      } else {
        var newLeftAlignedFrame = attributes.frame

        if leftMargin + attributes.frame.width < self.collectionViewContentSize.width {
          newLeftAlignedFrame.origin.x = leftMargin
        } else {
          newLeftAlignedFrame.origin.x = self.sectionInset.left
        }

        attributes.frame = newLeftAlignedFrame
      }
      leftMargin += attributes.frame.size.width + 8
      newAttributesForElementsInRect.append(attributes)
    }

    return newAttributesForElementsInRect
  }
}

extension HomeViewController : UITableViewDelegate, UITableViewDataSource{
//    func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cards!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HomeTableViewCell
        cell.titleLabel.text = cards?[indexPath.row].title
        cell.sourceLabel.text = cards?[indexPath.row].formattedSource
//        cell.dateLabel.text = cards?[indexPath.row].homeFormattedDate
        cell.dateLabel.text = ""
        cell.sourceColorView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: (cards?[indexPath.row].color!)! )
        cell.sourceLabel.textColor = .sourceFont
        // cell의 backgroudView 수정
        let backgrundView = UIView()
        let backView = UIView(frame: CGRect(x: 17, y: 0, width: view.frame.width-34, height: 86))
        
        backView.backgroundColor = .cardBack
        backgrundView.addSubview(backView)
        cell.backgroundView = backgrundView
        
        // cell의 selectedBackgroudView 수정
//        let selectedBackgrundView = UIView()
//        let selectView = UIView(frame: CGRect(x: 17, y: 0, width: view.frame.width-34, height: 86))
//        selectView.backgroundColor = .selected
//        selectedBackgrundView.addSubview(selectView)
//        cell.selectedBackgroundView = selectedBackgrundView
//
//        cell.cellView?.backgroundColor = .cardFront
        
        // 그림자 부분
        cell.backgroundView?.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        cell.backgroundView?.layer.masksToBounds = false
        cell.backgroundView?.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
        cell.backgroundView?.layer.shadowRadius = 3 // 반경?
        cell.backgroundView?.layer.shadowOpacity = 0.2 //
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}
