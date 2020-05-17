//
//  CardsViewController.swift
//  Noti
//
//  Created by Junroot on 2020/05/17.
//  Copyright © 2020 Junroot. All rights reserved.
//

import Foundation
import UIKit

struct CardViewController {
    let dateFormatter = DateFormatter()
    var cards = [Card]()
    
    init() {
        dateFormatter.dateFormat = "yyyy/MM/dd"
        cards += [
            Card(title:"2020학년도 학사일정(학부) 변경 안내", source:"학부-학사 게시판", tag:[], time: dateFormatter.date(from: "2020-02-17")!, color: UIColor.first, url:""),
            Card(title:"출석인정내규 개정 안내", source: "학부-학사 게시판", tag:[], time: dateFormatter.date(from: "2019-09-30")!, color: UIColor.first, url:""),
            Card(title:"창업현장실습 학점인정 정책 변경 안내(전공학점인정 축소)", source: "학부-학사 게시판", time:  dateFormatter.date(from: "2019-08-16")!, color: UIColor.first, url:""),
            Card(title:"온라인 공결시스템 이용 안내", source: "학부-학사 게시판", time:  dateFormatter.date(from: "2019-04-05")!, color: UIColor.first, url:""),
            Card(title:"2020년 상반기 김제시 대학생 학자금 대출이자 지원 사업 신청 안내", source: "포털-장학 게시판", time:  dateFormatter.date(from: "2020-04-23")!, color: UIColor.second, url:""),
            Card(title:"2020년도 수림재단 신규장학생 선발안내", source: "포털-장학 게시판", time:  dateFormatter.date(from: "2020-04-20")!, color: UIColor.second, url:""),
            Card(title:"BS-Care 기초과학교과목 성적상승 장학 안내", source: "포털-장학 게시판", time:  dateFormatter.date(from: "2020-04-20")!, color: UIColor.second, url:""),
            Card(title:"경기청년 해외취업과정 연수생 모집(베트남, 일본)", source: "학부-취업 게시판", time:  dateFormatter.date(from: "2020-04-23")!, color: UIColor.third, url:""),
            Card(title:"[푸르덴셜 생명] SPAC 설명회", source: "학부-취업 게시판", time:  dateFormatter.date(from: "2020-04-22")!, color: UIColor.third, url:""),
            Card(title:"[순천시] 2021 순천 4차산업혁명박람회 브랜드 공모]", source: "학부-취업 게시판", time:  dateFormatter.date(from: "2020-04-22")!, color: UIColor.third, url:"" ),
            Card(title:"제18회 임베디드SW경진대회 공고", source: "학부-학사 게시판", tag:[], time: dateFormatter.date(from: "2020-05-14")!, color:UIColor.first, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28898&page=1&code=notice")
        ]
        cards.sort {(obj1, obj2) -> Bool in
            return obj1.time > obj2.time
        }
    }
}
