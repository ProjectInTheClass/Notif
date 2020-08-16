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

class detailViewController: UIViewController, UIScrollViewDelegate{
    
    var title2: String?
    var source: String?
    var date: String?
    var back2: String?
    var url: String?
    var json = [String:String]()
    


    @IBOutlet weak var URLTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self

        
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.backBarButtonItem?.title = back2
        
        
        titleLabel.text = title2
        sourceLabel.text = source
        dateLabel.text = date
//        URLTextView.dataDetectorTypes = .link
//        URLTextView.isEditable = false
//        URLTextView.isUserInteractionEnabled = true
//        URLTextView.isSelectable = true
        
        URLTextView.text = url!
        URLTextView.textContainer.maximumNumberOfLines = 1
        URLTextView.textContainer.lineBreakMode = .byTruncatingTail
        
        titleView.layer.masksToBounds = false
        titleView.layer.shadowColor = UIColor.gray.cgColor
        titleView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        titleView.layer.shadowOpacity = 0.5
        titleView.layer.shadowRadius = 0
        //contentView.backgroundColor = .white
//        contentTextView.backgroundColor = .white
        
        activityIndicator.startAnimating()
        getContent()
        
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func getContent() {
        guard let url2 = URL(string: url!) else {return }
        var request = URLRequest(url: url2)
     
        request.httpMethod = "get"
        
        let session = URLSession.shared
        //URLSession provides the async request
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
                if (self.source!.contains("학생생활관")) {
                    dataString = dataString.slice(from: "<div class=\"cnt\">", to: "<div class=\"btn_area clearfix\">") ?? dataString
                    
                    let enddivIndices = dataString.ranges(of: "</div>")
                    
                    if let lastIndex = enddivIndices.last {
                        dataString = String(dataString[enddivIndices.first!.lowerBound...lastIndex.upperBound])
                    }
                    
                }
                else if (self.source!.contains("한양대학교")) {
                    dataString = dataString.slice(from: "<td class=\"view-script\">", to: "<div class=\"bbs-button-wrap container\">") ?? dataString
                     
                     let endtdIndices = dataString.ranges(of: "</td>")

                    if let lastIndex = endtdIndices.last {
                        dataString = String(dataString[..<lastIndex.upperBound])
                    }
                     
                     var imageIndices = dataString.indices(of: "/documents")
                     imageIndices.reverse()
                     for i in imageIndices {
                         dataString.insert(contentsOf: "https://www.hanyang.ac.kr", at: i)
                     }
                }
                else if (self.source!.contains("컴퓨터")) {
                    dataString = dataString.slice(from: "<td class=\"view_content\" colspan=\"2\">", to: "<td class=\"tit\">이전글</td>") ?? dataString
                    let endtdIndices = dataString.ranges(of: "</td>")

                    if let lastIndex = endtdIndices.last {
                        dataString = String(dataString[..<lastIndex.upperBound])
                    }
                } else if (self.source!.contains("경영")){
                    dataString = dataString.slice(from: "<td height=\"150\" valign=\"top\" colspan=\"2\" style=\"word-break:break-all; padding:13px;\">", to:"</tr>") ?? dataString
                } else if (self.source!.contains("기계")){
                    dataString = dataString.slice(from: "<div class=\"HTML_CONTENT\">", to:"</div></td>") ?? dataString
                } else if (self.source!.contains("포털")) {
                    dataString = dataString.slice(from: "\"contents\":\"", to: "\",\"haengsaSdt\"") ?? dataString
                    dataString = dataString.replacingOccurrences(of: "\\n", with: "")
                    dataString = dataString.replacingOccurrences(of: "\\\"", with: "\"")
//                    print(dataString)
                    
                }
                DispatchQueue.main.async {
                    let resultString = "<div style=\"font-size:17px; line-height:22px\" >" + dataString + "</div>"
                    let mutableAttributedString = NSMutableAttributedString(attributedString: resultString.htmlToAttributedString!)
                    mutableAttributedString.enumerateAttribute(NSAttributedString.Key.attachment , in: NSMakeRange(0, mutableAttributedString.length) , options: .init(rawValue: 0), using: {(value, range, stop) in
                        if let attachment = value as? NSTextAttachment {
                            let image = attachment.image(forBounds: attachment.bounds, textContainer: NSTextContainer(), characterIndex: range.location)!
                            let maxWidth = self.contentTextView.frame.size.width
                            if image.size.width > maxWidth {
                                let newSize = CGSize(width: maxWidth, height: image.size.height*(maxWidth/image.size.width))
                                let rect = CGRect(origin: CGPoint.zero, size: newSize)
                                
                                UIGraphicsBeginImageContext(newSize)
                                image.draw(in: rect)
                                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                                UIGraphicsEndImageContext()
                                
                                let newAttribute = NSTextAttachment()
                                newAttribute.image = newImage
                                mutableAttributedString.addAttribute(NSAttributedString.Key.attachment, value: newAttribute, range: range)
                            }
                        }
                    })
//                    print(resultString)
                    self.activityIndicator.stopAnimating()
                    self.contentTextView.attributedText = mutableAttributedString
                    self.contentTextView.backgroundColor = .white
                }
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
