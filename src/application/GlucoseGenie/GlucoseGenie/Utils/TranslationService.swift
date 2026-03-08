//
//  TranslationService.swift
//  GlucoseGenie
//

import Foundation

struct TranslationService {

    private static let batchSize = 100

    /// Translates an array of strings to the target language.
    /// Automatically chunks into batches of 100 to stay within Google's limits.
    /// Returns the original strings unchanged on any failure.
    static func translate(_ texts: [String], to targetLanguage: String) async -> [String] {
        guard !texts.isEmpty else { return texts }

        let langCode = targetLanguage.components(separatedBy: "-").first ?? targetLanguage
        guard langCode != "en" else { return texts }

        print("TranslationService: translating \(texts.count) strings to '\(langCode)'")

        // Split into chunks of batchSize
        let chunks = stride(from: 0, to: texts.count, by: batchSize).map {
            Array(texts[$0..<min($0 + batchSize, texts.count)])
        }

        var allTranslated: [String] = []

        for chunk in chunks {
            let result = await translateChunk(chunk, to: langCode)
            // If any chunk fails, abort and return originals
            guard result.count == chunk.count else {
                print("TranslationService: chunk failed, returning originals")
                return texts
            }
            allTranslated.append(contentsOf: result)
        }

        print("TranslationService: translated \(allTranslated.count) strings successfully")
        return allTranslated
    }

    // MARK: - Private

    private static func translateChunk(_ texts: [String], to langCode: String) async -> [String] {
        let key = Secrets.googleTranslateKey
        guard let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(key)") else {
            return texts
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "q": texts,
            "target": langCode,
            "format": "text"
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            return texts
        }
        request.httpBody = httpBody

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                print("TranslationService: HTTP \(httpResponse.statusCode) for chunk of \(texts.count)")
                guard httpResponse.statusCode == 200 else {
                    // Print raw error response to help diagnose
                    if let raw = String(data: data, encoding: .utf8) {
                        print("TranslationService error body: \(raw.prefix(300))")
                    }
                    return texts
                }
            }

            let decoded = try JSONDecoder().decode(GoogleTranslateResponse.self, from: data)
            return decoded.data.translations.map { $0.translatedText }

        } catch {
            print("TranslationService chunk error: \(error)")
            return texts
        }
    }
}

// MARK: - Response Models

private struct GoogleTranslateResponse: Codable {
    let data: GoogleTranslateData
}

private struct GoogleTranslateData: Codable {
    let translations: [GoogleTranslation]
}

private struct GoogleTranslation: Codable {
    let translatedText: String
}
