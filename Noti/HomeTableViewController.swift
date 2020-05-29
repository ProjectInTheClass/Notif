//
//  HomeTableViewController.swift
//  Noti
//
//  Created by Junroot on 2020/05/12.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {
    
    //var cardsViewController = CardViewController()
    // 모든 카드 정보(cardsViewController에 있는 카드와 테이블뷰에 뿌릴 카드를 나눔
    var cards = cardsDataSource.cards
    // 메세지 버튼(안본거만 뿌려주는 버튼)
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
                destination.json = cards[indexPath.row].json
                
                // 방문할경우 비짓처리하고 테이블뷰 리로드
                cards[indexPath.row].isVisited = true
                tableView.reloadData()
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .always

        //카드개수만큼만 보여주도록 설정함
        navigationItem.title = "\(cards.count)개의 새로운 글"

        tabBarItem.title = "홈"
        
        //네비게이션바 배경색 넣어주는 코드
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithOpaqueBackground()
        coloredAppearance.backgroundColor = UIColor.navBack
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.navFont]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.navFont]
        self.navigationController?.navigationBar.scrollEdgeAppearance = coloredAppearance
        self.navigationController?.navigationBar.standardAppearance = coloredAppearance
        
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
        cell.sourceLabel.text = cards[indexPath.row].source
        cell.dateLabel.text = cards[indexPath.row].formattedDate
//        cell.cellView.layer.borderWidth = 1
        
        cell.cellView.layer.shadowColor = UIColor.black.cgColor
        cell.cellView.layer.shadowOffset = CGSize(width: 0, height: 2) //반경
        cell.cellView.layer.shadowRadius = 2 // 반경?
        cell.cellView.layer.shadowOpacity = 0.5 // alpha값입니다.
        
        cell.sourceColorView.layer.backgroundColor = cards[indexPath.row].color.cgColor

        // 비짓이 트루로 되어있으면 배경 블러처리해줌
        if (cards[indexPath.row].isVisited == true){
            cell.cellView.backgroundColor = UIColor(white: 0.95, alpha: 1)
            cell.cellView.alpha = 0.67
        }else {
            cell.cellView.backgroundColor = .white
            cell.cellView.alpha = 1
        }
        
        return cell
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    //자잘하게 ui수정 카드 높이 수정함
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95
    }
    // 메시지 버튼 눌리면 할거
    @IBAction func unreadButtonIsSelected(_ sender: UIBarButtonItem) {
        listUnread.toggle()
        if listUnread{
            cards = cardsDataSource.cards.filter{ $0.isVisited == false }
        
        }
        else{
            cards = cardsDataSource.cards
        }
        tableView.reloadData()
    }
    
    // 이거 넣으면 세그웨이 두번실행되서 지움
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
        
        performSegue(withIdentifier: "detailSegue", sender: cell)
    }
    
    
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
