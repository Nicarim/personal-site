---
title: Hash Sum Mismatch – trouble when using WSL2 and VirtualBox
date: 2020-05-20T10:00:00+02:00
---

When I was writing a tutorial regarding usage of VirtualBox to compile Marlin firmware (for 3D Printers) I came across following issue:
```
E: Failed to fetch store:/var/lib/apt/lists/partial/jp.archive.ubuntu.com_ubuntu_dists_focal_main_binary-amd64_Packages.xz  Hash Sum mismatch
   Hashes of expected file:
    - Filesize:5826751 [weak]
    - SHA256:af226b4496cbb524bd4814d102047ae77769836203274dffc91cb543d5da13cc
    - SHA1:aef5c36ce45bd5c3154a1bb03c62b6cfb33e2bc6 [weak]
    - MD5Sum:7ef83228ec207df10acac48fbdd81112 [weak]
   Hashes of received file:
    - SHA256:e2c7fc5a2d86f75f03612fec614dcf84d3d502976558fbe40928c1dd120bb05e
    - SHA1:aef5c36ce45bd5c3154a1bb03c62b6cfb33e2bc6 [weak]
    - MD5Sum:7ef83228ec207df10acac48fbdd81112 [weak]
    - Filesize:5826751 [weak]
   Last modification reported: Thu, 23 Apr 2020 16:40:26 +0000
   Release file created at: Thu, 23 Apr 2020 17:33:17 +0000
```
This error was really strange because SHA256 is the only one that differs. 
([See related post on AskUbuntu](https://askubuntu.com/questions/1235914/hash-sum-mismatch-error-due-to-identical-sha1-and-md5-but-different-sha256/1241893#1241893))

## Solution
For me the solution that I quickly discovered due to some Japanese posting similar issue (<https://ktkr3d.github.io/2020/05/07/APT-Hash-sum-mismatch-error/>). 
What gave me an idea was that I recently enabled WSL2 and so-called “Virtual Machine Platform” (that gave a strange turtle icon in virtualbox where virtualization support is shown). 
Disabling WSL2 and Virtual Machine Platform solved the issue completely.

