local api = {}

local defaultOptions = {
	codeOpener = '<%',
	codeCloser = '%>',
  defaultAction = 'call',
  errorIfNotClosed = true,
	actions = {
    ['='] = 'escape',
    ['-'] = 'raw'
    }
}

local sub = string.sub

api.parseCode = function(part,opts)
	local resp = {
    type = 'code'
  }
  local actLength = 0
  local act = opts.defaultAction
  for k,v in pairs(opts.actions) do
    if #k>actLength and sub(part,1,#k)==k then
      actLength = #k
      act = v
    end
  end
  resp.action = act
  resp.data = sub(part,1+actLength)
  return resp
end

api.parseText = function(part,opts)
	return {
		type='text',
		data=part
	}
end

api.parse = function(str,opts)
	local opts = opts or defaultOptions
	local res = {}
	local isCode = false
	local parsers = {
		[true]  = opts.parseCode or api.parseCode,
		[false] = opts.parseText or api.parseText
	}
	local changer = {
		[true]  = opts.codeCloser,
		[false] = opts.codeOpener
	}
  local current=''
	local i=1; while i<=#str do--for i=1,#str do
    --print('i is',i)
    if sub(str,i,i-1+#changer[isCode])==changer[isCode] or i==#str then
      --print 'Finishing block!'
      res[#res+1]=parsers[isCode](current,opts)
      current=''
      if i<#str then isCode = not isCode end
      i=i+#changer[isCode]-1
      --print('Now i is',i)
    else
      current = current..sub(str,i,i)
    end
    i=i+1
	end
  if isCode==true and opts.errorIfNotClosed then
    error('Template is not closed!')
  end
  return res
end

return api
