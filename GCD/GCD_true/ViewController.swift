//
//  ViewController.swift
//  GCD_true
//
//  Created by 윤재웅 on 2020/09/29.
//

import UIKit

class ViewController: UIViewController {
    private var urls: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Photos.plist에서 뽑아내서, urls에 저장하기
        guard let url = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
            let contents = try? Data(contentsOf: url),
            let serial = try? PropertyListSerialization.propertyList(from: contents, format: nil),
            let serialUrls = serial as? [String]
            else { return print("무엇인가 잘못되었습니다...") }
        
        urls = serialUrls.compactMap { URL(string: $0) }
        
    }

}

extension ViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.urls.count
    }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageThum.image = nil
        
              downloadWithGlobalQueue(at: indexPath, cell)
        //    downloadWithUrlSession(at: indexPath, cell)
        
        return cell
    }
    
    // 🎾 글로벌큐를 이용한 다운로드 및 셀 표시
    private func downloadWithGlobalQueue(at indexPath: IndexPath, _ cell: PhotoCell) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            let url = self.urls[indexPath.item]
            
            guard let data = try? Data(contentsOf: url),
                let image = UIImage(data: data) else { return }
            
            // 🎾 UI업데이트는 메인큐에서
            DispatchQueue.main.async {
                cell.imageThum.image = image
                }
            }
        }
    
    
    // 🎾 URL세션을 이용한 다운로드 및 셀 표시
    private func downloadWithUrlSession(at indexPath: IndexPath, _ cell: PhotoCell) {
        URLSession.shared.dataTask(with: urls[indexPath.item]) {
            [weak self] data, response, error in
            
            guard let _ = self,
                let data = data,
                let image = UIImage(data: data) else { return }
            
            // 🎾 UI업데이트는 메인큐에서
            DispatchQueue.main.async {
                cell.imageThum.image = image
            }
        }.resume()
    }

    
}

extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            // Min spacing -- 아이템간, 라인간 간격
            // Section Insets -- 뷰의 좌우, 위아래 간격
            // none으로 지정 후 우리가 직접 계산
            let margin: CGFloat = 2
            let itemSpacing: CGFloat = 8
            
    //      Frame = 슈퍼뷰(상위뷰)의 좌표계에서 위치와 크기를 나타낸다.
    //      Bounds = 자기자신의 좌표계에서 위치와 크기를 나타낸다.
            let width = (collectionView.frame.width - (margin * 2) - (itemSpacing * 2)) / 3
            let height = width * 10/7
            
            return CGSize(width: width, height: height)
        }
}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageThum: UIImageView!
}


