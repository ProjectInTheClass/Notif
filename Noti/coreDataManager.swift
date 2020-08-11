//
//  CoreDataManager.swift
//  Noti
//
//  Created by sejin on 2020/06/08.
//  Copyright © 2020 Junroot. All rights reserved.
//

import Foundation
import CoreData
import UIKit



class CoreDataManager{
    static let shared : CoreDataManager = CoreDataManager()
    let appDelegate : AppDelegate? = UIApplication.shared.delegate as? AppDelegate
    lazy var context = appDelegate?.persistentContainer.viewContext
    // 메세지 버튼(안본거만 뿌려주는 버튼)
    var listUnread = false
    var mangedObjectContext : NSManagedObjectContext!
    
    func colorWithHexString(hexString: String) -> UIColor {
        var colorString = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()
        let alpha: CGFloat = 1.0
        let red: CGFloat = self.colorComponentFrom(colorString: colorString, start: 0, length: 2)
        let green: CGFloat = self.colorComponentFrom(colorString: colorString, start: 2, length: 2)
        let blue: CGFloat = self.colorComponentFrom(colorString: colorString, start: 4, length: 2)

        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {

        let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
        let endIndex = colorString.index(startIndex, offsetBy: length)
        let subString = colorString[startIndex..<endIndex]
        let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
        var hexComponent: UInt64 = 0

        guard Scanner(string: String(fullHexString)).scanHexInt64(&hexComponent) else {
            return 0
        }
        let hexFloat: CGFloat = CGFloat(hexComponent)
        let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
        return floatValue
    }
    func hexStringFromColor(color: UIColor) -> String {
       let components = color.cgColor.components
       let r: CGFloat = components?[0] ?? 0.0
       let g: CGFloat = components?[1] ?? 0.0
       let b: CGFloat = components?[2] ?? 0.0

       let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
       return hexString
    }
    func notificationChannel(subtitle : String, source: String, onSuccess: @escaping ((Bool) -> Void)){
             let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredChannel(subtitle: subtitle, source: source)
             var clickedChannel : Channel
             do {
                     if let results: [Channel] = try context?.fetch(fetchRequest) as? [Channel] {
                         clickedChannel = results[0]
                         clickedChannel.willChangeValue(forKey: "alarm")
                         clickedChannel.alarm.toggle()
                         clickedChannel.didChangeValue(forKey: "alarm")
                     }
                 } catch let error as NSError {
                     print("Could not fatch🥺: \(error), \(error.userInfo)")
                     onSuccess(false)
                 }

                contextSave { success in
                    onSuccess(success)
                }
         }
    
    //sort!!
    func getCards()->[Card]{
        let sorting : NSSortDescriptor = NSSortDescriptor(key: "time", ascending: false)
        
        var cards = [Card]()
        let fetchRequest : NSFetchRequest<Card>  = Card.fetchRequest()
        fetchRequest.sortDescriptors = [sorting]
        do{
            if let fetchResult : [Card] = try context?.fetch(fetchRequest){
                cards = fetchResult
            }
        }catch{
            fatalError("fetch error!")
        }
        return cards
    }
    
    func saveCards(title : String,  source : String, category : String, tag : [String], time : Date, color : UIColor, isVisited: Bool, url : String, json : [String:String], isFavorite : Bool, onSuccess :@escaping ((Bool)->Void)){
        if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: "Card", in: context) {
            
            if let cards: Card = NSManagedObject(entity: entity, insertInto: context ) as? Card {
                cards.title = title
                cards.category = category
                cards.source = source
                cards.tag = tag //as NSObject
                cards.time = time
                cards.color
                    = hexStringFromColor(color: color)
                cards.isVisited = isVisited
                cards.url = url
                cards.json = json //as NSObject
                cards.formattedSource = cards.category! + ((cards.category!.count == 0) ? "" : "-") + cards.source!
                cards.isFavorite = isFavorite
               let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yy-MM-dd"
                // 임시로 보여주기 위해 선언함
                cards.homeFormattedDate = dateFormatter.string(from: time)
                dateFormatter.dateFormat = "MM.dd"
                cards.historyFormattedDate = dateFormatter.string(from: time)
                dateFormatter.dateFormat = "HH:mm"
                cards.historyCardFormattedDate = dateFormatter.string(from: time)
                    
                /*do{
                    try self.context?.save()
                }catch{
                    print(error.localizedDescription)
                }*/
                contextSave {
                    success in onSuccess(success)
                }
               
            }
        }
    }
    func visitCards(url : String, onSuccess: @escaping ((Bool) -> Void)){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(url : url)
        var visitedCard : Card
        do {
                   if let results: [Card] = try context?.fetch(fetchRequest) as? [Card] {
                       visitedCard = results[0]
                       visitedCard.willChangeValue(forKey: "isVisited")
                       visitedCard.isVisited = true
                       visitedCard.didChangeValue(forKey: "isVisited")
                   }
               } catch let error as NSError {
                   print("Could not fatch🥺: \(error), \(error.userInfo)")
                   onSuccess(false)
               }
               
               contextSave { success in
                   onSuccess(success)
               }
    }
    func addCardsTag(tag : String, onSuccess: @escaping ((Bool) -> Void)){
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        var addTagCard : Card
        do {
            if let results: [Card] = try context?.fetch(fetchRequest) {
                    
                       for i in 0..<results.count{
                           if((results[i].title?.contains(tag))!){
                               addTagCard = results[i]
                            CoreDataManager.shared.addChannelTag(subtitle: addTagCard.category!, source: addTagCard.source!, tag: tag){onSuccess in print("saved = \(onSuccess)")}
                               addTagCard.willChangeValue(forKey: "tag")
                            addTagCard.tag?.append(tag)
                               addTagCard.didChangeValue(forKey: "tag")
                           }
                    }
                   }
               } catch let error as NSError {
                   print("Could not fatch🥺: \(error), \(error.userInfo)")
                   onSuccess(false)
               }
               
               contextSave { success in
                   onSuccess(success)
               }
    }
    func removeCardsTag(tag : String, onSuccess: @escaping ((Bool) -> Void)){
        let fetchRequest: NSFetchRequest<Card> = Card.fetchRequest()
        var removeTagCard : Card
        do {
            if let results: [Card] = try context?.fetch(fetchRequest) {
                    
                       for i in 0..<results.count{
                        if(results[i].tag!.count==1){
                            continue
                        }
                        for j in 1..<results[i].tag!.count{
                             if(tag == results[i].tag![j]){
                                removeTagCard = results[i]
                                let index = removeTagCard.tag?.firstIndex(of: tag)
                                 removeTagCard.willChangeValue(forKey: "tag")
                                 removeTagCard.tag?.remove(at: index!)
                                 removeTagCard.didChangeValue(forKey: "tag")
                                break;
                            }
                        }
                    }
                   }
               } catch let error as NSError {
                   print("Could not fatch🥺: \(error), \(error.userInfo)")
                   onSuccess(false)
               }
               
               contextSave { success in
                   onSuccess(success)
               }
    }
    func addFavoriteCard(url : String, onSuccess: @escaping ((Bool) -> Void)){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(url : url)
        var favoriteCard : Card
        do {
                   if let results: [Card] = try context?.fetch(fetchRequest) as? [Card] {
                       favoriteCard = results[0]
                       favoriteCard.willChangeValue(forKey: "isFavorite")
                       favoriteCard.isFavorite = true
                       favoriteCard.didChangeValue(forKey: "isFavorite")
                   }
               } catch let error as NSError {
                   print("Could not fatch🥺: \(error), \(error.userInfo)")
                   onSuccess(false)
               }
               contextSave { success in
                   onSuccess(success)
               }
    }
    func removeFavoriteCard(url : String, onSuccess: @escaping ((Bool) -> Void)){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredRequest(url : url)
        var favoriteCard : Card
        do {
                   if let results: [Card] = try context?.fetch(fetchRequest) as? [Card] {
                       favoriteCard = results[0]
                       favoriteCard.willChangeValue(forKey: "isFavorite")
                       favoriteCard.isFavorite = false
                       favoriteCard.didChangeValue(forKey: "isFavorite")
                   }
               } catch let error as NSError {
                   print("Could not fatch🥺: \(error), \(error.userInfo)")
                   onSuccess(false)
               }
               contextSave { success in
                   onSuccess(success)
               }
    }
    func getChannels()->[Channel]{
        //let dateFormatter = DateFormatter()
        var channels : [Channel]?
        let fetchRequest : NSFetchRequest<Channel>  = Channel.fetchRequest()
        do{
            if let fetchResult : [Channel] = try context?.fetch(fetchRequest){
            channels = fetchResult
            }
        }catch{
            fatalError("fetch error!")
        }
        return channels!
    }
   
    func saveChannels(title : String, subtitle :String, source : String, color : UIColor, channelTags : [String], group : String, isSubscribed : Bool  ,onSuccess : @escaping ((Bool)->Void)){
        if let context = context,
        let entity: NSEntityDescription
        = NSEntityDescription.entity(forEntityName: "Channel", in: context) {
        
        if let channels: Channel = NSManagedObject(entity: entity, insertInto: context ) as? Channel {
            channels.title = title
            channels.subtitle = subtitle
            channels.source = source
            channels.color = hexStringFromColor(color: color)
            channels.group = group
            channels.channelTags = channelTags
            channels.alarm = false
            channels.isSubscribed = isSubscribed
            contextSave{
                success in onSuccess(success)
            }
            }
        }
    }
    func subscribedChannel(subtitle : String, source: String, onSuccess: @escaping ((Bool) -> Void)){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredChannel(subtitle: subtitle, source: source)
        var visitedChannel : Channel
        do {
                if let results: [Channel] = try context?.fetch(fetchRequest) as? [Channel] {
                    visitedChannel = results[0]
                    visitedChannel.willChangeValue(forKey: "isSubscribed")
                    visitedChannel.isSubscribed.toggle()
                    visitedChannel.didChangeValue(forKey: "isSubscribed")
                }
                    } catch let error as NSError {
                        print("Could not fatch🥺: \(error), \(error.userInfo)")
                        onSuccess(false)
                    }
               
               contextSave { success in
                   onSuccess(success)
               }
    }
    func addChannelTag(subtitle : String, source: String, tag: String, onSuccess: @escaping ((Bool) -> Void)){
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = filteredChannel(subtitle: subtitle, source: source)
        var addTagChannel : Channel
        do {
                if let results: [Channel] = try context?.fetch(fetchRequest) as? [Channel] {
                    addTagChannel = results[0]
                    if((addTagChannel.channelTags?.contains(tag))!){
                        return
                    }
                    addTagChannel.willChangeValue(forKey: "channelTags")
                    addTagChannel.channelTags?.append(tag)
                    addTagChannel.didChangeValue(forKey: "channelTags")
                }
                    } catch let error as NSError {
                        print("Could not fatch🥺: \(error), \(error.userInfo)")
                        onSuccess(false)
                    }
               
               contextSave { success in
                   onSuccess(success)
               }
    }
    func removeChannelTag(tag: String, onSuccess: @escaping ((Bool) -> Void)){
       let fetchRequest : NSFetchRequest<Channel>  = Channel.fetchRequest()
        var removeTagChannel : Channel
        do {
            if let results: [Channel] = try context?.fetch(fetchRequest) {
                    for i in 0..<results.count{
                        if((results[i].channelTags?.contains(tag))!){
                            removeTagChannel = results[i]
                            let index = removeTagChannel.channelTags?.firstIndex(of: tag)
                            removeTagChannel.willChangeValue(forKey: "channelTags")
                            removeTagChannel.channelTags?.remove(at: index!)
                            removeTagChannel.didChangeValue(forKey: "channelTags")
                        }
                        
                    }
                }
            } catch let error as NSError {
                        print("Could not fatch🥺: \(error), \(error.userInfo)")
                        onSuccess(false)
                    }
               
               contextSave { success in
                   onSuccess(success)
               }
    }
    func getTags()->[Tags]{
        var allTags : [Tags]?
        let fetchRequest : NSFetchRequest<Tags> = Tags.fetchRequest()
               do{
                   if let fetchResult : [Tags] = try context?.fetch(fetchRequest){
                   allTags = fetchResult
                   }
               }catch{
                   fatalError("fetch error!")
               }
        return allTags!
    }
    
    func saveTags(name : String, time : Date, onSuccess : @escaping ((Bool)->Void)){
        if let context = context,
        let entity: NSEntityDescription
        = NSEntityDescription.entity(forEntityName: "Tags", in: context) {
            if let tag: Tags = NSManagedObject(entity: entity, insertInto: context ) as? Tags{
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy/MM/dd"
            tag.name = name
            tag.time = time
            tag.formattedDate = dateFormatter.string(from: time)
            contextSave{
                success in onSuccess(success)
            }
            }
        }
    }
    func removeTag(object : NSManagedObject){
        self.context?.delete(object)
        do{
            try self.context!.save()
        }catch{
            fatalError("fetch error!")
        }
        
    }

    func getUpdated()->[LastUpdated]{
        var lastUpdated = [LastUpdated]()
        let fetchRequest : NSFetchRequest<LastUpdated> = LastUpdated.fetchRequest()
               do{
                   if let fetchResult : [LastUpdated] = try context?.fetch(fetchRequest){
                   lastUpdated = fetchResult
                   }
               }catch{
                   fatalError("fetch error!")
               }
        return lastUpdated
    }
    func saveUpdated(date: String, onSuccess : @escaping ((Bool)->Void)){
            if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: "LastUpdated", in: context) {
                if let lastUpdate: LastUpdated = NSManagedObject(entity: entity, insertInto: context ) as? LastUpdated{
                    lastUpdate.date = date
                contextSave{
                    success in onSuccess(success)
                }
            }
        }
    }
    func saveToken(token: String, onSuccess : @escaping ((Bool)->Void)){
        if let context = context, let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: "Token", in: context){
            if let Token: Token = NSManagedObject(entity: entity, insertInto: context) as? Token{
                Token.name = token
            contextSave{
                success in onSuccess(success)
                }
            }
        }
    }
    func getToken()->String{
        //let dateFormatter = DateFormatter()
        var userToken = [Token]()
        let fetchRequest : NSFetchRequest<Token>  = Token.fetchRequest()
        do{
            if let fetchResult : [Token] = try context?.fetch(fetchRequest){
            userToken = fetchResult
            }
        }catch{
            fatalError("fetch error!")
        }
        return userToken[0].name!
    }
    
    func setData() {
        var lastUpdated = CoreDataManager.shared.getUpdated()
        let dateFormatter = DateFormatter()
        
        if(lastUpdated.count == 0){
            let dateNow = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            dateFormatter.dateFormat = "yyyy/MM/dd"
            
            CoreDataManager.shared.saveChannels(title: "전체",subtitle: "전체", source: "전체",color: .second,  channelTags:["대회", "모집","채용","장학금"], group: "전체", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "공지사항게시판",subtitle: "공지사항", source: "학생생활관", color: .third, channelTags: [""], group: "학생생활관", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "모집안내게시판",subtitle: "모집안내", source: "학생생활관", color: .third, channelTags: [""], group: "학생생활관", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "공지사항게시판",subtitle: "공지사항", source: "기계공학부",color: .first,  channelTags: [""], group: "학부사이트", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "학사일반게시판",subtitle: "학사일반", source: "컴퓨터소프트웨어학부",color: .first,  channelTags: [""], group: "학부사이트", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "취업정보게시판",subtitle: "취업정보", source: "컴퓨터소프트웨어학부",color: .first,  channelTags: [""], group: "학부사이트", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "공지사항게시판",subtitle: "공지사항", source: "경영학부",color: .first,  channelTags: [""], group: "학부사이트", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "학사게시판",subtitle: "학사", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "입학게시판",subtitle: "입학", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "모집/채용게시판",subtitle: "모집/채용", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "사회봉사게시판",subtitle: "사회봉사", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "일반게시판",subtitle: "일반", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "산학/연구게시판",subtitle: "산학/연구", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "행사게시판",subtitle: "행사", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "장학게시판",subtitle: "장학", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveChannels(title: "학회/세미나게시판",subtitle: "학회/세미나", source: "한양대학교", color: .fourth, channelTags: [""], group: "한양대학교", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveTags(name: "대회", time: dateNow!){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveTags(name: "모집", time: dateNow!){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveTags(name: "채용", time: dateNow!){ onSuccess in print("saved = \(onSuccess)")}
            CoreDataManager.shared.saveTags(name: "장학금", time: dateNow!){ onSuccess in print("saved = \(onSuccess)")}
            
            dateFormatter.dateFormat = "yy-MM-dd"
            CoreDataManager.shared.saveUpdated(date: "20-06-11"){ onSuccess in } //print("saved = \(onSuccess)")
            lastUpdated = CoreDataManager.shared.getUpdated()
        }
        let tags = CoreDataManager.shared.getTags()
       let url = URL(string:"https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/" + lastUpdated[0].date!)
        do {
            let data = try Data(contentsOf: url!)
            let cardsData = getCards()
            let json = try! JSONSerialization.jsonObject(with:data, options:[]) as! [String:Any]
            let body = json["body"] as! String
            let dataInBody = body.data(using: .utf8)!
            let arr = try! JSONSerialization.jsonObject(with: dataInBody, options: []) as! [String:Any]
            let messages = arr["message"] as! [[String:Any]]
            for message in messages {
                let card = message

                var json_:[String:String] = ["":""]
                var json_String = card["json_"] as! String
                if(json_String != ""){
                    json_String = json_String.slice(from: ":\"", to: "\"}]")!
                    json_ = ["GongjiSeq":json_String]
                }
                
                let cardURL = card["url"] as! String
                
                let checkRedundancy = cardsData.filter({ (data) -> Bool in
                    return ((data.url == cardURL) && (data.json!["GongjiSeq"] == json_["GongjiSeq"]))
                })
                
                if (checkRedundancy.count == 0)
                {
                    var color = UIColor()
                    switch card["source"] as! String{
                    case "한양대학교":
                        color = UIColor.fourth
                    case "기계공학부":
                        color = UIColor.first
                    case "컴퓨터소프트웨어학부":
                        color = UIColor.first
                    case "경영학부":
                        color = UIColor.first
                    case "학생생활관":
                        color = UIColor.third
                    default:
                        color = UIColor.fifth
                    }
                    
                    dateFormatter.dateFormat = "yy-MM-dd"
                    let cardTitle = card["title"] as! String
                    var tag = [""]
                    for tagNum in 0..<tags.count{
                        if(cardTitle.contains(tags[tagNum].name!)){
                            tag.append(tags[tagNum].name!)
                            CoreDataManager.shared.addChannelTag(subtitle: card["category"] as! String, source: card["source"] as! String, tag: tags[tagNum].name!){ onSuccess in print("saved = \(onSuccess)")}
                        }
                    }
                    CoreDataManager.shared.saveCards(title: card["title"] as! String, source: card["source"] as! String, category: card["category"] as! String, tag: tag, time: dateFormatter.date(from: card["time_"] as! String)!, color: color, isVisited: false, url: cardURL, json : json_, isFavorite: false){ onSuccess in } //print("saved = \(onSuccess)")
                }
            }
        dateFormatter.dateFormat = "yy-MM-dd"
        CoreDataManager.shared.saveUpdated(date: dateFormatter.string(from: Date())){ onSuccess in }
            
        } catch {
            print("Can't get url")
        }
    }
}
    
extension CoreDataManager {
    fileprivate func filteredRequest(url: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        fetchRequest.predicate = NSPredicate(format: "url = %@", NSString(string: url))
        return fetchRequest
    }
    
    fileprivate func filteredChannel(subtitle: String, source: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: "Channel")
        fetchRequest.predicate = NSPredicate(format: "subtitle = %@ AND source = %@", NSString(string: subtitle),NSString(string: source))
        return fetchRequest
    }
    fileprivate func contextSave(onSuccess: ((Bool) -> Void)) {
        do {
            try context?.save()
            onSuccess(true)
        } catch let error as NSError {
            print("Could not save🥶: \(error), \(error.userInfo)")
            onSuccess(false)
        }
    }
}
