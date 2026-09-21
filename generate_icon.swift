import Cocoa

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)
image.lockFocus()

// Red background
let bgPath = NSBezierPath(rect: NSRect(origin: .zero, size: size))
NSColor.systemRed.setFill()
bgPath.fill()

// Draw pills.fill SF Symbol
if let symbol = NSImage(systemSymbolName: "pills.fill", accessibilityDescription: nil) {
    // Configure symbol to be white
    let config = NSImage.SymbolConfiguration(pointSize: 600, weight: .regular)
    let configuredSymbol = symbol.withSymbolConfiguration(config)!
    
    // Color it white
    let tintedSymbol = NSImage(size: configuredSymbol.size)
    tintedSymbol.lockFocus()
    configuredSymbol.draw(in: NSRect(origin: .zero, size: configuredSymbol.size))
    NSColor.white.set()
    let rect = NSRect(origin: .zero, size: tintedSymbol.size)
    rect.fill(using: .sourceAtop)
    tintedSymbol.unlockFocus()

    let drawRect = NSRect(
        x: (size.width - tintedSymbol.size.width) / 2,
        y: (size.height - tintedSymbol.size.height) / 2,
        width: tintedSymbol.size.width,
        height: tintedSymbol.size.height
    )
    tintedSymbol.draw(in: drawRect)
}

image.unlockFocus()

// Save to disk
if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    if let pngData = bitmapRep.representation(using: .png, properties: [:]) {
        let url = URL(fileURLWithPath: "MyApp/Assets.xcassets/AppIcon.appiconset/icon.png")
        try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        try? pngData.write(to: url)
    }
}
