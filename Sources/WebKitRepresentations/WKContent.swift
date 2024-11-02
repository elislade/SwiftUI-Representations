import Foundation


public enum WebContent : Hashable, Sendable {
    
    case request(URLRequest)
    case data(_ data: Data, mimeType: String, characterEncodingName: String, baseURL: URL)
    case local(_ URL: URL, readAccessURL: URL)
    case html(_ string: String, baseURL: URL? = nil)
    
    public static func url(_ url: URL) -> Self {
        .request(.init(url: url))
    }
    
    public var url: URL? {
        switch self {
        case .request(let request): return request.url
        case .data: return nil
        case .local(let url, _): return url
        case .html(_, let baseURL): return baseURL
        }
    }
    
    public var urlWithRoot: URL? {
        guard let url else { return nil }
        return url.appendingPathComponent("/")
    }
    
}
