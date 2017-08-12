# justluatools
Just a bunch of libraries written in lua, written or found by me for my projects
Installing: just clone this repository in your package.path (with keeping it's name)
What is here:
* **utf8_validator**
	It is a validator of utf8, found in internet and optimized(but now it looks REALLY ugly, don't like it-use original version)
	Using: this submodule returns function, which receives string as first argument and returns true if it's valid utf8 text
	**Requires:**
	nothing
* **jsbundler**
	It is a script, which allows you to bundle multiple files in simple javascript script.
	The directory is converted into javascript object, which is placed into variable named data. The files are strings(or ArrayBuffers in case of binary files), directories are objects. The executed file is index.js
	**Usage**
		require('justluatools.jsbundler')('path/to/directory')
	index.js: 
		alert(data['test1.txt'])
		document.open()
		document.write('<img src="'+URL.createObjectURL(new Blob([data.directoryexample['testimg.png']],{type: 'image/png'}))+'"img></img>')
		document.close()
	test1.txt:
		Hello world!
	directoryexample/testbinary.png: any png image you want
	**Requires:**
	- luafilesystem
	- luajson
	- lbase64