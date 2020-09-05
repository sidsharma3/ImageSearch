//
//  ViewController.swift
//  ImageIdInfo
//
//  Created by Sid Sharma on 2020-09-04.
//  Copyright © 2020 Sid Sharma. All rights reserved.
//

import Alamofire
import SwiftyJSON
import SDWebImage
import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let imagePicker = UIImagePickerController()
    let baseURl = "https://en.wikipedia.org/w/api.php"
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .camera
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let userPickedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        
        guard let ciImage = CIImage(image: userPickedImage) else {
            fatalError("Conversion Issues happend when converting CIImage")
        }
        detect(image: ciImage)
        
        // leave the camera screen
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        // call on inception model
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("There is an issure when importing the model")
        }
        // classify image
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let classification = request.results?.first as? VNClassificationObservation else {
                fatalError("Could not classify the image")
            }
            let finalRes = classification.identifier.components(separatedBy: ",").first?.capitalized
            self.navigationItem.title = finalRes
            print(finalRes!)
            self.requestInfo(objectName: finalRes!)
        }
        // calls function to classify image
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
        } catch {
            print(error)
        }
        
    }
    // get data from wikipedia.
    func requestInfo(objectName: String) {
        
        Alamofire.request(baseURl, method: .get, parameters: [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts|pageimages",
        "exintro" : "",
        "explaintext" : "",
        "titles" : objectName,
        "indexpageids" : "",
        "redirects" : "1",
        "pithumbsize" : "500"
        ]).responseJSON { (response) in
            if response.result.isSuccess {
                print("got the info")
                print(response)
                
                let objectJSON : JSON = JSON(response.result.value!)
                
                let pageid = objectJSON["query"]["pageids"][0].stringValue
                
                let objectDescription  = objectJSON["query"]["pages"][pageid]["extract"].stringValue
                
                let classificationImageURL = URL(string: objectJSON["query"]["pages"][pageid]["thumbnail"]["source"].stringValue)
                
                self.imageView.sd_setImage(with: classificationImageURL)
                
                self.label.text = objectDescription
                
                
                
            }
        }
    }
    // thisn function is what allows the two controllers to connect to each other.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination : ReadViewController = segue.destination as! ReadViewController
        
        destination.dataToRead = self.label.text!
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
    // call to the other veiw controller
    @IBAction func ReadToMePressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ReadConnection", sender: self)
    }
    
}

