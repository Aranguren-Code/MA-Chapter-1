# Loading the necessary files
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#include("retrieve_data_P3.jl");
#include("Hub_Spoke_P3_(model)(0).jl");

tic()
solve(HS_P3)
elapsed_time = toc()

obj = getobjectivevalue(HS_P3)
h = getvalue(DEPOTS)
s = getvalue(SHORTAGE)
x = getvalue(FLOWX)
y = getvalue(FLOWY)
z = getvalue(FLOWZ)

f = open("HS_P3_(results).txt", "w")

write(f, string("var, orig, dest, value,\r\n"))
write(f, string("0,,,$obj,\r\n"))

for i in 1:D
  if h[i] == 1
    write(f, string("1,$i,,", @sprintf("%1.0f", h[i]), ",\r\n" ))
  end
end

for i in 1:C
  if s[i] > 0
    write(f, string("2,$i,,", @sprintf("%1.2f", s[i]), ",\r\n" ))
  end
end

for i in 1:P
  for j in 1:D
    if x[i,j] > 0
      write(f, string("3,$i,$j,", @sprintf("%1.2f", x[i,j]), ",\r\n" ))
    end
  end
end

for i in 1:D
  for j in 1:C
    if y[i,j] > 0
      write(f, string("4,$i,$j,", @sprintf("%1.2f", y[i,j]), ",\r\n" ))
    end
  end
end

for i in 1:P
  for j in 1:C
    if z[i,j] > 0
      write(f, string("5,$i,$j,", @sprintf("%1.2f", z[i,j]), ",\r\n" ))
    end
  end
end

write(f, string("elapsed time,", @sprintf("%1.5f", elapsed_time), ",\r\n" ))
close(f)
