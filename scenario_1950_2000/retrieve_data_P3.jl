# Data for the problem
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

using DataFrames

Network = readtable("network_parameters.csv");
ArcsT1 = readtable("parameters_in_T1.csv");
ArcsT2 = readtable("parameters_in_T2.csv");
ArcsT3 = readtable("parameters_in_T3.csv");
NodesP = readtable("parameters_in_P.csv");
NodesD = readtable("parameters_in_D.csv");
NodesC = readtable("parameters_in_C.csv");
Parameters = readtable("other_parameters.csv");

P = Network[1, 1] # total number of parcels
D = Network[1, 2] # total candidate depots
C = Network[1, 3] # total candidate biorefineries

NoArcsT1 = P * D
NoArcsT2 = D * C
NoArcsT3 = P * C

TransCost1 = Array{Float64}(P, D)
TransCost2 = Array{Float64}(D, C)
TransCost3 = Array{Float64}(P, C)
HarvCost = Array{Float64}(P)
Supply = Array{Float64}(P)
DepotCost = Array{Float64}(D)
DepotCap = Array{Float64}(D)
Demand = Array{Float64}(C)
ShortCost = Array{Float64}(C)

RentCost1 = Parameters[1, 2]
RentCost2 = Parameters[2, 2]
Bailing = Parameters[3, 2]
Fertilizer = Parameters[4, 2]
Swathing = Parameters[5, 2]
ParcelSize = Parameters[6, 2]
AvgKmph1 = Parameters[7, 2]
AvgKmph2 = Parameters[8, 2]
AvgKmph3 = Parameters[9, 2]
HrRate1 = Parameters[10, 2]
HrRate2 = Parameters[11, 2]
HrRate3 = Parameters[12, 2]
DryMass1 = Parameters[13, 2]
DryMass2 = Parameters[14, 2]
DryMass3 = Parameters[15, 2]
Load = Parameters[16, 2]
Unload = Parameters[17, 2]
Stack = Parameters[18, 2]

# transportation cost within the network via truck form parcels to depots (T1)
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

i = 1
j = 1
cnt = 1

while cnt <= NoArcsT1
    if j <= D
        TransCost1[i, j] = 2 * ArcsT1[cnt, 4] / AvgKmph1 * HrRate1 / DryMass1
        TransCost1[i, j] = TransCost1[i, j] + Load + Unload + Stack
        j += 1
        cnt += 1
    else
        i += 1
        j = 1
    end
end

# transportation cost within the network via truck form depots to coal plants
#(T2)
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

i = 1
j = 1
cnt = 1

while cnt <= NoArcsT2
    if j <= C
        TransCost2[i, j] = 2 * ArcsT2[cnt, 4] / AvgKmph2 * HrRate2 / DryMass2
        #TransCost2[i, j] = TransCost2[i, j] + Load + Unload + Stack
        #TransCost2[i, j] = TransCost2[i, j]  / 6
        #TransCost2[i, j] = TransCost2[i, j]  / (DryMass2 / DryMass1)
        j += 1
        cnt += 1
    else
        i += 1
        j = 1
    end
end

# transportation cost within the network via truck form parcels to coal plants
#(T3)
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

i = 1
j = 1
cnt = 1

while cnt <= NoArcsT3
    if j <= C
        TransCost3[i, j] = 2 * ArcsT3[cnt, 4] / AvgKmph3 * HrRate3 / DryMass3
        TransCost3[i, j] = TransCost3[i, j] + Load + Unload + Stack
        j += 1
        cnt += 1
    else
        i += 1
        j = 1
    end
end

# harvesting cost for every parcel in P
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

for i in 1:P
  if NodesP[i, 4] == "ATASCOSA"
    HarvCost[i] = Bailing + (Fertilizer + Swathing + RentCost1) / NodesP[i, 3]
  elseif NodesP[i, 4] == "WILSON"
    HarvCost[i] = Bailing + (Fertilizer + Swathing + RentCost2) / NodesP[i, 3]
  end
end

# supply of biomass in every parcel
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

for i in 1:P
    Supply[i] = ParcelSize * NodesP[i, 3]
end

# investment cost to open a depot
# storage capacity of a depot
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

for i in 1:D
    DepotCost[i] = NodesD[i, 3]
    DepotCap[i] = NodesD[i, 4]
end

# demand at each power plant
# penalty cost for slack of supply at each power plant
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

for i in 1:C
    Demand[i] = NodesC[i, 3]
    ShortCost[i] = NodesC[i, 4]
end
