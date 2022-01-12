//
//  MemoDAO.swift
//  MyMemory
//
//  Created by 신상우 on 2021/12/10.
//

import UIKit
import CoreData

class MemoDAO {
    lazy var context: NSManagedObjectContext = { // 관리 객체 컨텍스트
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    func fetch(keyword text: String? = nil) -> [MemoData]{ // 저장된 메모 전체를 불러오는 메소드
        var memolist = [MemoData]()
        // 1.요청 객체 생성
        // 타입 어노테이션 생략시 오류! NSManagedObject와 NSFetchRequest 둘 다 fetchRequest메소드를 가지고 있는데
        // 둘은 오버라이드관계도 아니고 서로 다른 타입을 반환하기때문에 컴파일 오류가 발생하므로 꼭 타입을 명시해주어야 한다.
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        // 1-1. 최신 글 순으로 정렬하도록 정렬 객체 생성
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        
        // 1-2. 검색 키워드가 있을 경우 검색 조건 추가
        if let t = text, t.isEmpty == false {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t) // 대소문자 구분x t가 들어간 메모
        }
        
        do {
            let resultset = try self.context.fetch(fetchRequest)
            
            //2. 읽어온 데이터 집합을 순회하면서 [MemoData] 타입으로 변환
            for record in resultset {
                // 3. MemoData 객체를 생성한다.
                let data = MemoData()
                
                // 4. MemoMO 프로퍼티 값을 MemoData의 프로퍼티로 복사한다.
                data.title = record.title
                data.contents = record.contents
                data.regdate = record.regdate
                data.objectID = record.objectID
                
                // 4-1. 이미지가 있을 때에만 복사
                if let image = record.image as Data? {
                    data.image = UIImage(data: image)
                }
                //MemoData객체를 memolist배열에 추가한다.
                memolist.append(data)
            }
        } catch let e as NSError {
            NSLog("An error has occurred : %s",e.localizedDescription )
        }
        return memolist
    }
    
    //새 메모를 저장하는 insert 메소드
    func insert(_ data: MemoData) {
        // 1. 관리 객체 인스턴스 생성
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        
        // 2. MemoData로부터 값을 복사한다.
        object.title = data.title
        object.contents = data.contents
        object.regdate = data.regdate!
        
        if let image = data.image {
            object.image = image.pngData()! // 코어 데이터는 UIImage타입을 지원하지 않기떄문에 데이터 타입으로 변환하여 저장
        }
        
        // 3. 영구 저장소에 변경 사항을 반영한다.
        do {
            try self.context.save()
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
        }
    }
    
    //메모 내용을 삭제하기위한 delete 메소드
    func delete(_ objectID: NSManagedObjectID) -> Bool {
        //삭제할 객체를 찾아 컨텍스트에서 삭제한다.
        let object = self.context.object(with: objectID)
        self.context.delete(object)
        
        //삭제된 내역을 영구 저장소에 저장한다.
        do {
            try self.context.save()
            return true
        } catch let e as NSError {
            NSLog("An error has occurred : %s", e.localizedDescription)
            return false
        }
    }
}
