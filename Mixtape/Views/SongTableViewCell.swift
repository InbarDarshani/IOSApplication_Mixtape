import UIKit
import Kingfisher

class SongTableViewCell: UITableViewCell {
    
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var mixtapeNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var name = "" {
        didSet{
            if(nameLabel != nil){ nameLabel.text = name }
        }
    }
    
    var artist = "" {
        didSet{
            if(artistLabel != nil){ artistLabel.text = artist }
        }
    }
    
    var caption = "" {
        didSet{
            if(captionLabel != nil){ captionLabel.text = caption }
        }
    }
    
    var imageUrl = "" {
        didSet{
            if(songImage != nil){
                songImage.kf.setImage(with: URL(string: imageUrl))
            }
        }
    }
    
    var mixtapeName = "" {
        didSet{
            if(mixtapeNameLabel != nil){ mixtapeNameLabel.text = mixtapeName }
        }
    }
    
    var userImageUrl = "" {
        didSet{
            if(userImage != nil){
                userImage.kf.setImage(with: URL(string: userImageUrl))
            }
        }
    }
    
    var userName = "" {
        didSet{
            if(userNameLabel != nil){ userNameLabel.text = userName }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        nameLabel.text = name
        artistLabel.text = artist
        captionLabel.text = caption
        songImage.kf.setImage(with: URL(string: imageUrl))
        mixtapeNameLabel.text = mixtapeName
        userImage.kf.setImage(with: URL(string: userImageUrl))
        userNameLabel.text = userName
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        songImage.clear()
        userImage.clear()
    }
    
}
