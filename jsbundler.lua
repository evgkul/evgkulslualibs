local lfs=require('lfs')
local istext=require('justluatools.utf8_validator')
local base64=require('base64')
local json=require('json')

local function fastread(name)
	local h=io.open(name)
	local f=h:read('*a')
	h:close()
	return f
end

local function urlescape(path) return path end

local function jsescape(str)
	str=string.gsub(str,'\\','\\\\')
	str=string.gsub(str,'"','\\"')
	str=string.gsub(str,"'","\\'")
	str=string.gsub(str,'\n','\\n')
	str=string.gsub(str,'\r','\\r')
	return str
end

local gen
gen=function(path,t)
	for name in lfs.dir(path) do
		if name~='.' and name~='..' then
			local fpath=path..'/'..urlescape(name)
			--print(fpath)
			if lfs.attributes(fpath).mode=='directory' then
				t[name]={}
				gen(fpath,t[name])
			else
				--print('reading file..')
				local file=fastread(fpath)
				--print('finished reading...')
				if istext(file) then
					--print('text..')
					file='t'..file
				else
					--print('binary..')
					file='b'..base64.encode(file)
				end
				t[name]=file
			end
		end
	end
end

local pl1=[==[
var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
var lookup = new Uint8Array(256);
  for (var i = 0; i < chars.length; i++) {
    lookup[chars.charCodeAt(i)] = i;
 }


function decodeb64(base64) {
    var bufferLength = base64.length * 0.75,
    len = base64.length, i, p = 0,
    encoded1, encoded2, encoded3, encoded4;

    if (base64[base64.length - 1] === "=") {
      bufferLength--;
      if (base64[base64.length - 2] === "=") {
        bufferLength--;
      }
    }

    var arraybuffer = new ArrayBuffer(bufferLength),
    bytes = new Uint8Array(arraybuffer);

    for (i = 0; i < len; i+=4) {
      encoded1 = lookup[base64.charCodeAt(i)];
      encoded2 = lookup[base64.charCodeAt(i+1)];
      encoded3 = lookup[base64.charCodeAt(i+2)];
      encoded4 = lookup[base64.charCodeAt(i+3)];

      bytes[p++] = (encoded1 << 2) | (encoded2 >> 4);
      bytes[p++] = ((encoded2 & 15) << 4) | (encoded3 >> 2);
      bytes[p++] = ((encoded3 & 3) << 6) | (encoded4 & 63);
    }

    return arraybuffer;
  };

//called with every property and its value
function process(key,value,obj) {
    //console.log(key + " : "+value);
    var m=value.substring(0,1)
    var value=value.substring(1)
    if (m=="b") {
		value=decodeb64(value)
		//console.log(value)
    }
    //console.log(value)
    obj[key]=value
}

function iterate(obj, stack) {
        for (var property in obj) {
            if (obj.hasOwnProperty(property)) {
                if (typeof obj[property] == "object") {
                    iterate(obj[property], stack + '.' + property);
                } else {
                    //console.log(property + "   " + obj[property]);
                    //$('#output').append($("<div/>").text(stack + '.' + property))
                    process(property,obj[property],obj)
                }
            }
        }
    }

iterate(data, '')

eval(data["index.js"])
]==]

local js_preset={[[javascript:var pl1="]],[["; var code="]],[[" eval(pl1)]]}

return function(conf)
	if type(conf)=='string' then conf={
			dir=conf,
		}
	end
	local dir=conf.dir
	local resp={}
	--print('Beginning generation!')
	gen(dir..'/',resp)
	--print('Encoding!')
	local jstr=json.encode(resp)
	--print('Finished!')
	return [[(function(){var pl1="]]..jsescape(pl1)..[[";var data=data||undefined; data=]]..jstr..[[; eval(pl1)})()]]
	--print(jstr)
	--return jstr
end

--print(test())
