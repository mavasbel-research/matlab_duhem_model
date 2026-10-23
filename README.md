<div align="center">

# Duhem Hysteresis Model

**Duhem and Miller hysteresis operators in MATLAB: butterfly loops built from level curves, nonlinear fitting to measured loops, ODE and Simulink simulation, and remnant control.**

[![MATLAB](https://img.shields.io/badge/MATLAB-0076A8?style=flat-square)](https://www.mathworks.com/products/matlab.html)
[![Simulink](https://img.shields.io/badge/Simulink-R2020a-0076A8?style=flat-square)](https://www.mathworks.com/products/simulink.html)
[![Years](https://img.shields.io/badge/years-2021%E2%80%932022-555555?style=flat-square)](https://github.com/mavasbel-research/matlab_duhem_model/commits/main)
[![Status](https://img.shields.io/badge/status-research%20archive-lightgrey?style=flat-square)](#-known-issues)
[![Thesis DOI](https://img.shields.io/badge/Thesis%20DOI-10.33612%2Fdiss.215199709-0055A5?style=flat-square)](https://doi.org/10.33612/diss.215199709)

</div>

> [!NOTE]
> Research code from the PhD thesis [*Multi-loop Hysteresis and Recursive Remnant Control*](https://doi.org/10.33612/diss.215199709) (University of Groningen, 2022). It is kept as it was left in February 2022 — read [Known issues](#-known-issues) before running it.

## 📑 Contents

- [The model](#-the-model)
- [Repository layout](#-repository-layout)
- [Requirements](#-requirements)
- [Getting started](#-getting-started)
- [Workflows](#-workflows)
- [Known issues](#-known-issues)
- [Related publications](#-related-publications)
- [Citation](#-citation)

## 📐 The model

A Duhem operator switches between two slope functions depending on the direction of the input (`DuhemModel.getdydt`):

$$
\dot y(t) =
\begin{cases}
f_1\big(u(t),y(t)\big)\,\dot u(t), & \dot u(t) \ge 0,\\
f_2\big(u(t),y(t)\big)\,\dot u(t), & \dot u(t) < 0.
\end{cases}
$$

The repository builds $f_1, f_2$ in three ways:

| Approach | How $f_1, f_2$ are obtained | Script |
|:---|:---|:---|
| **Level curves** | Two curves $c_1(u)$, $c_2(u)$ are drawn or defined; $f_1$ and $f_2$ are the signed vertical distances to them. The active example uses $c_1(u)=0.1u^3+0.1u+1$ and $c_2(u)=-c_1(u)$ on $u\in[-15,15]$. | `ButterflyCreate_f1f2.m`, `ButterflyCapture_c1c2.m` |
| **Polynomial fit** | Degree-5 polynomials fitted by least squares to the ascending and descending branches of a measured loop | `FitDuhemPoly.m` |
| **Miller model fit** | Parameters $(P_s, P_r, E_c)$ of the Miller model fitted with `fmincon` (interior point) to minimise the integrated-branch error | `FitDuhemNonLinear.m` |

For the Miller model, with $\delta = E_c / \ln\!\big(\tfrac{1+P_r/P_s}{1-P_r/P_s}\big)$:

$$
P_{sat}^{\pm}(E) = \pm P_s \tanh\!\Big(\frac{\pm E - E_c}{2\delta}\Big),\qquad
\Gamma^{\pm} = 1-\tanh\!\sqrt{\frac{P_d-P_{sat}^{\pm}}{\pm P_s-P_d}},\qquad
f_{1,2} = \big|\Gamma^{\pm}\,\tfrac{dP_{sat}^{\pm}}{dE}\big|.
$$

The anhysteresis curve ($f_1-f_2=0$) and the average curve ($f_1+f_2=0$) are extracted as zero-level contours.

## 🗂️ Repository layout

| Path | Contents |
|:---|:---|
| `LoadData.m` | Loads a measured strain–voltage loop into `dataHandler` (zero-mean, scaled by 10) |
| `FitDuhemNonLinear.m`, `FitDuhemPoly.m` | Fits described above |
| `OdeDuhemModel.m`, `OdeMillerModel.m`, `AsymMillerModel.m` | `ode113` simulation with periodic triangular inputs and animated loop plots |
| `ButterflyCreate_f1f2.m`, `ButterflyCapture_c1c2.m`, `ButterflyPlot_c1c2.m`, `ButterflyPlot_f1f2_3D.m` | Butterfly loops from level curves |
| `Remnant_Control_Experiment/` | Iterative pulse control of the remnant output (`RemnantControl.m`, `RemnantControlFixBaseCurve.m`) and their plots |
| `Simulink/` | `SimulinkDuhemModel.slx` (R2020a, sine input, f1/f2 MATLAB Function charts), parameters and plot script |
| `Back/BackFitMillerModel.m` | Older symbolic fit with `particleswarm` |

## 🧰 Requirements

| Requirement | Used by |
|:---|:---|
| MATLAB (the Simulink model was saved with R2020a) | everything |
| Optimization Toolbox (`fmincon`) | `FitDuhemNonLinear.m` |
| Parallel Computing Toolbox (`'UseParallel', true`) | `FitDuhemNonLinear.m` options |
| Simulink with MATLAB Function blocks | `Simulink/SimulinkDuhemModel.slx` |
| Global Optimization and Symbolic Math Toolboxes | `Back/BackFitMillerModel.m` only |

## 🚀 Getting started

> [!IMPORTANT]
> The commit `272cbfc` (*Refactor of commons*) removed the helper classes. Restore them from its parent, then point the two remaining calls at the restored class:

```bash
git clone https://github.com/mavasbel-research/matlab_duhem_model.git
cd matlab_duhem_model
git checkout 272cbfc^ -- Classes
sed -i 's/DuhemUtils\.verticalDistance/ButterflyUtils.verticalDistance/' ButterflyPlot_c1c2.m FitDuhemPoly.m
```

`DuhemUtils` was never committed; `ButterflyUtils.verticalDistance` in the restored classes is the method those two lines used before the refactor. Then, in MATLAB, from the repository root:

```matlab
addpath('Classes')
ButterflyCreate_f1f2    % defines c1/c2 and runs ButterflyPlot_c1c2
```

## 🔁 Workflows

Scripts pass data through the base workspace; run them from the repository root in these orders. They have not been re-run since 2022.

| Goal | Order |
|:---|:---|
| Butterfly loop from level curves | `ButterflyCreate_f1f2` *(or `ButterflyCapture_c1c2` to draw the curves with the mouse)* |
| Fit and simulate the Miller model | `LoadData` → `FitDuhemNonLinear` → `OdeMillerModel` |
| Remnant control on the fitted model | … → `OdeMillerModel` → `Remnant_Control_Experiment/RemnantControl` → `RemnantPlots` |
| Remnant control with a fixed base curve | `LoadData` → `FitDuhemNonLinear` → `RemnantControlFixBaseCurve` → `RemnantPlotsFixBase` |
| Polynomial fit and simulation | `LoadData` → `FitDuhemPoly` → `OdeDuhemModel` |
| Simulink | `Simulink/SimulinkCreateParams` → run `SimulinkDuhemModel.slx` → `SimulinkPlotData` |

## ⚠️ Known issues

| Issue | Where |
|:---|:---|
| Measured loops are read from absolute `G:\…` paths and are not included, so every `LoadData` workflow needs your own `.csv`/`.dat` files | `LoadData.m:9-28` |
| `Ec` is undefined (only `EcPlus`/`EcMinus` exist), and `regPlus`/`regMinus` are not produced by any script | `AsymMillerModel.m` |
| `attractiveManifoldsC1/C2` are not produced by any script | `Simulink/SimulinkPlotData.m` |
| The active code in the Simulink f1/f2 charts is a Bouc–Wen model; the level-curve variants are commented out | `Simulink/SimulinkDuhemModel.slx` |

## 📄 Related publications

| Year | Title | Venue |
|:---:|:---|:---|
| 2023 | [Modeling and Analysis of Duhem Hysteresis Operators With Butterfly Loops](https://doi.org/10.1109/TAC.2023.3238177) | IEEE Transactions on Automatic Control |
| 2022 | [On the Characterization of Butterfly and Multiloop Hysteresis Behavior](https://doi.org/10.1109/TAC.2021.3109533) | IEEE Transactions on Automatic Control |
| 2022 | [Multi-loop Hysteresis and Recursive Remnant Control](https://doi.org/10.33612/diss.215199709) | PhD thesis, University of Groningen |

`ButterflyCreate_f1f2.m` labels its examples "Butterfly cubic polynomial paper" and "Multiloop sine paper"; the repository does not record which figure belongs to which publication.

## 📝 Citation

<details>
<summary>BibTeX</summary>

```bibtex
@article{VasquezBeltran2023,
  title   = {Modeling and Analysis of Duhem Hysteresis Operators With Butterfly Loops},
  author  = {Vasquez-Beltran, Marco Augusto and Jayawardhana, Bayu and Peletier, Reynier F.},
  journal = {IEEE Transactions on Automatic Control},
  volume  = {68},
  number  = {10},
  pages   = {5977--5990},
  year    = {2023},
  doi     = {10.1109/TAC.2023.3238177}
}
```
</details>

This repository does not include a license file.

---

<div align="center">
<sub>Part of <a href="https://github.com/mavasbel-research">mavasbel-research</a> · <a href="https://github.com/mavasbel">Marco Vásquez Beltrán</a></sub>
</div>
