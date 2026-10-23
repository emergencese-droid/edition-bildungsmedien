import os
import uuid
import shutil
import subprocess
from typing import Optional
from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

# ETOS-Nexus & Controlling
from src.ai_bridge.controlling import ETOSControllingEngine, VibronicVector
from src.officewrite.builder import DocumentBuilder

# Optionaler Import des Hoshin-Kernels (fällt sauber zurück, falls noch nicht synchronisiert)
try:
    from src.ai_bridge.hoshin_kernel import HoshinFeedbackLoop
    hoshin_kernel = HoshinFeedbackLoop()
except ImportError:
    hoshin_kernel = None

app = FastAPI(title="PhoenixOffice Control Center")

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
templates_dir = os.path.join(BASE_DIR, "app", "templates")
static_dir = os.path.join(BASE_DIR, "app", "static")

os.makedirs(templates_dir, exist_ok=True)
os.makedirs(static_dir, exist_ok=True)

templates = Jinja2Templates(directory=templates_dir)
app.mount("/static", StaticFiles(directory=static_dir), name="static")

write_engine = DocumentBuilder()

# In-Memory Datenspeicher für Vorgänge
RECORDS = []

@app.get("/", response_class=HTMLResponse)
def get_dashboard(request: Request):
    return templates.TemplateResponse("dashboard.html", {
        "request": request,
        "records": RECORDS,
        "system_status": {
            "Subsystem-Health": "Online",
            "DB-Status": "Verbunden (In-Memory / SQLite)",
            "OfficeWrite Engine": "Bereit (DOCX Builder v1.0)",
            "Data Science Bridge": "ETOS-Nexus aktiv (P0-P3 Matrix)"
        }
    })

@app.get("/ingest", response_class=HTMLResponse)
def get_ingest(request: Request):
    return templates.TemplateResponse("ingest.html", {"request": request})

@app.post("/ingest")
def post_ingest(
    request: Request,
    sender: str = Form(...),
    recipient: str = Form(...),
    subject: str = Form(...),
    body: str = Form(...)
):
    record_id = str(uuid.uuid4())[:8]
    
    # ETOS-Nexus Berechnung ausführen (Standard: 45° Codon-Winkel)
    vector = VibronicVector(angle_deg=45.0, torsion=0.8, impact=0.85, urgency=0.75)
    p_score, tier, veto_req = ETOSControllingEngine.calculate_p_score(vector)
    
    # Klassifikation & Dokumentengenerierung
    intent = "lagebericht" if "lage" in subject.lower() or "lage" in body.lower() else "mitteilung"
    doc_path = write_engine.build_document(
        doc_id=record_id,
        title=subject,
        doc_type=intent,
        author=sender,
        summary=f"P-Score: {p_score} | Stufe: {tier} | Veto: {veto_req}",
        body=body
    )
    
    record = {
        "id": record_id,
        "sender": sender,
        "recipient": recipient,
        "subject": subject,
        "intent": intent,
        "status": "processed",
        "p_score": p_score,
        "tier": tier,
        "veto": veto_req,
        "doc_path": doc_path
    }
    RECORDS.insert(0, record)
    return RedirectResponse(url=f"/vorgang/{record_id}", status_code=303)

@app.get("/vorgang/{record_id}", response_class=HTMLResponse)
def get_record(request: Request, record_id: str):
    rec = next((r for r in RECORDS if r["id"] == record_id), None)
    return templates.TemplateResponse("record_detail.html", {"request": request, "record": rec})

# --- Integrierte Leitstand-Konsole im Browser ---
@app.get("/console", response_class=HTMLResponse)
def get_console(request: Request):
    html_content = """
    <!DOCTYPE html>
    <html lang="de">
    <head>
        <meta charset="UTF-8">
        <title>PhoenixOffice :: Leitstand-Konsole</title>
        <link rel="stylesheet" href="/static/styles.css">
        <style>
            body { font-family: sans-serif; background: #0d1117; color: #c9d1d9; padding: 25px; }
            .card { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 20px; max-width: 800px; margin: 0 auto; }
            input, select, button { padding: 10px; margin: 8px 0; background: #0d1117; border: 1px solid #30363d; color: #fff; border-radius: 6px; }
            button { background: #238636; cursor: pointer; font-weight: bold; border: none; }
            button:hover { background: #2ea043; }
            .nav { margin-bottom: 20px; display: flex; gap: 15px; }
            .nav a { color: #58a6ff; text-decoration: none; font-weight: 500; }
        </style>
    </head>
    <body>
        <div class="card">
            <div class="nav">
                <a href="/">← Zum Dashboard</a>
                <a href="/ingest">E-Mail Ingest</a>
                <a href="/write">PhoenixWrite (Steuerzentrale)</a>
            </div>
            <h2>Leitstand-Konsole (ETOS-Nexus Steuerung)</h2>
            <p>Hier kannst du Parameter direkt ohne Terminal prüfen und steuern:</p>
            <form action="/console/eval" method="POST">
                <label>Codon-Winkel (Grad):</label><br>
                <input type="number" step="0.1" name="angle" value="45.0" style="width: 100%;"><br>
                <label>Torsion (0.0 - 1.0):</label><br>
                <input type="number" step="0.05" name="torsion" value="0.80" style="width: 100%;"><br>
                <label>Impact (0.0 - 1.0):</label><br>
                <input type="number" step="0.05" name="impact" value="0.85" style="width: 100%;"><br>
                <label>Urgency (0.0 - 1.0):</label><br>
                <input type="number" step="0.05" name="urgency" value="0.75" style="width: 100%;"><br>
                <button type="submit">Vektor berechnen & P-Score simulieren</button>
            </form>
        </div>
    </body>
    </html>
    """
    return HTMLResponse(content=html_content)

@app.post("/console/eval", response_class=HTMLResponse)
def post_console_eval(
    angle: float = Form(...),
    torsion: float = Form(...),
    impact: float = Form(...),
    urgency: float = Form(...)
):
    vec = VibronicVector(angle_deg=angle, torsion=torsion, impact=impact, urgency=urgency)
    score, tier, veto = ETOSControllingEngine.calculate_p_score(vec)
    
    # Erweiterte Hoshin-Schrittfolgeberechnung (falls HoshinFeedbackLoop aktiv ist)
    hoshin_html = ""
    if hoshin_kernel:
        res = hoshin_kernel.derive_sequence([angle, torsion, impact, urgency], steps=3)
        rows = ""
        for s in res["schrittfolge"]:
            actions_str = ", ".join([f"<strong>{a['parameter']}:</strong> {a['empfehlung']}" for a in s["massnahmen"]])
            rows += f"""
            <tr style="border-bottom: 1px solid #30363d;">
                <td style="padding: 8px;">Zyklus {s['zyklus']}</td>
                <td style="padding: 8px;">{s['tier']}</td>
                <td style="padding: 8px;">{s['confidence_percent']}%</td>
                <td style="padding: 8px; font-size: 0.85rem;">{actions_str}</td>
            </tr>
            """
        hoshin_html = f"""
        <div style="margin-top: 25px; border-top: 1px solid #30363d; padding-top: 15px;">
            <h3 style="color:#7ee787;">Hoshin-Regelung (4D-Gradientenableitung)</h3>
            <table style="width:100%; border-collapse: collapse; text-align: left; font-size: 0.9rem;">
                <thead>
                    <tr style="color: #8b949e; border-bottom: 2px solid #30363d;">
                        <th style="padding: 6px;">Zyklus</th>
                        <th style="padding: 6px;">Stufe</th>
                        <th style="padding: 6px;">Vertrauen</th>
                        <th style="padding: 6px;">Empfohlene Maßnahmen</th>
                    </tr>
                </thead>
                <tbody>
                    {rows}
                </tbody>
            </table>
        </div>
        """

    return HTMLResponse(f"""
    <body style="background:#0d1117; color:#c9d1d9; font-family:sans-serif; padding:40px;">
        <div style="background:#161b22; border:1px solid #30363d; border-radius:8px; padding:25px; max-width:750px; margin:0 auto;">
            <h2 style="color:#58a6ff;">Ergebnis der ETOS-Berechnung</h2>
            <p><strong>P-Score:</strong> {score}</p>
            <p><strong>Eskalationsstufe:</strong> <span style="background:{'#da3633' if tier=='P0' else '#238636'}; padding:4px 8px; border-radius:4px; font-weight:bold;">{tier}</span></p>
            <p><strong>Veto-Pflicht:</strong> {'JA (Kabinett/StS)' if veto else 'Nein'}</p>
            
            {hoshin_html}
            
            <br><br>
            <a href="/console" style="color:#58a6ff; text-decoration:none;">← Zurück zur Konsole</a> | 
            <a href="/write" style="color:#58a6ff; text-decoration:none;">PhoenixWrite</a> | 
            <a href="/" style="color:#58a6ff; text-decoration:none;">Zum Dashboard</a>
        </div>
    </body>
    """)

# --- PhoenixWrite: Steuerzentrale für Dateierstellung & GitHub-Sync ---
@app.get("/write", response_class=HTMLResponse)
async def write_console_view():
    return HTMLResponse("""
    <!DOCTYPE html>
    <html lang="de">
    <head>
        <meta charset="UTF-8">
        <title>PhoenixWrite – Steuerungszentrale</title>
        <style>
            body { background: #0d1117; color: #c9d1d9; font-family: sans-serif; padding: 25px; }
            .box { max-width: 850px; margin: auto; background: #161b22; padding: 25px; border-radius: 8px; border: 1px solid #30363d; }
            input, textarea, select { width: 100%; margin-bottom: 12px; background: #0d1117; border: 1px solid #30363d; color: #f8fafc; padding: 10px; border-radius: 6px; box-sizing: border-box; }
            .btn { background: #238636; color: #fff; padding: 10px 18px; border: none; font-weight: bold; cursor: pointer; border-radius: 6px; }
            .btn:hover { background: #2ea043; }
            .btn-sync { background: #1f6feb; margin-bottom: 15px; }
            .btn-sync:hover { background: #388bfd; }
            .nav { margin-bottom: 20px; display: flex; gap: 15px; }
            .nav a { color: #58a6ff; text-decoration: none; font-weight: 500; }
            hr { border: 0; border-top: 1px solid #30363d; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="box">
            <div class="nav">
                <a href="/console">← Zum Leitstand (ETOS-Nexus)</a>
                <a href="/">Dashboard</a>
            </div>
            
            <h2>PhoenixWrite – Steuerzentrale</h2>
            <p style="color: #8b949e;">Dateien im System verwalten und Module aus GitHub synchronisieren:</p>
            
            <form action="/write/sync" method="post">
                <button type="submit" class="btn btn-sync">⚡ Aus GitHub synchronisieren & Module verteilen</button>
            </form>
            
            <hr>

            <h3>Neues Modul / Dokument direkt anlegen</h3>
            <form action="/write" method="post">
                <label>Dateiname (z. B. <code>hoshin_kernel.py</code>):</label>
                <input type="text" name="filename" value="hoshin_kernel.py" required>

                <label>Zielbereich im System:</label>
                <select name="target_area">
                    <option value="ai_bridge">KI-Bridge (src/ai_bridge/)</option>
                    <option value="officewrite">OfficeWrite (src/officewrite/)</option>
                    <option value="vault">Storage Vault (storage_vault/)</option>
                </select>

                <label>Inhalt / Quelltext:</label>
                <textarea name="body" rows="14" placeholder="Code oder Text hier hineinkopieren..."></textarea>

                <button type="submit" class="btn">Datei direkt im System speichern</button>
            </form>
        </div>
    </body>
    </html>
    """)

@app.post("/write", response_class=HTMLResponse)
async def write_console_save(
    filename: str = Form(...),
    target_area: str = Form(...),
    body: str = Form("")
):
    base_dir = os.path.expanduser("~/phoenix-office")
    
    if target_area == "ai_bridge":
        target_dir = os.path.join(base_dir, "src", "ai_bridge")
    elif target_area == "officewrite":
        target_dir = os.path.join(base_dir, "src", "officewrite")
    else:
        target_dir = os.path.join(base_dir, "storage_vault")
        
    os.makedirs(target_dir, exist_ok=True)
    if target_area in ["ai_bridge", "officewrite"]:
        init_file = os.path.join(target_dir, "__init__.py")
        if not os.path.exists(init_file):
            open(init_file, "a").close()

    target_path = os.path.join(target_dir, filename.strip())
    with open(target_path, "w", encoding="utf-8") as f:
        f.write(body)

    return HTMLResponse(f"""
    <!DOCTYPE html>
    <html lang="de"><head><meta charset="UTF-8"><style>body{{background:#0d1117;color:#c9d1d9;font-family:sans-serif;padding:40px;text-align:center;}}a{{color:#58a6ff;text-decoration:none;}}</style></head>
    <body>
        <div style="background:#161b22; border:1px solid #30363d; border-radius:8px; padding:25px; max-width:600px; margin:0 auto;">
            <h2 style="color:#7ee787;">Datei erfolgreich abgelegt!</h2>
            <p>Pfad: <code>{target_path}</code></p>
            <br>
            <a href="/write">← Zurück zur Steuerzentrale</a> | <a href="/console">Zum Leitstand</a>
        </div>
    </body></html>
    """)

@app.post("/write/sync", response_class=HTMLResponse)
async def write_console_sync():
    repo_dir = os.path.expanduser("~/edition-bildungsmedien")
    bridge_dir = os.path.expanduser("~/phoenix-office/src/ai_bridge")
    os.makedirs(bridge_dir, exist_ok=True)
    open(os.path.join(bridge_dir, "__init__.py"), "a").close()

    # Git Pull im geklonten Verzeichnis ausführen
    git_res = subprocess.run(["git", "-C", repo_dir, "pull"], capture_output=True, text=True)
    
    # hoshin_kernel.py nach src/ai_bridge/ übertragen
    src_kernel = os.path.join(repo_dir, "assets", "hoshin_kernel.py")
    msg = ""
    if os.path.exists(src_kernel):
        shutil.copy(src_kernel, os.path.join(bridge_dir, "hoshin_kernel.py"))
        msg = "hoshin_kernel.py wurde erfolgreich nach src/ai_bridge/ synchronisiert!"
    else:
        msg = "Hinweis: assets/hoshin_kernel.py wurde im GitHub-Repo noch nicht gefunden."

    return HTMLResponse(f"""
    <!DOCTYPE html>
    <html lang="de"><head><meta charset="UTF-8"><style>body{{background:#0d1117;color:#c9d1d9;font-family:sans-serif;padding:40px;text-align:center;}}a{{color:#58a6ff;text-decoration:none;}}</style></head>
    <body>
        <div style="background:#161b22; border:1px solid #30363d; border-radius:8px; padding:25px; max-width:650px; margin:0 auto;">
            <h2 style="color:#58a6ff;">Synchronisation abgeschlossen</h2>
            <pre style="text-align:left; background:#0d1117; color:#8b949e; padding:12px; border-radius:6px; overflow-x:auto;">{git_res.stdout}\n{git_res.stderr}</pre>
            <p><strong>{msg}</strong></p>
            <br>
            <a href="/write">← Zurück zur Steuerzentrale</a> | <a href="/console">Zum Leitstand</a>
        </div>
    </body></html>
    """)
