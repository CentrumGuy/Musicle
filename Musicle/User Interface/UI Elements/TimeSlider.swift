//
//  TimeSlider.swift
//  Sine Graph
//
//  Created by Shahar Ben-Dor on 10/30/20.
//  Copyright © 2020 Specter. All rights reserved.
//

import UIKit

// MARK: - Time Slider

/// A slider view specialized for showing time and duration.
open class TimeSlider: UIView, UIGestureRecognizerDelegate {
    
    /// The tint color on the right side of the thumb.
    @IBInspectable open var maximumTrackTintColor: UIColor = .systemFill {
        didSet { mediaProgressView.backgroundColor = maximumTrackTintColor }
    }
    
    /// The tint color on the left side of the thumb.
    @IBInspectable lazy open var minimumTrackTintColor: UIColor = tintColor ?? #colorLiteral(red: 0.3928723335, green: 0.3891946077, blue: 1, alpha: 1) {
        didSet {
            timePassedLabel.textColor = minimumTrackTintColor.withAlphaComponent(0.7)
            timeRemainingLabel.textColor = minimumTrackTintColor.withAlphaComponent(0.7)
            
            if !self.isTracking {
                mediaProgressIndicator.backgroundColor = minimumTrackTintColor
                mediaCompletionView.backgroundColor = minimumTrackTintColor
            }
        }
    }
    
    /// The tint color on the left side of the thumb when actively sliding.
    @IBInspectable lazy open var activeMinimumTrackTintColor: UIColor = minimumTrackTintColor {
        didSet {
            if self.isTracking {
                mediaProgressIndicator.backgroundColor = activeMinimumTrackTintColor
                mediaCompletionView.backgroundColor = activeMinimumTrackTintColor
            }
        }
    }
    
    /// The tint color on the left side of the thumb when disabled.
    @IBInspectable open var disabledMinimumTrackTintColor: UIColor = .secondarySystemFill {
        didSet {
            if !self.isEnabled {
                mediaProgressIndicator.backgroundColor = disabledMinimumTrackTintColor
                mediaCompletionView.backgroundColor = disabledMinimumTrackTintColor
            }
        }
    }
    
    private lazy var mediaProgressView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.backgroundColor = maximumTrackTintColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 4))
        
        mediaCompletionView.layer.cornerRadius = 2
        mediaCompletionView.translatesAutoresizingMaskIntoConstraints = false
        
        mediaProgressIndicator.isHidden = true
        
        view.addSubview(mediaCompletionView)
        view.addSubview(mediaProgressIndicator)
        view.addSubview(timePassedLabel)
        view.addSubview(timeRemainingLabel)
        var constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: mediaProgressIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mediaCompletionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: mediaCompletionView, attribute: .right, relatedBy: .equal, toItem: mediaProgressIndicator, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: timePassedLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: timePassedLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: timeRemainingLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: timeRemainingLabel, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 20),
        ]
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[mediaCompletionView]|", options: [], metrics: nil, views: ["mediaCompletionView": mediaCompletionView])
        view.addConstraints(constraints)
        return view
    }()
    
    private let mediaProgressIndicator: UIView = {
        let view = UIView()
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
        view.layer.cornerRadius = 5
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
        ]
        
        view.addConstraints(constraints)
        return view
    }()
    
    private let mediaCompletionView = UIView()
    
    private lazy var timePassedLabel: UILabel = {
        let label = UILabel()
        label.textColor = minimumTrackTintColor.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "timePassed"
        return label
    }()
    
    private lazy var timeRemainingLabel: UILabel = {
        let label = UILabel()
        label.textColor = minimumTrackTintColor.withAlphaComponent(0.7)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "timeRemaining"
        return label
    }()
    
    
    
    private lazy var mediaCompletionConstraint = NSLayoutConstraint(item: mediaCompletionView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)

    private lazy var panGesture: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        recognizer.delegate = self
        return recognizer
    }()
    
    /// A delegate which can handle update notifications.
    ///
    /// The default value is `nil`.
    weak var delegate: TimeSliderDelegate?
    
    /// A value representing the time progress.
    ///
    /// This value is from `0` to `1` where `0` indicates no progress and `1` indicates full progress.
    /// The default value is `0`.
    open var progress: CGFloat {
        set {
            var adjustedProgress = newValue
            if adjustedProgress < 0 {
                adjustedProgress = 0
            } else if adjustedProgress > 1 {
                adjustedProgress = 1
            }
            
            _progress = adjustedProgress
            let newConstraint = mediaCompletionConstraint.constraintWithMultiplier(max(0.00001, adjustedProgress))
            removeConstraint(mediaCompletionConstraint)
            mediaCompletionConstraint = newConstraint
            addConstraint(mediaCompletionConstraint)
            layoutIfNeeded()
            
            let timePassed = TimeInterval(progress) * mediaDuration
            let timeRemaining = mediaDuration - timePassed
            timePassedLabel.text = timePassed.toString(hoursAllowed: true, millisAllowed: false)
            timeRemainingLabel.text = "-\(timeRemaining.toString(hoursAllowed: true, millisAllowed: false))"
        }

        get {
            return _progress
        }
    }
    private var _progress: CGFloat = 0
    
    @IBInspectable open var mediaDuration: TimeInterval = 0 {
        didSet {
            let progress = self.progress
            self.progress = progress
        }
    }
    
    /// Whether the slider allows user interaction.
    ///
    /// The default value is `true`.
    open var isEnabled: Bool = true {
        didSet {
            if !isEnabled {
                touchesCancelled([], with: nil)
                updateColors()
                return
            }
            
            updateColors()
        }
    }
    
    /// Indicates whether the slider is actively tracking motion.
    open var isTracking: Bool { _isTracking }
    private var _isTracking: Bool = false
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.minimumTrackTintColor = tintColor
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
//        addGestureRecognizer(panGesture)
        addSubview(mediaProgressView)
    
        var constraints: [NSLayoutConstraint] = [
            mediaCompletionConstraint,
            NSLayoutConstraint(item: mediaProgressView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: -10)
        ]
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [.directionLeftToRight], metrics: nil, views: ["view": mediaProgressView])
        addConstraints(constraints)
        updateColors()
        progress = 0
    }

    /// Sets the progress.
    ///
    /// This method can be used at periodic time intervals to update the progress of the time slider to reflect the media progress.
    /// Calling this method will call the `delegate`'s `timeSliderDidUpdateProgress(_:progress:)` method.
    /// - Parameter progress: A value from `0` to `1` indicating the progress of the time slider.
    open func setProgress(to progress: CGFloat) {
        guard !isTracking else { return }
        self.progress = progress
        delegate?.timeSliderDidUpdateProgress?(self, with: progress)
    }
    
    @objc private func didPan(_ panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            guard isEnabled else { return }
            setTracking(true)
            updateColors()
            delegate?.timeSliderDidBeginSliding?(self, with: progress)
            fallthrough
        case .changed:
            guard isTracking else { return }
            let point = panGesture.location(in: mediaProgressView)
            var xLocation = point.x
            if xLocation < 0 {
                xLocation = 0
            } else if xLocation > mediaProgressView.bounds.width {
                xLocation = mediaProgressView.bounds.width
            }

            let newProgress = xLocation / mediaProgressView.bounds.width
            progress = newProgress
            delegate?.timeSliderDidSlide?(self, with: progress)
            delegate?.timeSliderDidUpdateProgress?(self, with: progress)

            UIView.animate(withDuration: 0.2) { [weak this = self] in
                this?.timePassedLabel.transform = newProgress <= 0.2 ? CGAffineTransform(translationX: 0, y: 8) : .identity
                this?.timeRemainingLabel.transform = newProgress >= 0.8 ? CGAffineTransform(translationX: 0, y: 8) : .identity
            }
        case .cancelled, .ended:
            guard isTracking else { return }
            setTracking(false)
            updateColors()
            delegate?.timeSliderDidEndSliding?(self, with: progress)
        default:
            break
        }
    }
    
    private func setTracking(_ toTrack: Bool) {
        _isTracking = toTrack

        UIView.animate(withDuration: 0.2, delay: 0, options: [.allowUserInteraction], animations: { [unowned this = self] in
            this.mediaProgressIndicator.transform = toTrack ? CGAffineTransform(scaleX: 2.5, y: 2.5) : .identity
            if !toTrack {
                this.timePassedLabel.transform = .identity
                this.timeRemainingLabel.transform = .identity
            }
        })
    }

    private func updateColors() {
        guard isEnabled else {
            mediaProgressIndicator.backgroundColor = disabledMinimumTrackTintColor
            mediaCompletionView.backgroundColor = disabledMinimumTrackTintColor
            return
        }

        if isTracking {
            UIView.animate(withDuration: 0.2) { [weak this = self] in
                this?.mediaProgressIndicator.backgroundColor = this!.activeMinimumTrackTintColor
                this?.mediaCompletionView.backgroundColor = this!.activeMinimumTrackTintColor
            }
        } else {
            UIView.animate(withDuration: 0.2) { [weak this = self] in
                this?.mediaProgressIndicator.backgroundColor = this!.minimumTrackTintColor
                this?.mediaCompletionView.backgroundColor = this!.minimumTrackTintColor
            }
        }
    }
    
    
    
    // MARK: - Overriden Methods
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return bounds.offsetBy(dx: 0, dy: -10).insetBy(dx: -32, dy: 0).contains(point)
    }
    
    override open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == self.panGesture else { return super.gestureRecognizerShouldBegin(gestureRecognizer) }
        let locationInThumb = gestureRecognizer.location(in: mediaProgressIndicator)
        let buffer: CGFloat = 32
        return super.gestureRecognizerShouldBegin(gestureRecognizer) && isEnabled && mediaProgressIndicator.bounds.insetBy(dx: -buffer, dy: -buffer).contains(locationInThumb)
    }
}



/// A delegate which can handle update events
@objc public protocol TimeSliderDelegate {
    
    /// Called when the progress of a TimeSlider updates through the `setProgress(to:)` method.
    /// - Parameters:
    ///   - timeSlider: The time slider.
    ///   - progress: The current progress.
    @objc optional func timeSliderDidUpdateProgress(_ timeSlider: TimeSlider, with progress: CGFloat)
    
    /// Called when the user actively slides a time slider.
    /// - Parameters:
    ///   - timeSlider: The time slider.
    ///   - progress: The current progress.
    @objc optional func timeSliderDidSlide(_ timeSlider: TimeSlider, with progress: CGFloat)
    
    /// Called when the user begins to slide a time slider.
    /// - Parameters:
    ///   - timeSlider: The time slider.
    ///   - progress: The current progress.
    @objc optional func timeSliderDidBeginSliding(_ timeSlider: TimeSlider, with progress: CGFloat)
    
    /// Called when the user finishes sliding a time slider.
    /// - Parameters:
    ///   - timeSlider: The time slider.
    ///   - progress: The current progress.
    @objc optional func timeSliderDidEndSliding(_ timeSlider: TimeSlider, with progress: CGFloat)
}





// MARK: - Extensions
private extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

private extension TimeInterval {
    func toString(hoursAllowed: Bool = true, millisAllowed: Bool = false) -> String {
        let time = NSInteger(self)
        
        let ms = millisAllowed ? Int((self.truncatingRemainder(dividingBy: 1)) * 1000) : 0
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        var string = ""
        if hours > 0 && hoursAllowed {
            string += "\(hours):"
        }
        
        if minutes > 0 {
            string += "\(minutes):"
        } else {
            string += "0:"
        }
        
        if seconds > 0 {
            string += String(format: "%0.2d", seconds)
        } else {
            string += "00"
        }
        
        if millisAllowed && ms > 0 {
            string += ":" + String(format: "%0.3d", ms)
        }
        
        return string
    }
}
