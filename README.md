# proxmox-fix-rmrr
Bash scripts to automate the process of disabling the RMRR check in the intel_iommu.c on the Proxmox 5.1 kernel

Before you attempt this read https://access.redhat.com/articles/1434873


Original guides/inspirations


The original thread, have a few bits of information missing 
https://forum.proxmox.com/threads/help-with-pci-passthrough.23980/ patch to Proxmox 4.4


Complete step by step guide for Proxmox 5.X 
https://forum.proxmox.com/threads/tutorial-compile-proxmox-ve-5-with-patched-intel-iommu-driver-to-remove-rmrr-check.36374/


Tested to work in HP DL380 Generation 6 with Proxmox 5.1 will probably work well with many other systems and/or configurations
  
As always this patch is distributed as-is and before you run it, be aware of the security, stability and 
other artifacts brought to you by running an modified and unsupported kernel like this one, and be aware that it may 
steal your wife then torch your house and kill your dog, I'm in no way responsible if it does.
