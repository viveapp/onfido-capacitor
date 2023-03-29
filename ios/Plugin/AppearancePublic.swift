//
//  AppearancePublic.swift
//  Plugin
//
//  Created by Polo Swelsen on 28/03/2023.
//  Copyright © 2023 Max Lynch. All rights reserved.
//

import Foundation
import UIKit

public class AppearancePublic: NSObject {

    public let primaryColor: UIColor
    public let primaryTitleColor: UIColor
    public let primaryBackgroundPressedColor: UIColor
    public let supportDarkMode: Bool

    public init(
        primaryColor: UIColor,
        primaryTitleColor: UIColor,
        primaryBackgroundPressedColor: UIColor,
        supportDarkMode: Bool = true) {
            self.primaryColor = primaryColor
            self.primaryTitleColor = primaryTitleColor
            self.primaryBackgroundPressedColor = primaryBackgroundPressedColor
            self.supportDarkMode = supportDarkMode
        }
}
