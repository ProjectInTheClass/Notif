//
//  classifyCards.swift
//  Noti
//
//  Created by sejin on 2020/05/20.
//  Copyright © 2020 Junroot. All rights reserved.
//

//import Foundation
//import CoreData

/*struct classifiedCard{
    let cardview = [Card]()
    var allTagsArray = [String]()
    var mangedObjectContext : NSManagedObjectContext!
    var cards = [Card]()
    init(){
        var allTags = [Tags]()
        let fetchRequest : NSFetchRequest<Tags>  = Tags.fetchRequest()
            do{
                allTags = try mangedObjectContext.fetch(fetchRequest)
            }catch{
                fatalError("fetch error!")
            }
                   
        
        for i in 0..<allTags.count{
            allTagsArray += [allTags[i].name]
        }
        if(allTags.count != 0){
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
}*/
