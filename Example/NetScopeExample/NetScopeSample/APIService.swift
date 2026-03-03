//
//  APIService.swift
//  NetScopeExample
//
//  Created by Sai Prasanth Amuluru on 02/03/26.
//

import Foundation

enum APIService {

    private static let baseURL = "https://jsonplaceholder.typicode.com"

    static func fetchPosts() async throws -> (Data, URLResponse) {
        let url = URL(string: "\(baseURL)/posts")!
        return try await URLSession.shared.data(from: url)
    }

    static func fetchPost(id: Int) async throws -> (Data, URLResponse) {
        let url = URL(string: "\(baseURL)/posts/\(id)")!
        return try await URLSession.shared.data(from: url)
    }

    static func createPost(title: String, body: String) async throws -> (Data, URLResponse) {
        let url = URL(string: "\(baseURL)/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = ["title": title, "body": body, "userId": 1]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        return try await URLSession.shared.data(for: request)
    }

    static func updatePost(id: Int, title: String) async throws -> (Data, URLResponse) {
        let url = URL(string: "\(baseURL)/posts/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = ["id": id, "title": title, "body": "updated body", "userId": 1]
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        return try await URLSession.shared.data(for: request)
    }

    static func deletePost(id: Int) async throws -> (Data, URLResponse) {
        let url = URL(string: "\(baseURL)/posts/\(id)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        return try await URLSession.shared.data(for: request)
    }

    /// Hits a non-existent endpoint to test 404 handling.
    static func fetch404() async throws -> (Data, URLResponse) {
        let url = URL(string: "\(baseURL)/this-does-not-exist")!
        return try await URLSession.shared.data(from: url)
    }
}
