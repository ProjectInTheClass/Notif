    //
//  HistoryTableViewController.swift
//  Noti
//
//  Created by 이상윤 on 2020/06/03.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit
import CoreData
class HistoryTableViewController: UITableViewController {

    var cards = CoreDataManager.shared.getCards()
    var channels = CoreDataManager.shared.getChannels()
    var allTags = CoreDataManager.shared.getTags()
    // 메세지 버튼(안본거만 뿌려주는 버튼)
    var listUnread = false
    var mangedObjectContext : NSManagedObjectContext!
    
    /*func updateCards(){
//        let now = Date()
        
        // 임시로 보여주기 위해 선언함
//        var dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
//        let now = dateFormatter.date(from: "2020-05-18 17:21")!
//        //
//
//        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: now)!
//        cards = cardsDataSource.cards.filter{ $0.time <= now && $0.time > yesterday && $0.url != ""}
        cards = cardsDataSource.cards
    }*/
    
// 일단 주석처리
//        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//            if (segue.identifier == "detailSegue") {
//                let destination = segue.destination as! detailViewController
//                if let cell = sender as? HomeTableViewCell {
//                    guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
//                    destination.title2 = cell.titleLabel.text
//                    destination.source = cell.sourceLabel.text
//                    destination.date = cell.dateLabel.text
//                    destination.back2 = title
//                    destination.url = cards[indexPath.row].url
//    //                print("!!!!!"+cards[indexPath.row].url)
//                    destination.json = cards[indexPath.row].json
//
//                    // 방문할경우 비짓처리하고 테이블뷰 리로드
//                    cards[indexPath.row].isVisited = true
//                    tableView.reloadData()
//
//                }
//            }
//        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        
        //카드개수만큼만 보여주도록 설정함
        navigationItem.title = "취업정보게시판"


        let source = NSAttributedString(string: "컴퓨터소프트웨어대학", attributes: [.font : UIFont.boldSystemFont(ofSize: 20), .foregroundColor: UIColor.sourceFont])

        navigationController?.hidesBarsOnSwipe = true
        // 라이트 뷰 생성
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: .bitWidth, height: 70)
        
        let rItem = UIBarButtonItem(customView: rightView)
        self.navigationItem.leftBarButtonItem = rItem
//        self.navigationItem.
        // 새로고침 버튼 생성
//        let refreshButton = UIButton(type:.system)
//        refreshButton.frame = CGRect(x:0, y:10, width: 180, height: 62)
//        refreshButton.setAttributedTitle(source, for: .normal)
//        refreshButton.tintColor = .black
//        refreshButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        let somet = UILabel()
        somet.frame = CGRect(x:0, y:10, width: 400, height: 62)
        somet.attributedText=source
        rightView.addSubview(somet)
//        rightView.addSubview(refreshButton)
        
        //네비게이션바 배경색 넣어주는 코드
        let coloredAppearance = UINavigationBarAppearance()
         coloredAppearance.configureWithOpaqueBackground()
         coloredAppearance.backgroundColor = UIColor.navBack
         coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
         coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
         self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
         self.navigationController?.navigationBar.standardAppearance = coloredAppearance
    
    }
    @objc func buttonClicked(){
           print("refresh button Clicked!")
    }
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return Array(Set(cards.map{$0.historyFormattedDate})).count
    }
     
    
    // 커스텀섹션헤더부분
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let view = UIView(frame: CGRect(x:0, y:0, width:tableView.frame.size.width, height:17 ))
        let label = UILabel(frame: CGRect(x:20, y:17, width:tableView.frame.size.width, height:17))

        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = UIColor.sectionFont
        label.text = Array(Set(cards.map{$0.historyFormattedDate})).sorted(by :>)[section]
        view.addSubview(label)
        view.backgroundColor = UIColor.white

        return view

    }
    
    
    // 섹션 헤더 높이 설정
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(allTags.count == 0 ){
                   return 1
        }
        let date = Array(Set(cards.map{$0.historyFormattedDate}))
        date.sorted(by : >)
        let returnData  =  cards.filter{$0.historyFormattedDate == date[section]} //cards.filter{$0.historyFormattedDate == date}
        return returnData.count
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let date = Array(Set(cards.map{$0.historyFormattedDate}))
        date.sorted(by: >)
        let sectionCards = cards.filter{$0.historyFormattedDate==date[indexPath.section]}
        if (sectionCards[indexPath.row].source != nil){
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HomeTableViewCell
            cell.titleLabel.text = sectionCards[indexPath.row].title
            cell.sourceLabel.text = sectionCards[indexPath.row].source
            cell.dateLabel.text = sectionCards[indexPath.row].historyCardFormattedDate
            cell.sourceColorView.backgroundColor = sectionCards[indexPath.row].color as? UIColor

            // 비짓이 트루로 되어있으면 배경 블러처리해줌
            if (cards[indexPath.row].isVisited == true){
                cell.cellView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                cell.cellView.alpha = 0.67
            }else {
                cell.cellView.backgroundColor = .white
                cell.cellView.alpha = 1
            }

            // 그림자 부분
            cell.cellView.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
            cell.cellView.layer.masksToBounds = false
            cell.cellView.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
            cell.cellView.layer.shadowRadius = 8 // 반경?
            cell.cellView.layer.shadowOpacity = 0.2 //
            return cell
        }else{

            let cell = tableView.dequeueReusableCell(withIdentifier: "a", for: indexPath) as! HistoryCell
            cell.history.text =  "#"+sectionCards[indexPath.row].title  + " 추가"
            //cell.history.text = "#추가"
            cell.history.textColor = UIColor.first
            let attributedStr = NSMutableAttributedString(string: cell.history.text!)
            
            //위에서 만든 attributedStr에 addAttribute메소드를 통해 Attribute를 적용. kCTFontAttributeName은 value로 폰트크기와 폰트를 받을 수 있음.
            attributedStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.sourceFont, range: (cell.history.text! as NSString).range(of:"추가"))


            //최종적으로 내 label에 속성을 적용
            cell.history.attributedText = attributedStr
            cell.backLine.backgroundColor = .sourceFont
            return cell
        }

                
    }
    
//    // Make the background color show through
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.clear
//        return headerView
//    }
    
    // 메시지 버튼 눌리면 할거
//        @IBAction func unreadButtonIsSelected(_ sender: UIBarButtonItem) {
//            listUnread.toggle()
//            if listUnread{
//                updateCards()
//                cards = cards.filter{ $0.isVisited == false }
//
//            }
//            else{
//                updateCards()
//            }
//            tableView.reloadData()
//        }
    
    // 이거 넣으면 세그웨이 두번실행되서 지움
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
//
//        performSegue(withIdentifier: "detailSegue", sender: cell)
//    }
//
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
