//
//  UIStackView+Extensions.swift
//  NewsApp
//
//  Created by Aziza Gilash on 05.03.2024.
//

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { view in
            addArrangedSubview(view)
        }
    }
}
