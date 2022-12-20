import ReactiveCocoa
import ReactiveSwift
import UIKit

final class ViewController: UIViewController {
    @IBOutlet
    private weak var date: UILabel!
    @IBOutlet
    private weak var button: UIButton!
    
    private var dateProperty = MutableProperty<String>("")
    private let dateFormater = DateFormatter()
    private let colors : [UIColor] = [.red, .blue, .brown, .cyan, .darkGray, .gray, .green, .lightGray, .magenta, .orange, .purple, .yellow]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTimer()
        initDateFormater()
        initDate()
        initBackGround()
        initButton()
    }
}

private extension ViewController {
    func initTimer() {
        Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(handleTimerExecution),
            userInfo: nil,
            repeats: true
        )
    }
    
    func initButton() {
        let action: Action<Void, Void, Never> = .init { _ in
            .empty
            .delay(2.0, on: QueueScheduler.main)
        }
        
        button.reactive.title <~ dateProperty
            .signal
            .map(\.count.description)
            .skipRepeats()
            .producer
            .observe(on: UIScheduler())
            .prefix(value: dateProperty.value.count.description)
            .logEvents()
        
        button.reactive.isUserInteractionEnabled <~ action.isExecuting
            .map { !$0 }
            .skipRepeats()
            .producer
            .observe(on: UIScheduler())
            .prefix(value: true)
            .logEvents(
                identifier: "[REACTIVE] [Clock]",
                fileName: "ViewController"
            )
        
        button.reactive.pressed = CocoaAction(action)
    }
    
    func initDateFormater() {
        dateFormater.timeStyle = .long
    }
    
    func initDate() {
        updateProperty()
        date.reactive.text <~ dateProperty
            .signal
            .producer
            .observe(on: UIScheduler())
            .prefix(value: dateProperty.value)
    }
    
    func updateProperty() {
        dateProperty.value = dateFormater.string(from: Date())
    }
    
    func initBackGround() {
        view.reactive.backgroundColor <~ dateProperty
            .signal
            .map { _ in self.colors[Int.random(in: 0...11)] }
            .delay(2.0, on: QueueScheduler.main)
            .producer
            .observe(on: UIScheduler())
            .prefix(value: .systemCyan)
            .logEvents()
    }
    
    @objc
    func handleTimerExecution() {
        updateProperty()
    }
}
