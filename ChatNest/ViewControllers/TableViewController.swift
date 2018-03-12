import UIKit
import Firebase

class TableViewController: UITableViewController, UISearchResultsUpdating {
    
    var senderDisplayName: String?
    var filteredRooms = [Room]()
    var searchController = UISearchController(searchResultsController: nil)
    var shouldShowSearchResults = false
    
    private var rooms: [Room] = []
    private var roomRef: DatabaseReference = Database.database().reference().child("rooms")
    private var roomRefHandle: DatabaseHandle?
    
    let databaseRef = Database.database().reference(fromURL: "https://chatnest-d3522.firebaseio.com/")
    
    lazy var leftButton: UIBarButtonItem  = {
        let image = UIImage.init(named: "user.profilePic")?.withRenderingMode(.alwaysOriginal)
        let button  = UIBarButtonItem.init(image: image, style: .plain, target: self, action: #selector(TableViewController.showProfile))
        return button
    }()
    
    
    @objc func showProfile()
    {
        print("inside 1st")
        let pvc = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "profileView") as! ProfileViewController
        self.present(pvc, animated: true,completion: nil)
        
    }
    
   
    // observing rooms
    
    private func observeRooms() {
        // We can use the observe method to listen for new
        // rooms being written to the Firebase DB
        roomRefHandle = roomRef.observe(.childAdded, with: { (snapshot) -> Void in
            let roomData = snapshot.value as! NSDictionary
            let id = snapshot.key
            if let roomName = roomData["roomName"] as! String!,
                let creatorName = roomData["creatorName"] as! String!,
                roomName.count > 0 {
                self.rooms.append(Room(id: id, roomName: roomName, creatorName: creatorName))
                self.tableView.reloadData()
            } else {
                print("Error! Could not load rooms list")
            }
        })
    }
    
    
    // create button to add a new chat room
    
    @IBAction func create(_ sender: Any) {
        NSLog("create button pressed")
        performSegue(withIdentifier: "goToAdd", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "goToChat" {
            if shouldShowSearchResults {
                let destinationVC = segue.destination as! ConversationViewController
                let index = tableView.indexPathForSelectedRow
                let room = filteredRooms[index!.row]
                destinationVC.room = room
            }
            else {
                let destinationVC = segue.destination as! ConversationViewController
                let index = tableView.indexPathForSelectedRow
                let room = rooms[index!.row]
                destinationVC.room = room
                
            }
        }
    }
    // to perform unwind segues
    
    @IBAction func cancelToTableViewController(_segue: UIStoryboardSegue) {
        guard _segue.destination is TableViewController else {
            return
        }
        
    }
    
    // adding a new chat room
    
    @IBAction func addToTableViewController(_segue: UIStoryboardSegue) {
        guard let addChatRoomViewController = _segue.source as? AddChatRoomViewController  else {
            return
        }
        
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("users").child(userID).child("credentials").observe(.value, with: { (snapshot) in
                //create a dictionary of users data
                let values = snapshot.value as? NSDictionary
                let creatorName = values?["name"] as? String
                
                if let roomName = addChatRoomViewController.input.text, roomName.count > 0 {
                    let newRoomRef = self.roomRef.childByAutoId()
                    let roomItem = [
                        "roomName": roomName,
                        "creatorName": creatorName
                    ]
                    newRoomRef.setValue(roomItem)
                }
                else {
                    print("Please enter a valid room name")
                    
                    // create the alert
                    let alert = UIAlertController(title: "You've added an empty room!", message: "Please enter a valid room name", preferredStyle: UIAlertControllerStyle.alert)
                    
                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                    
                    
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //To eliminate extra separators below UITableView
        self.tableView.tableFooterView = UIView()
        customization()
        observeRooms()
     
        filteredRooms = rooms
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        //tableView.contentInset = UIEdgeInsets.zero
        
        //Hide SearchBar
        tableView.setContentOffset(CGPoint.init(x: 0, y: 60), animated: false)
        
    }
    
    func customization() {
        
        self.navigationItem.leftBarButtonItem = self.leftButton
        
        if let id = Auth.auth().currentUser?.uid {
            User.info(forUserID: id, completion: { [weak weakSelf = self] (user) in
                let image = user.profilePic
                let contentSize = CGSize.init(width: 30, height: 30)
                UIGraphicsBeginImageContextWithOptions(contentSize, false, 0.0)
                let _  = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: contentSize), cornerRadius: 14).addClip()
                image.draw(in: CGRect(origin: CGPoint.zero, size: contentSize))
                let path = UIBezierPath.init(roundedRect: CGRect.init(origin: CGPoint.zero, size: contentSize), cornerRadius: 14)
                path.lineWidth = 2
                UIColor.white.setStroke()
                path.stroke()
                let finalImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!.withRenderingMode(.alwaysOriginal)
                UIGraphicsEndImageContext()
                DispatchQueue.main.async {
                    weakSelf?.leftButton.image = finalImage
                    weakSelf = nil
                }
            })
        }
        
    }
    
    
    deinit {
        if let refHandle = roomRefHandle {
            roomRef.removeObserver(withHandle: refHandle)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("prepare segue goToChat")
        self.performSegue(withIdentifier: "goToChat", sender: self)
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // to return number of rows
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResults
        {
            return filteredRooms.count
        }
        else
        {
            return rooms.count
        }
    }
    
    // to return a cell in table view
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if shouldShowSearchResults
        {
            let roomAdd = filteredRooms[indexPath.row]
            cell.textLabel?.text = roomAdd.roomName
            cell.detailTextLabel?.text = "Created by : " + roomAdd.creatorName
            
        }
            
        else {
            let roomAdd = rooms[indexPath.row]
            cell.textLabel?.text = roomAdd.roomName
            cell.detailTextLabel?.text = "Created by : " + roomAdd.creatorName
            
        }
        return cell
        
    }
    
    //to add a cell
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
        customization()
    }
    
    
    //to delete cell
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete
        {
            rooms.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // to update search results
    
    func updateSearchResults(for searchController: UISearchController) {
        // If we haven't typed anything into the search bar, then do not filter the results
        if searchController.searchBar.text! == "" {
            shouldShowSearchResults = false
            filteredRooms = rooms
        } else {
            // Filter the results
            shouldShowSearchResults = true
            filteredRooms = rooms.filter { $0.roomName.lowercased().contains(searchController.searchBar.text!.lowercased()) }
        }
        
        self.tableView.reloadData()
    }
    
}
