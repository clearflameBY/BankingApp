//
//  TableViewCell.swift
//  Banking application
//
//  Created by Илья Степаненко on 22.09.25.
//

import UIKit
import SnapKit

class TableViewCell: UITableViewCell {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 10, weight: .regular)
        return label
    }()

    private let starView: ToggleSwitchView = {
        let v = ToggleSwitchView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Called when you tap on the star
    var onToggleFavorite: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(starView)

        starView.addTarget(self, action: #selector(starValueChanged(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            starView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            starView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            starView.widthAnchor.constraint(equalToConstant: 40),
            starView.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: starView.leadingAnchor, constant: -8),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(lessThanOrEqualTo: starView.leadingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
        descriptionLabel.snp.makeConstraints { make in
            make.height.equalTo(15)
        }
    }
    
    func configureCell(rate: CurrencyRate2, isFavorite: Bool) {
        titleLabel.text = "\(rate.name) - \(rate.fullName)"
        if rate.type == .crypto {
            descriptionLabel.text = "Курс: \(rate.rate) USD"
        } else {
            descriptionLabel.text = "Курс: \(rate.rate) BYN"
        }
        // Обновляем состояние звезды
        starView.setValue(isFavorite)
    }
    
    @objc private func starValueChanged(_ sender: ToggleSwitchView) {
        // Let's give the controller the ability to update the favorites model
        onToggleFavorite?()
    }
}

