import UIKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: View references
    @IBOutlet weak var user_image_iv: UIImageView!
    @IBOutlet weak var user_name_lb: UILabel!
    @IBOutlet weak var mixtapes_list: UITableView!
    
    //MARK: Data holders
    var data = [MixtapeItem]()
    var user:User?{ didSet{ if(user_name_lb != nil){ updateDisplay() } } }
    
    //MARK: View functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mixtapes_list.delegate = self
        mixtapes_list.dataSource = self
        user = Model.instance.getCurrentUser()
        updateDisplay()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return data.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileMixtapeCell", for: indexPath) as! MixtapeTableViewCell
        let item = data[indexPath.row]
        cell.mixtapeItem = item
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMixtapeDetails" {
            let destination = segue.destination as! MixtapeDetailsViewController
            let index = mixtapes_list.indexPathForSelectedRow?.row ?? 0
            let selectedMixtape = data[index]
            destination.mixtapeItem = selectedMixtape
        }
    }

    //MARK: Internal functions
    func updateDisplay(){
        //Load user data
        user_name_lb.text = user!.displayName
        let userImageUrlStr = user!.imageUrl ?? ""
        if userImageUrlStr != "" { user_image_iv.kf.setImage(with: URL(string: userImageUrlStr)) }
        else{ user_image_iv.image = UIImage(named: "empty_user_image") }
        
        //Table refresh setup
        mixtapes_list.refreshControl = UIRefreshControl()
        mixtapes_list.refreshControl?.attributedTitle = NSAttributedString("Loading List...")
        mixtapes_list.refreshControl?.addTarget(self, action: #selector(reload), for: .valueChanged)
        reload()
    }
    
    @objc func reload(){
        //Start refresh
        if mixtapes_list.refreshControl?.isRefreshing == false { mixtapes_list.refreshControl?.beginRefreshing() }
        //Get songs from local db and finish refreshing
        Model.instance.getProfile(){ mixtapeItems in
            self.data = mixtapeItems
            DispatchQueue.main.async { self.mixtapes_list.reloadData() }
            self.mixtapes_list.refreshControl?.endRefreshing()
        }
    }

    

}
