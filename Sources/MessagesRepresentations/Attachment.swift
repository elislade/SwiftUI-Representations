import Foundation

public enum Attachment {
    case url(_ url: URL, alternateFilename: String? = nil)
    case data(_ data: Data, mimeType: String, filename: String)
}
