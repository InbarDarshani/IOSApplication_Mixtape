import UIKit
import Kingfisher

class SongDetailsViewController: UIViewController {

    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var artistLabel: UITextField!
    @IBOutlet weak var captionLabel: UITextField!
    @IBOutlet weak var mixtapeNameLabel: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var songItem:SongItem?{
        didSet{
            if(nameLabel != nil){ updateDisplay() }
        }
    }
    
    func updateDisplay(){
        nameLabel.text = songItem!.song.name
        artistLabel.text = songItem!.song.artist
        captionLabel.text = songItem!.song.caption
        mixtapeNameLabel.text = songItem!.mixtape.name
        userNameLabel.text = songItem!.user.displayName
                
        
        let songImageUrlStr = songItem!.song.imageUrl ?? ""
        if songImageUrlStr != "" {
            songImage.kf.setImage(with: URL(string: songImageUrlStr))
        }else{
            songImage.image = UIImage(named: "empty_song_image")
        }
        
        let userImageUrlStr = songItem!.user.imageUrl ?? ""
        if userImageUrlStr != "" {
            userImage.kf.setImage(with: URL(string: userImageUrlStr))
        }else{
            userImage.image = UIImage(named: "empty_user_image")
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if songItem != nil {
            updateDisplay()
        }
    }

}


