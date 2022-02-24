//
//  Media.swift
//  ChatAppPractice
//
//  Created by Apple New on 2022-02-24.
//

import Foundation
import UIKit
import MessageKit

struct Media : MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
