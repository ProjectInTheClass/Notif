//
//  HistoryViewController.swift
//  Noti
//
//  Created by sejin on 2020/05/20.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource {
    
   
    
    
    //var cardsViewController = CardViewController()
    var cardsViewController = classifiedCard()
    
    @IBOutlet weak var historyTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.historyTable.dataSource = self
        self.historyTable.rowHeight = 80
        // Do any additional setup after loading the view.
        self.historyTable.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
       
        return Array(Set( self.cardsViewController.cards.map{$0.formattedDate})).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return Array(Set(self.cardsViewController.cards.map{$0.formattedDate})).sorted().reversed()[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(channelsDataSource.allTags.count == 0 ){
                   return 1
        }
        let date = Array(Set(self.cardsViewController.cards.map{$0.formattedDate})).sorted().reversed()[section]
        return self.cardsViewController.cards.filter{$0.formattedDate == date}.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //home 화면에서 제공되던 card 셀들
        let cardCell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HomeTableViewCell
        //날짜별로 정렬하기 위해서 추가, 카드들을 날짜별로 묶어줄 수 있도록 각 섹션의 날짜가 저장된 변수
        let date = Array(Set(self.cardsViewController.cards.map{$0.formattedDate})).sorted().reversed()[indexPath.section]
        //cardsViewController.cards를 돌면서 각 날짜에 맞는 card를 필터를 걸어서 찾아내기 위한 변수
        let nowCell = self.cardsViewController.cards.filter{$0.formattedDate==date}[indexPath.row]
        //tag를 추가했을 때 생기는 cell, 기존의 card 구조체에서 제목과 시간만 저장됨
        let tagCell = tableView.dequeueReusableCell(withIdentifier: "tagCell", for: indexPath) as! tagTableViewCell
        
        if(channelsDataSource.allTags.count == 0 ){
            tagCell.whenTagCreated.text = "--------표시할 데이터 없음---------"
            return tagCell
        }
        
        //source가 있으면 cardCell, 아니면 tagCell로 구분함
        if(nowCell.source != nil){
            cardCell.titleLabel.text = nowCell.title
            cardCell.sourceLabel.text = nowCell.source
            //        cell.cellView.layer.borderWidth = 1
            cardCell.dateLabel.text = nowCell.formattedDate
            cardCell.cellView.layer.shadowColor = UIColor.black.cgColor
            cardCell.cellView.layer.shadowOffset = CGSize(width: 0, height: 2) //반경
            cardCell.cellView.layer.shadowRadius = 2 // 반경?
            cardCell.cellView.layer.shadowOpacity = 0.5 // alpha값입니다.
                    
            cardCell.sourceColorView.layer.backgroundColor = nowCell.color.cgColor
            
            return cardCell
       }
        //source가 없는 경우 tagCell 로 구분된다
        else{
            tagCell.whenTagCreated.text = "--------#" + nowCell.title + "추가됨-------"
            return tagCell
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
