//
//  AlbumView.swift
//  MyAlbum
//
//  Created by nju on 2022/12/14.
//

import UIKit

private let reuseIdentifier = "Cell"

class AlbumView: UICollectionViewController {

    private var viewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    public var images = [UIImage]()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.viewLayout.itemSize = CGSize(width: self.view.frame.width / 3 - 10, height: self.view.frame.width / 3 - 10)
        self.viewLayout.minimumLineSpacing = 4
        self.viewLayout.minimumInteritemSpacing = 4
        self.viewLayout.sectionInset.left = 7
        self.viewLayout.sectionInset.right = 7
        self.collectionView.collectionViewLayout = viewLayout
        // Do any additional setup after loading the view.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image", for: indexPath) as! CollectionViewCell
        
        cell.image.image = images[indexPath.item]
        cell.image.contentMode = UIView.ContentMode.scaleAspectFill
        // Configure the cell
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AlbumToImage" {
            let cell = sender as! CollectionViewCell
            let photoView = segue.destination as! PhotoView
            photoView.image = cell.image.image
        }
    }

}
