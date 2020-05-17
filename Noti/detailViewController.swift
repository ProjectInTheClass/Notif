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

class detailViewController: UIViewController {
    
    var title2: String?
    var source: String?
    var date: String?
    var back2: String?
    var url:String?
    
    
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
                var slicedString = dataString?.slice(from: "<td class=\"view_content\" colspan=\"2\">", to: "</td>")
                slicedString = "<div style=\"font-size:17px; line-height:22px\" >" + slicedString! + "</div>"
                
                self.contentTextView.attributedText = slicedString!.htmlToAttributedString
               
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
        request.httpMethod = "get"
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
            if let data = data, let dataString = String(data: data, encoding: encoding) {
//                print("Response data string:\n \(dataString)")
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
