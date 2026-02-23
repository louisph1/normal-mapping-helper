linux:
	odin build . -target=linux_amd64 -o:speed -out:normalmapper
windows:
	odin build . -target=windows_amd64 -o:speed -out:normalmapper.exe
