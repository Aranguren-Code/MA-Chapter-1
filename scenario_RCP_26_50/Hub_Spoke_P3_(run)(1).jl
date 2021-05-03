# Loading the necessary files
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

include("retrieve_data_P3.jl");
include("Hub_Spoke_P3_(model)(1).jl");

tic()
solve(HS_P3)
elapsed_time = toc()

obj = getobjectivevalue(HS_P3)
h = getvalue(DEPOTS)
x = getvalue(FLOWX)
y = getvalue(FLOWY)
z = getvalue(FLOWZ)

f = open("HS_P3_(results).csv", "w")

write(f, string("VARIABLE, PARCEL, DEPOT, PLANT, VALUE,\r\n"))
write(f, string("TC,,,, $obj,\r\n"))

for i in 1:D
  if h[i] == 1
    write(f, string("D,,$i,,", @sprintf("%1.0f", h[i]), ",\r\n" ))
  end
end

for i in 1:P
  for j in 1:D
    if x[i,j] > 0
      write(f, string("X,$i,$j,,", @sprintf("%1.4f", x[i,j]), ",\r\n" ))
    end
  end
end

for i in 1:D
  for j in 1:C
    if y[i,j] > 0
      write(f, string("Y,,$i,$j,", @sprintf("%1.4f", y[i,j]), ",\r\n" ))
    end
  end
end

for i in 1:P
  for j in 1:C
    if z[i,j] > 0
      write(f, string("Z,$i,,$j,", @sprintf("%1.4f", z[i,j]), ",\r\n" ))
    end
  end
end

write(f, string("elapsed time,", @sprintf("%1.5f", elapsed_time), ",\r\n" ))
close(f)