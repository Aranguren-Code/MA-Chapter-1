# Loading the necessary packages
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

using JuMP
using CPLEX

# Problem Description
# Deterministic Hub and Spoke Network for Power Plants
# ------------------------------

#HS_P3=Model(solver=GurobiSolver(Presolve=-1, MIPGap=0.01, OutputFlag=0))
HS_P3 = Model(solver = CplexSolver(CPX_PARAM_MIPDISPLAY = 0, CPX_PARAM_BENDERSSTRATEGY = 3))

# Variable Definition
# ------------------------------

@variable(HS_P3, DEPOTS[1:D], Bin)
@variable(HS_P3, FLOWX[1:P, 1:D] >= 0)
@variable(HS_P3, FLOWY[1:D, 1:C] >= 0)
@variable(HS_P3, FLOWZ[1:P, 1:C] >= 0)

# Constraints Definition
# ------------------------------

# constraint to restrict supply of biomass

@constraint(HS_P3, BIOMASS_SUPPLY[i=1:P], sum(FLOWX[i, j] for j=1:D) +
  sum(FLOWZ[i, j] for j=1:C) <= Supply[i])

# constraint for mass balance

@constraint(HS_P3, MASS_BALANCE[j=1:D], sum(FLOWX[i, j] for i=1:P) ==
  sum(FLOWY[j, i] for i=1:C))

# constraint to assure supply of the demand

@constraint(HS_P3, DEMAND_SUPPLY[j=1:C], sum(FLOWY[i, j] for i=1:D) +
  sum(FLOWZ[i, j] for i=1:P) >= Demand[j])

# constraint for biomass storage at depots

@constraint(HS_P3, BIOMASS_PROCESS[j=1:D], sum(FLOWX[i, j] for i=1:P) <=
  DepotCap[j]*DEPOTS[j])

# Objective Setting
# ------------------------------

@objective(HS_P3, Min, sum((HarvCost[i] + TransCost1[i, j]) *
  FLOWX[i, j] for i=1:P, j=1:D) +
  sum((TransCost2[i, j]) * FLOWY[i, j] for i=1:D, j=1:C) +
  sum((HarvCost[i] + TransCost3[i, j]) * FLOWZ[i, j] for i=1:P, j=1:C) +
  sum(DepotCost[i]*DEPOTS[i] for i=1:D))
