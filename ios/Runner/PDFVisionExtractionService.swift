import Foundation
import PDFKit
import Vision

enum PDFVisionExtractionService {
    static func renderFirstPage(at path: String) throws -> Data {
        guard let document = PDFDocument(url: URL(fileURLWithPath: path)),
              let page = document.page(at: 0) else {
            throw PDFVisionError.cannotOpen
        }
        let bounds = page.bounds(for: .mediaBox)
        let width: CGFloat = 600
        let height = max(1, width * bounds.height / max(1, bounds.width))
        let image = page.thumbnail(
            of: CGSize(width: width, height: height),
            for: .mediaBox
        )
        guard let data = image.pngData() else {
            throw PDFVisionError.cannotOpen
        }
        return data
    }

    static func extractPages(at path: String) async throws -> [String] {
        try await Task.detached(priority: .userInitiated) {
            guard let document = PDFDocument(url: URL(fileURLWithPath: path)) else {
                throw PDFVisionError.cannotOpen
            }

            var pages: [String] = []
            pages.reserveCapacity(document.pageCount)
            for index in 0..<document.pageCount {
                guard let page = document.page(at: index) else {
                    pages.append("")
                    continue
                }
                let selectable = page.string?
                    .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                if selectable.count >= 20 {
                    pages.append(selectable)
                } else {
                    pages.append(try recognizePage(page))
                }
            }
            return pages
        }.value
    }

    private static func recognizePage(_ page: PDFPage) throws -> String {
        let bounds = page.bounds(for: .mediaBox)
        let image = page.thumbnail(
            of: CGSize(width: max(1400, bounds.width * 2),
                       height: max(1800, bounds.height * 2)),
            for: .mediaBox
        )
        guard let cgImage = image.cgImage else { return "" }

        let textRequest = VNRecognizeTextRequest()
        textRequest.recognitionLevel = .accurate
        textRequest.usesLanguageCorrection = true
        if #available(iOS 16.0, *) {
            textRequest.automaticallyDetectsLanguage = true
        }

        let rectangleRequest = VNDetectRectanglesRequest()
        rectangleRequest.minimumConfidence = 0.65
        rectangleRequest.minimumSize = 0.03
        rectangleRequest.maximumObservations = 80

        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([textRequest, rectangleRequest])

        let observations = (textRequest.results ?? []).sorted { lhs, rhs in
            let verticalDifference = abs(lhs.boundingBox.midY - rhs.boundingBox.midY)
            if verticalDifference > 0.018 {
                return lhs.boundingBox.midY > rhs.boundingBox.midY
            }
            return lhs.boundingBox.minX < rhs.boundingBox.minX
        }
        var output = observations.compactMap {
            $0.topCandidates(1).first?.string
        }.joined(separator: "\n")

        let regionCount = rectangleRequest.results?.count ?? 0
        if regionCount >= 3 && !output.isEmpty {
            output += "\n\n[Diagram/table layout: \(regionCount) detected regions; labels are listed in visual reading order above.]"
        }
        return output
    }
}

enum PDFVisionError: LocalizedError {
    case cannotOpen

    var errorDescription: String? {
        "The selected PDF could not be opened."
    }
}
