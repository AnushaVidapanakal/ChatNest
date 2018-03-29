import UIKit
import Firebase
import SDWebImage
import Photos
import Toast_Swift

class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var profilePic: RoundedImageView!
    
    let storageRef = Storage.storage().reference(forURL: "gs://chatnest-d3522.appspot.com")
    let databaseRef = Database.database().reference(fromURL: "https://chatnest-d3522.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(profileView)
        loadProfileData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // To select a profile picture
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Create a holder variable for the chosen image
        var chosenImage = UIImage()
        // Save the image into a variable
        print(info)
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // To update the image view
        profilePic.image = chosenImage
        // To dismiss
        dismiss(animated: true, completion: nil)
    }
    
    // To dismiss when the user hits cancel
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // To load the profile data of the current user
    func loadProfileData() {
        // If the user is logged in, get the profile data
        if let userID = Auth.auth().currentUser?.uid {
            databaseRef.child("users").child(userID).child("credentials").observe(.value, with: { (snapshot) in
                
                // To create a dictionary of users' profile data
                let values = snapshot.value as? NSDictionary
                
                // If there is a url for the profile picture
                if let profileImageURL = values?["profilePicLink"] as? String {
                    // Using sd_setImage to load the picture
                    self.profilePic.sd_setImage(with: URL(string: profileImageURL), placeholderImage: UIImage(named: " "))
                }
                self.nameTextField.text = values?["name"] as? String
            })
        }
    }
    
    // To update the user credentials in the database
    func updateUsersProfile() {
        // To check if the user is logged in
        guard
            let userID = Auth.auth().currentUser?.uid,
            let newUserName  = self.nameTextField.text,
            let image = profilePic.image,
            let newImage = UIImageJPEGRepresentation(image,0.1) else {
                return
        }
        
        // To upload the update the profile picture to Firebase Storage
        let storageItem = storageRef.child("usersProfilePics").child(userID)
        
        storageItem.putData(newImage, metadata: nil) { (metadata, error) in
            if let error = error {
                print(error)
                return
            }
            if let profilePhotoURL = metadata?.downloadURL()?.absoluteString{
                let newValuesForProfile =
                    ["profilePicLink": profilePhotoURL,
                     "name": newUserName]
                
                // To update the user credentials in Firebase Database
                self.databaseRef.child("users").child(userID).child("credentials").updateChildValues(newValuesForProfile, withCompletionBlock: { (error, ref) in
                    if let error = error {
                        print(error)
                        return
                    }
                    print("Profile updated successfully")
                    // To display toast message
                    self.profileView.makeToast("Profile updated successfully")
                })
            }
        }
    }
    
    // Textfield delegates
    func textFieldDidBeginEditing(_ textField: UITextField) {
        return
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // To choose the profile picture
    @IBAction func selectPic(_ sender: Any) {
        // To create an instance of UIImagePickerController
        let picker = UIImagePickerController()
        // To set the delegate
        picker.delegate = self
        // To set the details
        // To zoom the picture
        picker.allowsEditing = false
        // To get the picture source type
        picker.sourceType = .photoLibrary
        // To set the media type
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        // To show the photo library
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logOut(_ sender: Any) {
        UserManager.logOutUser { (status) in
            if status == true {
                print("LOGGED OUT")
                self.performSegue(withIdentifier: "unwindSegueToLogin", sender: self)
            }
        }
    }
    
    @IBAction func update(_ sender: Any) {
        updateUsersProfile()
    }
}
