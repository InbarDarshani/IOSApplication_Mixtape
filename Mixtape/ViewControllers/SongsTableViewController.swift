import UIKit
import Kingfisher

class SongsTableViewController: UITableViewController {

    var data = [SongItem]()
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Table refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString("Loading List...")
        self.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        
        //Listener
        Model.feedDataNotification.observe { self.reload() }
        reload()
    }
    
    @objc func reload(){
        if self.refreshControl?.isRefreshing == false {
            self.refreshControl?.beginRefreshing()
        }
        Model.instance.getFeed(){ songItems in
            self.data = songItems
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { }
    
    //Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data.count }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedSongCell", for: indexPath) as! SongTableViewCell
        let item = data[indexPath.row]
        
        cell.nameLabel.text = item.song.name
        cell.artistLabel.text = item.song.artist
        cell.captionLabel.text = item.song.caption
        cell.mixtapeNameLabel.text = item.mixtape.name
        cell.userNameLabel.text = item.user.displayName
        
        
        let songImageUrlStr = item.song.imageUrl ?? ""
        if songImageUrlStr != "" {
            cell.songImage.kf.setImage(with: URL(string: songImageUrlStr))
        }else{
            cell.songImage.image = UIImage(named: "empty_song_image")
        }
        
        let userImageUrlStr = item.user.imageUrl ?? ""
        if userImageUrlStr != "" {
            cell.userImage.kf.setImage(with: URL(string: userImageUrlStr))
        }else{
            cell.userImage.image = UIImage(named: "empty_user_image")
        }
        
        return cell
    }
        
    //Prepare default cell selection segue to song details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "openSongDetails"){
            let destination = segue.destination as! SongDetailsViewController
            //let selectedSong = data[selectedRow]
            let index = tableView.indexPathForSelectedRow?.row ?? 0
            let selectedSong = data[index]
            destination.songItem = selectedSong
        }
    }
}
