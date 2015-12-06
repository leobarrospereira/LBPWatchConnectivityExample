//
//  LBPMainViewController.swift
//  LBPWatchConnectivity
//
//  Created by Leonardo Barros on 12/6/15.
//  Copyright © 2015 leonardobarros. All rights reserved.
//

import UIKit
import WatchConnectivity

class MainViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var watchMessageLabel: UILabel!
    
    lazy var watchSession : WCSession = {
        let session = WCSession.defaultSession()
        session.delegate = self
        return session
    }()
    
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        watchMessageLabel.text = ""
        
        if WCSession.isSupported() {
            watchSession.activateSession()
        }
    }

    
    // MARK: - Actions
    
    @IBAction func sendMessageToWatch(sender: AnyObject) {
        guard let message = messageTextField.text else { return }
        watchMessageLabel.text = ""
        
        watchSession.sendMessage(["message" : message], replyHandler: { dictReply in
            guard let _ = dictReply["received"] else { return }
            
            dispatch_async(dispatch_get_main_queue()) {
                self.watchMessageLabel.text = "Watch received the message";
            }
            
            }) { error in
                print("Error sending message to watch - \(error.localizedDescription)")
            }
    }
    
}


// MARK: - WCSessionDelegate

extension MainViewController: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        guard let messageText = message["message"] as? String else { return }
        dispatch_async(dispatch_get_main_queue()) {
            self.watchMessageLabel.text = "Watch said: \(messageText)"
            self.messageTextField.text = ""
        }
    }
    
}
