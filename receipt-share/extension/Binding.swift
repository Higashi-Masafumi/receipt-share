//
//  Binding.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/10.
//

import SwiftUI

extension Binding {
    /// Optional値のBindingを作成し、nilの場合にデフォルト値を使用
    func bound<T>(default defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
    
    /// Optional<String>のBindingを作成し、空文字列の場合はnilを設定
    func boundString(default defaultValue: String = "") -> Binding<String> where Value == Optional<String> {
        return Binding<String>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
    
    /// Optional<Int>のBindingを作成し、0の場合はnilを設定するオプションあり
    func boundInt(default defaultValue: Int = 0, nilIfZero: Bool = false) -> Binding<Int> where Value == Optional<Int> {
        return Binding<Int>(
            get: { self.wrappedValue ?? defaultValue },
            set: {
                if nilIfZero && $0 == 0 {
                    self.wrappedValue = nil
                } else {
                    self.wrappedValue = $0
                }
            }
        )
    }
    
    /// Optional<Double>のBindingを作成し、0の場合はnilを設定するオプションあり
    func boundDouble(default defaultValue: Double = 0.0, nilIfZero: Bool = false) -> Binding<Double> where Value == Optional<Double> {
        return Binding<Double>(
            get: { self.wrappedValue ?? defaultValue },
            set: {
                if nilIfZero && $0 == 0.0 {
                    self.wrappedValue = nil
                } else {
                    self.wrappedValue = $0
                }
            }
        )
    }
    
    /// Optional<Date>のBindingを作成
    func boundDate(default defaultValue: Date = Date()) -> Binding<Date> where Value == Optional<Date> {
        return bound(default: defaultValue)
    }
}
