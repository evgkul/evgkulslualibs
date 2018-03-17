local concat = table.concat

local api = {}

api._buffer = {
  _init = function(self)
    self.state = 'unfinished'
    self._activeElements = {}
    self.finishStates = {true}
    self._wrappers = {}
  end,
  add = function(self,data,wrapper)
    local td = type(data)
    if td=='nil' or td=='number' then data=tostring(data) end
    if data.step then
      self[#self+1]=data
      self._activeElements[#self] = data
      self._wrappers[data]=wrapper
    else
      if wrapper then data = wrapper(data) end
      if self[#self] and not self[#self].step then
        self[#self] = self[#self]..data
      else
        self[#self+1]=data
      end
    end
  end,
  step = function(self,noloop)
    local fstates = {}
    for k,v in pairs(self.finishStates) do
      fstates[v]=true
    end
    local stime = true
    local r = true
    while r and (stime or not noloop) do
      local rem = {}
      r,stime = false,false
      for k,v in pairs(self._activeElements) do
        r=true
        
        local res = v:step()
        if res or (fstates[v.state]) then
          local wrp = self._wrappers[v]
          if wrp then res = wrp(res or v) end
          rem[#rem+1]=k
          self[k]=res or v
        end
      end
      for k,v in pairs(rem) do
        self._activeElements[v]=nil
      end
    end
    if not r then
      self.state = true
      local res = ''
      if self.noReturnString then return ; end
      for i=1,#self do
        res=res..tostring(self[i])
      end
      return res
    end
  end,
  _escape = function(s)
    assert("Expected string in argument #1.")
    return (string.gsub(s, "[}{\">/<'&]", {
        ["&"] = "&amp;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ['"'] = "&quot;",
        ["'"] = "&#39;",
        ["/"] = "&#47;"
    }))
  end
  }
api._buffer_meta = {__index = api._buffer,__metatable = {}}
api.buffer = function()
  local buf = setmetatable({},api._buffer_meta)
  buf:_init()
  return buf
end
api._buffer.new = api.buffer

return api