//
//  NetScopeViewerHostingController.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 01/03/26.
//

#if DEBUG
import UIKit
import SwiftUI
import Combine
import NetScopeCore

public final class NetScopeViewerHostingController: UIHostingController<NetScopeViewerRootView> {
    public init() {
        super.init(rootView: NetScopeViewerRootView())
    }
    @MainActor required dynamic init?(coder aDecoder: NSCoder) { fatalError() }
}

public struct NetScopeViewerRootView: View {
    @StateObject private var viewModel = NetScopeViewModel()

    public var body: some View {
        NetScopeListView(viewModel: viewModel)
    }
}

final class NetScopeViewModel: ObservableObject {
    @Published var entries: [LogEntry] = []
    @Published var searchText: String = ""
    @Published var showFailedOnly: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        entries = LogStore.shared.entries

        LogStore.shared.entriesChangedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                self.entries = LogStore.shared.entries
            }
            .store(in: &cancellables)
    }

    var filtered: [LogEntry] {
           let base = showFailedOnly ? LogStore.shared.failedEntries() : entries
           guard !searchText.isEmpty else { return base }
           let lower = searchText.lowercased()
           return base.filter {
               $0.url.lowercased().contains(lower) ||
               $0.method.lowercased().contains(lower) ||
               ($0.statusCode.map { "\($0)" } ?? "").contains(lower)
           }
       }
    
    var totalCount: Int { entries.count }
    var failedCount: Int { entries.filter { !$0.isSuccess }.count }

    func clear() {
        LogStore.shared.clear()
    }
}

struct NetScopeListView: View {
    @ObservedObject var viewModel: NetScopeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Group {
                if viewModel.filtered.isEmpty {
                    emptyState
                } else {
                    List(viewModel.filtered) { entry in
                        NavigationLink(destination: NetScopeDetailView(entry: entry)) {
                            NetScopeRowView(entry: entry)
                        }
                        .listRowBackground(Color(.systemGroupedBackground))
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "URL, method, status code…")
            .navigationTitle("NetScope")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Label("\(viewModel.totalCount)", systemImage: "arrow.up.arrow.down")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        if viewModel.failedCount > 0 {
                            Label("\(viewModel.failedCount)", systemImage: "xmark.circle.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.red)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(role: .destructive) {
                            viewModel.clear()
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                        .disabled(viewModel.entries.isEmpty)

                        Toggle(isOn: $viewModel.showFailedOnly) {
                            Label("Failed Only", systemImage: "xmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 52))
                .foregroundColor(.secondary)
            Text(viewModel.showFailedOnly ? "No failed requests" : "No API calls captured yet")
                .font(.headline)
                .foregroundColor(.secondary)
            Text(viewModel.showFailedOnly ? "All requests succeeded." : "Make a request and it will appear here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

struct NetScopeRowView: View {
    let entry: LogEntry

    var body: some View {
        HStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 3)
                .fill(entry.isSuccess ? Color.green : Color.red)
                .frame(width: 4)
                .frame(maxHeight: 44)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    MethodBadge(method: entry.method)
                    StatusBadge(code: entry.statusCode, isSuccess: entry.isSuccess)
                    Spacer()
                    Text(entry.durationFormatted)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                    Text(entry.responseSizeFormatted)
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                }
                Text(entry.shortURL)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text(entry.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct MethodBadge: View {
    let method: String

    var color: Color {
        switch method.uppercased() {
        case "GET": return .blue
        case "POST": return .green
        case "PUT": return .orange
        case "PATCH": return .yellow
        case "DELETE": return .red
        default: return .gray
        }
    }

    var body: some View {
        Text(method)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(color.opacity(0.4), lineWidth: 1))
            .cornerRadius(5)
    }
}

struct StatusBadge: View {
    let code: Int?
    let isSuccess: Bool

    var body: some View {
        let label = code.map { "\($0)" } ?? "ERR"
        let color: Color = isSuccess ? .green : .red
        Text(label)
            .font(.system(size: 10, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(color.opacity(0.4), lineWidth: 1))
            .cornerRadius(5)
    }
}
#endif
