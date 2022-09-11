import UIKit

//TODO: add edit and delete buttons
class MixtapeDetailsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: View references
    @IBOutlet weak var mixtape_name_lb: UILabel!
    @IBOutlet weak var mixtape_description_lb: UILabel!
    @IBOutlet weak var mixtape_songs_list: UITableView!
    @IBOutlet weak var mixtape_user_image_iv: UIImageView!
    @IBOutlet weak var mixtape_user_name_lb: UILabel!
    
    //MARK: Data holders
    var data = [SongItem]()
    var mixtapeItem:MixtapeItem?{ didSet{ if(mixtape_name_lb != nil){ updateDisplay() } } }
    
    //MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mixtape_songs_list.delegate = self
        mixtape_songs_list.dataSource = self
        updateDisplay()
    }
        
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mixtapeSongCell", for: indexPath) as! SongTableViewCell
        let item = data[indexPath.row]
        cell.songItem = item
        return cell
    }

    //Prepare cell selection segue to song details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSongDetails"){
            let destination = segue.destination as! SongDetailsViewController
            let index = mixtape_songs_list.indexPathForSelectedRow?.row ?? 0
            let selectedSong = data[index]
            destination.songItem = selectedSong
        }
    }
    
    //MARK: Internal functions
    func updateDisplay(){
        //Load mixtape data
        mixtape_name_lb.text = mixtapeItem!.mixtape.name
        mixtape_description_lb.text = mixtapeItem!.mixtape.description
        mixtape_user_name_lb.text = mixtapeItem!.user.displayName
        let userImageUrlStr = mixtapeItem!.user.imageUrl ?? ""
        if userImageUrlStr != "" { mixtape_user_image_iv.kf.setImage(with: URL(string: userImageUrlStr)) }
        else{ mixtape_user_image_iv.image = UIImage(named: "empty_user_image") }
        //Table refresh setup
        mixtape_songs_list.refreshControl = UIRefreshControl()
        mixtape_songs_list.refreshControl?.attributedTitle = NSAttributedString("Loading List...")
        mixtape_songs_list.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        reload()
    }
    
    @objc func reload(){
        //Make sure mixtape data is available
        guard mixtapeItem != nil else { return }
        guard mixtapeItem!.mixtape.mixtapeId != nil else { return }
        //Start refresh
        if mixtape_songs_list.refreshControl?.isRefreshing == false { mixtape_songs_list.refreshControl?.beginRefreshing() }
        //Get songs from local db and finish refreshing
        Model.instance.getMixtapeSongItems(mixtapeId: mixtapeItem!.mixtape.mixtapeId!){ songItems in
            self.data = songItems
            DispatchQueue.main.async { self.mixtape_songs_list.reloadData() }
            self.mixtape_songs_list.refreshControl?.endRefreshing()
        }
    }

}
