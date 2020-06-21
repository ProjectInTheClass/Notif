//
//  CustomCollectionViewCell.swift
//  Noti
//
//  Created by 이상윤 on 2020/06/05.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
//    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var colorLabel: UILabel!
    
}


struct Tag {
  
    var title: String
    var time : NSDate
    var selected = false
    var formattedDate: String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        return dateFormatter.string(from: time as Date)
    }
}


class BaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    func setupViews() {
        
        
    }
}


class TokenMainCell: BaseCollectionViewCell {
  
  static let identifier = "TokenMainCell"
  
  var token: Tag? {
    didSet{
      guard let sender = self.token else { return }
      self.titleLabel.text = "  #" + sender.title
    }
  }
  
  var titleLabel: UILabel = {
    
    let lbl = UILabel()
    lbl.translatesAutoresizingMaskIntoConstraints = false
    lbl.textAlignment = .center
    lbl.font = UIFont.boldSystemFont(ofSize: 16)
    lbl.textColor = .sectionFont
    return lbl
  }()
  
  var cancelButton: UIButton = {
    
    let btn = UIButton()
    let myString = "X"
    let myAttribute = [ NSAttributedString.Key.foregroundColor: UIColor.blueSelected, NSAttributedString.Key.font: UIFont(name: "GillSans", size: 13.0)!]
     let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
    btn.setAttributedTitle(myAttrString, for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setContentHuggingPriority(.init(100), for: .horizontal)
    btn.isUserInteractionEnabled = false
    return btn
  }()
  
  override func setupViews() {
    
    self.titleLabel.text = nil
    self.backgroundColor = .white
    self.layer.cornerRadius = 9
    
    // 그림자
    self.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
    self.layer.masksToBounds = false
    self.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
    self.layer.shadowRadius = 3 // 반경?
    self.layer.shadowOpacity = 0.2 //
    
    let stack = UIStackView(arrangedSubviews: [titleLabel, cancelButton])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.distribution = .fillProportionally
    stack.spacing = -5
    
    addSubview(stack)
    self.addConstraints([
      stack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      stack.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1),
      ])
  }
}

class DynmicHeightCollectionView: UICollectionView {
  
  var isDynamicSizeRequired = false
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
      
      if self.intrinsicContentSize.height > frame.size.height {
        self.invalidateIntrinsicContentSize()
      }
      if isDynamicSizeRequired {
        self.invalidateIntrinsicContentSize()
      }
    }
  }
  
  override var intrinsicContentSize: CGSize {
    return contentSize
  }
}
