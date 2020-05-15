//
//  HomeTableViewController.swift
//  Noti
//
//  Created by Junroot on 2020/05/12.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    struct Post {
        let title: String
        let source: String
        let date: Date
        
        var formattedDate: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            return dateFormatter.string(from: date)
        }
        
        var sourceColor: CGColor {
            switch self.source {
            case "학부-학사 게시판":
                return UIColor(red: 220/256, green: 90/256, blue: 90/256, alpha: 1.0).cgColor
            case "포털-장학 게시판":
                return UIColor(red: 88/256, green: 168/256, blue: 84/256, alpha: 1.0).cgColor
            case "학부-취업 게시판":
                return UIColor(red: 83/256, green: 143/256, blue: 204/256, alpha: 1.0).cgColor
            default:
                return UIColor.black.cgColor
            }
        }
    }
    
    var postList = [Post]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detailSegue") {
            let destination = segue.destination as! detailViewController
            if let cell = sender as? HomeTableViewCell {
                destination.title2 = cell.titleLabel.text
                destination.source = cell.sourceLabel.text
                destination.date = cell.dateLabel.text
                destination.back2 = title
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        postList.append(Post(title:"2020학년도 학사일정(학부) 변경 안내", source: "학부-학사 게시판", date:  dateFormatter.date(from: "2020-02-17")!))
        postList.append(Post(title:"출석인정내규 개정 안내", source: "학부-학사 게시판", date:  dateFormatter.date(from: "2019-09-30")!))
        postList.append(Post(title:"창업현장실습 학점인정 정책 변경 안내(전공학점인정 축소)", source: "학부-학사 게시판", date:  dateFormatter.date(from: "2019-08-16")!))
        postList.append(Post(title:"온라인 공결시스템 이용 안내", source: "학부-학사 게시판", date:  dateFormatter.date(from: "2019-04-05")!))
        postList.append(Post(title:"2020년 상반기 김제시 대학생 학자금 대출이자 지원 사업 신청 안내", source: "포털-장학 게시판", date:  dateFormatter.date(from: "2020-04-23")!))
        postList.append(Post(title:"2020년도 수림재단 신규장학생 선발안내", source: "포털-장학 게시판", date:  dateFormatter.date(from: "2020-04-20")!))
        postList.append(Post(title:"BS-Care 기초과학교과목 성적상승 장학 안내", source: "포털-장학 게시판", date:  dateFormatter.date(from: "2020-04-20")!))
        postList.append(Post(title:"경기청년 해외취업과정 연수생 모집(베트남, 일본)", source: "학부-취업 게시판", date:  dateFormatter.date(from: "2020-04-23")!))
        postList.append(Post(title:"[푸르덴셜 생명] SPAC 설명회", source: "학부-취업 게시판", date:  dateFormatter.date(from: "2020-04-22")!))
        postList.append(Post(title:"[순천시] 2021 순천 4차산업혁명박람회 브랜드 공모]", source: "학부-취업 게시판", date:  dateFormatter.date(from: "2020-04-22")!))

        postList.sort {(obj1, obj2) -> Bool in
            return obj1.date < obj2.date
        }

        
        navigationItem.largeTitleDisplayMode = .always
        
        title = "홈"
        
    }
        
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return postList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! HomeTableViewCell
        
        cell.titleLabel.text = postList[indexPath.row].title
        cell.sourceLabel.text = postList[indexPath.row].source
        cell.dateLabel.text = postList[indexPath.row].formattedDate
//        cell.cellView.layer.borderWidth = 1
        
        cell.cellView.layer.shadowColor = UIColor.black.cgColor
        cell.cellView.layer.shadowOffset = CGSize(width: 0, height: 2) //반경
        cell.cellView.layer.shadowRadius = 2 // 반경?
        cell.cellView.layer.shadowOpacity = 0.5 // alpha값입니다.
        
        cell.sourceColorView.layer.backgroundColor = postList[indexPath.row].sourceColor

        return cell
    }
    
    // Make the background color show through
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(100)
    }
    
    // 이거 넣으면 세그웨이 두번실행되서 지움
    /*
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! HomeTableViewCell
        
        performSegue(withIdentifier: "detailSegue", sender: cell)
    }
    */
    
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
