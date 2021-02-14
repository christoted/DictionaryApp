//
//  ViewController.swift
//  DictionaryApp
//
//  Created by Christopher Teddy on 10/02/21.
//  Copyright © 2021 Christopher Teddy. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var tfWord: UITextField!
    @IBOutlet weak var tvDictionary: UITableView!
    
    let baseURL = "https://owlbot.info"
    
    var listOfDefintions = [Definition]()
    var listofDictionary = [DictionaryResponse]()
    
    var listofRandomWord = ["owl", "magma", "apple", "eat", "cat","drink", "dog", "food", "orange", "pizza"]
    
    //var context for coredata
    var context: NSManagedObjectContext!
    
    let dictionaryResponse = DictionaryResponse()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Init datasource and delete tableview
        tvDictionary.dataSource = self
        tvDictionary.delegate = self
        
        //Random Word
        let oneRandomWord = listofRandomWord.randomElement() ?? "empty"
        tfWord.text = oneRandomWord
        loadData(oneRandomWord)
        
        
        //Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        
    }
    @IBAction func btnSearch(_ sender: Any) {
        let searchWord = tfWord.text ?? "none"
        loadData(searchWord)
        
    }
    
    @IBAction func btnRefresh(_ sender: Any) {
        let oneRandomWord = listofRandomWord.randomElement() ?? "empty"
        tfWord.text = oneRandomWord
        loadData(oneRandomWord)
    }

    func loadData(_ word: String){
        
        let url = URL(string: "\(baseURL)/api/v4/dictionary/\(word)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Token c656580e0bde878c3c2a3aa3d54db991cf2a66e6", forHTTPHeaderField: "Authorization")
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if ( error != nil) {
                print(error as Any)
            } else {
                let httpResponse = response as? HTTPURLResponse
                
                print(String(decoding: data!, as: UTF8.self))
                
                if (httpResponse?.statusCode == 404) {
                    DispatchQueue.main.async {
                        self.showAlert(title: "Missing", message: "Sorry Unfortunately \(word) not found ")
                    }
                } else {
                    do {
                        
                        let responseObj = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: Any]
                        
                        let arrDefinitions = responseObj["definitions"] as! [[String : Any]]
                        
                        self.listOfDefintions.removeAll()

                        for result in arrDefinitions {
                            
                            let definition = Definition()
                            
                            let type = result["type"] as! String
                            let def = result["definition"] as! String
                            let example = result["example"] as? String
                            let image_url = result["image_url"] as? String
                            let emoji = result["emoji"] as? String
                            
                            
                            if ( image_url != nil) {
                                let url = URL(string: image_url!)
                                
                                let imageTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                                    if ( error != nil) {
                                        print(error?.localizedDescription)
                                        return
                                    }
                                    
                                    definition.image = UIImage(data: data!)

                                    DispatchQueue.main.async {
                                        self.tvDictionary.reloadData()
                                    }


                                    }

                                imageTask.resume()
                            }
                            
                            definition.type = type
                            definition.definition = def
                            definition.example = example
                            definition.image_url = image_url
                            definition.emoji = emoji
                            
                        
                                                     
                            self.listOfDefintions.append(definition)
                            
                        }
                        

                        
            
                        let word = responseObj["word"] as! String
                        let pronunciation = responseObj["pronunciation"] as? String
                        
                        self.dictionaryResponse.definition = self.listOfDefintions
                        self.dictionaryResponse.word = word
                        self.dictionaryResponse.pronunciation = pronunciation
                        
                        
                        self.listofDictionary.append(self.dictionaryResponse)
                    
                        
                        DispatchQueue.main.async {
                            self.tvDictionary.reloadData()
                        }
                        
                    } catch let error {
                        print(error.localizedDescription)
                        
                    }
                }
                
                
            
            }
            
            
        
        }.resume()
        
    }
    
    @IBAction func btnLike(_ sender: Any) {
        
        // Core Data
        let entity = NSEntityDescription.entity(forEntityName: "DictionaryTable", in: self.context)
        
        var word: String!
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DictionaryTable")
        
        do {
            let result = try context.fetch(request) as! [NSManagedObject]
            
            for  i in result {
                word = i.value(forKey: "word") as! String
            }
            
        } catch {
            
        }
                                     
        
                                    
        for i in dictionaryResponse.definition! {
            
       
            
            if ( word == dictionaryResponse.word) {
                showAlert(title: "Warning", message: "This word already saved")
                
                return
            } else {
                
                let newDef = NSManagedObject(entity: entity!, insertInto: self.context)
                
                newDef.setValue(dictionaryResponse.word, forKey: "word")
                newDef.setValue(i.definition, forKey: "definition")
                newDef.setValue(i.emoji, forKey: "emoji")
                newDef.setValue(i.example, forKey: "example")
                newDef.setValue(i.image_url, forKey: "image_url")
                newDef.setValue(i.type, forKey: "type")
            }
            
            
          
        }
        
        do {
            try context.save()
            
        } catch {
            print("Failed To Save")
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if ( editingStyle == .delete) {
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfDefintions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! WordTableViewCell
        
        let word = listOfDefintions[indexPath.row]
        
        if let image = word.image {
            cell.ivWord.image = image
        } else {
            cell.ivWord.image = UIImage(named: "loading1")
        }
        
        cell.lblType.text = listOfDefintions[indexPath.row].type
        
        cell.lblDefinition.text = listOfDefintions[indexPath.row].definition
        
                
    
        return cell
    }
    
    func showAlert(title: String, message: String) {
              let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

              let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
              
              alert.addAction(okAction)
             
              present(alert, animated: true, completion: nil )
          }
    

}

