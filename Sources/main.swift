import Foundation
import Swifter
import Dispatch

guard let nodeID = ArgumentParser.getValue("id") else {
    print("Please provide the node's id as the command line argument (id=HERE_THE_NAME)")
    exit(0)
}

let server = HttpServer()
server["/"] = { request, responseHeaders in
    print("\(nodeID) Handling request")
    return .ok(.html("LoadBalancerNode: \(nodeID)"))
}
server["/health"] = { request, responseHeaders in
    print("\(nodeID) Health check")
    return .ok(.html("LoadBalancerNode: \(nodeID)"))
}

server.notFoundHandler = { request, responseHeaders in
    print("File `\(request.path)` doesn't exist")
    return .notFound()
}
server.middleware.append( { request, header in
    print("Request \(request.id) \(request.method) \(request.path) from \(request.peerName ?? "")")
    request.onFinished = { id, code, duration in
        print("Request \(id) finished with \(code) in \(String(format: "%.3f", duration)) seconds")
    }
    return nil
})
do {
    var port: UInt16 = 9090
    if let arg = ArgumentParser.getValue("port"), let number = UInt16(arg) {
        port = number
    }
    print("Started LoadBalancerNode: \(nodeID) on port: \(port)")
    try server.start(port)
} catch {
    print("Error srating server: \(error)")
}
dispatchMain()
