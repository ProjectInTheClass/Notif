//
//  ChannelViewController.swift
//  Noti
//
//  Created by sejin on 2020/05/20.
//  Copyright © 2020 Junroot. All rights reserved.
//

import Foundation

struct ChannelViewController{
    var channels = [Channel]()
    channels += [Channel(title: "학부-학사", channelTags: [Tag(name: "대회"), Tag(name: "모집")]), Channel(title: "학부-취업", channelTags: [Tag(name: "모집"), Tag(name: "취업")]), Channel(title: "포털-장학", channelTags: [Tag(name: "장학금")]), Channel(title: "포털-일반", channelTags: [Tag]() ),]
    // Channel.allTags += [Tag(name: "대회"), Tag(name: "모집"),Tag(name: "장학금"),Tag(name: "취업"),]
     Channel.allTags += [Tag(name :"")]
}
