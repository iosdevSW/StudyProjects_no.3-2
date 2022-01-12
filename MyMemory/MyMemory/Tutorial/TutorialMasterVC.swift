//
//  TutorialMasterVC.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/27.
//

import UIKit

class TutorialMasterVC: UIViewController, UIPageViewControllerDataSource {
    
    var pageVC: UIPageViewController! //페이지 뷰 컨트롤러 인스턴스를 참조할 멤버 변수
    
    //콘텐츠 뷰 컨트롤러에 들어갈 타이틀과 이미지
    var contentTitles = ["STEP 1","STEP 2","STEP 3","STEP 4"]
    var contentImages = ["Page0","Page1","Page2","Page3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 1.페이지 뷰 컨트롤러 생성
        self.pageVC = self.instanceTutorialVC(name: "PageVC") as? UIPageViewController
        self.pageVC.dataSource = self
        
        // 2.페이지 뷰 컨트롤러의 기본 페이지 지정
        let startContentVC = self.getContentsVC(atIndex: 0)! // 최초로 노출될 페이지
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true)
        
        // 3. 페이지 뷰 컨트롤러를 마스터 뷰 컨트롤러의 자식 뷰 컨트롤러로 설정
        self.pageVC.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageVC.view.frame.size.width = self.view.frame.width
        self.pageVC.view.frame.size.height = self.view.frame.height - 80
        
        //4. 페이지 뷰 컨트롤러를 마스터 뷰 컨트롤러의 자식 뷰 컨트롤러로 지정
        self.addChild(self.pageVC)
        self.view.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParent: self)
    }
    
    //콘텐츠 뷰 컨트롤러를 동적으로 생성할 메소드
    func getContentsVC(atIndex idx: Int) -> UIViewController? {
        //인덱스가 데이터 배열을 초고화면 nil 반환
        guard self.contentTitles.count >= idx && self.contentImages.count > 0 else { return nil}
        
        //contetntVC라는 storyboardID를 가진 뷰 컨트롤러의 인스턴스를 생성하고 캐스팅
        guard let cvc = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else { return nil}
        
        cvc.titleText = self.contentTitles[idx]
        cvc.imageFile = self.contentImages[idx]
        cvc.pageIndex = idx
        
        return cvc
    }
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: UserInfoKey.tutorial)
        ud.synchronize()
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //MARK:- PageViewControllerDatasource Method
    //현재의 콘텐츠 뷰 컨트롤러보다 더 알쪽으로 올 콘텐츠 뷰 컨트롤러 객체 즉 앞쪽으로 스와이프 했을때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as! TutorialContentsVC).pageIndex else { return nil }
        
        guard index > 0 else { return nil } // 현재의 인덱스가 0보다 작거나 같으면 즉 맨 앞이면 종료
        
        index -= 1 //현재의 인덱스에서 하나 뺌 (즉 이전 페이지 인덱스)
        return self.getContentsVC(atIndex: index)
    }
    //현재의 콘텐츠 뷰 컨트롤러볻 더 뒤쪽에 올 콘텐츠 뷰 컨트롤러 객체 즉 뒤쪽으로 스와이프 했을때 보여줄 콘텐츠 뷰 컨트롤러 객체
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as! TutorialContentsVC).pageIndex else { return nil }
        
        index += 1 // 현재의 인덱스에 하나 더함 (즉 다음 페이지 인덱스)
        
        guard index < self.contentTitles.count else { return nil }
        
        return self.getContentsVC(atIndex: index)
    }
    
    // ios에게 페이지 총 개수를 알려줌 (인디게이터구현에 필요)
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.contentTitles.count
    }
    
    //ios에게 첫 페이지를 알려줌
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
