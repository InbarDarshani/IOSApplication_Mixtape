import UIKit
import Kingfisher

class SongDetailsViewController: UIViewController {
    
    //MARK: View references
    @IBOutlet weak var song_image_iv: UIImageView!
    @IBOutlet weak var song_name_lb: UILabel!
    @IBOutlet weak var song_artist_lb: UILabel!
    @IBOutlet weak var song_caption_lb: UILabel!
    @IBOutlet weak var song_mixtape_name_lb: UILabel!
    @IBOutlet weak var song_user_image_iv: UIImageView!
    @IBOutlet weak var song_user_name_lb: UILabel!
    @IBOutlet weak var song_delete_btn: UIButton!
    @IBOutlet weak var song_edit_btn: UIButton!
    @IBOutlet weak var deleteActivityIndicator: UIActivityIndicatorView!
    
    //MARK: Data holders
    var songItem:SongItem?{ didSet{ if(song_name_lb != nil){ updateDisplay() } } }
    
    //MARK: View Actions
    @IBAction func unwind(unwindSegue: UIStoryboardSegue){}
    @IBAction func deleteButtonClicked(_ sender: Any) {
        deleteActivityIndicator.startAnimating()
        Model.instance.deleteSong(song: songItem!.song){
            Model.feedDataNotification.post()
            self.deleteActivityIndicator.stopAnimating()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func editButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "toSongEdit", sender: self)
    }
    
    @IBAction func mixtapeNameClicked(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended{
            performSegue(withIdentifier: "toMixtapeDetails", sender: self)
        }
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
        if segue.identifier == "toMixtapeDetails" {
            let destination = segue.destination as! MixtapeDetailsViewController
            //Make sure mixtape data is available
            guard songItem != nil else { return }
            guard songItem!.mixtape.mixtapeId != nil else { return }
            //Get mixtape item from local db and pass to destination
            destination.mixtapeItem = Model.instance.getMixtapeItem(mixtapeId: (songItem!.mixtape.mixtapeId)!)
        }
    }

    //MARK: Internal functions
    func updateDisplay(){
        //Load song data
        song_name_lb.text = songItem!.song.name
        song_artist_lb.text = songItem!.song.artist
        song_caption_lb.text = songItem!.song.caption
        song_mixtape_name_lb.text = songItem!.mixtape.name
        song_user_name_lb.text = songItem!.user.displayName
        
        let imageUrlString = songItem!.song.imageUrl ?? ""
        if imageUrlString != "" { song_image_iv.kf.setImage(with: URL(string: imageUrlString)) }
        else{ song_image_iv.image = UIImage(named: "empty_song_image") }
        
        let userImageUrlStr = songItem!.user.imageUrl ?? ""
        if userImageUrlStr != "" { song_user_image_iv.kf.setImage(with: URL(string: userImageUrlStr)) }
        else{ song_user_image_iv.image = UIImage(named: "empty_user_image") }
    
        //Enable delete and edit for post creator
        if Model.instance.getCurrentUser().userId == songItem?.song.userId{
            song_edit_btn.isHidden = false
            song_delete_btn.isHidden = false
        }
    }
}


