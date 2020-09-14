//
//  PopMessage.swift
//  Noti
//
//  Created by 이상윤 on 2020/09/15.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class PopMessage: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupView()
    }
    
    
    var statusLabel: UILabel = {
      
      let lbl = UILabel()
      lbl.translatesAutoresizingMaskIntoConstraints = false
//      lbl.textAlignment = .center
      lbl.font = UIFont.boldSystemFont(ofSize: 16)
      lbl.textColor = .blueSelected
      return lbl
    }()
    
    func setupView() {
        self.statusLabel.text = nil
        self.backgroundColor = .cardFront
        self.layer.cornerRadius = 11
        
        // 그림자
        self.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        self.layer.masksToBounds = false
        self.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
        self.layer.shadowRadius = 3 // 반경?
        self.layer.shadowOpacity = 0.2 //
        
        addSubview(statusLabel)
        self.addConstraints([
            statusLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
          statusLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
          statusLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1),
          ])
    }
    
    func setLabel( messages : NSAttributedString){
        self.statusLabel.attributedText = messages
    }
}
