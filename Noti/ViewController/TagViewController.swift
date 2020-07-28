//
//  TagViewController.swift
//  Noti
//
//  Created by 이상윤 on 2020/06/20.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    var arr = [Tag]()
    var coreDataTag = CoreDataManager.shared.getTags()
    @IBOutlet weak var tagCollection: DynmicHeightCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "태그"
        for num in 0..<coreDataTag.count {
            arr.append(Tag(title: coreDataTag[num].name!, time: coreDataTag[num].time! as NSDate, selected: false))
        }
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

extension TagViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // 셀 개수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        arr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tag", for: indexPath) as! TokenMainCell
        cell.token = arr[indexPath.item]
        return cell
    }
    
    // 셀눌렸을떄, 삭제할때
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    }

}

// cell 사이즈 지정
extension TagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text = ""

        text = self.arr[indexPath.item].title


        let cellWidth = text.size(withAttributes:[.font: UIFont.boldSystemFont(ofSize:16.0)]).width + 30.0

        if collectionView == tagCollection {
          return CGSize(width: cellWidth + 35, height: 30.0)
        } else {
          return CGSize(width: cellWidth+100, height: 100.0)
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
