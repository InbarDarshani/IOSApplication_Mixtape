import UIKit
import Kingfisher

class SongTableViewCell: UITableViewCell {
    
    //MARK: View references
    @IBOutlet weak var song_image_iv: UIImageView?
    @IBOutlet weak var song_name_lb: UILabel?
    @IBOutlet weak var song_artist_lb: UILabel?
    @IBOutlet weak var song_caption_lb: UILabel?
    @IBOutlet weak var song_mixtape_name_lb: UILabel?
    @IBOutlet weak var song_user_image_iv: UIImageView?
    @IBOutlet weak var song_user_name_lb: UILabel?
    
    //MARK: Data holders
    var songItem:SongItem?{ didSet{ if(song_name_lb != nil){ updateDisplay() } } }
    
    //MARK: View functions
    override func awakeFromNib() {
        super.awakeFromNib()
        if songItem != nil { updateDisplay() }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        song_image_iv?.clear()
        song_user_image_iv?.clear()
    }
    
    //MARK: Internal functions
    func updateDisplay(){
        song_name_lb?.text = songItem!.song.name
        song_artist_lb?.text = songItem!.song.artist
        song_caption_lb?.text = songItem!.song.caption
        song_mixtape_name_lb?.text = songItem!.mixtape.name
        song_user_name_lb?.text = songItem!.user.displayName
        
        let imageUrlString = songItem!.song.imageUrl ?? ""
        if imageUrlString != "" { song_image_iv?.kf.setImage(with: URL(string: imageUrlString)) }
        else{ song_image_iv?.image = UIImage(named: "empty_song_image") }
        
        let userImageUrlStr = songItem!.user.imageUrl ?? ""
        if userImageUrlStr != "" { song_user_image_iv?.kf.setImage(with: URL(string: userImageUrlStr)) }
        else{ song_user_image_iv?.image = UIImage(named: "empty_user_image") }
    }
    
}
