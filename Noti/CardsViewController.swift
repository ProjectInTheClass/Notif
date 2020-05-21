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
            Card(title:"제18회 임베디드SW경진대회 공고", source:"학부-학사 게시판", tag:["대회"], time: dateFormatter.date(from: "2020-05-14")!, color: UIColor.first, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28898&page=1&code=notice"),
            Card(title:"2020학년도 2학기 재입학 신청 안내", source: "학부-학사 게시판", tag:[], time: dateFormatter.date(from: "2020-05-12")!, color: UIColor.first, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28892&page=1&code=notice"),
            Card(title:"[KAIST] 2020년 몰입캠프 여름학기 모집", source: "학부-학사 게시판",tag:["모집"], time:  dateFormatter.date(from: "2020-05-11")!, color: UIColor.first, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28891&page=1&code=notice"),
            Card(title:"2020학년도 여름계절학기 수강신청 안내", source: "학부-학사 게시판",tag:["수강신청"], time:  dateFormatter.date(from: "2020-05-11")!, color: UIColor.first, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28890&page=1&code=notice"),
            Card(title:"[NCSOFT] 2020 SUMMER INTERN 공개모집 (~5/21)", source: "학부-취업 게시판",tag: ["모집"], time:  dateFormatter.date(from: "2020-05-14")!, color: UIColor.second, url:"http://cs.hanyang.ac.kr/board/job_board.php?ptype=view&idx=28897&page=1&code=job_board"),
            Card(title:"파이썬마스터 자격검정 안내", source: "학부-취업 게시판", time:  dateFormatter.date(from: "2020-05-14")!, color: UIColor.second, url:"http://cs.hanyang.ac.kr/board/job_board.php?ptype=view&idx=28896&page=1&code=job_board"),
            Card(title:"2020년 상반기 KB국민은행 신입행원(L1) 수시채용", source: "학부-취업 게시판",tag:["채용"], time:  dateFormatter.date(from: "2020-05-14")!, color: UIColor.second, url:"http://cs.hanyang.ac.kr/board/job_board.php?ptype=view&idx=28895&page=1&code=job_board"),
            Card(title:"2020-2학기 1차 국가근로장학금 학생신청기간 안내", source: "포털-장학 게시판",tag:["장학금"], time:  dateFormatter.date(from: "2020-05-18")!, color: UIColor.third, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a", json: ["gongjiSeq":"15689"]),
            Card(title:"대운동장 인조잔디구장 및 지하주차장 사용 안내", source: "포털-일반 게시판", time:  dateFormatter.date(from: "2020-05-18")!, color: UIColor.fourth, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a", json: ["gongjiSeq":"15688"]),
            Card(title:"2020년도 상반기 울산광역시 대학생 학자금대출 이자지원 사업 신청 안내", source: "포털-장학 게시판", time:  dateFormatter.date(from: "2020-05-18")!, color: UIColor.third, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a" , json: ["gongjiSeq":"15686"]),
            Card(title:"2020-1학기 국가장학금1유형 지급(3차 지급실행) 예정 안내", source: "포털-장학 게시판", tag:["장학금"], time: dateFormatter.date(from: "2020-05-18")!, color:UIColor.first, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a", json: ["gongjiSeq":"15685"])
        ]
        cards.sort {(obj1, obj2) -> Bool in
            return obj1.time > obj2.time
        }
    }
}

struct ChannelViewController{
    var channels = [Channel]()
    let dateFormatter = DateFormatter()
    init() {
        dateFormatter.dateFormat = "yyyy/MM/dd"
        channels += [Channel(title: "학부-학사", channelTags: ["대회","모집"]), Channel(title: "학부-취업", channelTags: ["모집","채용"]), Channel(title: "포털-장학", channelTags: ["장학금"]), Channel(title: "포털-일반", channelTags: [] ),]
            //Channel.allTags += ["취업","모집","채용","장학금"]
            //Channel.allTags += ["모집"]
        Channel.allTags += [Tag(name: "대회", time: dateFormatter.date(from: "2020-05-12")!),Tag(name: "모집", time: dateFormatter.date(from: "2020-05-11")!),Tag(name: "채용", time: dateFormatter.date(from: "2020-05-14")!),Tag(name: "장학금", time: dateFormatter.date(from: "2020-05-13")!),]
    }
    
}
