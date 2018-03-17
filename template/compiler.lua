local api = {}
local match = string.match
local stringify = function(str)
  local seq = (match(str,'=+') or '=')..'='
  return '['..seq..'['..str..']'..seq..']'
end
api.codeParts = {
  header = 'local templateBuffer = ({...})[2]; if _ENV then _ENV = ({...})[1]; end ',
  footer = '--[[end]]',
  string = stringify,
  bufferName = 'templateBuffer',
  add = function(data,cfg) return api.renderPart('bufferName')..':add('..data[1]..','..data[2]..') ' end
}
api.renderPart = function(part,data,cfg)
  local parts = (cfg or api).codeParts
  local part = parts[part]
  if type(part)=='string' then return part end
  return part(data,cfg)
end
api.compile = function(t,cfg)
  local r = api.renderPart('header',nil,cfg)
  for k,v in pairs(t) do
    if v.type == 'code' and v.action == 'call' then
      r = r..' '..v.data..' '
    else
      local arg1 = v.data
      local arg2 = 'nil'
      if v.type=='text' then
        arg1 = stringify(arg1)
      elseif v.action~='raw' then
        if v.action=='escape' then arg2 = api.renderPart('bufferName',nil,cfg)..'._escape' end
      end
      r = r..api.renderPart('add',{arg1,arg2},cfg)
    end
  end
  r = r..api.renderPart('footer',nil,cfg)
  return r
end

return api