# NetScope
A lightweight network inspector for iOS debug builds. Intercepts URLSession traffic and shows requests/responses in a floating overlay — works on device and simulator.

- Zero external dependencies
- Captures all HTTP methods, headers, bodies, status codes, and timing
- Works with any networking layer that uses URLSession (including Alamofire, Moya, etc.)
- Debug-only — all code is wrapped in `#if DEBUG`

## Requirements

- iOS 15+
- Swift 5.9+

## Installation

### Swift Package Manager

Add NetScope to your project via **File > Add Package Dependencies** in Xcode, or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SaiPrasanthAmuluru/NetScope.git", from: "1.0.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "NetScope", package: "NetScope")
    ]
)
```

If you only need specific modules, you can import them individually:

| Module | What it does |
|--------|-------------|
| `NetScopeCore` | Models and log storage |
| `NetScopeURLSession` | URLProtocol-based interceptor |
| `NetScopeUI` | Floating bubble and log viewer |
| `NetScope` | Umbrella — re-exports all of the above |

## Usage

### Quick start

In your app entry point:

```swift
import NetScope

@main
struct MyApp: App {

    init() {
        #if DEBUG
        NetScopeUniversal.startCapturing()
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    #if DEBUG
                    NetScopeController.shared.install()
                    #endif
                }
        }
    }
}
```

That's it. A floating bubble appears on screen — tap it to browse captured requests.

### Register on a specific URLSessionConfiguration

If you're using a library that creates its own `URLSessionConfiguration` (like Alamofire), register the interceptor directly on the configuration:

```swift
let config = URLSessionConfiguration.default
#if DEBUG
NetScopeUniversal.register(in: config)
#endif
let session = URLSession(configuration: config)
```

## Example

See the [`Example/`](Example/) directory for a sample app that fires real API calls against [JSONPlaceholder](https://jsonplaceholder.typicode.com) and shows them in the NetScope viewer.

## License

MIT — see [LICENSE](LICENSE) for details.

