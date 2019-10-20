# [macOS Catalina Patcher](http://dosdude1.com/catalina)

## The easy way to run macOS Catalina on your Unsupported Mac

Use the Xcode Project to build.

Excluding patched binary files, this repo is governed by GNU GPL v3

## APFS BootROM Support:

If you have a machine that supports High Sierra natively, you MUST ensure you have the latest version of the system's BootROM installed. If you have NOT previously installed High Sierra, you can download and install [this](https://ipfs.io/ipfs/QmZ5KmpG4SeHF8gWrHmoLcG9a3BNAcWWQoERg4q2J1kuQL/OfficialAPFSFWUpdate.zip) package to install the latest BootROM version. When installing, ensure your system is plugged in to power, or the update will not be installed.

### Early-2008 or newer Mac Pro, iMac, or MacBook Pro:

- MacPro3,1 
- MacPro4,1
- MacPro5,1
- iMac8,1
- iMac9,1
- iMac10,x
- iMac11,x (systems with AMD Radeon HD 5xxx and 6xxx series GPUs will be almost unusable when running Catalina.)
- iMac12,x (systems with AMD Radeon HD 5xxx and 6xxx series GPUs will be almost unusable when running Catalina.)
- MacBookPro4,1
- MacBookPro5,x
- MacBookPro6,x
- MacBookPro7,x
- MacBookPro8,x

### Late-2008 or newer MacBook Air or Aluminum Unibody MacBook:

- MacBookAir2,1
- MacBookAir3,x
- MacBookAir4,x
- MacBook5,1

### Early-2009 or newer Mac Mini or white MacBook:

- Macmini3,1
- Macmini4,1
- Macmini5,x (systems with AMD Radeon HD 6xxx series GPUs will be almost unusable when running Catalina.)
- MacBook5,2
- MacBook6,1
- MacBook7,1

### Early-2008 or newer Xserve:

- Xserve2,1
- Xserve3,1


## Machines that ARE NOT supported:

### 2006-2007 Mac Pros, iMacs, MacBook Pros, and Mac Minis:

- MacPro1,1
- MacPro2,1
- iMac4,1
- iMac5,x
- iMac6,1
- iMac7,1
- MacBookPro1,1
- MacBookPro2,1
- MacBookPro3,1
- Macmini1,1
- Macmini2,1

### The 2007 iMac 7,1 is compatible if the CPU is upgraded to a Penryn-based Core 2 Duo, such as a T9300.

### 2006-2008 MacBooks:

- MacBook1,1
- MacBook2,1
- MacBook3,1
- MacBook4,1
- 2008 MacBook Air (MacBookAir 1,1)


## Known issues:

### AMD/ATI Radeon HD 5xxx and 6xxx series graphics acceleration:

Currently, it is not possible to achieve full graphics acceleration under Catalina on any machines that use a Radeon HD 5xxx or 6xxx series GPU. If you have a machine with one of these GPUs installed, I'd advise upgrading it if possible (can be done in 2010/2011 iMacs, iMac11,x-12,x), disabling the dedicated GPU if using a 2011 15" or 17" MacBook Pro (MacBookPro8,2/8,3, instructions to do so can be found here), or not installing Catalina. Running Catalina without full graphics acceleration will result in extremely poor system performance.
