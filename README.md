<div align="center">
  <h1>⛸️ Experimental Study of Vibrations in Risport Figure Skates during Off-Ice Jumps</h1>
  <p><i>Data Analysis for Mechanical Systems - Project Review</i></p>
  <p><b>Politecnico di Milano - Master of Science in Mechanical Engineering (Sports Engineering)</b></p>
</div>

<br>

> **Abstract:** This project aims to investigate how Risport figure skates design and lacing tightness affect the vibrations transmitted during jump landings. The purpose is to provide significant indicators relevant to comfort and potential overuse-risk mechanisms in athletes.

---

## 📑 Table of Contents
- [🎯 Key Objectives](#-key-objectives)
- [🔬 Methodology](#-methodology)
- [📊 Data Analysis](#-data-analysis)
- [🏆 Main Results](#-main-results)
- [🚀 Future Perspectives](#-future-perspectives)
- [👥 Authors](#-authors)

---

## 🎯 Key Objectives
*   **Analyze Impact Forces:** Investigate the transmission of impact forces through the skate to the skater's lower leg during landing.
*   **Compare Skate Models:** Evaluate two different Risport skate models (**RF1 Elite** and **Electra**) with varying stiffness levels.
*   **Assess Lacing Tightness:** Determine the effect of lacing tightness (tight vs. loose) on the overall vibration transmission.

## 🔬 Methodology
The study utilized two distinct experimental setups to cross-validate findings:

1.  **Off-Ice Jumps (Field Test):** A professional skater performed off-ice jumps wearing instrumented skates to capture realistic landing impact profiles (acceleration vs. time).
2.  **Electrodynamic Shaker (Lab Test):** A controlled laboratory setup using a mechanical shaker and a silicone foot prosthesis to reproducibly simulate the landing impacts on a single skate.

**🛠️ Data Acquisition & Hardware:**
*   **Piezoelectric Accelerometers:** Monoaxial sensors placed strategically at the *toe, sole, and heel* of the skate.
*   **Movella DOT™:** Wearable IMU sensors placed around the ankle of the prosthesis to capture transmitted vibrations.
*   **Force Sensing Resistors (FSR):** Used to standardize and measure lacing tightness between human subjects and the laboratory setup.

## 📊 Data Analysis
Data processing was extensively carried out in **MATLAB**, leveraging:
*   **Time & Frequency Domain Analysis:** Extracting the Power Spectral Density (PSD) of the impact signals.
*   **Frequency Response Function (FRF):** Computing transmissibility from the shaker to the heel, and from the heel to the prosthesis.
*   **ISO 2631-1 Vibration Indices:** Calculating Root-Mean-Square (RMS) and Vibration Dose Value (VDV) to quantify exposure.
*   **Statistical Validation:** Applying ANOVA and Tukey's post-hoc tests to evaluate the statistical significance between the different skate configurations.

## 🏆 Main Results
*   📍 **Optimal Sensor Location:** The **heel** proved to be the most stable and reliable reference point for characterizing jump landing impacts.
*   ✅ **Setup Validation:** The shaker-to-heel transmission was approximately unitary in the frequency bandwidth of interest (0-40 Hz), fully validating the experimental rig.
*   📈 **RMS vs. VDV:** While RMS metrics showed limited differentiation across configurations, **VDV** (a dose-based descriptor) was highly sensitive. It revealed statistically significant differences, highlighting that the *RF1 Elite model with loose lacing* transmits the highest vibration dose.
*   ⚠️ **Health Risk Assessment:** When evaluated against ISO 2631-1 reference limits, the calculated equivalent 8-hour VDV(8) values greatly exceeded the Health Guidance Caution Zone (HGCZ). This indicates that the impulsive and repetitive nature of figure skating landings poses a significant vibration exposure risk for athletes.

## 🚀 Future Perspectives
*   **Broader Equipment Analysis:** Expand testing to include a wider variety of skate models, boot stiffnesses, and blade geometries.
*   **Custom Evaluation Criteria:** Develop new vibration standards specifically tailored for impulsive, high-magnitude athletic events rather than continuous industrial exposure.
*   **On-Ice Testing:** Conduct direct measurements on ice to account for the unique damping properties and rheological behavior of ice compared to synthetic off-ice mats.

---

## 👥 Authors
**Group 8**
*   Gianatti Luigi
*   Malpeli Martina
*   Renzi Edoardo
*   Rovaris Roberto
*   Setti Viola
*   Tacchini Giorgio
*   Testoni Veronica
*   Traverso Filippo

**Advisor:** Prof. Diego Scaccabarozzi  
**Co-advisors:** Ing. Chiara Martina, Ing. Andrea Appiani  
**Academic Year:** 2025-2026
