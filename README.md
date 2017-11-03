# proxmox-fix-rmrr
Bash scripts to automate the process of disabling the RMRR check in the intel_iommu.c on the proxmox 4.4 and 5.X kernel

Before you atempt this read the security implications of this modification https://access.redhat.com/articles/1434873

Original guides/inspirations

The original thread, have a few bits of information missing https://forum.proxmox.com/threads/help-with-pci-passthrough.23980/ patch to Proxmox 4.4

Complete step by step guide for proxmox 5.0 https://forum.proxmox.com/threads/tutorial-compile-proxmox-ve-5-with-patched-intel-iommu-driver-to-remove-rmrr-check.36374/ 5.0/5.1


Tested to work in
  HP DL380 Generation 6
  
  HP ML110 Generation 9
  
  HP ML310 Generation 8
  
