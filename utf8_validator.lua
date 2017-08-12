local utf8_validator = {
  __VERSION     = '0.0.1',
  __DESCRIPTION = 'Library for easily validating UTF-8 strings in pure Lua',
  __URL         = 'https://github.com/kikito/utf8_validator.lua',
  __LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2013 Enrique García Cota

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  ]]
}

local find = string.find

-- Numbers taken from table 3-7 in www.unicode.org/versions/Unicode6.2.0/UnicodeStandard-6.2.pdf
-- find-based solution inspired by http://notebook.kulchenko.com/programming/fixing-malformed-utf8-in-lua
function utf8_validator.validate(str)
	local b={}
	for i=1,#str do
		b[i]=string.byte(string.sub(str,i,i))
	end
  local i, len = 1, #str
  while i <= len do
	--local b=string.byte(string.sub(str,i,i))
    if    b[i]>0 and b[i]<128 --[[i == find(str, "[%z\1-\127]", i)]]   then i = i + 1
    elseif (b[i]>193 and b[i]<224) and (b[i+1]>122 and b[i+1]<192) --[[i == find(str, "[\194-\223][\123-\191]", i)]] then i = i + 2
    elseif 
		(b[i]==224 and (b[i+1]>159 and b[i+1]<192) and (b[i+2]>127 and b[i+2]<192))
		or ((b[i]>=225 and b[i]<=236) and (b[i+1]>=128 and b[i+1]<=191) and (b[i+2]>=128 and b[i+2]<=191))
		or (b[i]==237 and (b[i+1]>=128 and b[i+1]<=159) and (b[i+2]>=128 and b[i+2]<=191))
		or ((b[i]>=238 and b[i]<=239) and (b[i+1]>=128 and b[i+1]<=191) and (b[i+2]>=128 and b[i+2]<=191))
    --[[i == find(str,        "\224[\160-\191][\128-\191]", i)
        or i == find(str, "[\225-\236][\128-\191][\128-\191]", i)
        or i == find(str,        "\237[\128-\159][\128-\191]", i)
        or i == find(str, "[\238-\239][\128-\191][\128-\191]", i)]] then i = i + 3
    elseif i == find(str,        "\240[\144-\191][\128-\191][\128-\191]", i)
        or i == find(str, "[\241-\243][\128-\191][\128-\191][\128-\191]", i)
        or i == find(str,        "\244[\128-\143][\128-\191][\128-\191]", i) then i = i + 4
    else
      return false, i
    end
  end

  return true
end

setmetatable(utf8_validator, {__call = function(_, ...) return utf8_validator.validate(...) end})

return utf8_validator
