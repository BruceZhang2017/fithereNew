import UIKit

class FemaleHealthTableViewCell: UITableViewCell {

    let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let arrowImageView = UIImageView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
        contentView.addSubview(containerView)

        containerView.addSubview(iconImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(arrowImageView)

        containerView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.top.equalTo(6)
            make.bottom.equalTo(-6)
        }

        iconImageView.image = UIImage(systemName: "heart.circle.fill")
        iconImageView.tintColor = UIColor(red: 1.0, green: 0.4, blue: 0.6, alpha: 1.0)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.snp.makeConstraints { make in
            make.leading.equalTo(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }

        arrowImageView.image = UIImage(systemName: "chevron.right")
        arrowImageView.tintColor = UIColor(red: 0.56, green: 0.59, blue: 0.63, alpha: 1.0)
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalTo(-16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(20)
        }

        titleLabel.text = "female_cycle_title".localized()
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .black
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.top.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-12)
        }

        subtitleLabel.text = "female_cycle_subtitle".localized()
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.56, green: 0.59, blue: 0.63, alpha: 1.0)
        subtitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualTo(arrowImageView.snp.leading).offset(-12)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
