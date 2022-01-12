//
//  MemoData.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/08.
//

import UIKit
import CoreData

// 데이터 모델링
class MemoData {
    var memoIdx : Int? // 데이터 식별값
    var title : String? // 메모 제목
    var contents : String? // 메모 내용
    var image : UIImage? // 이미지
    var regdate : Date? // 작성일
    var objectID : NSManagedObjectID? // 원본 MemoMO 객체를 참조하기 위한 속성
}
