import UIKit
import iOSDropDown
import MaterialComponents

class SongAddEditViewController: UIViewController {

    //MARK: View references
    @IBOutlet weak var page_title_lb: UILabel!
    @IBOutlet weak var song_image_iv: UIImageView!
    @IBOutlet weak var song_name_tf: MDCTextField!
    @IBOutlet weak var song_artist_tf: UITextField!
    @IBOutlet weak var song_caption_tf: UITextField!
    @IBOutlet weak var song_mixtape_name_tf: DropDown!
    @IBOutlet weak var song_mixtape_description_tf: UITextField!
        
    //MARK: Data holders
    var isEdit:Bool = false{
        didSet{
            if(song_name_tf != nil){ updateDisplay() }
        }
    }
    
    var songItem:SongItem?{
        didSet{
            if(song_name_tf != nil){ updateDisplay() }
        }
    }
    
    //MARK: Internal variables
    let alert = UIAlertController(title: "Input Error", message: "", preferredStyle: .alert)
    let alertAction = UIAlertAction(title:"OK", style: .default, handler: { (alert:UIAlertAction!)-> Void in } )
    
    var inputSongName = ""
    var inputArtist = ""
    var inputCaption = ""
    var inputSelectedMixtape = ""
    
    var inputNewMixtapeName = ""
    var inputNewMixtapeDescription = ""
    //var currentUserId
    
    //MARK: View actions
    @IBAction func saveButtonClicked(_ sender: Any) { submit() }
    
    //MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDisplay()
    }

    //MARK: Internal functions
    func updateDisplay(){
        
        //Load user mixtapes into auto complete text field
        song_mixtape_name_tf.isEnabled = false
        Model.instance.getProfile(){ mixtapeItems in
            let userMixtapeNames = mixtapeItems.map{ $0.mixtape.name! }
            //let userMixtapeIds = mixtapeItems.map{ $0.mixtape.mixtapeId! }

            self.song_mixtape_name_tf.optionArray = userMixtapeNames
            //self.song_mixtape_name_tf.optionIds = userMixtapeIds

            self.song_mixtape_name_tf.didSelect{ selectedText, index, id in
                 print("TAG Selected String: \(selectedText) \n index: \(index)")
            }

            self.song_mixtape_name_tf.isEnabled = true
        }
        
//        //Load user mixtapes into auto complete text field
//        song_mixtape_name_tf.isEnabled = false
//        Model.instance.getProfile(){ mixtapeItems in
//            let userMixtapeNames = mixtapeItems.map{ $0.mixtape.name! }
//            self.song_mixtape_name_tf.filterStrings(userMixtapeNames)
//
//
//            self.song_mixtape_name_tf.itemSelectionHandler = { filteredResults, itemPosition in
//                let item = filteredResults[itemPosition]
//                self.song_mixtape_name_tf.text = item.title
//                print("TAG Item at position \(itemPosition): \(item.title)")
//            }
//
//            self.song_mixtape_name_tf.isEnabled = true
//        }
        
        
        if isEdit{
            page_title_lb.text = "Edit Song"
            song_name_tf.text = songItem!.song.name
            song_artist_tf.text = songItem!.song.artist
            song_caption_tf.text = songItem!.song.caption
            song_mixtape_name_tf.text = songItem!.mixtape.name
            song_mixtape_description_tf.text = songItem!.mixtape.description
            
            let songImageUrlStr = songItem!.song.imageUrl ?? ""
            if songImageUrlStr != "" {
                song_image_iv.kf.setImage(with: URL(string: songImageUrlStr))
            }else{
                song_image_iv.image = UIImage(named: "empty_song_image")
            }
        }
    }

    func submit(){
        
//        if {
//
//        }else{
//            self.present(alert, animated:true, completion:nil)
//        }
    }
    

    
}
