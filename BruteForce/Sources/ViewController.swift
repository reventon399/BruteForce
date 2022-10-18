//
//  ViewController.swift
//  BruteForce
//
//  Created by Алексей Лосев on 12.10.2022.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    //MARK: - Properties
    
    private var isBruteForceStopped = false
    private let whiteTextFieldBorderColor = UIColor.white
    private let blackTextFieldBorderColor = UIColor.black
    
    private var isBlack: Bool = false {
        didSet {
            DispatchQueue.main.async { [self] in
                if isBlack {
                    view.backgroundColor = .black
                    passwordLabel.textColor = .white
                    changeColorButton.tintColor = .white
                    startBruteForceButton.tintColor = .white
                    stopBruteForceButton.tintColor = .white
                    resetButton.tintColor = .white
                    passwordActivityIndicator.color = .white
                    passwordTextField.textColor = .white
                    passwordTextField.layer.borderColor = whiteTextFieldBorderColor.cgColor
                    passwordTextField.attributedPlaceholder = NSAttributedString(
                        string: "Type your password here",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
                } else {
                    view.backgroundColor = .white
                    passwordLabel.textColor = .black
                    changeColorButton.tintColor = .black
                    startBruteForceButton.tintColor = .black
                    stopBruteForceButton.tintColor = .black
                    resetButton.tintColor = .black
                    passwordActivityIndicator.color = .black
                    passwordTextField.textColor = .black
                    passwordTextField.layer.borderColor = blackTextFieldBorderColor.cgColor
                    passwordTextField.attributedPlaceholder = NSAttributedString(
                        string: "Type your password here",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                }
            }
        }
    }
    
    //MARK: - Outlets
    
    private lazy var changeColorButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Change Color", for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 20
        
        
        button.addTarget(self, action: #selector(changeTheme), for: .touchUpInside)
        return button
    }()
    
    private lazy var startBruteForceButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Start", for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 20
        
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
        button.isEnabled = false
        button.setTitle("Reset", for: .normal)
        button.tintColor = .black
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 20
        
        button.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var changeColorStartResetButtonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [changeColorButton,
                                                   startBruteForceButton,
                                                   resetButton])
        stack.axis = .horizontal
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(
            string: "Type your password here",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        textField.textAlignment = .center
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 20
        return textField
    }()
    
    private lazy var passwordLabel: UILabel = {
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
    
    @objc private func changeTheme() {
        DispatchQueue.main.async { [self] in
            isBlack.toggle()
        }
    }
    
    @objc private func startBruteForce() {
        if passwordTextField.text == "" {
            showEmptyTextFieldAlert()
        } else {
            startBruteForceButton.isUserInteractionEnabled = false
            passwordTextField.isUserInteractionEnabled = false
            guard let password = passwordTextField.text else { return }
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
        resetButton.isEnabled = true
        isBruteForceStopped = true
        passwordActivityIndicator.isHidden = true
        passwordActivityIndicator.stopAnimating()
        stopBruteForceButton.isHidden = true
    }
    
    @objc private func resetButtonPressed() {
        if view.backgroundColor == .black {
            passwordLabel.textColor = .white
        } else {
            passwordLabel.textColor = .black
        }
        startBruteForceButton.isUserInteractionEnabled = true
        passwordTextField.isUserInteractionEnabled = true
        passwordLabel.text = "Let's hack your password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.text = ""
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
    
    private func showNotEmptyTextFieldAlert() {
        let alert = UIAlertController(
            title: "Text Field isn't empty",
            message: "Tap on "+"Reset"+" button before start hacking",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        alert.addAction(UIAlertAction(title: "Reset", style: .default, handler: { [self] event in
            isBruteForceStopped = true
            stopBruteForceButton.isHidden = true
            passwordTextField.text = ""
            passwordTextField.isSecureTextEntry = true
        }))
    }
    
    //MARK: - BruteForce methods
    
    private func bruteForce(passwordToUnlock: String) {
        
        let allowedCharacters: [String] = String().printable.map { String($0) }
        var password: String = ""
        
        while password != passwordToUnlock {
            if isBruteForceStopped {
                DispatchQueue.main.async { [self] in
                    changeInterface(password: passwordTextField.text ?? "", isSucceded: false)
                }
                break
            }
            password = generateBruteForce(password, fromArray: allowedCharacters)
            DispatchQueue.main.async { [self] in
                passwordLabel.text = password
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
            let successText = """
            Your password is: \(password)
            Press "Reset" to check another password
            """
            passwordLabel.text = successText
            passwordLabel.textColor = .systemGreen
            passwordTextField.isSecureTextEntry = false
            passwordActivityIndicator.isHidden = true
            passwordActivityIndicator.stopAnimating()
            stopBruteForceButton.isHidden = true
        } else {
            let failureText = """
            Your password: \(password) wasn't hacked.
            Press "Reset" to check another password
            """
            passwordLabel.text = failureText
            passwordLabel.textColor = .systemRed
            passwordTextField.isSecureTextEntry = false
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
        view.addSubview(passwordTextField)
        view.addSubview(passwordLabel)
        view.addSubview(passwordActivityIndicator)
        view.addSubview(stopBruteForceButton)
        view.addSubview(changeColorStartResetButtonsStack)
    }
    
    private func setupLayout() {
        passwordTextField.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY).offset(-150)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(50)
        }
        
        passwordLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view.snp.centerY)
            make.top.equalTo(passwordTextField.snp.bottom).offset(50)
            make.left.equalTo(view.snp.left).offset(50)
            make.right.equalTo(view.snp.right).offset(-50)
        }
        
        passwordActivityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(passwordLabel.snp.bottom).offset(50)
        }
        
        changeColorStartResetButtonsStack.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalTo(view.snp.bottom).offset(-20)
            make.height.equalTo(50)
        }
        
        stopBruteForceButton.snp.makeConstraints { make in
            make.top.equalTo(passwordActivityIndicator.snp.bottom).offset(50)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.height.equalTo(50)
        }
    }
}


