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

    @IBOutlet weak var tagCollection: DynmicHeightCollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "태그"
        for (_,str) in ["취업", "인턴", "카카오", "삼성전자", "수강신청", "장애학생도우미", "장학금", "일반대학원", "채용연계", "Generics", "Error", "Deinitialization"].enumerated() {
            arr.append(Tag(title: str, time: NSDate(), selected: false))
        }

    }
    
// 추가버튼 눌렸을때
    @IBAction func addPressed(_ sender: Any) {
        let alertController = UIAlertController(title: "태그 추가하기", message: "추가할 태그의 이름을 입력해주세요", preferredStyle: .alert)
        alertController.addTextField{(textField) in textField.placeholder = "태그 이름 입력"}

        let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
            let textField = alertController.textFields![0]
            if let newTag = textField.text, newTag != "" {
//                guard self.arr.map({ $0.title }).contains(newTag) else {
//
//                }
                self.arr.append(Tag(title: newTag, time: NSDate(), selected: false))
                let indexPath = IndexPath(row: self.arr.count - 1, section: 0)
                self.tagCollection.insertItems(at: [indexPath])

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
        print("tag \(indexPath) sellected")
        arr.remove(at: indexPath.item)
        tagCollection.deleteItems(at: [indexPath])
        tagCollection.reloadData()
        tagCollection.collectionViewLayout.invalidateLayout()

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