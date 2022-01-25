//
//  UserInfoManager.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/27.
//

import UIKit
import Alamofire

struct UserInfoKey{ // 저장에 사용할 키
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}

class UserInfoManager{
    var loginId: Int {
        get{
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(v){
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    var account: String? { // 비로그인 시에 nil
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    var name: String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    var profile: UIImage? {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile) {
                return UIImage(data: _profile)
            } else {
                return UIImage(named: "account.jpg") // 이미지가 없을 시 기본이미지
            }
        }
        set(v) {
            if v != nil {
                let ud = UserDefaults.standard
                //UIImage타입은 프로퍼티 리스트에 직접 저장이 안되서 data타입으로 변환 후 저장
                ud.set(v?.pngData(), forKey: UserInfoKey.profile)
                ud.synchronize()
            }
        }
    }
    
    var isLogin: Bool {
        if self.loginId == 0 || self.account == nil {
            return false
        } else {
            return true
        }
    }
    
    func login(account: String, passwd: String, success: (()->Void )? = nil, fail: ((String) -> Void)? = nil){
        // 1. URL과 전송할 값 준비
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account" : account,
            "passwd" : passwd
        ]
        
        // 2. API 호출
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        // 2-2. DecodableType 정의
        struct respo: Decodable {
            let user_id: Dictionary<String,String>
            let resultCode: Int
        }
        
        // 3. API 호출 결과 처리
        call.responseData(){ response in
            switch response.result{
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]{
                    let resultCode = json["result_code"] as! Int
                    if resultCode == 0 { //로그인 성공
                        let user = json["user_info"] as! NSDictionary
                        
                        self.loginId = user["user_id"] as! Int
                        self.account = user["account"] as? String
                        self.name = user["name"] as? String
                        
                        if let path = user["profile_path"] as? String {
                            if let imageData = try? Data(contentsOf: URL(string: path)!) {
                                self.profile = UIImage(data: imageData)
                            }
                        }
                        
                        // 토큰 정보 추출
                        let accessToken = json["access_token"] as! String
                        let refreshToken = json["refresh_token"] as! String
                        
                        //토큰 정보 저장
                        let tk = TokenUtils()
                        tk.save("kr.co.rubypaper.MyMemory", account: "accessToken", value: accessToken)
                        tk.save("kr.co.rubypaper.MyMemory",account: "refreshToken", value: refreshToken)
                        
                        success?()
                    } else { // 로그인 실패
                        let msg = (json["error_msg"] as? String) ?? "로그인이 실패했습니다."
                        fail?(msg)
                    }
                }
                break
            case .failure(let error):
                fail?("잘못된 응답 형식입니다 : \(error)")
                break
            }
        }
    }
    
    func logout(completion: ( ()->Void )? = nil ) {
        // 1. 호출 URL
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        
        // 2. 인증 헤더 구현
        let tokenUtils = TokenUtils()
        let header = tokenUtils.getAuthorizationHeader()
        
        // 3. API 호출 및 응답 처리
        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: header)
        call.responseData() { response in
            switch response.result {
            case .success(_):
                self.deviceLogout()
                break
            case . failure(let error):
                NSLog("error : \(error.localizedDescription)")
                break
            }
            completion?()
        }
    }
    
    func deviceLogout() {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        
        //키 체인에 젖아된 값을 모두 삭제
        let tokenUtils = TokenUtils()
        tokenUtils.delete("kr.co.rubypaper.Mymemory", account: "refreshToken")
        tokenUtils.delete("kr.co.rubypaper.Mymemory", account: "accessToken")
    }
    
    func newProfile(_ profile: UIImage?, success: ( ()->Void )? = nil, fail: ( (String)->Void )? = nil ) {
        // API 호출 URL
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/profile"
        
        // 인증 헤더
        let tk = TokenUtils()
        let header = tk.getAuthorizationHeader()
        
        // 전송할 프로필 이미지
        let profileData = profile!.pngData()?.base64EncodedString()
        let param: Parameters = [ "profile_image" : profileData!]
        
        // 이미지 전송
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header)
        
        call.responseData(){ response in
            switch response.result{
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    let resultCode = json["result_code"] as! Int
                    if resultCode == 0 {
                        self.profile = profile
                        success?()
                    }else {
                        let msg = (json["error_msg"] as? String) ?? "이미지 프로필 변경이 실패했습니다."
                        fail?(msg)
                    }
                }
                break
            case .failure(_):
                fail?("올바른 값이 아닙니다.")
                break
            }
        }
        
    }
}
