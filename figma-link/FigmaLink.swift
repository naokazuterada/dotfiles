import Cocoa

class FigmaLinkController: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var timer: Timer?
    var isMonitoring = false
    var prevChangeCount: Int = 0
    var statusMenuItem: NSMenuItem!
    var toggleMenuItem: NSMenuItem!

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            button.title = "Fig"
        }

        let menu = NSMenu()

        statusMenuItem = NSMenuItem(title: "● 監視中", action: nil, keyEquivalent: "")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)

        menu.addItem(NSMenuItem.separator())

        toggleMenuItem = NSMenuItem(title: "監視停止", action: #selector(toggleMonitoring), keyEquivalent: "")
        toggleMenuItem.target = self
        menu.addItem(toggleMenuItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "終了", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu

        startMonitoring()
    }

    @objc func toggleMonitoring() {
        if isMonitoring {
            stopMonitoring()
        } else {
            startMonitoring()
        }
    }

    func startMonitoring() {
        prevChangeCount = NSPasteboard.general.changeCount
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
        RunLoop.current.add(timer!, forMode: .common)
        isMonitoring = true
        updateUI()
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
        updateUI()
    }

    func updateUI() {
        if isMonitoring {
            statusItem.button?.title = "Fig"
            statusMenuItem.title = "● 監視中"
            toggleMenuItem.title = "監視停止"
        } else {
            statusItem.button?.title = "Fig✕"
            statusMenuItem.title = "○ 停止中"
            toggleMenuItem.title = "監視開始"
        }
    }

    func checkClipboard() {
        let currentCount = NSPasteboard.general.changeCount
        if currentCount == prevChangeCount { return }
        prevChangeCount = currentCount

        guard let text = NSPasteboard.general.string(forType: .string) else { return }

        if isFigmaBoilerplate(text), let url = extractFigmaURL(text) {
            showCleanDialog(url: url)
        }
    }

    func isFigmaBoilerplate(_ text: String) -> Bool {
        text.contains("Figmaから実装して") && text.contains("@https://www.figma.com/")
    }

    func extractFigmaURL(_ text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: "https://www\\.figma\\.com/[^ \\n\\r]*"),
              let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
              let range = Range(match.range, in: text) else { return nil }
        return String(text[range])
    }

    func showCleanDialog(url: String) {
        let alert = NSAlert()
        alert.messageText = "Figmaリンクを検出しました"
        alert.informativeText = "URLのみに変換しますか？\n\n\(url)"
        alert.addButton(withTitle: "クリーニング")
        alert.addButton(withTitle: "そのまま")
        alert.alertStyle = .informational

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(url, forType: .string)
            prevChangeCount = NSPasteboard.general.changeCount
        }
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}

// --- main ---
let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = FigmaLinkController()
app.delegate = delegate
app.run()
