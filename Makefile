ASM=nasm
AFLAGS=-f win32 -F cv8 -gcv8 

LINKER=ld
ENTRY=_start
SUBSYS=console
EMU=-mi386pe
INC=-L "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.17763.0\um\x86"
LINK =-l kernel32 -l user32 -lgdi32 -d --export-all-symbols


all: test

test: test.exe

LFLAGS=-entry=$(ENTRY) --subsystem=$(SUBSYS) $(EMU) $(INC) $(LINK)

%.obj: %.asm 
	$(ASM) $(AFLAGS) $< -o $@

test.exe: test.obj CreateWindow.obj LoadTriangles.obj StringFuncs.obj
	ld -o $@ $^ $(LFLAGS)  

clean:
	del -f *.obj *.lst