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

        print(colorString)
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
        print(floatValue)
        return floatValue
    }
    func hexStringFromColor(color: UIColor) -> String {
       let components = color.cgColor.components
       let r: CGFloat = components?[0] ?? 0.0
       let g: CGFloat = components?[1] ?? 0.0
       let b: CGFloat = components?[2] ?? 0.0

       let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
       print(hexString)
       return hexString
    }
    //sort!!
    func getCards()->[Card]{
        //cards.sort {(obj1, obj2) -> Bool in
          //  return obj1.time > obj2.time
        //}
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
    
    func saveCards(title : String,  channelName : String, category : String, tag : [String], time : Date, color : UIColor, isVisited: Bool, url : String, json : [String:String], onSuccess :@escaping ((Bool)->Void)){
        if let context = context,
            let entity: NSEntityDescription
            = NSEntityDescription.entity(forEntityName: "Card", in: context) {
            
            if let cards: Card = NSManagedObject(entity: entity, insertInto: context ) as? Card {
                cards.title = title
                cards.category = category
                cards.channelName = channelName
                cards.tag = tag //as NSObject
                cards.time = time
                cards.color
                    = hexStringFromColor(color: color)
                cards.isVisited = isVisited
                cards.url = url
                cards.json = json //as NSObject
                cards.source = cards.category! + ((cards.category!.count == 0) ? "" : "-") + cards.channelName!
                
               let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yy-MM-dd"
                // 임시로 보여주기 위해 선언함
                cards.homeFormattedDate = dateFormatter.string(from: time)
                dateFormatter.dateFormat = "M.d"
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
        var visitedCard = Card()
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
    
    
    func getChannels()->[Channel]{
        //let dateFormatter = DateFormatter()
        var channels = [Channel]()
        let fetchRequest : NSFetchRequest<Channel>  = Channel.fetchRequest()
        do{
            if let fetchResult : [Channel] = try context?.fetch(fetchRequest){
            channels = fetchResult
            }
        }catch{
            fatalError("fetch error!")
        }
        return channels
    }
   
    func saveChannels(title : String, subtitle :String, category : String, color : UIColor, channelTags : [String], source : String, isSubscribed : Bool  ,onSuccess : @escaping ((Bool)->Void)){
        if let context = context,
        let entity: NSEntityDescription
        = NSEntityDescription.entity(forEntityName: "Channel", in: context) {
        
        if let channels: Channel = NSManagedObject(entity: entity, insertInto: context ) as? Channel {
            channels.title = title
            channels.subtitle = subtitle
            channels.category = category
            channels.color = hexStringFromColor(color: color)
            channels.source = source
            channels.channelTags = channelTags
            channels.alarm = false
            channels.isSubscribed = isSubscribed
            contextSave{
                success in onSuccess(success)
            }
            }
        }
    }
    func getTags()->[Tags]{
        var allTags = [Tags]()
        let fetchRequest : NSFetchRequest<Tags> = Tags.fetchRequest()
               do{
                   if let fetchResult : [Tags] = try context?.fetch(fetchRequest){
                   allTags = fetchResult
                   }
               }catch{
                   fatalError("fetch error!")
               }
        return allTags
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
    /*func httpRequest(_sender : Any){
        let api = strUrl + " json"
        let encoding = api.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: encoding!)
    }*/
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
    
    func setData() -> Bool{
        var lastUpdated = CoreDataManager.shared.getUpdated()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yy-MM-dd"
        if(lastUpdated.count == 0){
            let dateNow = Calendar.current.date(byAdding: .day, value: -1, to: Date())
            CoreDataManager.shared.saveUpdated(date: dateFormatter.string(from: dateNow!)){ onSuccess in } //print("saved = \(onSuccess)")
            lastUpdated = CoreDataManager.shared.getUpdated()
        }
        
        let url = URL(string:"https://wdjzl50cnh.execute-api.ap-northeast-2.amazonaws.com/RDS/" + lastUpdated[lastUpdated.count - 1].date!)
        print(lastUpdated[lastUpdated.count - 1].date)
       
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

                let json_:[String:String] = ["":""]
                if(card["json_"] != nil){
                    
                }
                
                let cardURL = card["url"] as! String
                
                let checkRedundancy = cardsData.filter({ (data) -> Bool in
                    return (data.url == cardURL) && (data.json == json_)
                })
                
                if (checkRedundancy.count == 0)
                {
                    let time = card["time_"] as! String
                    var color = UIColor()
                    switch card["source"] as! String{
                    case "한양포털":
                        color = UIColor.first
                    case "기계공학부":
                        color = UIColor.second
                    case "컴퓨터소프트웨어학부":
                        color = UIColor.third
                    case "경영학부":
                        color = UIColor.fourth
                    default:
                        color = UIColor.fifth
                    }
                    
                    dateFormatter.dateFormat = "yy-MM-dd"
                    CoreDataManager.shared.saveCards(title: card["title"] as! String, channelName: card["source"] as! String, category: card["category"] as! String, tag: [""], time: dateFormatter.date(from: card["time_"] as! String)!, color: color, isVisited: false, url: cardURL, json : json_){ onSuccess in } //print("saved = \(onSuccess)")
                }
            }
        dateFormatter.dateFormat = "yy-MM-dd"
        CoreDataManager.shared.saveUpdated(date: dateFormatter.string(from: Date())){ onSuccess in }
        } catch {
            print("Can't get url")
        }
        dateFormatter.dateFormat = "yyyy/MM/dd"
        CoreDataManager.shared.saveChannels(title: "전체",subtitle: "전체", category: "", color: .sourceFont, channelTags: ["대회","모집"], source: "..", isSubscribed: true){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveChannels(title: "학사게시판",subtitle: "학사", category:  "포털", color: .fourth, channelTags: [], source: "포털", isSubscribed: false){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveChannels(title: "장학게시판",subtitle: "장학", category:  "포털",color: .third,  channelTags: ["장학금"], source: "포털", isSubscribed: false){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveChannels(title: "학사일반게시판",subtitle: "학사일반", category: "컴퓨터소프트웨어대학",color: .first, channelTags: ["대회","모집"], source: "학부사이트", isSubscribed: false){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveChannels(title: "취업정보게시판",subtitle: "취업정보", category: "컴퓨터소프트웨어대학",color: .second, channelTags: ["모집","채용"], source: "학부사이트", isSubscribed: false){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveChannels(title: "test", subtitle: "check", category: "경영대학", color: .second, channelTags: [], source: "학부사이트", isSubscribed: false){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveTags(name: "대회", time: dateFormatter.date(from: "2020-05-12")!){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveTags(name: "모집", time: dateFormatter.date(from: "2020-05-11")!){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveTags(name: "채용", time: dateFormatter.date(from: "2020-05-14")!){ onSuccess in print("saved = \(onSuccess)")}
        CoreDataManager.shared.saveTags(name: "장학금", time: dateFormatter.date(from: "2020-05-13")!){ onSuccess in print("saved = \(onSuccess)")}
        
        return true;
    }
    /*init(){
     
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        self.saveCards(title:"제18회 임베디드SW경진대회 공고", channelName:  "컴퓨터소프트웨어대학", category: "학사일반게시판", tag:["대회"], time: dateFormatter.date(from: "2020-05-14 01:21")!, color: UIColor.first, isVisited: true, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28898&page=1&code=notice", json: ["":""])
        self.saveCards(title:"2020학년도 2학기 재입학 신청 안내", channelName: "컴퓨터소프트웨어대학", category: "학사일반게시판", tag:[], time: dateFormatter.date(from: "2020-05-17 16:20")!, color: UIColor.first, isVisited: true, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28892&page=1&code=notice", json: ["":""])
        self.saveCards(title:"[KAIST] 2020년 몰입캠프 여름학기 모집", channelName: "컴퓨터소프트웨어대학", category: "학사일반게시판",tag:["모집"], time:  dateFormatter.date(from: "2020-05-17 20:14")!, color: UIColor.first, isVisited: true, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28891&page=1&code=notice", json: ["":""])
        self.saveCards(title:"2020학년도 여름계절학기 수강신청 안내", channelName: "컴퓨터소프트웨어대학", category: "학사일반게시판",tag:["수강신청"], time:  dateFormatter.date(from: "2020-05-11 14:12")!, color: UIColor.first, isVisited: true, url:"http://cs.hanyang.ac.kr/board/info_board.php?ptype=view&idx=28890&page=1&code=notice", json: ["":""])
        self.saveCards(title:"[NCSOFT] 2020 SUMMER INTERN 공개모집 (~5/21)", channelName: "컴퓨터소프트웨어대학", category: "취업정보게시판",tag: ["모집"], time:  dateFormatter.date(from: "2020-05-17 18:22")!, color: UIColor.second, isVisited: false, url:"http://cs.hanyang.ac.kr/board/job_board.php?ptype=view&idx=28897&page=1&code=job_board", json: ["":""])
        self.saveCards(title:"파이썬마스터 자격검정 안내", channelName: "컴퓨터소프트웨어대학", category: "취업정보게시판", tag:[], time:  dateFormatter.date(from: "2020-05-14 12:12")!, color: UIColor.second, isVisited: false, url:"http://cs.hanyang.ac.kr/board/job_board.php?ptype=view&idx=28896&page=1&code=job_board", json: ["":""])
        self.saveCards(title:"2020년 상반기 KB국민은행 신입행원(L1) 수시채용", channelName: "컴퓨터소프트웨어대학", category: "취업정보게시판",tag:["채용"], time:  dateFormatter.date(from: "2020-05-18 10:45")!, color: UIColor.second, isVisited: false, url:"http://cs.hanyang.ac.kr/board/job_board.php?ptype=view&idx=28895&page=1&code=job_board", json: ["":""])
        self.saveCards(title:"2020-2학기 1차 국가근로장학금 학생신청기간 안내", channelName: "포털", category: "장학게시판",tag:["장학금"], time:  dateFormatter.date(from: "2020-05-18 17:50")!, color: UIColor.third, isVisited: true, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a", json: ["gongjiSeq":"15689"])
        self.saveCards(title:"대운동장 인조잔디구장 및 지하주차장 사용 안내", channelName: "포털", category: "학사게시판", tag:[], time:  dateFormatter.date(from: "2020-05-18 14:40")!, color: UIColor.fourth, isVisited: false, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a", json: ["gongjiSeq":"15688"])
        self.saveCards(title:"2020년도 상반기 울산광역시 대학생 학자금대출 이자지원 사업 신청 안내", channelName: "포털", category: "장학게시판", tag:[], time:  dateFormatter.date(from: "2020-05-18 11:10")!, color: UIColor.third, isVisited: false, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a" , json: ["gongjiSeq":"15686"])
        self.saveCards(title:"2020-1학기 국가장학금1유형 지급(3차 지급실행) 예정 안내", channelName: "포털", category: "장학게시판", tag:["장학금"], time: dateFormatter.date(from: "2020-05-18 10:20")!, color:UIColor.third, isVisited: false, url:"https://portal.hanyang.ac.kr/GjshAct/findGongjisahangs.do?pgmId=P308200&menuId=M006263&tk=0be29593626429dfc3f1b618045bc8172b86832df0d333bc0f5db47199b9028a", json: ["gongjiSeq":"15685"])
        self.saveCards(title:"장학", channelName: "", category: "", tag :[], time:dateFormatter.date(from : "2020-05-18 17:10")!, color:UIColor.first, isVisited: false, url:"", json:["":""])
        dateFormatter.dateFormat = "yyyy/MM/dd"
        self.saveChannels(title: "전체",subtitle: "전체", category: "", color: .sourceFont, channelTags: ["대회","모집"])
        self.saveChannels(title: "학사게시판",subtitle: "학사", category:  "포털", color: .fourth, channelTags: [] )
        self.saveChannels(title: "장학게시판",subtitle: "장학", category:  "포털",color: .third,  channelTags: ["장학금"])
        self.saveChannels(title: "학사일반게시판",subtitle: "학사일반", category: "컴퓨터소프트웨어대학",color: .first, channelTags: ["대회","모집"])
        self.saveChannels(title: "취업정보게시판",subtitle: "취업정보", category: "컴퓨터소프트웨어대학",color: .second, channelTags: ["모집","채용"])
        self.saveTags(name: "대회", time: dateFormatter.date(from: "2020-05-12")!)
        self.saveTags(name: "모집", time: dateFormatter.date(from: "2020-05-11")!)
        self.saveTags(name: "채용", time: dateFormatter.date(from: "2020-05-14")!)
        self.saveTags(name: "장학금", time: dateFormatter.date(from: "2020-05-13")!)
    }*/
}
    
extension CoreDataManager {
    fileprivate func filteredRequest(url: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult>
            = NSFetchRequest<NSFetchRequestResult>(entityName: "Card")
        fetchRequest.predicate = NSPredicate(format: "url = %@", NSString(string: url))
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

