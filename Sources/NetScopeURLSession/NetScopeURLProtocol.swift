//
//  NetScopeURLProtocol.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 02/03/26.
//

#if DEBUG
import Foundation
import NetScopeCore

final class NetScopeURLProtocol: URLProtocol {

    private static let handledKey = "NetScopeURLProtocolHandled"

    private var startTime: Date?
    private var urlTask: URLSessionDataTask?
    private var receivedData = Data()
    private var urlResponse: URLResponse?

    override class func canInit(with request: URLRequest) -> Bool {
        guard URLProtocol.property(forKey: handledKey, in: request) == nil else {
            return false
        }
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let tagged = tag(request: request) else {
            client?.urlProtocolDidFinishLoading(self)
            return
        }

        startTime = Date()
        receivedData = Data()

        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        urlTask = session.dataTask(with: tagged)
        urlTask?.resume()
    }

    override func stopLoading() {
        urlTask?.cancel()
        urlTask = nil
    }

    private func tag(request: URLRequest) -> URLRequest? {
        guard let mutable = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else {
            return nil
        }
        URLProtocol.setProperty(true, forKey: Self.handledKey, in: mutable)
        return mutable as URLRequest
    }
}

extension NetScopeURLProtocol: URLSessionDataDelegate {

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        urlResponse = response
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data) {
        receivedData.append(data)
        client?.urlProtocol(self, didLoad: data)
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        let httpResponse = urlResponse as? HTTPURLResponse
        let duration = startTime.map { Date().timeIntervalSince($0) }

        let urlRequest = task.originalRequest ?? request
        let url = urlRequest.url?.absoluteString ?? "Unknown URL"
        let method = urlRequest.httpMethod ?? "GET"
        let requestHeaders = urlRequest.allHTTPHeaderFields ?? [:]

        let requestBody: String?
        if let bodyData = urlRequest.httpBody, !bodyData.isEmpty {
            requestBody = String(data: bodyData, encoding: .utf8)
        } else {
            requestBody = nil
        }

        let requestParameters: String?
        if let queryItems = URLComponents(string: url)?.queryItems, !queryItems.isEmpty {
            requestParameters = queryItems
                .map { "\($0.name)=\($0.value ?? "")" }
                .joined(separator: "&")
        } else {
            requestParameters = nil
        }

        let responseHeaders = (httpResponse?.allHeaderFields as? [String: String]) ?? [:]
        let responseBodyRaw = receivedData.isEmpty ? nil : receivedData

        let entry = LogEntry(
            url: url,
            method: method,
            requestHeaders: requestHeaders,
            requestBody: requestBody,
            requestParameters: requestParameters,
            statusCode: httpResponse?.statusCode,
            responseHeaders: responseHeaders,
            responseBodyRaw: responseBodyRaw,
            duration: duration,
            error: error?.localizedDescription
        )

        LogStore.shared.add(entry)

        if let error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}
#endif
