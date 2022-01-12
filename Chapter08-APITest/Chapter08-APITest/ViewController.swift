//
//  ViewController.swift
//  Chapter08-APITest
//
//  Created by 신상우 on 2022/01/11.
//

// 간단한 실습용!!
// 앱이 HTTP 프로토콜을 사용하는 외부 서버와 통신하기 위해 info.plist에서 ATS를 설정해주어야함.
// ( App Transport Security Settings - Allow Arbitrary Loads: YES ) 둘 다 추가.
// 서버가 HTTPS 프로토콜을 사용한다면 보안상 안전하여 ATS 설정을 안해도 된다.
// IP기반의 주소를 써도 안해도 되지만 서버 증설이나 장애시 대처가 어려워 실제 서비스에선 사용 안한다.


/* 데이터 호출 구문
 Data(contentOf:) base64 인코딩된 문자열 ( 이미지 같은 바이너리데이터)
 Stirng(contentOf:) 일반 문자열
 NSString(contentOf:) 한글,한자 등 2바이트를 사용하는 언어가 포함되어 있을때 UTF-8(등으로 인코딩을 지정할 필요가 있을 때)
 */
import UIKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var currentTime: UILabel!
    @IBOutlet weak var userId: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var responseView: UITextView!
    
    //MARK: - 코코아 터치 프레임워크 기본 라이브러리 이용
    //GET 방식
    @IBAction func callCurrentTime(_ sender: Any) {
        // 1. URL설정 및 GET 방식으로 API 호출
        do {
            let url = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/currentTime")
            
            let response = try String(contentsOf: url!)
            
            // 2. 읽어온 값을 레이블에 표시
            self.currentTime.text = response
            self.currentTime.sizeToFit() // 사이즈 재조정
            self.currentTime.center = CGPoint( // 위치 재조정
                x: self.view.frame.width / 2,
                y: self.currentTime.frame.midY)
        } catch let e as NSError {
            print(e.localizedDescription)
        }
    }
    
    //POST방식
    @IBAction func post(_ sender: Any) {
        // 1. 전송할 값 준비
        let userId = (self.userId.text)!
        let name = (self.name.text)!
        let param = "userId=\(userId)&name=\(name)"
        let paramData = param.data(using: .utf8) // 공백,한글,문장보호 등 일부 문자는 변형 될 수 있으므로 인코딩 해주어야한다.
        
        // 2. URL 객체 정의
        let url = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/echo")
        
        // 3. URLRequest 객체를 정의하고, 요청 내용을 담는다.
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        // 4. HTTP 메시지 헤더 설정
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Length")
        
        // 5. URLSession 객체를 통해 전송 및 응답값 처리 로직 작성
        // HTTP통신은 비동기로 이루어지기 때문에 응답값을 받아 처리할 내용을 클로저 형태로 미리 작성하여 인자값으로 넣어주어야 한다.
        let task = URLSession.shared.dataTask(with: request){ (data,response,error) in
            // 5-1. 서버가 응답이 없거나 통신이 실패한 경우
            if let e = error {
                NSLog("An error has occurred : \(e.localizedDescription)")
                return
            }
            // 5-2. 응답 처리 로직
            /*
             스위프트는 최근 멀티 스레드 프로세싱 강화하면서
             메인 스레드에선 UI관련 서브 스레드에선 비동기 실행 구문 처리하도록 아키텍처를 정리
             여기선 응답받은 내용을 텍스트 뷰에 표시 해야하는데 이는 UI변경에 속하므로 메인 스레드에서 실행.
            */
            DispatchQueue.main.async() {
                do{
                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    guard let jsonObject = object else { return }
                    
                    // JSON 결과값을 추출
                    let result = jsonObject["result"] as? String
                    let timestamp = jsonObject["timestamp"] as? String
                    let userId = jsonObject["userId"] as? String
                    let name = jsonObject["name"] as? String
                    
                    // 결과가 성공일 때에만 텍스트 뷰에 출력
                    if result == "SUCCESS" {
                        self.responseView.text = "아이디 : \(userId!)" + "\n"
                        + "이름 : \(name!)" + "\n"
                        + "응답 결과 : \(result!)" + "\n"
                        + "응답 시간 : \(timestamp!)" + "\n"
                        + "요청 방식 : x-www-form-urlencoded"
                    }
                } catch let e as NSError {
                    print("An error has occurred while parsing JSONObject : \(e.localizedDescription)")
                }
            }
        }
        // 6. POST 전송
        task.resume()
    }
    
    //JSON방식 - 따로 방식이 있는 것은 아니고 POST방식이지만 전송 타입이 JSON타입이다.
    @IBAction func json(_ sender: Any) {
        // 1. 전송할 값 준비
        let userId = (self.userId.text)!
        let name = (self.name.text)!
        let param = ["userId" : userId, "name" : name]
        let paramData = try! JSONSerialization.data(withJSONObject: param, options: [])
        
        // 2. URL 객체 정의
        let url = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/echoJSON")
        
        // 3. URLRequest 객체 정의 및 요청 내용 담기
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.httpBody = paramData
        
        // 4. HTTP 메시지 헤더 설정
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(String(paramData.count), forHTTPHeaderField: "Content-Length")
        
        // 5. URLSession 객체를 통해 전송 및 응답값 처리 로직 작성
        let task = URLSession.shared.dataTask(with: request){ (data,response,error) in
            // 5-1. 서버가 응답이 없거나 통신이 실패한 경우
            if let e = error {
                NSLog("An error has occurred : \(e.localizedDescription)")
                return
            }
            // 5-2. 응답 처리 로직
            DispatchQueue.main.async() {
                do{
                    let object = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                    guard let jsonObject = object else { return }
                    
                    // JSON 결과값을 추출
                    let result = jsonObject["result"] as? String
                    let timestamp = jsonObject["timestamp"] as? String
                    let userId = jsonObject["userId"] as? String
                    let name = jsonObject["name"] as? String
                    
                    // 결과가 성공일 때에만 텍스트 뷰에 출력
                    if result == "SUCCESS" {
                        self.responseView.text = "아이디 : \(userId!)" + "\n"
                        + "이름 : \(name!)" + "\n"
                        + "응답 결과 : \(result!)" + "\n"
                        + "응답 시간 : \(timestamp!)" + "\n"
                        + "요청 방식 : application/json"
                    }
                } catch let e as NSError {
                    print("An error has occurred while parsing JSONObject : \(e.localizedDescription)")
                }
            }
        }
        // 6. POST 전송
        task.resume()
    }
    
    //MARK: - Alamofire 외부 라이브러리 이용
    @IBAction func alamofire(_ sender: Any) {
        // API 기본 호출 기본이 Get
        let url1 = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/currentTime")
        AF.request(url1!).responseString(){ (response) in
            self.currentTime.text = response.value
            
            self.currentTime.sizeToFit() // 사이즈 재조정
            self.currentTime.center = CGPoint( // 위치 재조정
                x: self.view.frame.width / 2,
                y: self.currentTime.frame.midY)
        }
        
        // API POST 방식 ( 전송방식,파라미터,인코딩방법)
        let url2 = URL(string: "http://swiftapi.rubypaper.co.kr:2029/practice/echo")
        let param: [String : String] = ["userId" : "공부공부", "name" : "어렵당어렵당"]
        let request = AF.request(url2!, method: .post, parameters: param, encoding: URLEncoding.httpBody)
        
        request.responseDecodable(of: Dictionary<String, String>.self){ response in
            let result = try! response.result.get()
            print(result["userId"]!)
            print(result["name"]!)
        }
        
    }
    
}

