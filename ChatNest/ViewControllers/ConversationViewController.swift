import UIKit
import Firebase
import GrowingTextView
import CoreLocation

class ConversationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GrowingTextViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var totalChatView: UIView!
    @IBOutlet weak var msgTextView: GrowingTextView!
    @IBOutlet weak var inputBar: UIView!
    
    var currentUser: User?
    var room: Room? {
        didSet {
            let roomsRef: DatabaseReference = Database.database().reference().child("rooms")
            let roomRef = roomsRef.child(room!.id)
            messageRef = roomRef.child("messages")
            observeMessages()
            title = room?.roomName
        }
    }
    
    let databaseRef = Database.database().reference(fromURL: "https://chatnest-d3522.firebaseio.com/")
    
    private var messages : [Message] = []
    private var messageRef: DatabaseReference?
    private var messagesRefHandle: DatabaseHandle?
    
    private let locationManager = LocationManager.shared
    private var locns : [CLLocation] = []
    
    private var currentLocation: CLLocation?
    
   // private let radius: CLLocationDistance = 1000
    
    var msg: Message?
    
   
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Keyboard handling
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.showKeyboard(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ConversationViewController.keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // to get user's current location
        locationManager.start()
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //To eliminate the separators of the UITableView
        self.chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.chatTableView.delegate = self
        self.chatTableView.dataSource = self
        
        // To self size the cells
        self.chatTableView.estimatedRowHeight = 68.0
        chatTableView.rowHeight = UITableViewAutomaticDimension
        
        NSLog("Finished loading")
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        msgTextView.resignFirstResponder()
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sid = Auth.auth().currentUser?.uid
        let message = messages[indexPath.row]
        let messageSenderId = message.senderId
        
        // comparing sender id with currently logged in user id
        if sid == messageSenderId {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Sender", for: indexPath) as! SenderCell
            let message = messages[indexPath.row]
            cell.updateMessage(message: message)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Receiver", for: indexPath) as! ReceiverCell
            let message = messages[indexPath.row]
            cell.updateMessage(message: message)
            return cell
        }
    }
    
    /*   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
     return 55.0
     
     } */
    
    // animating the cells in table view
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView.isDragging {
            cell.transform = CGAffineTransform.init(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration: 0.3, animations: {
                cell.transform = CGAffineTransform.identity
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        msgTextView.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.msgTextView.resignFirstResponder()
    }
    
    
    
    // to send a message
    @IBAction func sendMessage(_ sender: Any) {
        NSLog("Message added")
        let messages = msgTextView.text
        let newMessageRef = messageRef!.childByAutoId()
        
        let locVal = locationManager.coord
        
        
        /*  let timestamp = ServerValue.timestamp() as! Double!
         let date = Date(timeIntervalSince1970: timestamp / 1000)
         let dateFormatter = DateFormatter()
         let dateString = self.timeSince(from: date, numericDates: true)  // Just now */
        
        
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("users").child(userID).child("credentials").observe(.value, with: { (snapshot) in
                //create a dictionary of users data
                let values = snapshot.value as? NSDictionary
                
                let senderName = values?["name"] as? String
                let messageItem = [
                    "text" : messages as Any,
                    "timestamp" : ServerValue.timestamp(),
                    "dateString": String(),
                    "senderName": senderName as Any,
                    "senderId": Auth.auth().currentUser?.uid as Any,
                    "latitude": locVal?.latitude as Any,
                    "longitude": locVal?.longitude as Any
                    
                    ] as [String : Any]
                
                newMessageRef.setValue(messageItem)
                self.msgTextView.text = ""
                
                
                
            }
            )}
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.inputBar.frame.origin.y -= keyboardSize.height
        }
        NSLog("before \(inputBar.frame)")
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.inputBar.frame.origin.y = 587
        }
    }
    
    @objc func keyboardHide(notification: Notification){
        chatTableView.contentInset = UIEdgeInsets.zero
    }
    
    @objc func showKeyboard(notification: Notification) {
        if let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let height = frame.cgRectValue.height
            self.chatTableView.contentInset.bottom = height
            self.chatTableView.scrollIndicatorInsets.bottom = height
            if self.messages.count > 0 {
                self.chatTableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    
    private func observeMessages() {
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        
        NSLog("observe messages function entry")
        
        messagesRefHandle = messageRef!.observe(.childAdded, with: { (snapshot) -> Void in
            let messageData = snapshot.value as! NSDictionary
            let id = snapshot.key
            
            
            if let text = messageData["text"] as! String!,
                let senderName = messageData["senderName"] as! String!,
                let timestamp = messageData["timestamp"] as! Double!,
                let dateString = messageData["dateString"] as! String!,
                let senderId = messageData["senderId"] as! String!,
                let latitude = messageData["latitude"] as! Double!,
                let longitude = messageData["longitude"] as! Double!,
                text.count > 0 {
                
                let date = Date(timeIntervalSince1970: timestamp / 1000)
                let dateFormatter = DateFormatter()
                let dateString = self.timeSince(from: date, numericDates: true)  // Just now
                
                //let locValues = self.locationManager.coord
                
                
           /*    for msg in messageData {
                    
                    var distanceInMeters: CLLocationDistance = 0
                    
                    let msgLocation = CLLocation(latitude: latitude, longitude: longitude)
                    
                    if let currentLocation = self.currentLocation {
                        // Set distanceInMeters to the distance between the user's current location and the location of the message.
                        distanceInMeters = currentLocation.distance(from: msgLocation)
                        // If this distance is not within 1000 metres, remove this msg from the array
                        if self.radius < distanceInMeters {
                            
                            self.messages = self.messages.filter({ (msg: Message) -> Bool in
                                return self.contains(msg as Message! as! UIFocusEnvironment)
                            })
                            
                        }
                    }
                }  */
                
                var distanceInMeters: CLLocationDistance = 0
                let msgLocation = CLLocation(latitude: latitude, longitude: longitude)
                if let currentLocation = self.currentLocation {
                    // Set distanceInMeters to the distance between the user's current location and the location of the message.
                    distanceInMeters = currentLocation.distance(from: msgLocation)
                    print("DIST IS:")
                    NSLog("\(distanceInMeters)")
                }
                
                
            /*    let msgLocation = CLLocation(latitude: latitude, longitude: longitude)
                print("msgLocation is:")
                NSLog("\(msgLocation)")
                //let distance = self.locationManager.location?.distance(from: msgLocation)
                let coordinates = self.locationManager.coord
                let UserLat = coordinates?.latitude
                let UserLong = coordinates?.longitude
                let UserLastLocn = CLLocation(latitude: UserLat, longitude: UserLong!)
                print("UserLastLocn is:")
                NSLog("\(String(describing: UserLastLocn))")
                let lastDistance = UserLastLocn.distance(from: msgLocation)
                print("lastDistance is:")
                NSLog("\(String(describing: lastDistance))")
                
               // print("distance is:")
               // NSLog("\(distance)")
             */
                NSLog("\(dateString)")
                NSLog("\(senderName)")
                NSLog("\(senderId)")
                NSLog("\(text)")
                print("location Values in ConvVC:")
               // NSLog("\(String(describing: locValues))")
                
                
                let message = Message(mId: id, text: text, timestamp: timestamp, dateString: dateString, senderName: senderName, senderId: senderId, latitude: latitude, longitude: longitude)
                self.messages.append(message)
                
                self.chatTableView.reloadData()
                //self.chatTableView.insertRows(at: [IndexPath.init(row: self.messages.count - 1, section: 0)], with: .left)
                //self.chatTableView.reloadRows(at: [IndexPath.init(row: self.messages.count - 1, section: 0)], with: .left)
                
                self.chatTableView.scrollToRow(at: IndexPath.init(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
            }
            else {
                print("Error! Couldn't load messages")
            }
            
        })
        
    }
    
    
    func timeSince(from: Date, numericDates: Bool = false) -> String {
        let calendar = Calendar.current
        let now = NSDate()
        let earliest = now.earlierDate(from as Date)
        let latest = earliest == now as Date ? from : now as Date
        let components = calendar.dateComponents([.year, .weekOfYear, .month, .day, .hour, .minute, .second], from: earliest, to: latest as Date)
        
        var result = ""
        
        if components.year! >= 2 {
            result = "\(components.year!) years ago"
        } else if components.year! >= 1 {
            if numericDates {
                result = "1 year ago"
            } else {
                result = "Last year"
            }
        } else if components.month! >= 2 {
            result = "\(components.month!) months ago"
        } else if components.month! >= 1 {
            if numericDates {
                result = "1 month ago"
            } else {
                result = "Last month"
            }
        } else if components.weekOfYear! >= 2 {
            result = "\(components.weekOfYear!) weeks ago"
        } else if components.weekOfYear! >= 1 {
            if numericDates {
                result = "1 week ago"
            } else {
                result = "Last week"
            }
        } else if components.day! >= 2 {
            result = "\(components.day!) days ago"
        } else if components.day! >= 1 {
            if numericDates {
                result = "1 day ago"
            } else {
                result = "Yesterday"
            }
        } else if components.hour! >= 2 {
            result = "\(components.hour!) hours ago"
        } else if components.hour! >= 1 {
            if numericDates {
                result = "1 hour ago"
            } else {
                result = "An hour ago"
            }
        } else if components.minute! >= 2 {
            result = "\(components.minute!) minutes ago"
        } else if components.minute! >= 1 {
            if numericDates {
                result = "1 minute ago"
            } else {
                result = "A minute ago"
            }
        } else if components.second! >= 3 {
            result = "\(components.second!) seconds ago"
        } else {
            result = "Just now"
        }
        
        return result
    }
    
    
}


