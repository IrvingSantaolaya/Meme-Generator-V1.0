//
//  SentMemeTableViewController.swift
//  Meme Generator
//
//  Created by Irving Martinez on 2/6/19.
//  Copyright © 2019 Irving Martinez. All rights reserved.
//

import UIKit

class SentMemeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Variable that will hold the saved memes
    var memes = [Meme]()
    
    // Instance of the tableview
    @IBOutlet weak var sentMemeTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tableview delegate and datasource
        sentMemeTableview.delegate = self
        sentMemeTableview.dataSource = self
        
        // Access the shared data model and assign it to 'memes'
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
    }
    
    // Reload tableview after the user is done with creating a meme
    override func viewWillAppear(_ animated: Bool) {
        
        // Access to the shared data model
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        sentMemeTableview.reloadData()
    }
    
    // When the user taps on the add button
    @IBAction func addButtonTapped(_ sender: Any) {
        
        let memeGeneratorVC = storyboard?.instantiateViewController(withIdentifier: "CreateMemeViewController") as! MemeGeneratorViewController
        
        present(memeGeneratorVC, animated: true, completion: nil)
        
    }
}




// MARK: - Table view delegate and data source methods

extension SentMemeViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return memes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemesCell", for: indexPath)
        let meme = memes[indexPath.row]
        
        cell.imageView?.image = meme.memedImage
        cell.textLabel?.text = "\(meme.topText) \(meme.bottomText)"
        
        return cell
    }
    
    // Present a meme generator view controller when user taps on cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let memeGeneratorVC = storyboard?.instantiateViewController(withIdentifier: "CreateMemeViewController") as! MemeGeneratorViewController
        
        memeGeneratorVC.sentTopText = memes[indexPath.row].topText
        memeGeneratorVC.sentBottomText = memes[indexPath.row].bottomText
        memeGeneratorVC.sentImage = memes[indexPath.row].originalImage
        
        present(memeGeneratorVC, animated: true, completion: nil)
        
    }
    
    
    
}
