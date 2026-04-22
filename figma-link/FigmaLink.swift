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

        if hasBoilerplate(text), let cleaned = removeBoilerplate(text) {
            showCleanDialog(cleaned: cleaned)
        }
    }

    // 「これらのN個のデザインをFigmaから実装して。」の定型文を検出
    func hasBoilerplate(_ text: String) -> Bool {
        text.range(of: "これらの.+をFigmaから実装して", options: .regularExpression) != nil
    }

    // 定型文の行を除去し、残りのテキスト（@URL等）を返す
    func removeBoilerplate(_ text: String) -> String? {
        let lines = text.components(separatedBy: "\n")
        let filtered = lines.filter { line in
            line.range(of: "これらの.+をFigmaから実装して", options: .regularExpression) == nil
        }
        let result = filtered.joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return result.isEmpty ? nil : result
    }

    func showCleanDialog(cleaned: String) {
        let alert = NSAlert()
        alert.messageText = "Figmaの定型文を検出しました"
        alert.informativeText = "コメント部分を削除しますか？"
        alert.addButton(withTitle: "削除する")
        alert.addButton(withTitle: "そのまま")
        alert.alertStyle = .informational

        NSApp.activate(ignoringOtherApps: true)
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(cleaned, forType: .string)
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
