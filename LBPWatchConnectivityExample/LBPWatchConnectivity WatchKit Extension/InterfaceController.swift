//
//  InterfaceController.swift
//  LBPWatchConnectivity WatchKit Extension
//
//  Created by Leonardo Barros on 12/6/15.
//  Copyright © 2015 leonardobarros. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    // MARK: - Properties
    
    @IBOutlet var messageLabel: WKInterfaceLabel!
    @IBOutlet var replyYesButton: WKInterfaceButton!
    @IBOutlet var replyNoButton: WKInterfaceButton!
    
    lazy var watchSession : WCSession = {
        let session = WCSession.defaultSession()
        session.delegate = self
        return session
    }()
    
    
    // MARK: - Interface Life Cycle
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        configInitialViewState()
        
        if WCSession.isSupported() {
            watchSession.activateSession()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    
    // MARK: - Enable/Disable items
    
    func configInitialViewState() {
        replyYesButton.setEnabled(false)
        replyNoButton.setEnabled(false)
        messageLabel.setText("Waiting iPhone")
    }
    
    func enableButtons() {
        replyYesButton.setEnabled(true)
        replyNoButton.setEnabled(true)
    }
    
    
    // MARK: - Actions
    
    @IBAction func replyYesToIPhone() {
        replyToIPhone(true)
    }
    
    @IBAction func replyNoToIphone() {
        replyToIPhone(false)
    }
    
    func replyToIPhone(confirm: Bool) {
        configInitialViewState()
        
        let resultMessage: String
        if confirm {
            resultMessage = "Yes"
        } else {
            resultMessage = "No"
        }
        
        let messageToSend = ["message": resultMessage]
        watchSession.sendMessage(messageToSend, replyHandler: nil) { error in
            print("Error on send message to iPhone - \(error.localizedDescription)")
        }
    }
    
}


// MARK: - WCSessionDelegate

extension InterfaceController: WCSessionDelegate {
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        guard let messageText = message["message"] as? String else { return }
        messageLabel.setText("iPhone said:\n \(messageText)")
        
        self.enableButtons()
        replyHandler(["received": "ok"])
    }
    
}
