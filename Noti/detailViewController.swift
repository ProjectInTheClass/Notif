//
//  detailViewController.swift
//  Noti
//
//  Created by Junroot on 2020/05/13.
//  Copyright © 2020 Junroot. All rights reserved.
//

import UIKit

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

class detailViewController: UIViewController {
    
    var title2: String?
    var source: String?
    var date: String?
    var back2: String?
    var url:String?
    var json = [String:String]()
    
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem?.title = back2
        
        titleLabel.text = title2
        sourceLabel.text = source
        dateLabel.text = date
//        contentTextView.text = url
        
        getContent() {
            dataString, encoding in
            DispatchQueue.main.async {
                
                let resultString = "<div style=\"font-size:17px; line-height:22px\" >" + dataString! + "</div>"
                print(resultString)
                self.contentTextView.attributedText = resultString.htmlToAttributedString
               
            }
        }

        
        
        titleView.layer.masksToBounds = false
        titleView.layer.shadowColor = UIColor.gray.cgColor
        titleView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        titleView.layer.shadowOpacity = 0.5
        titleView.layer.shadowRadius = 0
        
    }

    
    
    func getContent(completion: @escaping (_ dataString:String?, _ encoding:String.Encoding) -> ()) {
        guard let url2 = URL(string: url!) else {return }
        var request = URLRequest(url: url2)
        if (self.source!.hasPrefix("학부")) {
            request.httpMethod = "get"
        } else if (self.source!.hasPrefix("포털")) {
            request.httpMethod = "post"
            request.setValue("application/json+sua; charset=UTF-8", forHTTPHeaderField: "Content-Type")
            request.setValue("https://portal.hanyang.ac.kr", forHTTPHeaderField: "Origin")
            request.setValue("ipSecGb=MQ%3D%3D; savedUserId=anVucm9vdDA5MDk%3D; WMONID=GQOvjLQn9EC; HYIN_JSESSIONID=3_IwslGjnw3_Ofp8I2LXCV8auS-tSHEMCKsQzPxJneE2XU8cBZzw!-1281175488!-1914115946; newLoginStatus=PORTALb4517457-3799-48ce-9dd3-fb2619fc1732; COM_JSESSIONID=duowsmgywu9ar1zEuMs9bakyUMJ2C-wHQAIJpexCjUCLj-aEIaC0!1301282226!777610703; _SSO_Global_Logout_url=get%5Ehttps%3A%2F%2Fportal.hanyang.ac.kr%2Flgot.do%24get%5Ehttps%3A%2F%2Fportal.hanyang.ac.kr%2Fhaksa%2Flgot.do%24; HAKSA_JSESSIONID=VWowsm6h-q30k6CTLq0FspImm0n8MCr_gxL0HG_BDxOsPDr33toz!1933421118!-968664353", forHTTPHeaderField: "Cookie")
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            request.httpBody = jsonData
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }

            var encoding = String.Encoding.utf8
            if let response = response as? HTTPURLResponse {
//                print("Response HTTP Status code: \(response.statusCode)")
                if (response.textEncodingName == "euc-kr") {
                    encoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(0x0422))
                }
            }
            // Convert HTTP Response Data to a simple String
            if let data = data, var dataString = String(data: data, encoding: encoding) {
                
//                print("Response data string:\n \(dataString)")
                if (self.source!.hasPrefix("학부")) {
                    dataString = dataString.slice(from: "<td class=\"view_content\" colspan=\"2\">", to: "<td class=\"tit\">이전글</td>")!
                    let endtdIndices = dataString.ranges(of: "</td>")

                    if let lastIndex = endtdIndices.last {
                        dataString = String(dataString[..<lastIndex.upperBound])
                    }
                } else if (self.source!.hasPrefix("포털")) {
                    dataString = dataString.slice(from: "\"contents\":\"", to: "\",\"haengsaSdt\"")!
                    dataString = dataString.replacingOccurrences(of: "\\n", with: "")
                    dataString = dataString.replacingOccurrences(of: "\\\"", with: "\"")
//                    print(dataString)
                    
                }
                completion(dataString,encoding)
            }
            
        }
        
        task.resume()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
