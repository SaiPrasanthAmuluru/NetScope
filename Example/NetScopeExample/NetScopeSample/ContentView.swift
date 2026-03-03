//
//  ContentView.swift
//  NetScopeExample
//
//  Created by Sai Prasanth Amuluru on 02/03/26.
//

import SwiftUI

struct ContentView: View {

    @State private var statusMessage = "Tap a button to make an API call"
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    buttonGrid
                    statusSection
                }
                .padding()
            }
            .navigationTitle("NetScope Example")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "antenna.radiowaves.left.and.right")
                .font(.system(size: 44))
                .foregroundColor(.blue)
            Text("Tap any button below to fire a real API call.\nAll requests are captured by NetScope.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("Look for the floating bubble to open the log viewer.")
                .font(.caption)
                .foregroundColor(.orange)
                .fontWeight(.medium)
        }
        .padding(.bottom, 8)
    }

    private var buttonGrid: some View {
        VStack(spacing: 12) {
            apiButton(title: "GET /posts", icon: "arrow.down.circle.fill", color: .blue) {
                let (_, response) = try await APIService.fetchPosts()
                return statusText(for: response, label: "GET /posts")
            }

            apiButton(title: "GET /posts/1", icon: "arrow.down.circle.fill", color: .blue) {
                let (_, response) = try await APIService.fetchPost(id: 1)
                return statusText(for: response, label: "GET /posts/1")
            }

            apiButton(title: "POST /posts", icon: "arrow.up.circle.fill", color: .green) {
                let (_, response) = try await APIService.createPost(
                    title: "NetScope Test",
                    body: "This is a test post from NetScope example app."
                )
                return statusText(for: response, label: "POST /posts")
            }

            apiButton(title: "PUT /posts/1", icon: "pencil.circle.fill", color: .orange) {
                let (_, response) = try await APIService.updatePost(id: 1, title: "Updated Title")
                return statusText(for: response, label: "PUT /posts/1")
            }

            apiButton(title: "DELETE /posts/1", icon: "trash.circle.fill", color: .red) {
                let (_, response) = try await APIService.deletePost(id: 1)
                return statusText(for: response, label: "DELETE /posts/1")
            }

            apiButton(title: "GET /404 (Error)", icon: "exclamationmark.triangle.fill", color: .gray) {
                let (_, response) = try await APIService.fetch404()
                return statusText(for: response, label: "GET /404")
            }

            Button {
                Task {
                    isLoading = true
                    statusMessage = "Firing all requests..."
                    do {
                        async let r1 = APIService.fetchPosts()
                        async let r2 = APIService.fetchPost(id: 1)
                        async let r3 = APIService.createPost(title: "Batch", body: "batch test")
                        async let r4 = APIService.updatePost(id: 1, title: "Batch Update")
                        async let r5 = APIService.deletePost(id: 1)
                        async let r6 = APIService.fetch404()
                        let _ = try await [r1, r2, r3, r4, r5, r6] as [Any]
                        statusMessage = "All 6 requests completed — check the bubble!"
                    } catch {
                        statusMessage = "Batch error: \(error.localizedDescription)"
                    }
                    isLoading = false
                }
            } label: {
                Label("Fire All at Once", systemImage: "bolt.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .disabled(isLoading)
        }
    }

    private var statusSection: some View {
        GroupBox {
            HStack {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }

    private func apiButton(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () async throws -> String
    ) -> some View {
        Button {
            Task {
                isLoading = true
                statusMessage = "Loading..."
                do {
                    statusMessage = try await action()
                } catch {
                    statusMessage = "\(title) failed: \(error.localizedDescription)"
                }
                isLoading = false
            }
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .tint(color)
        .disabled(isLoading)
    }

    private func statusText(for response: URLResponse, label: String) -> String {
        if let http = response as? HTTPURLResponse {
            return "\(label) — \(http.statusCode)"
        }
        return "\(label) — completed"
    }
}
