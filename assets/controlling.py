import math
from dataclasses import dataclass
from typing import Tuple, Dict, Any

@dataclass
class VibronicVector:
    angle_deg: float      # L_FORM_03: 45°, 90°, 150°, 180°
    torsion: float        # L_FORM_02: rho0 * exp(-alpha * r)
    impact: float         # 0.0 - 1.0
    urgency: float        # 0.0 - 1.0
    is_resonant: bool = False # L_FORM_04: Phaseninterferenz

class ETOSControllingEngine:
    """ETOS-Nexus Controlling & Governance Matrix (Segment 1 & 2)"""
    
    SYSTEM_CLOCK_HZ = 50.0   # L_FORM_01: 50.0 Hz (20ms Zyklus)
    CLOCK_CYCLE_S = 0.020
    
    WHITEHEAD_ACTIVE = 0.66  # L_FORM_05: 2:1 Balance
    WHITEHEAD_SPACE = 0.32

    @staticmethod
    def calculate_p_score(vector: VibronicVector) -> Tuple[float, str, bool]:
        """
        L_VECTOR_SYS: Berechnet den Gesamtzustandsvektor und ordnet
        ihn in P0, P1, P2 oder P3 mit Veto-Entscheid ein.
        """
        # Gewichtete Basis: 35% Impact, 25% Urgency, 25% Torsion, 15% Winkelnormalisierung
        norm_angle = (vector.angle_deg % 360) / 360.0
        base_score = (
            0.35 * vector.impact +
            0.25 * vector.urgency +
            0.25 * min(vector.torsion, 1.0) +
            0.15 * norm_angle
        )
        
        # L_FORM_04: Resonanz-Torsionssprung (+15% Boost)
        if vector.is_resonant or vector.angle_deg in [45.0, 90.0, 150.0, 180.0]:
            base_score *= 1.15

        p_score = round(min(base_score, 1.0), 3)

        # Segment 2 / Tabellenblatt 2: Eskalationsstufen
        if p_score >= 0.85:
            tier = "P0"
            veto_required = True   # Kabinett / StS Veto-Pflicht
        elif p_score >= 0.65:
            tier = "P1"
            veto_required = False  # Bedingt / Campaign Center
        elif p_score >= 0.40:
            tier = "P2"
            veto_required = False  # Audit-Protokoll / Draft only
        else:
            tier = "P3"
            veto_required = False  # Vollautomatische Archivierung

        return p_score, tier, veto_required

    @classmethod
    def evaluate_whitehead_balance(cls, action_words: int, reflection_words: int) -> bool:
        """L_FORM_05: Prüft die Invariante (Disbalance-Veto > 5%)."""
        total = action_words + reflection_words
        if total == 0:
            return True
        actual_ratio = action_words / total
        return abs(actual_ratio - cls.WHITEHEAD_ACTIVE) <= 0.05
