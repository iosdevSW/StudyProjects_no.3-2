//
//  MemoFormVC.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/08.
//

import UIKit

class MemoFormVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextViewDelegate {
    var subject: String! //내용에서 첫 줄을 추출한 값을 저장하는 변수
    lazy var dao = MemoDAO()
    
    @IBOutlet weak var contents: UITextView!
    @IBOutlet weak var preview: UIImageView!
    
    override func viewDidLoad() {
        self.contents.delegate = self
        
        let bgImage = UIImage(named: "memo-background.png")!
        self.view.backgroundColor = UIColor(patternImage: bgImage)
        
        self.contents.layer.borderWidth = 0
        self.contents.layer.borderColor = UIColor.clear.cgColor
        self.contents.backgroundColor = .clear
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 9 //이미지 사진에 맞춰 줄간격 설정.
        self.contents.attributedText = NSAttributedString(string: " ", attributes: [.paragraphStyle: style])
        self.contents.text = ""
    }
    //MARK: IBAction
    @IBAction func save(_ sender: Any) {
        let alertV = UIViewController()
        let iconImage = UIImage(named: "warning-icon-60")
        alertV.view = UIImageView(image: iconImage)
        alertV.preferredContentSize = iconImage?.size ?? CGSize.zero
        
        //내용이 입력되지 않았을 경우 경고한다.
        guard self.contents.text?.isEmpty == false else {
            let alert = UIAlertController(title: "nil", message: "내용을 입력해주세요.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default)
            alert.addAction(action)
            alert.setValue(alertV, forKey: "contentViewController")
            self.present(alert, animated: true)
            return
        }
        // MemoData객체 생성하고 데이터를 담는다.
        let data = MemoData()
        data.title = self.subject // 제목
        data.contents = self.contents.text // 내용
        data.image = self.preview.image //이미지
        data.regdate = Date() // 작성 시각
        
//        //앱 델리게이트 객체를 불러 온 후 memolist 배열에 memodata 객체 추가
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.memolist.append(data)
        
        self.dao.insert(data) // 코어데이터에 메모 데이터 추가
        
        // 작성폼 종료 이전 화면으로 전환
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pick(_ sender: Any) {
        let picker = UIImagePickerController() // UIImagePickerControllerDelegate UINavigationControllerDelegate 채택 필요
        let alert = UIAlertController(title: "", message: "이미지를 가져올 곳을 선택해주세요.", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "카메라", style: .default){_ in
            picker.sourceType = .camera
            self.present(picker, animated: false)
        }
        let photoLibrayAction = UIAlertAction(title: "사진 라이브러리", style: .default){ _ in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: false)
        }
        let savedPhotoAlbumAction = UIAlertAction(title: "저장 앨범", style: .default){ _ in
            picker.sourceType = .savedPhotosAlbum
            self.present(picker, animated: false)
        }
        
        alert.addAction(cameraAction)
        alert.addAction(photoLibrayAction)
        alert.addAction(savedPhotoAlbumAction)
        picker.delegate = self
        picker.allowsEditing = true // 이미지 편집 허용
        
        self.present(alert, animated: false)
        
    }
    //MARK: delegateMethod
    
    //사용자가 이미지를 선택하면 자동으로 이 메소드가 호출
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.preview.image = info[.editedImage] as? UIImage // 선택(편집완료된)이미지를 미리보기에 출력
        
        picker.dismiss(animated: false)
    }
    
    //내용이 변경될 때 마다 호출
    func textViewDidChange(_ textView: UITextView) {
        let contents = textView.text as NSString // textView 내용 추출
        let length = ( (contents.length > 15) ? 15 : contents.length) // 15글자까지 추출
        self.subject = contents.substring(with: NSRange(location: 0, length: length) ) // 제목을 subject에 저장
        
        self.navigationItem.title = self.subject // 네비게이션 제목으로 출력
    }
    
    //화면 터치시 네비게이션바 토글작용
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let bar = self.navigationController?.navigationBar
        
        let ts = TimeInterval(0.3)
        UIView.animate(withDuration: ts){
            bar?.alpha = ( bar?.alpha == 0 ? 1 : 0)
        }
        
    }

}
