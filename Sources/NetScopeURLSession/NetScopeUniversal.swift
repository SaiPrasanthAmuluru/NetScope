//
//  NetScopeUniversal.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 02/03/26.
//

#if DEBUG
import Foundation

public final class NetScopeUniversal {

    private init() {}

    public static func startCapturing() {
        URLProtocol.registerClass(NetScopeURLProtocol.self)
    }

    public static func stopCapturing() {
        URLProtocol.unregisterClass(NetScopeURLProtocol.self)
    }

    /// Injects the interceptor into a specific configuration. Useful for libraries
    /// like Alamofire that create their own URLSessionConfiguration internally.
    public static func register(in configuration: URLSessionConfiguration) {
        var protocols = configuration.protocolClasses ?? []
        protocols.insert(NetScopeURLProtocol.self, at: 0)
        configuration.protocolClasses = protocols
    }
}
#endif
