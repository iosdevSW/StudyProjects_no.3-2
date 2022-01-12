//
//  MemoListVC.swift
//  MyMemory
//
//  Created by 신상우 on 2021/11/08.
//

import UIKit

class MemoListVC: UITableViewController,UISearchBarDelegate {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate // 앱 델리게이트 객체의 참조 정보
    lazy var dao = MemoDAO()
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let revealVC = self.revealViewController() {
            let btn = UIBarButtonItem()
            btn.image = UIImage(named: "sidemenu.png")
            btn.target = revealVC
            btn.action = #selector(revealVC.revealToggle(_:))
            
            searchBar.enablesReturnKeyAutomatically = false //검색 바의 키보드에서 리턴 키가 항상 활성화 되도록 처리
            self.navigationItem.leftBarButtonItem = btn
            self.view.addGestureRecognizer(revealVC.panGestureRecognizer())
        }
    }
    
    //검색버튼 클릭시 키워드를 적용해 데이터를 검색하고, 테이블 뷰 갱신
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text// 검색박에 입력된 키워드를 가져온다.
        
        self.appDelegate.memolist = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //튜토리얼 화면 띄우기 view didload는 메모리에 로드만 된 상태이기 때문에 화면 전환이 불가능하여 willappear에서 생성
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: false)
            return
        }
        self.appDelegate.memolist = self.dao.fetch()
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // tableView의 행 개수 return
        let count = self.appDelegate.memolist.count
        return count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = self.appDelegate.memolist[indexPath.row] // row에 맞는 데이터 가져오기.
        let cellId = rowData.image == nil ? "memoCell" : "memoCellWithImage"
        //rowData 의 이미지가 있으면 memoCellWithImage , 없으면 memoCell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as! MemoCell
        
        //셀 내용 구성
        cell.subject?.text = rowData.title
        cell.contents?.text = rowData.contents
        cell.img?.image = rowData.image
        
        //date 타입의 날짜를 포맷에 맞게 변경
        let formmater = DateFormatter()
        formmater.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.regdate?.text = formmater.string(from: rowData.regdate!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.appDelegate.memolist[indexPath.row]
        guard let vc = self.storyboard?.instantiateViewController(identifier: "MemoRead") as? MemoReadVC else
        { return }
        
        vc.param = row
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let data = self.appDelegate.memolist[indexPath.row]
        
        if dao.delete(data.objectID!) {
            self.appDelegate.memolist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// NSSearchBar : 델리게이트 패턴에 의해 동작하는 검색바
// NSPredicate 객체 : 코어데이터에서 검색 조건을 담당하는 객체
