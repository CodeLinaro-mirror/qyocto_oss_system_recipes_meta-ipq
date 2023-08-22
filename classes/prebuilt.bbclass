
python () {

    topdirpath = d.getVar('TOPDIR')
    topdir=topdirpath+"/../prebuiltipk/"
    machinetype = d.getVar('KARCH')
    pkgsarchtype = d.getVar('PACKAGE_ARCH')

    if machinetype == "arm64":
        topdir=topdir+"64/"
    elif machinetype == "arm":
        topdir=topdir+"32/"

    pn = d.getVar('PN')
    pr = d.getVar('PR')
    pv = d.getVar('PV')
    task = d.getVar('BB_RUNTASK')
    skip_sysdpoppkgs = d.getVar("PACKAGESPLITFUNCS")
    inheritcache = d.getVar('__inherit_cache', False)
    prebuiltpath=topdir
    topdir=topdir+pn+"_"+pv+"-"+pr+"_"+pkgsarchtype+".ipk"
    if os.path.isdir(prebuiltpath):
        if os.path.isfile(topdir):
            # To skip the systemd inherit of the package
            sysdclass=topdirpath+"/../openembedded-core/meta/classes/systemd.bbclass"
            sysdclass=os.path.abspath(sysdclass)
            if sysdclass in inheritcache:
                #    inheritcache.remove(sysdclass)
                if "systemd_populate_packages" in skip_sysdpoppkgs:
                    skip_sysdpoppkgs=skip_sysdpoppkgs.replace("systemd_populate_packages", " ")
                    d.setVar('PACKAGESPLITFUNCS', skip_sysdpoppkgs)
            # To skip kernel-module-split inherit of the package
            sysdclass=topdirpath+"/../openembedded-core/meta/classes/kernel-module-split.bbclass"
            sysdclass=os.path.abspath(sysdclass)
            if sysdclass in inheritcache:
                #    inheritcache.remove(sysdclass)
                if "split_kernel_module_packages" in skip_sysdpoppkgs:
                    skip_sysdpoppkgs=skip_sysdpoppkgs.replace("split_kernel_module_packages", " ")
                    d.setVar('PACKAGESPLITFUNCS', skip_sysdpoppkgs)
            # To skip the license check sum of the package
            d.setVar('LICENSE', 'CLOSED')
            d.setVar('BB_STRICT_CHECKSUM', '0')
            # To skip the tasks of the package
            d.setVarFlag('do_fetch', 'noexec', '1')
            d.setVarFlag('do_unpack', 'noexec', '1')
            d.setVarFlag('do_patch', 'noexec', '1')
            d.setVarFlag('do_configure', 'noexec', '1')
            d.setVarFlag('do_compile', 'noexec', '1')
            d.setVarFlag('do_install', 'noexec', '1')


}
