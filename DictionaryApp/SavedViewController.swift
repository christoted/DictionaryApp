//
//  SavedViewController.swift
//  DictionaryApp
//
//  Created by Christopher Teddy on 11/02/21.
//  Copyright © 2021 Christopher Teddy. All rights reserved.
//

import UIKit
import CoreData

class SavedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tvSavedWord: UITableView!
    @IBOutlet weak var lblDataIndicator: UILabel!
    
    //var context for coredata
    var context: NSManagedObjectContext!
    
    var arrSection = [String]()
    var listOfDefintions = [Definition]()
    var listofDictionary = [DictionaryResponse]()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        //Core Data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
        
        tvSavedWord.delegate = self
        tvSavedWord.dataSource = self
        
        getData()
        
    }
    
    func deleteData(indexPath: IndexPath) {
        let oldWord = listofDictionary[indexPath.section].word as! String
        let oldListDefinition = listofDictionary[indexPath.section].definition
        let oldDefinition = listofDictionary[indexPath.section].definition?[indexPath.row].definition as! String
        
        let oldEmoji = listofDictionary[indexPath.section].definition?[indexPath.row].emoji as? String
        let oldExample = listofDictionary[indexPath.section].definition?[indexPath.row].example as? String
        let oldImageURL = listofDictionary[indexPath.section].definition?[indexPath.row].image_url as? String
        let oldType = listofDictionary[indexPath.section].definition?[indexPath.row].type as! String
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DictionaryTable")
        
        if (oldImageURL == nil) {
              request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "word == %@", oldWord), NSPredicate(format: "definition == %@", oldDefinition), NSPredicate(format: "type == %@", oldType)])
        } else {
              request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "word == %@", oldWord), NSPredicate(format: "definition == %@", oldDefinition), NSPredicate(format: "type == %@", oldType),
              NSPredicate(format: "image_url == %@", oldImageURL!)
              ])
        }
        
           
             
              do {
                     let results = try context.fetch(request) as! [NSManagedObject]
                        
                     for data in results {
                         context.delete(data)
                         
                     }
                 
                     try context.save()
                     getData()
                     
                    }catch{
                        
                 }
    }
    
    func getData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DictionaryTable")
        
        listofDictionary.removeAll()
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
           
            for i in results {
                
                listOfDefintions.removeAll()
              
                let dictionary = DictionaryResponse()
                let definition = Definition()
        
                
                let def = i.value(forKey: "definition") as? String
                let emoji = i.value(forKey: "emoji") as? String
                let example = i.value(forKey: "example") as? String
                let image_url = i.value(forKey: "image_url") as? String
                let pronunciation = i.value(forKey: "pronunciation") as? String
                let type = i.value(forKey: "type") as? String
                let word = i.value(forKey: "word") as? String
                
              
            
                definition.type = type
                definition.definition = def
                definition.example = example
                definition.emoji = emoji
                
                if ( image_url != nil) {
                    definition.image_url = image_url
                    
                    let url = URL(string: image_url!)
                    
                    let imageTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        if ( error != nil) {
                            print(error?.localizedDescription)
                            return
                        }
                        
                        definition.image = UIImage(data: data!)
                        
                        DispatchQueue.main.async {
                            self.tvSavedWord.reloadData()
                        }
                        
                        
                    }
                    
                    imageTask.resume()
                    
                }
                
                
                listOfDefintions.append(definition)
                
                dictionary.definition = listOfDefintions
                
                
                dictionary.word = word
                

                listofDictionary.append(dictionary)
            }
            
            if ( listofDictionary.count != 0) {
                lblDataIndicator.isHidden = true
            } else {
                lblDataIndicator.isHidden = false
            }
            
            tvSavedWord.reloadData()
            
            
        } catch {
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    // Section
    func numberOfSections(in tableView: UITableView) -> Int {

        return listofDictionary.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listofDictionary[section].word
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if ( listofDictionary[section].definition?.count == nil) {
            return 0
        } else {
             return listofDictionary[section].definition!.count
        }
    
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_save") as! WordSaveTableViewCell
        
        let wordDef = listofDictionary[indexPath.section].definition?[indexPath.row]
        
        cell.lblTypeSave.text = listofDictionary[indexPath.section].definition?[indexPath.row].type
        
        cell.lblDefinitionSave.text = listofDictionary[indexPath.section].definition?[indexPath.row].definition
        
        if let image = wordDef?.image {
            cell.ivWordSave.image = image
        } else {
            cell.ivWordSave.image = UIImage(named: "loading1")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if ( editingStyle == .delete) {
       
            deleteData(indexPath: indexPath)
            
            }
        }
    }


