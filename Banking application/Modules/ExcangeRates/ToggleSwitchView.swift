//
//  ToggleSwitchView.swift
//  Lesson 15
//
//  Created by Andrei Atrakhimovich on 17.04.25.
//

import UIKit

class ToggleSwitchView: UIControl {

    private let onImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "star.fill")
        image.tintColor = .systemYellow
        image.alpha = 0
        return image
    }()

    private let offImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(systemName: "star")
        image.tintColor = .systemYellow
        return image
    }()

    var isOn = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(onImageView)
        addSubview(offImageView)

        NSLayoutConstraint.activate([
            onImageView.topAnchor.constraint(equalTo: topAnchor),
            onImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            onImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            onImageView.bottomAnchor.constraint(equalTo: bottomAnchor),

            offImageView.topAnchor.constraint(equalTo: topAnchor),
            offImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            offImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            offImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)
        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Избранное"
        updateUI()
    }

    @objc private func handleTap() {
        isOn.toggle()
        updateUI()
        sendActions(for: .valueChanged)
    }

    func setValue(_ value: Bool) {
        guard isOn != value else { return }
        isOn = value
        updateUI()
    }

    private func updateUI() {
        UIView.animate(withDuration: 0.5) {
            self.onImageView.alpha = self.isOn ? 1 : 0
            self.offImageView.alpha = self.isOn ? 0 : 1
        }
        accessibilityValue = isOn ? "В избранном" : "Не в избранном"
    }
}

