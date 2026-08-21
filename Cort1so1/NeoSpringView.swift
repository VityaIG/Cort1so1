import SwiftUI
import WebKit
import Darwin

/// Выполнение реального перезапуска SpringBoard (Respring) без искусственных спиннеров
struct NeoSpringView: View {
    var onFinished: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            NeoSpringWebView()
                .brightness(-1.0)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .onAppear {
            // 1. Попытка мгновенного нативного перезапуска SpringBoard (для TrollStore / Jailbroken)
            triggerNativeRespring()
        }
        .task {
            // 2. Фоллбэк таймаут для сред без креша SpringBoard (симулятор)
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            onFinished?()
        }
    }

    /// Попытка прямого респринга через системные утилиты (TrollStore / Jailbreak)
    private func triggerNativeRespring() {
        let binaries = [
            "/var/jb/usr/bin/sbreload",
            "/usr/bin/sbreload",
            "/var/jb/usr/bin/killall",
            "/usr/bin/killall"
        ]
        
        for binary in binaries {
            if FileManager.default.fileExists(atPath: binary) {
                var pid: pid_t = 0
                if binary.contains("killall") {
                    var args: [UnsafeMutablePointer<CChar>?] = [
                        strdup(binary),
                        strdup("-9"),
                        strdup("SpringBoard"),
                        nil
                    ]
                    posix_spawn(&pid, binary, nil, nil, &args, nil)
                } else {
                    var args: [UnsafeMutablePointer<CChar>?] = [
                        strdup(binary),
                        nil
                    ]
                    posix_spawn(&pid, binary, nil, nil, &args, nil)
                }
            }
        }
    }
}

let respringHTMLDocument = """
<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            html, body { width: 100%; height: 100%; margin: 0; padding: 0; overflow: hidden; background: black; }
            iframe { width: 100%; height: 100%; border: none; }
        </style>
    </head>
    <body>
        <iframe id="frame" srcdoc="" sandbox="allow-forms allow-modals allow-orientation-lock allow-pointer-lock allow-popups allow-presentation allow-scripts"></iframe>
        <script>
            const frame = document.getElementById('frame');
            const funfun = `
                <html>
                <head>
                    <style>
                        html, body { width: 100%; height: 100%; margin: 0; padding: 0; overflow: hidden; }
                        .container { perspective: 1px; perspective-origin: 9999999% 9999999%; width: 100vw; height: 100vh; }
                        .layer { position: absolute; width: 100vw; height: 100vh; backdrop-filter: blur(100px); -webkit-backdrop-filter: blur(100px); }
                    </style>
                </head>
                <body>
                    <div class="container" id="c"></div>
                    <script>
                        const container = document.getElementById('c');
                        for (let i = 0; i < 1000; i++) {
                            let d = document.createElement('div');
                            d.className = 'layer';
                            d.style.transform = 'translate3d(100000px, 100000px, ' + i + 'px) rotateY(90deg)';
                            container.appendChild(d);
                        }

                        setInterval(() => {
                            try {
                                if (navigator.share) {
                                    navigator.share({ title: 'R', text: 'R'.repeat(100000) }).catch(() => {});
                                }
                            } catch(e) {}
                            let x = new Uint8Array(1024 * 1024 * 32);
                            crypto.getRandomValues(x);
                        }, 0);

                        function bombard() {
                            for (let j = 0; j < 30; j++) {
                                let b = new Uint8Array(1024 * 1024 * 16);
                                crypto.getRandomValues(b);
                            }
                            requestAnimationFrame(bombard);
                        }
                        bombard();
                    <\\/script>
                </body>
                </html>
            `;

            frame.srcdoc = funfun;
        </script>
    </body>
</html>
"""

struct NeoSpringWebView: UIViewRepresentable {
    typealias UIViewType = WKWebView

    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences = preferences
        
        let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.loadHTMLString(respringHTMLDocument, baseURL: nil)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(respringHTMLDocument, baseURL: nil)
    }
}

#Preview {
    NeoSpringView(onFinished: {})
}
