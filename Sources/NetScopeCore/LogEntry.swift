//
//  LogEntry.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 01/03/26.
//

import Foundation

public struct LogEntry: Identifiable, Hashable, Equatable, Sendable {

    public static let maxResponseBodySize = 100_000 // 100KB

    public let id: UUID
    public let timestamp: Date

    public let url: String
    public let method: String
    public let requestHeaders: [String: String]
    public let requestBody: String?
    public let requestParameters: String?
    
    public let statusCode: Int?
    public let responseHeaders: [String: String]
    public let responseBodyRaw: Data?
    public let duration: TimeInterval?
    public let error: String?
    
    public var responseBody: String? {
        guard let data = responseBodyRaw, !data.isEmpty else { return nil }
        if let obj = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
           let str = String(data: pretty, encoding: .utf8) {
            return str
        }
        return String(data: data, encoding: .utf8)
    }
    
    public var isSuccess: Bool {
        guard let code = statusCode else { return false }
        return (200..<300).contains(code)
    }
    
    public var statusBadge: String {
        guard let code = statusCode else { return error != nil ? "ERR" : "???" }
        return "\(code)"
    }
    
    public var durationFormatted: String {
        guard let d = duration else { return "-" }
        if d < 1 { return "\(Int(d * 1000))ms" }
        return String(format: "%.2fs", d)
    }
    
    public var shortURL: String {
        guard let url = URL(string: url) else { return self.url }
        return url.path
    }
    
    public var responseSizeFormatted: String {
        guard let data = responseBodyRaw else { return "-" }
        let bytes = data.count
        if bytes < 1_000 { return "\(bytes) B" }
        if bytes < 1_000_000 { return String(format: "%.1f KB", Double(bytes) / 1_000) }
        return String(format: "%.1f MB", Double(bytes) / 1_000_000)
    }
    
    public var isResponseTruncated: Bool {
        guard let data = responseBodyRaw else { return false }
        return data.count >= Self.maxResponseBodySize
    }
    
    public var curlCommand: String {
        var parts = ["curl -X \(method)"]
        requestHeaders.forEach { key, value in
            parts.append("-H '\(key): \(value)'")
        }
        if let body = requestBody, !body.isEmpty {
            let escaped = body.replacingOccurrences(of: "'", with: "'\\''")
            parts.append("-d '\(escaped)'")
        }
        parts.append("'\(url)'")
        return parts.joined(separator: " \\\n  ")
    }
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        url: String,
        method: String,
        requestHeaders: [String: String],
        requestBody: String?,
        requestParameters: String?,
        statusCode: Int?,
        responseHeaders: [String: String],
        responseBodyRaw: Data?,
        duration: TimeInterval?,
        error: String?
    ) {
        self.id = id
        self.timestamp = timestamp
        self.url = url
        self.method = method
        self.requestHeaders = requestHeaders
        self.requestBody = requestBody
        self.requestParameters = requestParameters
        self.statusCode = statusCode
        self.responseHeaders = responseHeaders
        if let data = responseBodyRaw, data.count > Self.maxResponseBodySize {
            self.responseBodyRaw = data.prefix(Self.maxResponseBodySize)
        } else {
            self.responseBodyRaw = responseBodyRaw
        }
        self.duration = duration
        self.error = error
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
        lhs.id == rhs.id
    }
}
