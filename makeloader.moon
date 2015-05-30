libs = {"libbinio", "libsef"}

f = io.open "loader.lua"

data = ""

for lib in *libs
  libfile = io.open "SEF/"..lib..".lua"
  data ..= "local "..lib.." = (function()"..libfile\read("*a").." end)()\n"

out = f\read('*a')
f\close!

f = io.open "compiled_loader.lua", "w"

f\write data
f\write out
f\close!
