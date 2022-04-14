################################################################################
#
# GNUmakefile
#
# Image makefile for IPQ systems.  Along with CROSS_COMPILE and
# tools in the PAT, the following are required.
#
#        ARCH : The architecture.
# DESCRIPTION : A descriptive string for the image.
#     ADDRESS : The load and entry address.
#         DTB : The device tree.
#     KERNEL_IMAGE : The Linux Image.
#
################################################################################

ifdef ARCH
ASSERT_ARCH =
else
ASSERT_ARCH = \
@echo "ARCH is not defined!" ; exit 1
endif

ifdef DESCRIPTION
ASSERT_DESCRIPTION =
else
ASSERT_DESCRIPTION = \
@echo "DESCRIPTION is not defined!" ; exit 1
endif

ifdef ADDRESS
ASSERT_ADDRESS =
else
ASSERT_ADDRESS = \
@echo "ADDRESS is not defined!" ; exit 1
endif

ifdef DTB
ASSERT_DTB =
else
ASSERT_DTB = \
@echo "DTB is not defined!" ; exit 1
endif

ifdef KERNEL_IMAGE
ASSERT_KERNEL_IMAGE =
else
ASSERT_KERNEL_IMAGE = \
@echo "KERNEL_IMAGE is not defined!" ; exit 1
endif

%.its: %.its.in
	@$(ASSERT_ARCH)
	@$(ASSERT_ADDRESS)
	@$(ASSERT_DTB)
	@$(ASSERT_DESCRIPTION)
	@sed -e 's/ARCH/$(ARCH)/' -e 's/LOAD/$(ADDRESS)/' \
		-e 's/ENTRY/$(ADDRESS)/' \
		-e 's/DTB_NAME/$(DTB_NAME)/' \
		-e 's/DESCRIPTION/"$(DESCRIPTION)"/' $< >$@

all: clean linux.fit fdt.fit

linux.fit: Image.gz Image.lzma linux.its
	mkimage -f linux.its $@

multi.fit: Image.gz Image.lzma
	mkimage -f multi.its $@
	rm -f multi.its

fdt.fit: fdt.its
	@$(ASSERT_DTB)
	cp $(DTB) linux.dtb
	mkimage -f fdt.its $@
	rm -f linux.dtb

linux.dtb:
	cp $(DTB) linux.dtb

Image: $(KERNEL_IMAGE)
	cp $(DTB) linux.dtb

Image.gz: $(KERNEL_IMAGE)
	gzip -f -c -9 $< >$@
	cp $(DTB) linux.dtb

Image.lzma: $(KERNEL_IMAGE)
	lzma -zvfk -4 $<
	cp $<.lzma .
	cp $(DTB) linux.dtb

clean:
	@rm -f Image.gz Image.lzma *.its *.img *.fit
