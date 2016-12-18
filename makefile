# start stuff

# Edit these variables if more directories are needed.
SRCDIRS		:=	$(CURDIR) src

# end stuff

PROJ=$(shell basename $(CURDIR))

# Verilog Compiler
VC=iverilog


#BUILD=$(VC) -o $(PROJ).vvp
#BUILD=$(VC) -g2005-sv -o $(PROJ).vvp
BUILD=$(VC) -g2009 -o $(PROJ).vvp


#SRCFILES		:=	$(foreach DIR,$(SRCDIRS),$(notdir $(wildcard $(DIR)/*.v)))
#
export VPATH	:=	$(foreach DIR,$(SRCDIRS),$(CURDIR)/$(DIR))
#SRCFILES		:=	$(shell find . -type f -iname "*.sv")
PKGFILES		:=	$(foreach DIR,$(SRCDIRS),$(shell find $(DIR) \
	-maxdepth 1  -type f -iname "*.svpkg"))
SRCFILES		:=	$(foreach DIR,$(SRCDIRS),$(shell find $(DIR) \
	-maxdepth 1  -type f -iname "*.sv"))

all: reminder clean
	$(BUILD) $(PKGFILES) $(SRCFILES)


.PHONY : reminder
reminder:
	@echo "Reminder:  With Icarus Verilog, DON'T CAST BITS TO ENUMS!"

.PHONY : clean
clean:  
	rm -fv $(PROJ).vvp
