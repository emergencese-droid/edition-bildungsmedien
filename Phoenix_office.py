from flask import Flask, Response, jsonify

app = Flask(__name__)

HTML = r"""<!DOCTYPE html>
<html lang="de">
<head>
    <meta charset="UTF-8">
    <title>PhoenixOffice</title>
    <style>
        body { font-family: system-ui, sans-serif; margin: 0; padding: 0; background: #111; color: #eee; }
        #phoenix-office { display: flex; flex-direction: column; height: 100vh; }
        header { padding: 10px 20px; background: #222; border-bottom: 1px solid #444; }
        nav { padding: 8px 20px; background: #181818; border-bottom: 1px solid #333; }
        nav button { margin-right: 8px; padding: 6px 10px; background: #333; color: #eee; border: none; cursor: pointer; }
        nav button:hover { background: #555; }
        main { flex: 1; padding: 10px 20px; overflow: auto; }
        section { margin-bottom: 16px; padding: 10px; border: 1px solid #333; border-radius: 4px; background: #1a1a1a; }
        h1, h2, h3 { margin: 4px 0 8px; }
        pre { background: #000; padding: 6px; border-radius: 4px; font-size: 12px; overflow: auto; }
        #routing-heatmap { display: grid; grid-template-columns: repeat(21, 12px); grid-gap: 2px; margin-top: 8px; }
        .heatmap-cell { width: 12px; height: 12px; border-radius: 2px; }
    </style>
</head>
<body>

<div id="phoenix-office">

    <header>
        <h1>PhoenixOffice – Kontrollzentrum</h1>
    </header>

    <nav id="phoenix-nav">
        <button data-target="dashboard">Dashboard</button>
    </nav>

    <main id="phoenix-main">
        <div id="phoenix-dashboard">

            <section>
                <h2>Systemstatus</h2>
                <div id="sys-status"></div>
                <div id="sys-level"></div>
                <div id="sys-reason"></div>
            </section>

            <section>
                <h2>Schwarze Energie</h2>
                <div id="se-state"></div>
                <pre id="se-window"></pre>
            </section>

            <section>
                <h2>Frequenzen (PhoenixAI)</h2>
                <pre id="ai-frequencies"></pre>
            </section>

            <section>
                <h2>Mail – Statistik & Risiko</h2>
                <pre id="mail-stats"></pre>
                <pre id="mail-risk"></pre>
            </section>

            <section>
                <h2>Routing KI – Vorschläge</h2>
                <pre id="routing-suggestions"></pre>
            </section>

            <section>
                <h2>Routing Heatmap</h2>
                <div id="routing-heatmap"></div>
            </section>

            <section>
                <h2>Matrix21×21 – Kontext</h2>
                <pre id="matrix-context"></pre>
            </section>

            <section>
                <h2>Schreibmodul – PhoenixWrite</h2>
                <pre id="write-stats"></pre>
            </section>

            <section>
                <h2>Gewaltenmonitoring</h2>
                <pre id="gewalten-monitor"></pre>
            </section>

        </div>
    </main>

</div>

<script type="module">
async function updateDashboard() {
    const res = await fetch("/api/dashboard");
    const data = await res.json();

    document.getElementById("sys-status").innerText = data.guard.status;
    document.getElementById("sys-level").innerText = data.guard.level;
    document.getElementById("sys-reason").innerText = data.guard.reason;

    document.getElementById("se-state").innerText = data.guard.se_state;
    document.getElementById("se-window").innerText =
        JSON.stringify(data.guard.window_activity, null, 2);

    document.getElementById("ai-frequencies").innerText =
        JSON.stringify(data.ai.frequencies, null, 2);

    document.getElementById("mail-stats").innerText =
        JSON.stringify(data.mail.stats, null, 2);

    document.getElementById("mail-risk").innerText =
        JSON.stringify(data.mail.risk, null, 2);

    document.getElementById("routing-suggestions").innerText =
        JSON.stringify(data.routing.suggestions, null, 2);

    renderHeatmap(data.routing.heatmap);

    document.getElementById("matrix-context").innerText =
        JSON.stringify(data.matrix.context, null, 2);

    document.getElementById("write-stats").innerText =
        JSON.stringify(data.write.stats, null, 2);

    document.getElementById("gewalten-monitor").innerText =
        JSON.stringify(data.monitoring.gewalten, null, 2);
}

function renderHeatmap(data) {
    const container = document.getElementById("routing-heatmap");
    container.innerHTML = "";
    for (let x = 0; x < data.length; x++) {
        for (let y = 0; y < data[x].length; y++) {
            const cell = document.createElement("div");
            cell.className = "heatmap-cell";
            const score = data[x][y];
            if (score < 10) cell.style.background = "#2e7d32";
            else if (score < 30) cell.style.background = "#f9a825";
            else if (score < 60) cell.style.background = "#ef6c00";
            else cell.style.background = "#c62828";
            cell.title = "Score: " + score;
            container.appendChild(cell);
        }
    }
}

updateDashboard();
</script>

</body>
</html>
"""

@app.route("/")
def index():
    return Response(HTML, mimetype="text/html")


@app.route("/api/dashboard")
def api_dashboard():
    # Dummy-Daten – hier kannst du später PhoenixAI, Guard, Matrix etc. einhängen
    guard = {
        "status": "OK",
        "level": "LOW",
        "reason": "System stabil",
        "se_state": "stable",
        "window_activity": {"windows": 0, "events": []},
    }

    ai = {
        "frequencies": {
            "L1": 0.12, "L2": 0.18, "L3": 0.25,
            "L4": 0.31, "L5": 0.28, "L6": 0.35
        }
    }

    mail_stats = {
        "total": 42,
        "positive": 30,
        "negative": 12,
        "conflict": 5,
        "structure": 20,
        "critical": 3,
        "risk_score": 14
    }

    mail_risk = {
        "risk_score": 14,
        "semantic": 0.2,
        "relationship": 0.3,
        "se_state": "stable",
        "freq_risk": 0.1,
        "critical": False,
        "conflict": 0.3,
        "negative": 0.4
    }

    routing_suggestions = [
        {"route": "partner_inbox", "score": 72},
        {"route": "risk_inbox", "score": 48},
        {"route": "general_inbox", "score": 25},
    ]

    # einfache 21×21 Heatmap mit zufälligen Werten
    heatmap = [[(x + y) % 100 for y in range(21)] for x in range(21)]

    matrix_context = {
        "rows": 21,
        "cols": 21,
        "types": ["partner", "role", "audit", "esc", "tensor", "ctx"]
    }

    write_stats = {
        "documents": 7,
        "chapters": 32,
        "words": 18450
    }

    gewalten = {
        "executive": {"load": 0.32, "signals": 12, "risk": 0.1},
        "legislative": {"load": 0.21, "signals": 7, "risk": 0.05},
        "judicial": {"load": 0.44, "signals": 18, "risk": 0.22},
    }

    return jsonify({
        "guard": guard,
        "ai": ai,
        "mail": {"stats": mail_stats, "risk": mail_risk},
        "routing": {"suggestions": routing_suggestions, "heatmap": heatmap},
        "matrix": {"context": matrix_context},
        "write": {"stats": write_stats},
        "monitoring": {"gewalten": gewalten},
    })


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=True)
