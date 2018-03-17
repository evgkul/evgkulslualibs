local p = 'evgkulslualibs.'
local parser   = require(p..'template.parser')
local compiler = require(p..'template.compiler')
local runtime  = require(p..'template.runtime')

local api = {}

api.mkEnv = function(e,g)
  local e = e or {}
  local g = g or _G
  local meta = {
    __index = g
  }
  e.templateBuffer = runtime.buffer()
  setmetatable(e,meta)
  return e
end

api.compile = function(template,name,global,cfg)
  local tcomp = compiler.compile(parser.parse(template))
  return function(env)
    local global = global or _G
    local env = api.mkEnv(env,global)
    local b = env.templateBuffer
    local f,err = load(tcomp,name,nil,env)
    --print(tcomp)
    if not f then error(err) end
    f(env,b)
    if not (cfg or {}).returnBuffer then return b:step() else return b end
  end
end

return api
