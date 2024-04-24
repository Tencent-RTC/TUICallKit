//
//  Observers.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/4/3.
//

import Foundation

class Observer {}

public class Observable<Type> {
    
    // MARK: - Callback
    fileprivate class Callback {
        fileprivate weak var observer: AnyObject?
        fileprivate let options: [ObservableOptions]
        fileprivate let closure: (Type, ObservableOptions) -> Void
        
        fileprivate init(
            observer: AnyObject,
            options: [ObservableOptions],
            closure: @escaping (Type, ObservableOptions) -> Void) {
            self.observer = observer
            self.options = options
            self.closure = closure
        }
    }
    
    // MARK: - Properties  Use SWIFT's DIDSET feature to call the value back to callback
    public var value: Type {
        didSet {
            removeNilObserverCallbacks()
            notifyCallbacks(value: oldValue, option: .old)
            notifyCallbacks(value: value, option: .new)
        }
    }
    
    private func removeNilObserverCallbacks() {
        callbacks = callbacks.filter { $0.observer != nil }
    }
    
    // MARK: Receive the closure callback to callback
    private func notifyCallbacks(value: Type, option: ObservableOptions) {
        let callbacksToNotify = callbacks.filter { $0.options.contains(option) }
        callbacksToNotify.forEach { $0.closure(value, option) }
    }
    
    // MARK: - Object Lifecycle
    public init(_ value: Type) {
        self.value = value
    }
    
    // MARK: - Managing Observers
    private var callbacks: [Callback] = []
    
    /// Adding an observer
    ///
    /// - Parameters:
    ///   - observer: Observer
    ///   - removeIfExists: If the observer exists, it needs to be removed
    ///   - options: Observed
    ///   - closure: Call back
    public func addObserver(
        _ observer: AnyObject,
        removeIfExists: Bool = true,
        options: [ObservableOptions] = [.new],
        closure: @escaping (Type, ObservableOptions) -> Void) {
        if removeIfExists {
            removeObserver(observer)
        }
        let callback = Callback(observer: observer, options: options, closure: closure)
        callbacks.append(callback)
        if options.contains(.initial) {
            closure(value, .initial)
        }
    }
    
    public func removeObserver(_ observer: AnyObject) {
        callbacks = callbacks.filter { $0.observer !== observer }
    }
}

// MARK: - ObservableOptions
public struct ObservableOptions: OptionSet {
    public static let initial = ObservableOptions(rawValue: 1 << 0)
    public static let old = ObservableOptions(rawValue: 1 << 1)
    public static let new = ObservableOptions(rawValue: 1 << 2)
    
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
