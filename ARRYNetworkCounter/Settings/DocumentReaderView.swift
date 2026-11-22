import SwiftUI

/// Native macOS markdown document reader providing offline viewing of bundled guides and legal terms.
public struct DocumentReaderView: View {
    public let document: DocumentationDocument
    public let onClose: () -> Void
    public let documentContent: String

    public init(document: DocumentationDocument, onClose: @escaping () -> Void) {
        self.document = document
        self.onClose = onClose
        self.documentContent = DocumentationLoader.loadDocument(document)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header bar with navigation back button
            headerBar

            Divider()

            // Scrollable rendered markdown content
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(parseMarkdownBlocks(documentContent), id: \.id) { block in
                        renderBlock(block)
                    }
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .textSelection(.enabled)
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }

    // MARK: - Header Bar

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: onClose) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 11, weight: .semibold))
                    Text("Documentation")
                        .font(.subheadline)
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: document.systemIcon)
                    .font(.subheadline)
                    .foregroundColor(.accentColor)

                Text(document.title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()

            // Balance spacing
            Text("Offline")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    Capsule()
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }

    // MARK: - Markdown Block Rendering

    @ViewBuilder
    private func renderBlock(_ block: MarkdownBlock) -> some View {
        switch block.type {
        case .h1(let text):
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey(text))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Divider()
            }
            .padding(.top, 4)
            .padding(.bottom, 6)

        case .h2(let text):
            VStack(alignment: .leading, spacing: 4) {
                Text(LocalizedStringKey(text))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding(.top, 10)
            .padding(.bottom, 2)

        case .h3(let text):
            Text(LocalizedStringKey(text))
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .padding(.top, 6)

        case .h4(let text):
            Text(LocalizedStringKey(text))
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 4)

        case .paragraph(let text):
            Text(LocalizedStringKey(text))
                .font(.body)
                .lineSpacing(3)
                .foregroundColor(.primary)

        case .divider:
            Divider()
                .padding(.vertical, 4)

        case .codeBlock(let code):
            ScrollView(.horizontal, showsIndicators: false) {
                Text(code)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.primary)
                    .padding(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )

        case .table(let rows):
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(rows.indices, id: \.self) { index in
                        Text(rows[index])
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(index == 0 ? .primary : .secondary)
                            .fontWeight(index == 0 ? .semibold : .regular)
                    }
                }
                .padding(10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor), lineWidth: 0.5)
            )

        case .quote(let text):
            HStack(spacing: 10) {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 3)

                Text(LocalizedStringKey(text))
                    .font(.subheadline)
                    .italic()
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    // MARK: - Markdown Parser

    private func parseMarkdownBlocks(_ raw: String) -> [MarkdownBlock] {
        var blocks: [MarkdownBlock] = []
        let lines = raw.components(separatedBy: "\n")
        var i = 0

        while i < lines.count {
            let line = lines[i]
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            if trimmed.isEmpty {
                i += 1
                continue
            }

            if trimmed == "---" || trimmed == "***" {
                blocks.append(MarkdownBlock(type: .divider))
                i += 1
                continue
            }

            if trimmed.hasPrefix("#### ") {
                blocks.append(MarkdownBlock(type: .h4(String(trimmed.dropFirst(5)))))
                i += 1
                continue
            }

            if trimmed.hasPrefix("### ") {
                blocks.append(MarkdownBlock(type: .h3(String(trimmed.dropFirst(4)))))
                i += 1
                continue
            }

            if trimmed.hasPrefix("## ") {
                blocks.append(MarkdownBlock(type: .h2(String(trimmed.dropFirst(3)))))
                i += 1
                continue
            }

            if trimmed.hasPrefix("# ") {
                blocks.append(MarkdownBlock(type: .h1(String(trimmed.dropFirst(2)))))
                i += 1
                continue
            }

            if trimmed.hasPrefix("> ") {
                blocks.append(MarkdownBlock(type: .quote(String(trimmed.dropFirst(2)))))
                i += 1
                continue
            }

            if trimmed.hasPrefix("```") {
                var codeLines: [String] = []
                i += 1
                while i < lines.count && !lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                    codeLines.append(lines[i])
                    i += 1
                }
                if i < lines.count { i += 1 } // skip closing ```
                blocks.append(MarkdownBlock(type: .codeBlock(codeLines.joined(separator: "\n"))))
                continue
            }

            if trimmed.hasPrefix("|") {
                var tableRows: [String] = []
                while i < lines.count && lines[i].trimmingCharacters(in: .whitespaces).hasPrefix("|") {
                    let tableLine = lines[i].trimmingCharacters(in: .whitespaces)
                    // skip markdown separator row |:---|---:|
                    if !tableLine.contains("---") {
                        tableRows.append(tableLine)
                    }
                    i += 1
                }
                blocks.append(MarkdownBlock(type: .table(tableRows)))
                continue
            }

            // Regular paragraph accumulation
            var paragraphLines: [String] = [line]
            i += 1
            while i < lines.count {
                let nextTrimmed = lines[i].trimmingCharacters(in: .whitespaces)
                if nextTrimmed.isEmpty || nextTrimmed.hasPrefix("#") || nextTrimmed.hasPrefix("```") || nextTrimmed.hasPrefix("|") || nextTrimmed == "---" {
                    break
                }
                paragraphLines.append(lines[i])
                i += 1
            }
            blocks.append(MarkdownBlock(type: .paragraph(paragraphLines.joined(separator: " "))))
        }

        return blocks
    }
}

/// Representation of a parsed markdown block for native layout rendering.
private struct MarkdownBlock: Identifiable {
    let id = UUID()
    let type: BlockType

    enum BlockType {
        case h1(String)
        case h2(String)
        case h3(String)
        case h4(String)
        case paragraph(String)
        case divider
        case codeBlock(String)
        case table([String])
        case quote(String)
    }
}
