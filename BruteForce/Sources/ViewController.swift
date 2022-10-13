//
//  ViewController.swift
//  BruteForce
//
//  Created by Алексей Лосев on 12.10.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    //MARK: - Private properties
    
    
    private var isBlack: Bool = false {
        
        didSet {
            if isBlack {
                view.backgroundColor = .black
                label.textColor = .white
                changeColorButton.tintColor = .white
                startBruteForceButton.tintColor = .white
                stopBruteForceButton.tintColor = .white
                resetButton.tintColor = .white
                passwordActivityIndicator.color = .white
                textField.textColor = .white
                textField.layer.borderColor = whiteTextFieldBorderColor.cgColor
            } else {
                view.backgroundColor = .white
                label.textColor = .black
                changeColorButton.tintColor = .black
                startBruteForceButton.tintColor = .black
                stopBruteForceButton.tintColor = .black
                resetButton.tintColor = .black
                passwordActivityIndicator.color = .black
                textField.textColor = .black
                textField.layer.borderColor = blackTextFieldBorderColor.cgColor
            }
        }
    }
    
    private var isBruteForceStopped = false
    private let whiteTextFieldBorderColor = UIColor.white
    private let blackTextFieldBorderColor = UIColor.black
    
    //MARK: - Outlets
    
    private lazy var changeColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Color", for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(onBut(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var startBruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(startBruteForce), for: .touchUpInside)
        return button
    }()
    
    private lazy var stopBruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Stop", for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 20
        button.isHidden = true
        
        button.addTarget(self, action: #selector(stopBruteForce), for: .touchUpInside)
        return button
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.tintColor = .black
        
        button.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.placeholder = "Type your password here"
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 20
        return textField
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Let's hack your password"
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var passwordActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.isHidden = true
        return indicator
    }()
    
    //MARK: - Buttons Actions
    
    @objc private func onBut(_ sender: Any) {
        isBlack.toggle()
    }
    
    @objc private func startBruteForce() {
            if textField.text == "" {
                showEmptyTextFieldAlert()
            } else {
                guard let password = textField.text else { return }
                let queue = DispatchQueue(
                    label: "bruteForce",
                    qos: .background
                )
                queue.async {
                    self.bruteForce(passwordToUnlock: password)
                }
                passwordActivityIndicator.startAnimating()
                passwordActivityIndicator.isHidden = false
                stopBruteForceButton.isHidden = false
            }
    }
    
    @objc private func stopBruteForce() {
        isBruteForceStopped = true
        passwordActivityIndicator.isHidden = true
        passwordActivityIndicator.stopAnimating()
        stopBruteForceButton.isHidden = true
    }
    
    @objc private func resetButtonPressed() {
        label.text = ""
        label.textColor = .black
        textField.isSecureTextEntry = true
        textField.text = ""
        passwordActivityIndicator.isHidden = true
        passwordActivityIndicator.stopAnimating()
        isBruteForceStopped = false
    }
    
    //MARK: - Alert
    
   private func showEmptyTextFieldAlert() {
        let alert = UIAlertController(
            title: "Empty Text Field",
            message: "Write your password in text field for correct working of this app",
            preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { event in
            
        }))
        self.present(alert, animated: true)
    }
    
    //MARK: - BruteForce methods
    
   private func bruteForce(passwordToUnlock: String) {
       
        let allowedCharacters: [String] = String().printable.map { String($0) }
        var password: String = ""

           while password != passwordToUnlock {
               if isBruteForceStopped {
                   DispatchQueue.main.async { [self] in
                       changeInterface(password: textField.text ?? "", isSucceded: false)
                   }
                   break
               }
               password = generateBruteForce(password, fromArray: allowedCharacters)
               DispatchQueue.main.async { [self] in
                   label.text = password
               }
           }
       
       if !isBruteForceStopped {
           DispatchQueue.main.async { [self] in
               changeInterface(password: password, isSucceded: true)
           }
       }
    }
    
    private func changeInterface(password: String, isSucceded: Bool) {
        if isSucceded {
            let successText = "Your password is: \(password)"
            label.text = successText
            label.textColor = .systemGreen
            textField.isSecureTextEntry = false
            passwordActivityIndicator.isHidden = true
            passwordActivityIndicator.stopAnimating()
            stopBruteForceButton.isHidden = true
        } else {
            let failureText = "Your password: \(password) wasn't hacked"
            label.text = failureText
            label.textColor = .systemRed
        }
    }
    
    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }
    
    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index]) : Character("")
    }
    
    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var initialString: String = string
        
        if initialString.count <= 0 {
            initialString.append(characterAt(index: 0, array))
        }
        else {
            initialString.replace(at: initialString.count - 1,
                                  with: characterAt(index: (indexOf(character: initialString.last!, array) + 1) % array.count, array))
            if indexOf(character: initialString.last!, array) == 0 {
                initialString = String(generateBruteForce(String(initialString.dropLast()), fromArray: array)) + String(initialString.last!)
            }
        }
        return initialString
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupHierarchy()
        setupLayout()
    }
    
    //MARK: - Setup
    
    private func setupHierarchy() {
        view.addSubview(changeColorButton)
        view.addSubview(startBruteForceButton)
        view.addSubview(resetButton)
        view.addSubview(textField)
        view.addSubview(label)
        view.addSubview(passwordActivityIndicator)
        view.addSubview(stopBruteForceButton)
    }
    
    private func setupLayout() {
        
        textField.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY).offset(-150)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(50)
        }
        
        label.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.top.equalTo(textField.snp.bottom).offset(50)
            make.left.equalTo(view.snp.left).offset(50)
            make.right.equalTo(view.snp.right).offset(-50)
        }
        
        passwordActivityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(label.snp.bottom).offset(50)
        }
        
        changeColorButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.left.equalTo(view.snp.left).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        stopBruteForceButton.snp.makeConstraints { make in
            make.top.equalTo(passwordActivityIndicator.snp.bottom).offset(50)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(50)
        }
        
        startBruteForceButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.left.equalTo(changeColorButton.snp.right).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
        
        resetButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.left.equalTo(startBruteForceButton.snp.right).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(50)
        }
    }
}


