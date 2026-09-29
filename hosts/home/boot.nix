{
  boot = {
    plymouth.enable = true;
    kernelModules = ["kvm-intel"];
    kernelParams = [
      "copytoram"
      "quiet"
      "nvidia.NVreg_EnableGpuFirmware=0"
      # Allow GPU profiling for non-root users.
      "nvidia.NVreg_RestrictProfilingToAdminUsers=0"
    ];
    supportedFilesystems = ["nfs"];
    loader = {
      grub = {
        enable = true;
        device = "nodev";
        enableCryptodisk = true;
        efiSupport = true;

        # Save EFI binary as EFI/BOOT/BOOTX64.EFI. This is not really
        # necessary, but this way the system can boot even if NVRAM entries get
        # wiped for whatever reason: just boot from removable device as usual.
        efiInstallAsRemovable = true;

        # Lately the initial ram disk has grown quite a bit.
        # Maybe some kernel module that is included transitively is too big?
        configurationLimit = 5;

        useOSProber = false;
        extraEntries = ''
          menuentry 'UEFI Firmware Settings' { fwsetup }
        '';
      };
    };
    initrd = {
      kernelModules = ["nvidia"];
      availableKernelModules = [
        "ahci"
        "nvme"
        "usb_storage"
        "usbhid"
        "xhci_pci"
      ];
      luks.devices = let
        luksDev = ctrl: {
          device = "/dev/nvme${toString ctrl}n1"; # 2T
          allowDiscards = true;
          preLVM = true;
        };
      in {
        crypta = luksDev 0; # 2T
        cryptb = luksDev 1; # 2T
      };
      services.lvm.enable = true;
    };
    tmp = {
      useTmpfs = true;
      cleanOnBoot = true;
      tmpfsSize = "80G";
    };
  };
}
