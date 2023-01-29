//
//  ScannedCodesTableViewCell.swift
//  QR Code Scanner
//
//  Created by amrmahdy on 06/01/2023.
//

import UIKit

struct ScannedCodesViewModel: Codable {
    var information: String
    var date: String
}
class ScannedCodesTableViewCell: UITableViewCell {
    private lazy var link: UILabel = {
       let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.text = "https://www.facebook.com https://www.facebook.com https://www.facebook.com https://www.facebook.com"
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var dateText: UILabel = {
       let label = UILabel()
        label.font = UIFont(name: label.font.fontName, size: 14)
        label.text = "4 days, 13 hrs ago"
        return label
    }()
    private lazy var optionsBtn: UIButton = {
        let button = UIButton()
      
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 0.5)
        return button
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
               // Initialization code
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func setupUI () {
        let containerSv = UIStackView()
        let detailsSv = UIStackView()
        containerSv.axis = .horizontal
        containerSv.distribution = .fill
        containerSv.alignment = .center
        containerSv.spacing = 16
        detailsSv.axis = .vertical
        detailsSv.alignment = .fill
        detailsSv.spacing = 8
        
        addSubview(containerSv)
        containerSv.translatesAutoresizingMaskIntoConstraints = false
        
        containerSv.addArrangedSubview(detailsSv)
        containerSv.addArrangedSubview(optionsBtn)
        
        detailsSv.addArrangedSubview(link)
        detailsSv.addArrangedSubview(dateText)
        
        NSLayoutConstraint.activate([
            containerSv.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerSv.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerSv.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            containerSv.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
        ])
        optionsBtn.widthAnchor.constraint(equalToConstant: 44).isActive = true
        optionsBtn.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    func configure(with viewModel: ScannedCodesViewModel) {
        link.text = viewModel.information
        dateText.text = viewModel.date
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
