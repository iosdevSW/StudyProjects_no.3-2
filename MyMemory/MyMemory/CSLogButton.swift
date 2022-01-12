//
//  CSLogButton.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/16.
//

import UIKit

public enum CSLogType: Int{
    case basic // 기본 로그타입
    case title // 버튼의 타이틀을 출력
    case tag // 버튼의 태그값을 출력
}

public class CSLogButton: UIButton {
    public var logType: CSLogType = .basic
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        self.tintColor = .white
        
        self.addTarget(self, action: #selector(self.logging(_:)), for: .touchUpInside)
    }
    
    @objc func logging(_ sender: UIButton){
        switch self.logType{
        case .basic:
            NSLog("버튼이 클릭 되었습니다")
        case .title:
            let btnTitle = sender.titleLabel?.text ?? "타이틀이 없는"
            NSLog("\(btnTitle) 버튼이 클릭 되었습니다.")
        case .tag:
            NSLog("\(sender.tag) 버튼이 클릭 되었습니다.")
        }
    }
}
