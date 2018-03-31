import UIKit
import QuartzCore
import Firebase

class AddChatRoomViewController: UIViewController {
    
    @IBOutlet weak var btnCheckBox: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var locAwareLabel: UILabel!
    
    let databaseRef = Database.database().reference(fromURL: "https://chatnest-d3522.firebaseio.com/")
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                btnCheckBox.setImage(UIImage(named:"Checkmark2"), for: .selected)
            } else {
                btnCheckBox.setImage(UIImage(named:"Checkmarkempty2"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        btnCheckBox.setImage(UIImage(named:"Checkmarkempty2"), for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        input.layer.cornerRadius = 10.0
        guard let addRoom = input.text, addRoom != "" else{
            print("text field is empty")
            return
        }
    }
    // To add a new room
    @IBAction func addRoom(_ sender: Any) {
        if(input.text!.isEmpty)
        {
            self.errorLabel.isHidden = false
            input.resignFirstResponder()
        }
        else
        {
            // Add chatroom and unwind to tableVC
            performSegue(withIdentifier: "addRoom", sender: self)
        }
    }
    
    // To check or uncheck the checkbox
    @IBAction func checkMarkTapped(_ sender: UIButton) {
        if sender == btnCheckBox {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
        
        // To animate the checkbox
        UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            
        }) { (success) in
            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveLinear, animations: {
                sender.isSelected = !sender.isSelected
                sender.transform = .identity
            }, completion: nil)
        }
    }
}
