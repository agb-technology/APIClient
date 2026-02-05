import Foundation

public actor APIClient {
    
    private let session: URLSession
    private var reqInterceptors: [RequestInterceptor] = []
    private var respInterceptors: [ResponseInterceptor] = []
    private var config: APIClientConfig
    
    public init(
        session: URLSession = .shared,
        config: APIClientConfig = .default
    ) {
        self.session = session
        self.config = config
    }
    
    public func addRequestInterceptor(_ interceptor: RequestInterceptor) {
        reqInterceptors.append(interceptor)
    }
    
    public func addResponseInterceptor(_ interceptor: ResponseInterceptor) {
        respInterceptors.append(interceptor)
    }
    
    // 构建完整 URLRequest
    private func buildRequest(
        endpoint: String,
        method: String,
        headers: [String: String]?,
        queryItems: [URLQueryItem]? = nil,
        body: Data?
    ) throws -> URLRequest {
        // URL 拼装
        let fullURL: String = config.baseURL + endpoint
        guard var components = URLComponents(string: fullURL) else {
            throw APIClientError.url(.invalidURL)
        }
        if let queryItems = queryItems {
            components.queryItems = queryItems
        }
        guard let url = components.url else {
            throw APIClientError.url(.malformedURL)
        }
        // 构建 Request
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = config.requestTimeout
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        config.defaultHeaders.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        headers?.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = body
        return req
    }
    
    // 请求方法
    private func send<T: Decodable>(
        endpoint: String,
        method: HTTPMethod = .GET,
        headers: [String: String]? = nil,
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil,
        responseType: T.Type
    ) async throws -> T {
        do {
            // 构建 URLRequest
            var request = try buildRequest(
                endpoint: endpoint,
                method: method.rawValue,
                headers: headers,
                queryItems: queryItems,
                body: body
            )
            
            // 请求拦截器
            for interceptor in reqInterceptors {
                request = try await interceptor.intercept(request)
            }
            
            do {
                // 发送请求
                var (data, response) = try await session.data(for: request)
                
                // 日志
                log(req: request, resp: response, data: data)
                
                // 响应拦截器 (e.g. 401 刷新 + 重试)
                for interceptor in respInterceptors {
                    (data, response) = try await interceptor.intercept(
                        data: data,
                        response: response,
                        request: request,
                        session: session
                    )
                }
                
                // 校验响应
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIClientError.response(.invalidResponse, statusCode: nil, data: data)
                }
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    let code: APIClientErrorCode
                    switch httpResponse.statusCode {
                    case 400: code = .invalidRequest
                    case 401: code = .unauthorized
                    case 403: code = .forbidden
                    case 404: code = .notFound
                    case 408: code = .requestTimeout
                    case 500: code = .serverError
                    case 503: code = .serviceUnavailable
                    default: code = .httpError
                    }
                    throw APIClientError.response(code, statusCode: httpResponse.statusCode, data: data)
                }
                
                return try JSONDecoder().safeDecode(T.self, from: data)
                
            } catch let urlError as URLError {
                let code: APIClientErrorCode
                switch urlError.code {
                case .notConnectedToInternet:
                    code = .networkUnavailable
                case .timedOut:
                    code = .networkTimeout
                case .cannotFindHost, .cannotConnectToHost:
                    code = .dnsResolutionFailed
                case .networkConnectionLost:
                    code = .networkConnectionLost
                case .secureConnectionFailed, .serverCertificateUntrusted,
                        .serverCertificateHasBadDate, .serverCertificateNotYetValid:
                    code = .sslError
                default:
                    code = .unknownError
                }
                throw APIClientError.network(code, underlying: urlError)
            } catch let apiError as APIClientError {
                throw apiError
            } catch {
                throw APIClientError.unknown(.unknownError, underlying: error)
            }
        } catch let apiError as APIClientError {
            throw apiError
        } catch {
            throw APIClientError.unknown(.unknownError, underlying: error)
        }
    }
    
    public func get<T: Decodable>(
        endpoint: String,
        headers: [String: String]? = nil,
        queryItems: [URLQueryItem]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await send(
            endpoint: endpoint,
            method: .GET,
            headers: headers,
            queryItems: queryItems,
            body: nil,
            responseType: responseType
        )
    }
    
    public func post<T: Decodable, U: Encodable>(
        endpoint: String,
        headers: [String: String]? = nil,
        queryItems: [URLQueryItem]? = nil,
        bodyObject: U,
        responseType: T.Type
    ) async throws -> T {
        let bodyData = try JSONEncoder().encode(bodyObject)
        return try await send(
            endpoint: endpoint,
            method: .POST,
            headers: headers,
            queryItems: queryItems,
            body: bodyData,
            responseType: responseType
        )
    }
    
    // 无 body 的 POST
    public func post<T: Decodable>(
        endpoint: String,
        headers: [String: String]? = nil,
        queryItems: [URLQueryItem]? = nil,
        responseType: T.Type
    ) async throws -> T {
        return try await send(
            endpoint: endpoint,
            method: .POST,
            headers: headers,
            queryItems: queryItems,
            body: nil,
            responseType: responseType
        )
    }
    
    public func put<T: Decodable, U: Encodable>(
        endpoint: String,
        headers: [String: String]? = nil,
        bodyObject: U,
        responseType: T.Type
    ) async throws -> T {
        let bodyData = try JSONEncoder().encode(bodyObject)
        return try await send(
            endpoint: endpoint,
            method: .PUT,
            headers: headers,
            body: bodyData,
            responseType: responseType
        )
    }
    
    public func delete<T: Decodable>(
        endpoint: String,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await send(
            endpoint: endpoint,
            method: .DELETE,
            headers: headers,
            body: nil,
            responseType: responseType
        )
    }
    
    public func head(
        url: String,
        headers: [String: String]? = nil
    ) async throws -> HTTPURLResponse {
        guard let url = URL(string: url) else {
            throw APIClientError.url(.invalidURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.HEAD.rawValue
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIClientError.response(.invalidResponse, statusCode: nil, data: nil)
            }
            return httpResponse
        } catch let urlError as URLError {
            let code: APIClientErrorCode
            switch urlError.code {
            case .notConnectedToInternet: code = .networkUnavailable
            case .timedOut: code = .networkTimeout
            case .cannotFindHost, .cannotConnectToHost: code = .dnsResolutionFailed
            case .networkConnectionLost: code = .networkConnectionLost
            default: code = .unknownError
            }
            throw APIClientError.network(code, underlying: urlError)
        } catch {
            throw APIClientError.unknown(.unknownError, underlying: error)
        }
    }
    
    private func log(req: URLRequest, resp: URLResponse, data: Data) {
#if DEBUG
        if let httpResponse = resp as? HTTPURLResponse {
            var bodyString = "--"
            if let body = req.httpBody {
                bodyString = String(data: body, encoding: .utf8) ?? "[binary data]"
            }
            
//            print("""
//                📌 [APIClient]
//                ├─ Request:
//                │  ├─ Method: \(req.httpMethod ?? "--") 
//                │  ├─ URL: \(req.url?.absoluteString ?? "--")
//                │  ├─ Request Header: \(req.allHTTPHeaderFields ?? [:])
//                │  └─ Request Body: \(bodyString)                
//                └─ Response:
//                   └─  Status Code: \(httpResponse.statusCode)
//                \(data.prettyPrintedJSONString)
//                """)
            
            print("""
                📌 [APIClient]
                ├─ Request:
                │  ├─ Method: \(req.httpMethod ?? "--") 
                │  ├─ URL: \(req.url?.absoluteString ?? "--")
                └─ Response:
                   └─  Status Code: \(httpResponse.statusCode)
                """)
            //
        }
#endif // DEBUG
    }
}
