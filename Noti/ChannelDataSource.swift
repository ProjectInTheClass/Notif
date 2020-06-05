//
//  channelView.swift
//  Noti
//
//  Created by sejin on 2020/05/29.
//  Copyright © 2020 Junroot. All rights reserved.
//

import Foundation

class ChannelDataSource{
    var channels = [Channel]()
    var channelForServer = [Channel]()
    let dateFormatter = DateFormatter()
    var allTags = [Tag]()
    init() {
        dateFormatter.dateFormat = "yyyy/MM/dd"
        channels += [Channel(title: "전체",subtitle: "전체", category: "", color: .sourceFont, channelTags: ["대회","모집"]),Channel(title: "학사게시판",subtitle: "학사", category:  "포털", color: .fourth, channelTags: [] ),Channel(title: "장학게시판",subtitle: "장학", category:  "포털",color: .third,  channelTags: ["장학금"]),Channel(title: "학사일반게시판",subtitle: "학사일반", category: "컴퓨터소프트웨어대학",color: .first, channelTags: ["대회","모집"]), Channel(title: "취업정보게시판",subtitle: "취업정보", category: "컴퓨터소프트웨어대학",color: .second, channelTags: ["모집","채용"])]
            //Channel.allTags += ["취업","모집","채용","장학금"]
            //Channel.allTags += ["모집"]
        allTags += [Tag(name: "대회", time: dateFormatter.date(from: "2020-05-12")!),Tag(name: "모집", time: dateFormatter.date(from: "2020-05-11")!),Tag(name: "채용", time: dateFormatter.date(from: "2020-05-14")!),Tag(name: "장학금", time: dateFormatter.date(from: "2020-05-13")!),]
    }
    
}

var channelsDataSource = ChannelDataSource()
