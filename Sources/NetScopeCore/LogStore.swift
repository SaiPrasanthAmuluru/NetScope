//
//  LogStore.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 01/03/26.
//

import Foundation
import Combine

public final class LogStore: ObservableObject {

    public static let maxEntryCount = 500
    public static let shared = LogStore()
    private init() {}

    private let queue = DispatchQueue(label: "com.netscope.store", attributes: .concurrent)
    private var _entries: [LogEntry] = []
    
    public var entries: [LogEntry] {
        queue.sync { _entries }
    }
    
    public var totalCount: Int {
        queue.sync { _entries.count }
    }
    
    private let _latestEntrySubject = PassthroughSubject<LogEntry?, Never>()
    public var latestEntryPublisher: AnyPublisher<LogEntry, Never>  {
        _latestEntrySubject
            .compactMap{ $0 }
            .eraseToAnyPublisher()
    }

    private let _entriesChangedSubject = PassthroughSubject<Void, Never>()
    public var entriesChangedPublisher: AnyPublisher<Void, Never> {
        _entriesChangedSubject.eraseToAnyPublisher()
    }
    
    public func add(_ entry: LogEntry) {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            self._entries.insert(entry, at: 0)
            if self._entries.count > Self.maxEntryCount {
                self._entries = Array(self._entries.prefix(Self.maxEntryCount))
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self._latestEntrySubject.send(entry)
                self._entriesChangedSubject.send()
            }
        }
    }
    
    public func clear() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            self._entries.removeAll(keepingCapacity: false)
            DispatchQueue.main.async {
                self._latestEntrySubject.send(nil)
                self._entriesChangedSubject.send()
            }
        }
    }
    
    public func entries(matching searchText: String)  -> [LogEntry] {
        guard !searchText.isEmpty else { return [] }
        let lowerCasedSearchText = searchText.lowercased()
        return queue.sync {
            _entries.filter {
                $0.url.lowercased().contains(lowerCasedSearchText) ||
                $0.method.lowercased().contains(lowerCasedSearchText) ||
                ($0.statusCode.map { "\($0)" } ?? "" ).contains(lowerCasedSearchText)
            }
        }
    }
    
    public func failedEntries() -> [LogEntry] {
        queue.sync {
            _entries.filter { !$0.isSuccess }
        }
    }
}
