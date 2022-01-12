//
//  SideBarVC.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/18.
//

import UIKit

class SideBarVC: UITableViewController {
    let titles = ["새 글 작성하기","친구 새 글", "달력으로 보기", "공지사항", "통계", "계정 관리"]
    let icons = [
        UIImage(named: "icon01.png"),
        UIImage(named: "icon02.png"),
        UIImage(named: "icon03.png"),
        UIImage(named: "icon04.png"),
        UIImage(named: "icon05.png"),
        UIImage(named: "icon06.png"),
    ]
    
    let nameLabel = UILabel()
    let emailLabel = UILabel()
    let profileImage = UIImageView()
    let uinfo = UserInfoManager() //개인정보 관리 매니저
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        
        headerView.backgroundColor = .brown
        
        self.tableView.tableHeaderView = headerView
        
        self.nameLabel.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        
        self.nameLabel.textColor = .white
        self.nameLabel.font = .boldSystemFont(ofSize: 15)
        self.emailLabel.backgroundColor = .clear
        
        headerView.addSubview(self.nameLabel)
        
        self.emailLabel.frame = CGRect(x: 70, y: 30, width: 120, height: 30)
        
        self.emailLabel.font = .systemFont(ofSize: 11)
        self.emailLabel.backgroundColor = .clear
        
        headerView.addSubview(self.emailLabel)
        
        self.profileImage.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        self.profileImage.layer.borderWidth = 0
        self.profileImage.layer.masksToBounds = true //기존의 이미지 위에 덧씌워 일부를 가리는 역할을 하는 레이어
        
        view.addSubview(self.profileImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.nameLabel.text = self.uinfo.name ?? "Guest"
        self.emailLabel.text = self.uinfo.account ?? ""
        self.profileImage.image = self.uinfo.profile
    }
    
    //MARK:- TableViewDelegateMethod
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "menucell"
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.imageView?.image = self.icons[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 14)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 { //새 글 작성
            //임력폼 객체 스토리보드아이디로 가져오기
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            
            // navigationController를 revealVC의 forntviewcontroller 속성으로 가져오기
            let target = self.revealViewController().frontViewController as! UINavigationController
            
            target.pushViewController(uv!, animated: true) //띄우기
            
            //사이드 바 닫기
            self.revealViewController().revealToggle(self)
        } else if indexPath.row == 5 { // 계정 관리
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            
            self.present(uv!, animated: true){ // 프로필 관리 컨트롤러 띄우기
                self.revealViewController().revealToggle(self) // 사이드 바 닫기
            }
        }
    }
}
