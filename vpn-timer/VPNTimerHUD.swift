import Cocoa

class TimerWindowController: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var window: NSWindow!
    var label: NSTextField!
    var timer: Timer!
    let endTime: TimeInterval
    let pidFile = "/tmp/vpn_timer.pid"
    let timerScript = "/tmp/vpn_timer_bg.sh"
    let endTimeFile = "/tmp/vpn_timer_end.txt"
    let disconnectScptFile: String

    init(endTime: TimeInterval, disconnectScptFile: String) {
        self.endTime = endTime
        self.disconnectScptFile = disconnectScptFile
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let width: CGFloat = 260
        let height: CGFloat = 90
        let rect = NSRect(x: 0, y: 0, width: width, height: height)

        window = NSWindow(
            contentRect: rect,
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "VPN Timer"
        window.level = .floating
        window.delegate = self
        window.isReleasedWhenClosed = false

        // 画面右上に配置
        if let screen = NSScreen.main {
            let visibleFrame = screen.visibleFrame
            let x = visibleFrame.maxX - width - 16
            let y = visibleFrame.maxY - height - 16
            window.setFrameOrigin(NSPoint(x: x, y: y))
        }

        let contentView = window.contentView!

        label = NSTextField(labelWithString: "")
        label.font = NSFont.monospacedDigitSystemFont(ofSize: 28, weight: .medium)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)

        let button = NSButton(title: "VPN を切断", target: self, action: #selector(disconnect))
        button.bezelStyle = .rounded
        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),

            button.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
        ])

        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        updateLabel()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateLabel), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }

    @objc func updateLabel() {
        let remaining = Int(endTime - Date().timeIntervalSince1970)
        if remaining <= 0 {
            label.stringValue = "切断中..."
            timer.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                NSApp.terminate(nil)
            }
            return
        }
        let h = remaining / 3600
        let m = (remaining % 3600) / 60
        let s = remaining % 60
        label.stringValue = String(format: "残り %d:%02d:%02d", h, m, s)
    }

    @objc func disconnect() {
        timer.invalidate()
        label.stringValue = "切断中..."

        DispatchQueue.global().async { [self] in
            // バックグラウンドタイマーを停止
            if let pid = try? String(contentsOfFile: pidFile, encoding: .utf8)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            {
                let kill = Process()
                kill.executableURL = URL(fileURLWithPath: "/bin/kill")
                kill.arguments = [pid]
                try? kill.run()
                kill.waitUntilExit()
            }

            // VPN切断
            let osascript = Process()
            osascript.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
            osascript.arguments = [disconnectScptFile]
            try? osascript.run()
            osascript.waitUntilExit()

            // クリーンアップ
            for f in [pidFile, timerScript, endTimeFile, disconnectScptFile] {
                try? FileManager.default.removeItem(atPath: f)
            }

            DispatchQueue.main.async {
                self.label.stringValue = "切断しました"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    NSApp.terminate(nil)
                }
            }
        }
    }

    // ウィンドウを閉じてもVPNは切断しない（タイマーは継続）
    func windowWillClose(_ notification: Notification) {
        NSApp.terminate(nil)
    }
}

// --- main ---
let args = CommandLine.arguments
guard args.count >= 2, let endTime = Double(args[1]) else {
    fputs("Usage: vpn-timer-hud <end_unix_timestamp> [disconnect_scpt_path]\n", stderr)
    exit(1)
}
let disconnectScpt = args.count >= 3 ? args[2] : "/tmp/vpn_timer_disconnect.scpt"

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let delegate = TimerWindowController(endTime: endTime, disconnectScptFile: disconnectScpt)
app.delegate = delegate
app.run()
