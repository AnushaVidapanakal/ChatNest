import UIKit
import QuartzCore

class AddChatRoomViewController: UIViewController {
    
    @IBOutlet weak var input: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
}
