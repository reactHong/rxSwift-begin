//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import RxSwift
import SwiftyJSON
import UIKit

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"


class Observable<T> {
    
    private let task: (@escaping (T) -> Void) -> Void
    
    init(_ task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func subscribe(_ f: @escaping (T) -> Void) {
        self.task(f)
    }
}

class ViewController: UIViewController {
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var editView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }

    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        UIView.animate(withDuration: 0.3, animations: { [weak v] in
            v?.isHidden = !s
        }, completion: { [weak self] _ in
            self?.view.layoutIfNeeded()
        })
    }

    private func downloadJson() -> Observable<String?> {
        return Observable() { f in
            DispatchQueue.global().async {
                let url = URL(string: MEMBER_LIST_URL)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                
                DispatchQueue.main.async {
                    f(json)
                }
            }
        }
    }
    
    // MARK: SYNC

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    @IBAction func onLoad() {
        editView.text = ""
        setVisibleWithAnimation(activityIndicator, true)

        let observable: Observable<String?> = self.downloadJson()
        observable.subscribe { json in
            self.editView.text = json
            self.setVisibleWithAnimation(self.activityIndicator, false)
        }
    }
}
