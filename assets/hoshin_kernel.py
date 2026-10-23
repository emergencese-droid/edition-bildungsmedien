import numpy as np

class HoshinFeedbackLoop:
    def __init__(self, target_vector=None, sigma_vector=None, alpha=0.02, max_grad=50.0):
        """
        Gehärteter 4D-Hoshin-Regelkern für PhoenixOffice.
        Zustand: [0: Theta (Grad), 1: Torsion, 2: Impact, 3: Urgency]
        """
        self.mu = np.array([45.0, 0.0, 0.0, 0.0] if target_vector is None else target_vector, dtype=float)
        self.sigma = np.array([5.0, 0.15, 0.15, 0.15] if sigma_vector is None else sigma_vector, dtype=float)
        self.alpha = alpha
        self.max_grad = max_grad

        # Potentialparameter V(x) = 1/2 x^T A x + 1/4 (x^T B x)^2
        self.A = np.diag([0.02, 1.5, 1.8, 2.0])
        self.B = np.array([
            [0.01, 0.02, 0.01, 0.01],
            [0.02, 0.60, 0.30, 0.20],
            [0.01, 0.30, 0.80, 0.40],
            [0.01, 0.20, 0.40, 1.00]
        ])

        self.dim_labels = ["Phase (θ)", "Torsion (τ)", "Impact (I)", "Urgency (U)"]

    def _validate_state(self, state) -> np.ndarray:
        arr = np.asarray(state, dtype=float)
        if arr.shape != (4,):
            raise ValueError("State muss exakt 4 Dimensionen besitzen: [theta, torsion, impact, urgency]")
        return arr

    def evaluate_sensor(self, delta: np.ndarray):
        """Berechnet Mahalanobis-Distanz und normiertes Vertrauen (0.0 bis 1.0)."""
        d_m2 = float(np.sum((delta / self.sigma) ** 2))
        confidence = float(np.exp(-0.5 * d_m2))
        return d_m2, confidence

    def calculate_gradient(self, delta: np.ndarray) -> np.ndarray:
        """Gradientenbildung mit numerischem Clipping gegen Übersteuern."""
        linear = self.A @ delta
        quartic_weight = float(delta.T @ self.B @ delta)
        grad = linear + (quartic_weight * (self.B @ delta))
        
        grad_norm = np.linalg.norm(grad)
        if grad_norm > self.max_grad:
            grad = grad * (self.max_grad / grad_norm)
        return grad

    def _interpret_actions(self, delta: np.ndarray, action: np.ndarray) -> list:
        """Erzeugt Klartext-Handlungsanweisungen für den Leitstand."""
        actions = []
        for i in range(4):
            val = delta[i]
            act = action[i]
            if abs(val) < (self.sigma[i] * 0.3):
                status = "Im Toleranzbereich (stabil)"
            elif act > 0:
                status = f"Erhöhen (+{abs(act):.3f})"
            else:
                status = f"Reduzieren (-{abs(act):.3f})"
            actions.append({"parameter": self.dim_labels[i], "empfehlung": status})
        return actions

    def derive_sequence(self, current_state: list, steps: int = 5) -> dict:
        state = self._validate_state(current_state)
        sequence = []

        for step_idx in range(1, steps + 1):
            delta = state - self.mu
            d_m2, conf = self.evaluate_sensor(delta)
            grad = self.calculate_gradient(delta)

            # Adaptive Dämpfung
            damping = 1.0 / (1.0 + 0.15 * np.sqrt(d_m2))
            action = -self.alpha * damping * grad
            next_state = state + action

            # P-Score Einstufung
            if d_m2 > 9.0:
                tier = "P0 (Eskalation / Veto)"
            elif d_m2 > 4.0:
                tier = "P1 (Hohe Wachsamkeit)"
            elif d_m2 > 1.0:
                tier = "P2 (Normale Steuerung)"
            else:
                tier = "P3 (Zielkorridor erreicht)"

            sequence.append({
                "zyklus": step_idx,
                "zustand": [round(float(v), 3) for v in state],
                "confidence_percent": round(conf * 100.0, 1),
                "mahalanobis_d2": round(d_m2, 2),
                "tier": tier,
                "massnahmen": self._interpret_actions(delta, action)
            })

            state = next_state

        return {
            "initial_state": [round(float(v), 3) for v in current_state],
            "ziel_soll": self.mu.tolist(),
            "schrittfolge": sequence,
            "endzustand": [round(float(v), 3) for v in state]
        }
