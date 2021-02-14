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
    
    // For Section
    var arrSection = [String]()
    var arrDictionary = [[DictionaryModel]]()
    
    
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
//        let oldWord = listofDictionary[indexPath.section].word as! String
//        let oldListDefinition = listofDictionary[indexPath.section].definition
//        let oldDefinition = listofDictionary[indexPath.section].definition?[indexPath.row].definition as! String
//
//        let oldEmoji = listofDictionary[indexPath.section].definition?[indexPath.row].emoji as? String
//        let oldExample = listofDictionary[indexPath.section].definition?[indexPath.row].example as? String
//        let oldImageURL = listofDictionary[indexPath.section].definition?[indexPath.row].image_url as? String
//        let oldType = listofDictionary[indexPath.section].definition?[indexPath.row].type as! String
        
        let oldWord = arrDictionary[indexPath.section][indexPath.row].word as! String
        let oldDefinition = arrDictionary[indexPath.section][indexPath.row].definition as! String
        let oldEmoji = arrDictionary[indexPath.section][indexPath.row].emoji as? String
        let oldExample = arrDictionary[indexPath.section][indexPath.row].example as? String
        let oldImageURL = arrDictionary[indexPath.section][indexPath.row].image_url as? String
        let oldType = arrDictionary[indexPath.section][indexPath.row].type as! String
        
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
        
        arrSection.removeAll()
        arrDictionary.removeAll()
        do {
            let results = try context.fetch(request) as! [NSManagedObject]
           
            for i in results {
            
                let dictionaryModel = DictionaryModel()
        
                
                let def = i.value(forKey: "definition") as? String
                let emoji = i.value(forKey: "emoji") as? String
                let example = i.value(forKey: "example") as? String
                let image_url = i.value(forKey: "image_url") as? String
                let pronunciation = i.value(forKey: "pronunciation") as? String
                let type = i.value(forKey: "type") as? String
                let word = i.value(forKey: "word") as? String
                
              
        
                
                dictionaryModel.type = type
                dictionaryModel.definition = def
                dictionaryModel.example = example
                dictionaryModel.emoji = emoji
                dictionaryModel.word = word

                
                if ( image_url != nil) {
                    dictionaryModel.image_url = image_url

                    let url = URL(string: image_url!)
                    
                    let imageTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                        if ( error != nil) {
                            print(error?.localizedDescription)
                            return
                        }
                        

                        dictionaryModel.image = UIImage(data: data!)
                        
                        DispatchQueue.main.async {
                            self.tvSavedWord.reloadData()
                        }
                        
                        
                    }
                    
                    imageTask.resume()
                    
                }
                
                if ( arrSection.count == 0) {
                    arrSection.append(dictionaryModel.word!)
                   
                    for i in 0...arrSection.count-1 {
                        arrDictionary.append([DictionaryModel]())
                        arrDictionary[i].append(dictionaryModel)
                    }
                    print("TEST")

                   
                } else {
                    var position: Int?
                    var flag: Int = 0
                    for i in 0...arrSection.count-1 {
                      
                        if ( dictionaryModel.word == arrSection[i]) {
                            arrDictionary.append([DictionaryModel]())
                            flag = 1
                            position = i
                            arrDictionary[i].append(dictionaryModel)
                            print("\(position!)")
                            break

                        }
                    }
                    print("TEST")

                    if flag == 0 {
                        arrDictionary.append([DictionaryModel]())
                        arrSection.append(dictionaryModel.word!)
                        arrDictionary[arrSection.count-1].append(dictionaryModel)
                    }
                }
            }
        
            
            if ( arrDictionary.count != 0) {
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

        return arrSection.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrSection[section]
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arrDictionary.append([DictionaryModel]())
        if ( arrDictionary[section].count == 0) {
            
            
            return 0
        } else {
             return arrDictionary[section].count
        }
        return 0
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_save") as! WordSaveTableViewCell
        
        
        let wordDef = arrDictionary[indexPath.section][indexPath.row]
        
        cell.lblTypeSave.text = arrDictionary[indexPath.section][indexPath.row].type
        
        cell.lblDefinitionSave.text = arrDictionary[indexPath.section][indexPath.row].definition
        
        if let image = wordDef.image {
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


