//
//  ViewController.swift
//  e_legion_TT
//
//  Created by Oleg on 19.02.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    @IBOutlet weak var displayResult: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var alertLabel: UILabel!
    
    var tasks: [Tasks] = []
    
    var stillTyping = false
    var dotIsPlaced = false
    var firstOperand: Double = 0
    var secondOperand: Double = 0
    var operationSing: String = ""
    var workings: String = ""
    
    var currentInput: Double {
        get {
            return Double(displayResult.text!)!
        }
        set {
            let value = "\(newValue)"
            let valueArray = value.components(separatedBy: ".")
            if valueArray[1] == "0" {
                displayResult.text = "\(valueArray[0])"
                historyLabel.text = "\(valueArray[0])"
            } else {
                displayResult.text = "\(newValue)"
            }
            stillTyping = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyLabel.layer.shadowOpacity = 0.8
        historyLabel.layer.shadowRadius = 2
        historyLabel.layer.shadowOffset = CGSize(width: 0, height: 1)
        displayResult.layer.shadowOpacity = 0.8
        displayResult.layer.shadowRadius = 2
        displayResult.layer.shadowOffset = CGSize(width: 0, height: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        do{
            tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        historyLabel.text = tasks.first?.historyData
        displayResult.text = tasks.first?.resultData
        
        alertLabel.isHidden = true
    }
    
    //MARK: mButtons
    @IBAction func mPlusPressedButton(_ sender: UIButton) {
        if tasks.first?.resultData == nil {
            if displayResult.text?.hasPrefix("-") == true  {
                let resultText = displayResult.text?.dropFirst()
                let historyText = historyLabel.text?.dropFirst()
                if let newTask = historyText, let newTask2 = resultText {
                    CoreData.shared.saveTask(withHistoryTitle: String(newTask), withResultTitle: String(newTask2))
                }
            } else {
                let historyText = historyLabel.text
                let resultText = displayResult.text
                
                if let newTask = historyText, let newTask2 = resultText {
                    CoreData.shared.saveTask(withHistoryTitle: newTask, withResultTitle: newTask2)
                }
            }
        } else {
            setAlertLabel()
        }
    }
    
    @IBAction func mMinusPressedButton(_ sender: UIButton) {
        if tasks.first?.resultData == nil {
            let historyText = historyLabel.text
            let resultText = displayResult.text
            
            if let newTask = historyText, let newTask2 = resultText {
                CoreData.shared.saveTask(withHistoryTitle: "-" + newTask, withResultTitle: "-" + newTask2)
            }
        } else {
            setAlertLabel()
        }
    }
    
    @IBAction func mCleanPressedButton(_ sender: UIButton) {
        CoreData.shared.deleteTask()
        alertLabel.isHidden = true
    }
    
    @IBAction func mResultPressedButton(_ sender: UIButton) {
        displayResult.text = tasks.first?.resultData
        historyLabel.text = tasks.first?.historyData
    }
    
    //MARK: numberPressed
    @IBAction func numberPressed(_ sender: UIButton) {
        let number = sender.currentTitle!
        addToWorkings(value: "\(sender.currentTitle!)" )
        if stillTyping {
            displayResult.text = displayResult.text! + number
        } else {
            displayResult.text = number
            stillTyping = true
        }
    }
    
    //MARK: functionAction
    @IBAction func functionAction(_ sender: UIButton) {
        operationSing = sender.currentTitle!
        firstOperand = currentInput
        stillTyping = false
        dotIsPlaced = false
        
        addToWorkings(value: "\(operationSing)")
    }
    
    //MARK: operateWithTwoOperands
    func operateWithTwoOperands(operation: (Double, Double) -> Double) {
        currentInput = operation(firstOperand, secondOperand)
        stillTyping = false
    }
    
    //MARK: equalitySingPressed
    @IBAction func equalitySingPressed(_ sender: UIButton) {
        if stillTyping {
            secondOperand = currentInput
        }
        
        dotIsPlaced = false
        
        switch operationSing {
        case "+": operateWithTwoOperands{$0 + $1}
        case "-": operateWithTwoOperands{$0 - $1}
        case "x": operateWithTwoOperands{$0 * $1}
        case "/": operateWithTwoOperands{$0 / $1}
        case "^": operateWithTwoOperands{a, b in pow(a, b)}
        default: break
        }
    }
    
    //MARK: clearButton
    @IBAction func clearButton(_ sender: UIButton) {
        firstOperand = 0
        secondOperand = 0
        currentInput = 0
        displayResult.text = "0"
        historyLabel.text = "0"
        stillTyping = false
        dotIsPlaced = false
        operationSing = ""
        workings = ""
    }
    
    //MARK: functionButtons
    @IBAction func plusMinusButtonPressed(_ sender: UIButton) {
        historyLabel.text = "\(-currentInput)"
        currentInput = -currentInput
    }
    
    @IBAction func squareRootButtonPressed(_ sender: UIButton) {
        currentInput = sqrt(currentInput)
    }
    
    @IBAction func SquaringButtonPressed(_ sender: UIButton) {
        currentInput = pow(currentInput, 2)
    }
    
    @IBAction func CubingButtonPressed(_ sender: UIButton) {
        currentInput = pow(currentInput, 3)
    }
    
    @IBAction func exponentButtonPressed(_ sender: UIButton) {
        currentInput = exp(currentInput)
    }
    
    @IBAction func piButtonPressed(_ sender: UIButton) {
        currentInput = Double.pi
    }
    
    //MARK: dotButtonPressed
    @IBAction func dotButtonPressed(_ sender: UIButton) {
        if stillTyping && !dotIsPlaced {
            displayResult.text = displayResult.text! + "."
            dotIsPlaced = true
        } else if !stillTyping && !dotIsPlaced {
            displayResult.text = "0."
        }
    }
    
    //MARK: addToWorkings
    func addToWorkings(value: String){
        if dotIsPlaced {
            historyLabel.text =  historyLabel.text! + "."  + value
        } else {
            workings = workings + value
            historyLabel.text = workings
        }
    }
    
    //MARK: setAlertLabel
    func setAlertLabel() {
        alertLabel.text = "Очистите старое значение нажав mc"
        alertLabel.isHidden = false
        alertLabel.textColor = .systemRed
    }
}

