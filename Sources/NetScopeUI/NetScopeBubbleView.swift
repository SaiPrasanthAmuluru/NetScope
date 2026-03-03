//
//  NetScopeBubbleView.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 01/03/26.
//

#if DEBUG
import UIKit
import NetScopeCore

final class NetScopeBubbleView: UIView {

    var onTap: (() -> Void)?

    private let iconLabel = UILabel()
    private let badgeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        backgroundColor = UIColor(red: 0.05, green: 0.05, blue: 0.12, alpha: 0.92)
        layer.cornerRadius = 26
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 8
        layer.shadowOffset = CGSize(width: 0, height: 4)

        iconLabel.text = "⚡️"
        iconLabel.font = .systemFont(ofSize: 22)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconLabel)
        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        badgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = UIColor(red: 1, green: 0.23, blue: 0.19, alpha: 1)
        badgeLabel.layer.cornerRadius = 9
        badgeLabel.layer.masksToBounds = true
        badgeLabel.isHidden = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(badgeLabel)
        NSLayoutConstraint.activate([
            badgeLabel.topAnchor.constraint(equalTo: topAnchor, constant: -4),
            badgeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 4),
            badgeLabel.heightAnchor.constraint(equalToConstant: 18),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 18)
        ])

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(dragged(_:))))
    }

    func update(count: Int, entry: LogEntry) {
        badgeLabel.text = count > 99 ? "99+" : "\(count)"
        badgeLabel.isHidden = false
        pulse()
    }

    func resetCount() {
        badgeLabel.isHidden = true
        badgeLabel.text = nil
    }

    private func pulse() {
        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.15) {
                    self.transform = .identity
                }
            }
        )
    }

    @objc private func tapped() {
        onTap?()
    }

    @objc private func dragged(_ gesture: UIPanGestureRecognizer) {
        guard let superview else { return }
        let translation = gesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)

        if gesture.state == .ended {
            snapToEdge(in: superview)
        }
    }

    private func snapToEdge(in superview: UIView) {
        let padding: CGFloat = 12 + 26
        let targetX = center.x < superview.bounds.midX
            ? padding
            : superview.bounds.width - padding

        let minY = superview.safeAreaInsets.top + 26
        let maxY = superview.bounds.height - superview.safeAreaInsets.bottom - 26
        let targetY = min(max(center.y, minY), maxY)

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.center = CGPoint(x: targetX, y: targetY)
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard bounds.contains(point) else { return nil }
        return super.hitTest(point, with: event)
    }
}
#endif
