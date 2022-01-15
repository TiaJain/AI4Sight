//
//  WeatherData.swift
//  AI4SIGHT-VI
//
//  Created by Tia Jain on 30/03/2020.
//  Copyright © 2020 Tia Jain. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}
