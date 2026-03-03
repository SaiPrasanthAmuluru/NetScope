# NetScope Example

Sample app showing how to integrate NetScope with a SwiftUI project. Uses [JSONPlaceholder](https://jsonplaceholder.typicode.com) as a test API.

## How to run

1. Create a new iOS App project in Xcode (SwiftUI, Swift), save it in this `Example/` directory
2. Delete the auto-generated Swift files — the ones here replace them
3. Add the local NetScope package: **File > Add Package Dependencies > Add Local** → point to the root `NetScope/` directory
4. Drag `NetScopeExampleApp.swift`, `ContentView.swift`, and `APIService.swift` into the project
5. Build & run

The app has buttons for GET, POST, PUT, DELETE, and a 404 endpoint. Tap the floating bubble to open the network log.
