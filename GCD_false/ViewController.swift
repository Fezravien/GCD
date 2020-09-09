//
//  ViewController.swift
//  GCD_false
//
//  Created by 윤재웅 on 2020/09/09.
//  Copyright © 2020 pazravien. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var urls: [URL] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Photos.plist에서 뽑아내서, urls에 저장하기
        // Target Membership설정
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
        
        // 🎾 cellForItemAt에서 처리하면 동시성처리가 안되고 있는 것임
        if let data = try? Data(contentsOf: urls[indexPath.item]),
          let image = UIImage(data: data) {
            cell.imageThum.image = image
        } else {
            cell.imageThum.image = nil
        }
        
        return cell
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
            let width = (collectionView.bounds.width - (margin * 2) - (itemSpacing * 2)) / 3
            let height = width * 10/7
            
            return CGSize(width: width, height: height)
        }
}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageThum: UIImageView!
}
