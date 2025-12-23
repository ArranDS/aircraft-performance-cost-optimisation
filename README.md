# Aircraft Performance & Cost Optimisation (using MATLAB)

## Overview
This project was to develop a MATLAB based analytical method which can evaluate
as well as optimise short haul commercial aircraft mission performance under payload,
range and MTOW constraints.

The objective was to identify cost efficient operating regions by analysing
the sensitivity of fuel burn and also operating cost to the key performance drivers.

## Method
- Estimating fuel burn using the Breguet range equation
- Creating aircraft mass model with the MTOW feasibility constraint
- Direct operating cost proxy based on the fuel burn
- Performing a sensitivity analysis across liftto drag ratio (L/D) and specific fuel consumption (SFC)
- Grid search optimisation to identify the minimum cost feasible

## Key Results
- The fuel burn decreases non-linearly by increasing L/D
- The operating cost increases approximately linearly with SFC
- The optimal cost region occurs at high aerodynamic efficiency and low engine SFC
- The results highlighted clear trade-offs between performance improvements and cost

## Tools Used
- MATLAB
- Numerical modelling
- Data visualisation
- Optimisation via parameter sweeps
