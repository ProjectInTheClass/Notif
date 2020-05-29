//
//  classifyCards.swift
//  Noti
//
//  Created by sejin on 2020/05/20.
//  Copyright © 2020 Junroot. All rights reserved.
//

import Foundation

struct classifiedCard{
    let cardview = CardViewController()
    let channelview = ChannelViewController()
    var allTagsArray = [String]()
    
    var cards = [Card]()
    init(){
        for i in 0..<channelview.allTags.count{
            allTagsArray += [channelview.allTags[i].name]
        }
        if(channelview.allTags.count != 0){
            for i in 0..<cardview.cards.count{
                if(cardview.cards[i].source == nil){
                    self.cards.append(cardview.cards[i])
                    continue
                }
                for j in 0..<cardview.cards[i].tag.count{
                    if(allTagsArray.contains(cardview.cards[i].tag[j])){
                        self.cards.append(cardview.cards[i])
                    }
                }
            }
        }
    }
}
