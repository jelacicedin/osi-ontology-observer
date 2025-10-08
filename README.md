# 🧩 OSI Observer

**OSI Observer** is a standalone event detection and evaluation framework for OpenSCENARIO-based simulations.  
It consumes raw simulation logs (`.dat` from [esmini](https://github.com/esmini/esmini)) or standardized [OSI](https://opensimulationinterface.github.io/) ground-truth data and produces a structured list of detected events.  
These events can then be compared against an ontology or reference description (e.g., crash report or scenario specification) to measure how well the simulation reproduces expected behavior.

---

## ✨ Features
- 🔍 **Automatic event detection**: lane changes, hard brakes, turns, and collisions (with impact classification via geometry/heading).  
- 🧠 **Ontology-based scoring**: compare detected events to a reference event list and compute an *Event Realization Score (ERS)*.  
- 🧾 **Supports multiple sources**:  
  - `--dat` → esmini `.dat` recordings (via `dat2csv`)  
  - `--osi` → OSI files or live UDP streams  
- 🧰 **Portable and non-intrusive**: no simulator modifications required.  
- 🧪 **Unit-test fixtures**: minimal scenarios included for validation.  

---

## Esmini Installation
```bash
sudo chmod a+x ./get_esmini.sh
./get_esmini.sh
```

## Running all Esmini example XOSC codes
```bash
sudo chmod a+x ./run_esmini_examples.sh
./run_esmini_examples.sh
```

After execution, the executed XOSC files will be in the examples folder.

## 📦 Installation
```bash
git clone https://github.com/<your-user>/osi-observer.git
cd osi-observer
pip install -e .
```
