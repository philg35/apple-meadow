//
//  userData.swift
//  PhoneLight
//
//  Created by Philip Gross on 12/21/20.
//

import Foundation
import SwiftUI
import Combine

class UserData : ObservableObject {
    @Published var phoneLight = phoneLightData
}
