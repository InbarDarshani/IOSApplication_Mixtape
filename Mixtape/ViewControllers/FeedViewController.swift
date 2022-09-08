import UIKit
import Kingfisher

class FeedViewController: UITableViewController {
    
    //MARK: Data holders
    var data = [SongItem]()
    
    //MARK: View functions
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

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data.count }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedSongCell", for: indexPath) as! SongTableViewCell
        let item = data[indexPath.row]
        cell.songItem = item
        return cell
    }
    
    //Prepare default cell selection segue to song details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSongDetails"){
            let destination = segue.destination as! SongDetailsViewController
            let index = tableView.indexPathForSelectedRow?.row ?? 0
            let selectedSong = data[index]
            destination.songItem = selectedSong
        }
    }
    
    //MARK: Internal functions
    @objc func reload(){
        if self.refreshControl?.isRefreshing == false {
            self.refreshControl?.beginRefreshing()
        }
        Model.instance.getFeed(){ songItems in
            self.data = songItems
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.refreshControl?.endRefreshing()
        }
    }
}

