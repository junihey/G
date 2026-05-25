const osc = require("osc");
const WebSocket = require("ws");

const udpPort = new osc.UDPPort({
    localAddress: "127.0.0.1",
    localPort: 1234
});

const wss = new WebSocket.Server({ port: 8080 });

wss.on("connection", (ws) => {
    console.log("✅ RNBO Web Interface (Browser) hat sich verbunden!");
    
    udpPort.on("message", (oscMsg) => {
        // Zeigt das empfangene Signal im schwarzen Fenster an
        console.log("📥 Signal von Luanti empfangen:", oscMsg);
        
        // Leitet das Signal an den Browser weiter
        ws.send(JSON.stringify(oscMsg));
    });
});

udpPort.open();
console.log("🚀 Bridge laeuft! Warte auf Luanti (Port 1234) und RNBO (Port 8080)...");