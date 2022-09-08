import UIKit

class MixtapeTableViewCell: UITableViewCell {

    //MARK: View references
    @IBOutlet weak var mixtape_name_lb: UILabel?
    @IBOutlet weak var mixtape_description_lb: UILabel?

    //MARK: Data holders
    var mixtapeItem:MixtapeItem?{ didSet{ if(mixtape_name_lb != nil){ updateDisplay() } } }
    
    //MARK: View functions
    override func awakeFromNib() {
        super.awakeFromNib()
        if mixtapeItem != nil { updateDisplay() }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: Internal functions
    func updateDisplay(){
        mixtape_name_lb?.text = mixtapeItem!.mixtape.name
        mixtape_description_lb?.text = mixtapeItem!.mixtape.description
    }
}
