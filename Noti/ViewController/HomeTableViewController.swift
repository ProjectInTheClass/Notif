//
//  HomeTableViewController.swift
//  Noti
//
//  Created by Junroot on 2020/05/12.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit
import CoreData

class HomeTableViewController: UITableViewController {
    var mangedObjectContext : NSManagedObjectContext!
    var cards = [Card]()
    
    func loadData(){
        let cardsData = CoreDataManager.shared.getCards()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        let now = dateFormatter.string(from: Date())
               
        let yesterday = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)

        let allChannels = CoreDataManager.shared.getChannels()
        
        let channels = allChannels.filter{ $0.isSubscribed == true }
        cards = cardsData.filter{ ($0.homeFormattedDate! == now||$0.homeFormattedDate! == yesterday) && $0.url != ""}
        cards = cards.filter{(card) -> Bool in
        return channels.filter{(channel) -> Bool in
            return channel.source == card.source && card.formattedSource!.contains(channel.subtitle!)}.count != 0}
        navigationItem.title = "\(cards.count)개의 새로운 글"
    }
    

    var listUnread = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue") {
            let destination = segue.destination as! detailViewController
            if let cell = sender as? HomeTableViewCell {
                guard let indexPath = self.tableView.indexPathForSelectedRow else {return}
                destination.title2 = cell.titleLabel.text
                destination.source = cell.sourceLabel.text
                destination.date = cell.dateLabel.text
                destination.back2 = title
                destination.url = cards[indexPath.row].url
                destination.json = cards[indexPath.row].json!
                
                // 방문할경우 비짓처리하고 테이블뷰 리로드
                cards[indexPath.row].isVisited = true
                CoreDataManager.shared.visitCards(url: cards[indexPath.row].url!){ onSuccess in print("saved = \(onSuccess)")}
                tableView.reloadData()
                
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CoreDataManager.shared.setData()
        loadData()
        navigationItem.largeTitleDisplayMode = .always
        
        //카드개수만큼만 보여주도록 설정함
        navigationItem.title = "\(cards.count)개의 새로운 글"

        tabBarItem.title = "홈"
        
        //네비게이션바 배경색 넣어주는 코드
        let coloredAppearance = UINavigationBarAppearance()
        if self.traitCollection.userInterfaceStyle == .dark{
            coloredAppearance.configureWithOpaqueBackground()
            //coloredAppearance.backgroundColor = UIColor.navBack
            //coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
            //coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
            self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
            self.navigationController?.navigationBar.standardAppearance = coloredAppearance
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        else{
            coloredAppearance.configureWithOpaqueBackground()
            coloredAppearance.backgroundColor = UIColor.navBack
            coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
            coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
            self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
            self.navigationController?.navigationBar.standardAppearance = coloredAppearance
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        }
        
        
        
        // 라이트 뷰 생성
        let rightView = UIView()
        rightView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        // rItem이라는 UIBarButtonItem 객체 생성
        let rItem = UIBarButtonItem(customView: rightView)
        navigationItem.rightBarButtonItem = rItem
        // 새로고침 버튼 생성
        let unreadButton = UIButton(type:.system)
        unreadButton.frame = CGRect(x:0, y:0, width: 30, height: 30)
        unreadButton.setImage(UIImage(systemName: "envelope"), for: .normal)
        unreadButton.addTarget(self, action: #selector(unreadButtonIsSelected), for: .touchUpInside)
        // 라이트 뷰에 버튼 추가
        rightView.addSubview(unreadButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CoreDataManager.shared.setData()
        loadData()
        self.tableView.reloadData()
    }
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return cards.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! HomeTableViewCell
        
        cell.titleLabel.text = cards[indexPath.row].title
        cell.sourceLabel.text = cards[indexPath.row].formattedSource
        cell.dateLabel.text = cards[indexPath.row].homeFormattedDate
        cell.sourceColorView.backgroundColor = CoreDataManager.shared.colorWithHexString(hexString: cards[indexPath.row].color! )
        cell.sourceLabel.textColor = .sourceFont
        // cell의 backgroudView 수정
        let backgrundView = UIView()
        let backView = UIView(frame: CGRect(x: 17, y: 0, width: view.frame.width-34, height: 86))
        
        backView.backgroundColor = .white
        backgrundView.addSubview(backView)
        cell.backgroundView = backgrundView
        
        // cell의 selectedBackgroudView 수정
        let selectedBackgrundView = UIView()
        let selectView = UIView(frame: CGRect(x: 17, y: 0, width: view.frame.width-34, height: 86))
        selectView.backgroundColor = .selected
        selectedBackgrundView.addSubview(selectView)
        cell.selectedBackgroundView = selectedBackgrundView

        
        // 비짓이 트루로 되어있으면 배경 블러처리해줌
        if (cards[indexPath.row].isVisited == true){
            cell.cellView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
            cell.cellView?.alpha = 0.67
        }else {
            if self.traitCollection.userInterfaceStyle == .dark{
                cell.cellView?.backgroundColor = .systemGray4
            }
            else{
                cell.cellView?.backgroundColor = .white
                
            }
            cell.cellView?.alpha = 1
        }
        
        // 그림자 부분
        cell.backgroundView?.layer.shadowColor = UIColor.black.cgColor // 검정색 사용
        cell.backgroundView?.layer.masksToBounds = false
        cell.backgroundView?.layer.shadowOffset = CGSize(width: 1, height: 2) //반경
        cell.backgroundView?.layer.shadowRadius = 3 // 반경?
        cell.backgroundView?.layer.shadowOpacity = 0.2 //

        return cell
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // 메시지 버튼 눌리면 할거
    @IBAction func unreadButtonIsSelected(_ sender: UIButton) {
        listUnread.toggle()
        if listUnread{
            sender.setImage(UIImage(systemName: "envelope.fill"), for: .normal)
            loadData()
            cards = cards.filter{ $0.isVisited == false }
            navigationItem.title = "\(cards.count)개의 새로운 글"

        }
        else{
            sender.setImage(UIImage(systemName: "envelope"), for: .normal)
            loadData()
        }
        tableView.reloadData()
    }
    
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
