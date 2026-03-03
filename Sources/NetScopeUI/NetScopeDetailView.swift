//
//  NetScopeDetailView.swift
//  NetScope
//
//  Created by Sai Prasanth Amuluru on 01/03/26.
//

#if DEBUG
import SwiftUI
import NetScopeCore

struct NetScopeDetailView: View {
    let entry: LogEntry
    @State private var copiedCurl = false
    @State private var expandedSections: Set<String> = ["Request", "Response"]

    var body: some View {
        List {
            // Summary card
            Section { summaryCard }

            // Request section
            CollapsibleSection(title: "Request", icon: "arrow.up.circle.fill", color: .blue, expanded: $expandedSections) {
                if let params = entry.requestParameters {
                    DetailRow(label: "Parameters", value: params, monospaced: true)
                }
                if let body = entry.requestBody {
                    DetailRow(label: "Body", value: body, monospaced: true)
                }
                if !entry.requestHeaders.isEmpty {
                    HeadersView(title: "Headers", headers: entry.requestHeaders)
                }
            }

            // Response section
            CollapsibleSection(title: "Response", icon: "arrow.down.circle.fill", color: entry.isSuccess ? .green : .red, expanded: $expandedSections) {
                if entry.isResponseTruncated {
                    Label("Response truncated at 100KB", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                if let body = entry.responseBody {
                    DetailRow(label: "Body (\(entry.responseSizeFormatted))", value: body, monospaced: true)
                } else {
                    Text("No response body")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if !entry.responseHeaders.isEmpty {
                    HeadersView(title: "Headers", headers: entry.responseHeaders)
                }
                if let error = entry.error {
                    DetailRow(label: "Error", value: error, valueColor: .red)
                }
            }

            // cURL section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(entry.curlCommand)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)

                    Button {
                        UIPasteboard.general.string = entry.curlCommand
                        withAnimation { copiedCurl = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation { copiedCurl = false }
                        }
                    } label: {
                        Label(
                            copiedCurl ? "Copied!" : "Copy as cURL",
                            systemImage: copiedCurl ? "checkmark" : "doc.on.doc"
                        )
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(copiedCurl ? .green : .blue)
                }
                .padding(.vertical, 4)
            } header: {
                Label("cURL Command", systemImage: "terminal")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Request Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                MethodBadge(method: entry.method)
                StatusBadge(code: entry.statusCode, isSuccess: entry.isSuccess)
                Spacer()
                Text(entry.durationFormatted)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundColor(.secondary)
                Text(entry.responseSizeFormatted)
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundColor(.secondary)
            }

            Text(entry.url)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
                .textSelection(.enabled)

            Text(entry.timestamp.formatted(date: .abbreviated, time: .complete))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @Binding var expanded: Set<String>
    @ViewBuilder let content: () -> Content

    private var isExpanded: Bool { expanded.contains(title) }

    var body: some View {
        Section {
            if isExpanded { content() }
        } header: {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded { expanded.remove(title) }
                    else { expanded.insert(title) }
                }
            } label: {
                HStack {
                    Label(title, systemImage: icon)
                        .foregroundColor(color)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            .buttonStyle(.plain)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var monospaced = false
    var valueColor: Color = .primary

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(monospaced ? .system(size: 12, design: .monospaced) : .system(size: 13))
                .foregroundColor(valueColor)
                .textSelection(.enabled)
        }
        .padding(.vertical, 2)
    }
}

struct HeadersView: View {
    let title: String
    let headers: [String: String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                HStack(alignment: .top, spacing: 8) {
                    Text(key)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.blue)
                        .frame(minWidth: 80, alignment: .leading)
                    Text(value)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                }
            }
        }
        .padding(.vertical, 2)
    }
}
#endif
