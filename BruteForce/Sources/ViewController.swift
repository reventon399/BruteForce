//
//  ViewController.swift
//  BruteForce
//
//  Created by Алексей Лосев on 12.10.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    
    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }
    
    //MARK: - Outlets
    
    private lazy var changeColorButton: UIButton = {
       let button = UIButton()
        
        button.addTarget(self, action: #selector(onBut(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var anotherOneButton: UIButton = {
        let button = UIButton()
         
//         button.addTarget(self, action: #selector(onBut(_:)), for: .touchUpInside)
         return button
     }()
    
    private lazy var textField: UITextField = {
       let textField = UITextField()
        return textField
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    //MARK: - Button Actions
    
    @objc private func onBut(_ sender: Any) {
        isBlack.toggle()
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.bruteForce(passwordToUnlock: "1!gr")
        
        // Do any additional setup after loading the view.
    }
    
    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS: [String] = String().printable.map { String($0) }
        
        var password: String = ""
        
        // Will strangely ends at 0000 instead of ~~~
        while password != passwordToUnlock { // Increase MAXIMUM_PASSWORD_SIZE value for more
            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)
            //             Your stuff here
            print(password)
            // Your stuff here
        }
        
        print(password)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index]) : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string
    
    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))
        
        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }
    
    return str
}

