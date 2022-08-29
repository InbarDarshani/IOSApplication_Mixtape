import UIKit
import Kingfisher

class SongDetailsViewController: UIViewController {
    
    //MARK: View references
    @IBOutlet weak var song_image_iv: UIImageView!
    @IBOutlet weak var song_name_tf: UITextField!
    @IBOutlet weak var song_artist_tf: UITextField!
    @IBOutlet weak var song_caption_tf: UITextField!
    @IBOutlet weak var song_mixtape_name_tf: UITextField!
    @IBOutlet weak var song_user_image_iv: UIImageView!
    @IBOutlet weak var song_user_name_lb: UILabel!
    @IBOutlet weak var song_delete_btn: UIButton!
    @IBOutlet weak var song_edit_btn: UIButton!
    
    //MARK: Data holders
    var songItem:SongItem?{
        didSet{
            if(song_name_tf != nil){ updateDisplay() }
        }
    }
    
    //MARK: View Actions
    @IBAction func unwind(unwindSegue: UIStoryboardSegue){}
    
    
    @IBAction func deleteButtonClicked(_ sender: Any) {
        Model.instance.deleteSong(song: songItem!.song){
            self.performSegue(withIdentifier: "backToFeed", sender: self)
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSongEdit", sender: self)
    }
    
    //MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if songItem != nil { updateDisplay() }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSongEdit" {
            let destination = segue.destination as! SongAddEditViewController
            destination.songItem = songItem
            destination.isEdit = true
        }
    }

    //MARK: Internal functions
    func updateDisplay(){
        song_name_tf.text = songItem!.song.name
        song_artist_tf.text = songItem!.song.artist
        song_caption_tf.text = songItem!.song.caption
        song_mixtape_name_tf.text = songItem!.mixtape.name
        song_user_name_lb.text = songItem!.user.displayName
        
        let songImageUrlStr = songItem!.song.imageUrl ?? ""
        if songImageUrlStr != "" {
            song_image_iv.kf.setImage(with: URL(string: songImageUrlStr))
        }else{
            song_image_iv.image = UIImage(named: "empty_song_image")
        }
        
        let userImageUrlStr = songItem!.user.imageUrl ?? ""
        if userImageUrlStr != "" {
            song_user_image_iv.kf.setImage(with: URL(string: userImageUrlStr))
        }else{
            song_user_image_iv.image = UIImage(named: "empty_user_image")
        }
    
        //Enable delete and edit for post creator
        if Model.instance.getCurrentUser().userId == songItem?.song.userId{
            song_edit_btn.isHidden = false
            song_delete_btn.isHidden = false
        }
    }
}


