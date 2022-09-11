import UIKit
import iOSDropDown

class SongAddEditViewController: UIViewController,  UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: View references
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var song_image_iv: UIImageView!
    @IBOutlet weak var song_name_tf: UITextField!
    @IBOutlet weak var song_artist_tf: UITextField!
    @IBOutlet weak var song_caption_tf: UITextField!
    @IBOutlet weak var song_mixtape_name_tf: DropDown!
    @IBOutlet weak var song_mixtape_description_view: UIStackView!
    @IBOutlet weak var song_mixtape_description_tf: UITextField!
    @IBOutlet weak var loadImageIndicator: UIActivityIndicatorView!
    
    //MARK: Data holders
    var isEdit:Bool = false{ didSet{ if(song_name_tf != nil){ updateDisplay() } } }     //Indicates if this controller used for song editing
    var songItem:SongItem?{ didSet{ if(song_name_tf != nil){ updateDisplay() } } }
    
    //MARK: Internal variables
    let alert = UIAlertController(title: "Input Error", message: "", preferredStyle: .alert)
    let alertAction = UIAlertAction(title:"OK", style: .default, handler: { (alert:UIAlertAction!)-> Void in } )
    var currentUserId = Model.instance.getCurrentUser().userId!
    var userMixtapes:[Mixtape] = []
    //User's inputs holders
    var inputSongName = ""
    var inputArtist = ""
    var inputCaption = ""
    var inputMixtapeName = ""
    var inputWithNewMixtape:Bool = false
    var inputNewMixtapeDescription = ""
    var inputImage: UIImage? = nil
    var inputWithNewImage:Bool = false
    
    //MARK: View actions
    @IBAction func openGallery(_ sender: Any) { takePicture(source: .photoLibrary) }
    @IBAction func openCamera(_ sender: Any) {
        alert.message = "ERROR - Source type 1 not available!"
        self.present(alert, animated:true, completion:nil)
        //TODO: fix takePicture(source: .camera)
    }
    @IBAction func saveButtonClicked(_ sender: Any) { submit() }
    @IBAction func unwind(unwindSegue: UIStoryboardSegue){}
    @IBAction func loadFromSpotify(_ sender: Any) { loadImageFromSpotify() }
    
    //MARK: View functions
    override func viewWillAppear(_ animated: Bool) {
        //Get user mixtapes and Setup mixtapes dropdown list
        Model.instance.getUserMixtapes(userId: currentUserId){ mixtapes in
            self.userMixtapes = mixtapes
            self.song_mixtape_name_tf.optionArray = mixtapes.map{ $0.name! }
        }
        //Add same listener for mixtape selection from dropdown and for mixtape typing
        song_mixtape_name_tf.addAction(UIAction(){ action in self.handleMixtapeFieldChanges() }, for: .editingChanged)
        song_mixtape_name_tf.didSelect(completion: handleMixtapeFieldChanges)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDisplay()
    }
    
    //MARK: Internal functions
    func updateDisplay(){
        alert.addAction(alertAction)
        //Adjust display for editing song
        if isEdit{
            song_name_tf.text = songItem!.song.name
            song_artist_tf.text = songItem!.song.artist
            song_caption_tf.text = songItem!.song.caption
            song_mixtape_name_tf.text = songItem!.mixtape.name
            song_mixtape_description_tf.text = songItem!.mixtape.description
            
            let imageUrlString = songItem!.song.imageUrl ?? ""
            if imageUrlString != "" { song_image_iv.kf.setImage(with: URL(string: imageUrlString)) }
            else{ song_image_iv.image = UIImage(named: "empty_song_image") }
        }
    }
    
    func handleMixtapeFieldChanges(_ selectedText: String = "", _ index: Int = 0, _ id: Int = 0){
        //Get text field value from dropdown selection or from text typing
        let value = selectedText.isEmpty ? song_mixtape_name_tf.text! : selectedText
        guard !value.isEmpty else { return }
        
        //handle existing\notexisting mixtape
        inputWithNewMixtape = !(userMixtapes.map{ $0.name! }).contains(value)
        song_mixtape_description_view.isHidden = !inputWithNewMixtape
    }
    
    func submit(){
        //Start loading
        activityIndicator.startAnimating()
        //Get inputs
        inputSongName = song_name_tf.text!
        inputArtist = song_artist_tf.text!
        inputCaption = song_caption_tf.text!
        inputMixtapeName = song_mixtape_name_tf.text!
        inputWithNewMixtape =  !(userMixtapes.map{ $0.name! }).contains(inputMixtapeName)
        inputNewMixtapeDescription = song_mixtape_description_tf.text!
        inputWithNewImage = inputImage != nil
        
        //Validate Input
        if inputSongName.isEmpty{
            alert.message = "Please enter song's name"
        }
        else if inputMixtapeName.isEmpty{
            alert.message = "Please choose or create mixtape"
        } else {
            saveToDb()
            return
        }
        
        //Stop loading and show error alert
        activityIndicator.stopAnimating()
        self.present(alert, animated:true, completion:nil)
    }
    
    func saveToDb(){
        //Initial song object with input values and existing value
        let song  = Song()
        song.songId = isEdit ? songItem!.song.songId : ""
        song.name = inputSongName
        song.artist = inputArtist
        song.caption = inputCaption
        song.userId = currentUserId
        //Copy image url if its editing mode and set mixtapeId if existing one was chosen
        song.imageUrl = isEdit ? songItem!.song.imageUrl : ""
        song.mixtapeId = !inputWithNewMixtape ? userMixtapes.first(where: { $0.name == inputMixtapeName })?.mixtapeId : ""
        //Create new mixtape object with input values
        let newMixtape = Mixtape(name: inputMixtapeName, description: inputNewMixtapeDescription, userId: currentUserId)
               
        //Add\Update Song with image and new mixtape
        if inputWithNewImage && inputWithNewMixtape {
            isEdit ?
            Model.instance.updateSong(song: song, mixtape: newMixtape, image: inputImage!, completion: done) :
            Model.instance.addSong(song: song, mixtape: newMixtape, image: inputImage!, completion: done)
        }
        //Add\Update Song with image and existing mixtape
        if inputWithNewImage && !inputWithNewMixtape {
            isEdit ?
            Model.instance.updateSong(song: song, image: inputImage!, completion: done) :
            Model.instance.addSong(song: song, image: inputImage!, completion: done)
        }
        //Add\Update Song with no image and new mixtape
        if !inputWithNewImage && inputWithNewMixtape {
            isEdit ?
            Model.instance.updateSong(song: song, mixtape: newMixtape, completion: done) :
            Model.instance.addSong(song: song, mixtape: newMixtape, completion: done)
        }
        //Add\Update Song with no image and existing mixtape
        if !inputWithNewImage && !inputWithNewMixtape {
            isEdit ?
            Model.instance.updateSong(song: song, completion: done) :
            Model.instance.addSong(song: song, completion: done)
        }
    }
    
    func done()->Void{
        self.dismiss(animated: true){
            self.clearView()
            self.tabBarController?.selectedIndex = 0
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func clearView(){
        activityIndicator.stopAnimating()
        song_name_tf.text = ""
        song_artist_tf.text = ""
        song_caption_tf.text = ""
        song_mixtape_name_tf.text = ""
        song_mixtape_description_tf.text = ""
        song_image_iv.image = UIImage(named: "empty_song_image")
        inputSongName = ""
        inputArtist = ""
        inputCaption = ""
        inputMixtapeName = ""
        inputWithNewMixtape = false
        inputNewMixtapeDescription = ""
        inputImage = nil
        inputWithNewImage = false
    }
    
    func takePicture(source: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        if (UIImagePickerController.isSourceTypeAvailable(source)) {
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            alert.message = "Source type is not available!"
            self.present(alert, animated:true, completion:nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        inputImage = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage
        self.song_image_iv.image = inputImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func loadImageFromSpotify(){
        loadImageIndicator.startAnimating()
        
        //Get inputs
        inputSongName = song_name_tf.text!
        inputArtist = song_artist_tf.text!
    
        //Validate Input
        guard !inputSongName.isEmpty && !inputArtist.isEmpty else {
            alert.message = "Please enter song's name and artist first!"
            self.present(alert, animated:true, completion:nil)
            loadImageIndicator.stopAnimating()
            return
        }
        
        SpotifyApi.getTrackImage(songTitle: inputSongName, songArtist: inputArtist){ imageUrl  in
            //Validate api result
            guard imageUrl != nil else {
                self.alert.message = "Error getting song image"
                self.present(self.alert, animated:true, completion:nil)
                self.loadImageIndicator.stopAnimating()
                return
            }
            //Set image from result
            self.song_image_iv.kf.setImage(with: URL(string: imageUrl!)) { _ in
                self.loadImageIndicator.stopAnimating()
                self.inputImage = self.song_image_iv.image!
            }
        }
    }
    
}
