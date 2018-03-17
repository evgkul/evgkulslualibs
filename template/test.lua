return function(s,po,co)
  parser = dofile('parser.lua')
  compiler = dofile('compiler.lua')
  return compiler.compile(parser.parse(s,po),co)
end