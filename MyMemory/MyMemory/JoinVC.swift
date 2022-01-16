//
//  JoinVC.swift
//  MyMemory
//
//  Created by 신상우 on 2022/01/12.
//

import UIKit
import Alamofire

class JoinVC: UIViewController,UITableViewDataSource,UITableViewDelegate {
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView! // 정적인 테이블뷰 만들기
    
    //테이블 뷰에 들어갈 텍스트 필드들
    var fieldAccount: UITextField!
    var fieldPassword: UITextField!
    var fieldName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //프로필 이미지를 둥글게
        self.profile.layer.cornerRadius = self.profile.frame.width / 2
        self.profile.layer.masksToBounds = true
        
        //프로필 이미지에 탭 제스쳐 및 액션 이벤트 설정
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedProfile(_:)))
        self.profile.addGestureRecognizer(gesture)
    }
    
    // 계정 정보 전송 및 응답처리 (API)
    @IBAction func submit(_ sender: Any) {
        // 1. 전달할 값 준비
        // 1-1. 이미지를 Base64 인코딩처리
        let profile = self.profile.image!.pngData()?.base64EncodedString()
        
        // 1-2. 전달값을 Parameters 타입의 객체로 정의
        let param: Parameters = [
            "account" : self.fieldAccount.text!,
            "passwd" : self.fieldPassword.text!,
            "name" : self.fieldName.text!,
            "porfile_image" : profile!
        ]
        
        // 2. API 호출
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/join"
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        struct Json: Decodable {
            let result_code: Int
//            let result: String
            let error_msg: String
//            let user_info: Dictionary<String,String>
        }
        
        // 3. 서버 응답값 처리
        call.responseDecodable(of: Json.self ) { response in
            switch response.result {
            case .success(let value): // 서버 호출 성공
                if value.result_code == 0 { // HTTP Code가 0 이면 정상 알림
                    self.alert("가입이 완료되었습니다.")
                } else { // 그 외에 코드가 오면 오류 경고메세지.
                    self.alert("오류 발생 : \(value.error_msg)")
                }
                break
            case .failure(_): // 서버 호출 실패
                self.alert("서버 호출 과정에서 오류가 발생했습니다.")
                break
            }
        
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 // 정적인 테이블뷰!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let tfFrame = CGRect(x:20, y:0, width: cell.bounds.width - 20, height: 37)
        
        switch indexPath.row {
        case 0 :
            self.fieldAccount = UITextField(frame: tfFrame)
            self.fieldAccount.placeholder = "계정(이메일)"
            self.fieldAccount.borderStyle = .none
            self.fieldAccount.autocapitalizationType = .none
            self.fieldAccount.font = .systemFont(ofSize: 14)
            cell.addSubview(self.fieldAccount)
        case 1 :
            self.fieldPassword = UITextField(frame: tfFrame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.isSecureTextEntry = true
            self.fieldPassword.font = .systemFont(ofSize: 14)
            cell.addSubview(self.fieldPassword)
        case 2 :
            self.fieldName = UITextField(frame: tfFrame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.font = .systemFont(ofSize: 14)
            cell.addSubview(self.fieldName)
        default :
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
   
}
// 이미지 피커 컨트롤러를 구현하는 데에 필요한 프로토콜,메소드
extension JoinVC: UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    
    @objc func tappedProfile(_ sender: Any) {
        let msg = "프로필 이미지를 읽어올 곳을 선택하세요"
        let sheet = UIAlertController(title: msg, message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "취소", style: .cancel))
        sheet.addAction(UIAlertAction(title: "저장된 앨범", style: .default){ (_) in
            self.selectLibrary(src: .savedPhotosAlbum) // 저장된 앨범에서 이미지 선택
        })
        sheet.addAction(UIAlertAction(title: "포토 라이브러리", style: .default){
            (_) in
            self.selectLibrary(src: .photoLibrary) // 포토 라이브러리 이미지 선택하기
        })
        sheet.addAction(UIAlertAction(title: "카메라", style: .default){
            (_) in
            self.selectLibrary(src: .camera) // 카메라에서 이미지 촬영하기
        })
        self.present(sheet, animated: false)
    }
    
    func selectLibrary(src: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(src) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            self.present(picker, animated: false)
        } else {
            self.alert("사용할 수 없는 타입입니다.")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let rawVal = UIImagePickerController.InfoKey.originalImage.rawValue
        if let img = info[UIImagePickerController.InfoKey(rawValue: rawVal)] as? UIImage {
            self.profile.image = img
        }
        self.dismiss(animated: true)
    }
}
