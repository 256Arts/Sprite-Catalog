//
//  DebugViewController.swift
//  Sprite Catalog
//
//  Created by Jayden Irwin on 2021-04-02.
//

#if DEBUG && canImport(UIKit)
import UIKit

class DebugReorderViewController: UICollectionViewController, UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissModal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveJSON))
        
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.register(DebugImageCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        SpriteSet.allSprites.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DebugImageCell
        let sprite = SpriteSet.allSprites[indexPath.item]
        cell.imageView.image = sprite.states.first!.variants.first!.frameImage()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let sprite = SpriteSet.allSprites[indexPath.item]
        let item = UIDragItem(itemProvider: NSItemProvider())
        item.localObject = sprite
        return [item]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        let sprite = SpriteSet.allSprites[indexPath.item]
        let item = UIDragItem(itemProvider: NSItemProvider())
        item.localObject = sprite
        return [item]
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .unspecified)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destIndex = coordinator.destinationIndexPath?.item {
            let sourceIndices = coordinator.items.map({ $0.sourceIndexPath!.item })
            SpriteSet.allSprites.move(fromOffsets: IndexSet(sourceIndices), toOffset: destIndex)
            collectionView.reloadData()
        }
    }
    
    @objc func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func saveJSON() {
        do {
            let data = try JSONEncoder().encode(SpriteSet.allSprites)
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("ZCatalog").appendingPathExtension("json")
            try data.write(to: fileURL)
            let exportVC = UIDocumentPickerViewController(forExporting: [fileURL])
            present(exportVC, animated: true, completion: nil)
        } catch {
            print("Failed to encode sprites JSON")
        }
    }
    
}

class DebugImageCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.magnificationFilter = .nearest
        
        contentView.layer.cornerRadius = 12
        contentView.addSubview(imageView)
        
        contentView.addConstraints([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
#endif
