# Supplementary Material and MATLAB Code

This repository provides the supplementary material and MATLAB code for the paper:

**Fault Diagnosis of Networked Discrete Event Systems With Communication Delays Using Time Labeled Petri Nets**

**Authors:** Yifan Dong, Tomáš Masopust, and Zhiwu Li

**Journal:** IEEE Transactions on Automatic Control

## Supplementary Material

The supplementary material presents a computational case study based on a parameterized wafer processing system modeled by a time labeled Petri net (TLPN).

The case study evaluates the computational performance and scalability of the proposed fault diagnosis approach under multi-channel communication delays. Specifically, 16 experiments are conducted with different numbers of processing modules and wafers.

The experimental results report the number of EM-SCG vertices, the EM-SCG construction time, the LP-based fault diagnosis time, and the corresponding diagnosis outcomes.

## MATLAB Code

The `MATLAB` folder contains the MATLAB implementation used for the computational case study, including EM-SCG construction and LP-based fault diagnosis.

**Requirements:** MATLAB with Optimization Toolbox (`linprog`).

### How to Run

1. Download the repository and open MATLAB.
2. Set the MATLAB current folder to the `MATLAB` directory.
3. Run the following commands in the MATLAB Command Window.

To verify the basic functionality:

```matlab
run_wafer12('selftest');
```

To execute the default computational experiments:

```matlab
out = run_wafer12;
```

To run a smaller example with 5 processing modules and 1 wafer:

```matlab
out = run_wafer12(struct('nList',5,'mList',1));
```

### Output

The program displays the computational results in the MATLAB Command Window and generates the following files:

- `wafer_multi_v_results.csv`: Experimental results.
- `wafer_multi_v_results.mat`: MATLAB data containing the results.
- `wafer_multi_v_results.tex`: LaTeX table of the experimental results.

The results include the EM-SCG size, construction time, fault diagnosis time, and diagnosis outcomes.
