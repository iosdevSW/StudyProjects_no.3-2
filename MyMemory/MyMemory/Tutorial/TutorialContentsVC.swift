//
//  TutorialContentsVC.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/27.
//

import UIKit
class TutorialContentsVC: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
 
    var pageIndex: Int!
    var titleText: String!
    var imageFile: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgImageView.contentMode = .scaleAspectFill
        
        //전달받은 타이틀 정보를 레이블 객체에 대입하고 크기 조절
        self.titleLabel.text = self.titleText
        self.titleLabel.sizeToFit()
        
        self.bgImageView.image = UIImage(named: self.imageFile)
    }
}
