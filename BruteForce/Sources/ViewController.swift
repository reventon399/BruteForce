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
    
    private var isBruteForceStarted = false
    
    private var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
                self.label.textColor = .white
                self.changeColorButton.tintColor = .white
                self.startBruteForceButton.tintColor = .white
                self.resetButton.tintColor = .white
            } else {
                self.view.backgroundColor = .white
                self.label.textColor = .black
                self.changeColorButton.tintColor = .black
                self.startBruteForceButton.tintColor = .black
                self.resetButton.tintColor = .black
            }
        }
    }
    
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
            }
    }
    
    @objc private func stopBruteForce() {
        
    }
    
    @objc private func resetButtonPressed() {
        isBruteForceStarted = false
        textField.text = ""
        label.text = "Let's hack your password"
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
               if isBruteForceStarted {
                   DispatchQueue.main.async { [self] in
                       changeInterface(password: textField.text ?? "", isHacked: false)
                   }
                   break
               }
               password = generateBruteForce(password, fromArray: allowedCharacters)
               DispatchQueue.main.async { [self] in
                   label.text = password
               }
           }
       if !isBruteForceStarted {
           DispatchQueue.main.async { [self] in
               changeInterface(password: password, isHacked: true)
           }
       }
    }
    
    private func changeInterface(password secretKey: String, isHacked: Bool) {
        if isHacked {
                  let successText = "Password is found:\n\(secretKey)"
                  self.label.text = successText
                  self.label.textColor = .systemGreen
                  self.textField.isSecureTextEntry = false
                  self.passwordActivityIndicator.isHidden = true
                  self.passwordActivityIndicator.stopAnimating()
              } else {
                  let failureText = "Password \n\(secretKey)\n not hacked"
                  self.label.text = failureText
                  self.label.textColor = .systemRed
              }
    }
    
    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }
    
    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index]) : Character("")
    }
    
    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
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


