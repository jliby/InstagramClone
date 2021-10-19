//
//  FeedViewController.swift
//  instagram
//
//  Created by James  Luberisse on 10/11/21.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    var selectedPost: PFObject!

    let commentBar = MessageInputBar()
    var posts = [PFObject]()
    var showsCommentBar = false
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return showsCommentBar
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.captionLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
            
            cell.photoView.af_setImage(withURL: url);
            return cell
        } else  if indexPath.row  <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                    let comment = comments[indexPath.row - 1]
                    let user = comment["author"] as! PFUser
                    
                    cell.commentLabel.text = comment["text"] as? String
                    cell.nameLabel.text = user.username
                    
                    return cell
        
        
    }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
             
             return cell
            
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground {
            (posts, error) in if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)        // Do any additional setup after loading the view.
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!

        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground {(success, error) in
            if success {
                print("Comment saved")
            }else{
                print("Error saving comments")
            }
        }
        
        tableView.reloadData()
          
          // clear and dismiss the input bar
          commentBar.inputTextView.text = nil
          showsCommentBar = false
          becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
  
    }

    @IBAction func onLogoutButton(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main",bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
 
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    
    }
    
    @IBAction func onLogout(_ sender: Any) {

    }
    
    @objc func keyboardWillBeHidden(note: Notification) {
        
        
        commentBar.inputTextView.text = nil
        showsCommentBar = false;
        becomeFirstResponder()
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
               let comments = (post["comments"] as? [PFObject]) ?? []
               
               if indexPath.row == comments.count + 1 {
                   showsCommentBar = true
                   becomeFirstResponder()
                   commentBar.inputTextView.becomeFirstResponder()
                   
               }
        
        
            selectedPost = pos

        
    }

}
