# HTTP

## 基本工作流程

1. **解析 URL**：客户端从用户输入或其他来源获取 URL（统一资源定位符），并解析 URL 以获取主机名、端口号、路径和查询参数等信息。

2. **DNS 解析**：客户端使用主机名通过 DNS（域名系统）解析获取服务器的 IP 地址。这个过程涉及向 DNS 服务器发送请求并接收响应以获取相应的 IP 地址。

3. **建立 TCP 连接**：客户端使用服务器的 IP 地址和端口号建立与服务器的 TCP 连接。这是通过三次握手的过程来确保连接的可靠性。

4. **发起 HTTP 请求**：客户端构建 HTTP 请求，包括*请求方法*（如 GET、POST）、*请求头*和*请求体*等。请求头包含了关于请求的附加信息，如主机、用户代理、接受的内容类型等。请求体包含一些可选的请求数据，如在 POST 请求中发送的表单数据。

5. **服务器处理请求**：服务器接收到客户端的请求后，根据请求的内容进行处理。这可能涉及读取请求的头部和体部，执行服务器端的代码逻辑，与数据库进行交互等。

6. **服务器发送 HTTP 响应**：服务器生成 HTTP 响应，包括响应状态码、响应头和响应体。响应状态码指示请求的处理结果，如 200 表示成功，404 表示资源未找到等。响应头包含关于响应的附加信息，如内容类型、长度、缓存控制等。响应体包含实际的响应数据，如 HTML 文档、JSON 数据等。

7. **响应传输**：服务器将 HTTP 响应通过之前建立的 TCP 连接发送回客户端。这个过程中，响应被分割成小的数据包（如 TCP 报文段）并通过网络传输。

8. **客户端接收响应**：客户端接收到来自服务器的响应数据，并将其重新组装成完整的 HTTP 响应。

9. **客户端处理响应**：客户端根据响应的内容进行处理，这可能涉及解析 HTML 文档、渲染页面、处理 JSON 数据等。根据需要，客户端可能会发起其他 HTTP 请求来获取页面上的附加资源，如图像、样式表或脚本文件。

10. **连接关闭**：在数据传输完成后，客户端和服务器之间的 TCP 连接可以关闭，以释放网络资源并结束 HTTP 交互。

## 客户端

### HTTP 客户端请求内容

1. **请求行(Request Line)**：请求行包含请求方法（如 GET、POST、PUT、DELETE 等）、请求的 URL 路径和 HTTP 协议版本。

    一般格式如下：

    ```text
    <method> <path> <version>
    ```

    其中，`<method>` 表示请求方法（如 GET、POST 等），`<path>` 表示请求的资源路径，`<version>` 表示使用的 HTTP 协议版本。

    例如：

    ```text
    GET /example/path HTTP/1.1
    ```

2. **请求头(Request Headers)**：请求头包含关于请求的附加信息，如请求的主机、用户代理、内容类型等。常见的请求头包括：

    - Host：指定请求的目标主机。
    - User-Agent：标识发起请求的客户端（如浏览器）信息。
    - Content-Type：指定请求体中的数据类型，如表单数据、JSON 数据等。
    - Accept：指定客户端可以接受的响应内容类型。
    - Authorization：提供身份验证凭证，用于访问需要授权的资源。
    - Cookie：包含客户端的会话标识和其他状态信息。

    例如：

    ```text
    Host: example.com
    User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36
    Content-Type: application/json
    Accept: text/html,application/xhtml+xml,application/json
    ```

3. **请求体(Request Body)**：请求体包含可选的请求数据，如在 POST 请求中发送的表单数据、JSON 数据等。对于 GET 请求等没有请求体的方法，请求体通常为空。请求体的格式和内容根据请求的需求而定。

    例如，发送 JSON 数据的请求体：

    ```json
    {
        "name": "John",
        "age": 30
    }
    ```

**NOTE:** 其中请求头和请求体是*可选的*，具体内容和格式取决于具体的请求需求。

### 请求行中的请求方法

HTTP 请求方法指定了客户端对服务器资源执行的操作类型。以下是一些常见的 HTTP 请求方法及其作用：

1. **GET**：用于*请求获取指定资源的表示形式*。它是最常用的请求方法之一，通常用于从服务器获取数据。GET 请求是幂等的，即多次发送相同的 GET 请求应该返回相同的响应，不会对服务器状态产生副作用。

2. **POST**：用于*向服务器提交数据*，请求在服务器上创建新的资源。通常用于提交表单数据、上传文件等操作。POST 请求不是幂等的，即多次发送相同的 POST 请求可能会在服务器上创建多个资源。

3. **PUT**：用于*向服务器更新指定资源的表示形式*。PUT 请求要求客户端提供完整的资源表示形式，包括要替换的资源的全部内容。如果资源不存在，则创建一个新资源。PUT 请求也是幂等的，即多次发送相同的 PUT 请求应该产生相同的结果。

4. **DELETE**：用于*请求服务器删除指定的资源*。DELETE 请求用于删除服务器上的资源。DELETE 请求是幂等的，即多次发送相同的 DELETE 请求应该产生相同的结果。

5. **PATCH**：用于*对服务器上的资源进行部分更新*。PATCH 请求用于对已有资源进行局部修改，而不是替换整个资源。PATCH 请求是非幂等的，即多次发送相同的 PATCH 请求可能会产生不同的结果。

6. **HEAD**：*类似于 GET 请求，但只请求获取资源的头部信息，不返回资源的实际内容*。HEAD 请求通常用于检查资源的元数据或验证资源是否存在，而无需传输完整的响应内容。

## HTTP status codes

HTTP (Hypertext Transfer Protocol) is the underlying protocol used for communication on the World Wide Web. HTTP status codes are three-digit numbers returned by web servers to indicate the status of a client's request. Each status code conveys a specific meaning about the request or the response. Here are some common HTTP status codes and their explanations:

1. Informational 1xx:

    - 100 Continue: The server received the initial part of the request, and the client should proceed with the rest of the request.

2. Successful 2xx:

    - 200 OK: The request was successful, and the server has returned the requested data.
    - 201 Created: The request was successful, and the server has created a new resource as a result.
    - 204 No Content: The request was successful, but there is no data to return (e.g., in response to a successful DELETE request).

3. Redirection 3xx:

    - 301 Moved Permanently: The requested resource has moved to a new URL, and future requests should use the new URL.
    - 302 Found (or 307 Temporary Redirect): The requested resource temporarily resides at a different URL, and the client should use the new URL for future requests.
    - 304 Not Modified: The client's cached copy of the resource is still valid, and the server does not need to send the requested resource again.

4. Client Error 4xx:

    - 400 Bad Request: The server cannot understand the request due to client error (e.g., malformed request syntax).
    - 401 Unauthorized: Authentication is required, and the client must provide valid credentials to access the requested resource.
    - 403 Forbidden: The client does not have the necessary permissions to access the requested resource.
    - 404 Not Found: The requested resource could not be found on the server.

5. Server Error 5xx:

    - 500 Internal Server Error: An unexpected condition was encountered on the server, preventing it from fulfilling the request.
    - 502 Bad Gateway: The server acting as a gateway or proxy received an invalid response from the upstream server.
    - 503 Service Unavailable: The server is currently unable to handle the request due to maintenance or overload.
    - 504 Gateway Timeout: The server acting as a gateway or proxy did not receive a timely response from the upstream server.

Please note that this is not an exhaustive list, as there are many other HTTP status codes with specific purposes and meanings. However, these are some of the most commonly encountered status codes in web development.
