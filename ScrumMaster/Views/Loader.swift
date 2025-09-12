import Combine
import UIKit
import SwiftUI

final class LoaderView: UIView {
    var animated: Bool = false {
        didSet { animated ? startTimer() : stopTimer() }
    }
    
    let progressSubject = CurrentValueSubject<Float, Never>(0.0)
    
    private var timer: Timer?
    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    deinit {
        stopTimer()
        progressSubject.send(completion: .finished)
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
            // If removed from hierarchy, stop the timer
        if window == nil { stopTimer() }
    }
    
    private func setupLayers() {
        let lineWidth: CGFloat = 8.0
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let lineWidth: CGFloat = 8.0
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let circularPath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 1.5 * CGFloat.pi,
            clockwise: true
        )
        trackLayer.path = circularPath.cgPath
        progressLayer.path = circularPath.cgPath
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { [weak self] _ in
            guard let self else { return }
            var v = self.progressSubject.value + 0.1
            if v > 1.0 { v = 0.0 }
            self.progressSubject.send(v)
            self.progressLayer.strokeEnd = CGFloat(v)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct Loader: UIViewRepresentable {
    @Binding var progress: Float
    var animated: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(progress: $progress)
    }
    
    func makeUIView(context: Context) -> LoaderView {
        let view = LoaderView(frame: .zero)
        
            // Break the retain cycle: weakly capture coordinator, and cancel later.
        view.progressSubject
            .receive(on: RunLoop.main)
            .sink { [weak coordinator = context.coordinator] value in
                coordinator?.updateProgress(value)
            }
            .store(in: &context.coordinator.subscriptions)
        
            // Trigger timer via didSet
        view.animated = animated
        return view
    }
    
    func updateUIView(_ uiView: LoaderView, context: Context) {
        uiView.animated = animated
    }
    
    static func dismantleUIView(_ uiView: LoaderView, coordinator: Coordinator) {
            // Explicitly cancel Combine subscriptions and stop the timer
        coordinator.subscriptions.forEach { $0.cancel() }
        coordinator.subscriptions.removeAll()
        uiView.stopTimer()
    }
    
    final class Coordinator: NSObject {
        var progress: Binding<Float>
        var subscriptions = Set<AnyCancellable>()
        init(progress: Binding<Float>) { self.progress = progress }
        func updateProgress(_ newProgress: Float) { progress.wrappedValue = newProgress }
    }
}
