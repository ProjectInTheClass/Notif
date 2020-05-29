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
        channels += [Channel(title: "학부-학사", category: "컴퓨터소프트웨어학부", channelTags: ["대회","모집"]), Channel(title: "학부-취업", category: "컴퓨터소프트웨어학부", channelTags: ["모집","채용"]), Channel(title: "포털-장학", category:  "한양포탈", channelTags: ["장학금"]), Channel(title: "포털-일반", category:  "한양포탈",channelTags: [] ),]
            //Channel.allTags += ["취업","모집","채용","장학금"]
            //Channel.allTags += ["모집"]
        allTags += [Tag(name: "대회", time: dateFormatter.date(from: "2020-05-12")!),Tag(name: "모집", time: dateFormatter.date(from: "2020-05-11")!),Tag(name: "채용", time: dateFormatter.date(from: "2020-05-14")!),Tag(name: "장학금", time: dateFormatter.date(from: "2020-05-13")!),]
    }
    
}

var channelsDataSource = ChannelDataSource()
