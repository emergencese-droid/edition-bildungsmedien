import os
import uuid
from typing import Optional
from fastapi import FastAPI, Request, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

# ETOS-Nexus & Controlling
from src.ai_bridge.controlling import ETOSControllingEngine, VibronicVector
from src.officewrite.builder import DocumentBuilder

app = FastAPI(title="PhoenixOffice Control Center")

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
templates = Jinja2Templates(directory=os.path.join(BASE_DIR, "app", "templates"))
app.mount("/static", StaticFiles(directory=os.path.join(BASE_DIR, "app", "static")), name="static")

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
            button { background: #238636; cursor: pointer; font-weight: bold; }
            button:hover { background: #2ea043; }
            .nav { margin-bottom: 20px; display: flex; gap: 15px; }
            .nav a { color: #58a6ff; text-decoration: none; }
        </style>
    </head>
    <body>
        <div class="card">
            <div class="nav">
                <a href="/">← Zum Dashboard</a>
                <a href="/ingest">E-Mail Ingest</a>
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
    return HTMLResponse(f"""
        <body style="background:#0d1117; color:#c9d1d9; font-family:sans-serif; padding:40px;">
            <div style="background:#161b22; border:1px solid #30363d; border-radius:8px; padding:25px; max-width:600px; margin:0 auto;">
                <h2 style="color:#58a6ff;">Ergebnis der ETOS-Berechnung</h2>
                <p><strong>P-Score:</strong> {score}</p>
                <p><strong>Eskalationsstufe:</strong> <span style="background:{'#da3633' if tier=='P0' else '#238636'}; padding:4px 8px; border-radius:4px;">{tier}</span></p>
                <p><strong>Veto-Pflicht:</strong> {'JA (Kabinett/StS)' if veto else 'Nein'}</p>
                <br>
                <a href="/console" style="color:#58a6ff;">← Zurück zur Konsole</a> | <a href="/" style="color:#58a6ff;">Zum Dashboard</a>
            </div>
        </body>
    """)
