---
title: "Flashing Android 7 onto Lenovo A3500-FL (Custom ROM, Recovery)"
date: 2021-08-19T15:17:00+02:00
draft: false
---

Long time ago I bought a tablet [Lenovo A3500-FL](https://www.gsmarena.com/lenovo_a7_50_a3500-6280.php). 
It's really old tablet but still works suprisingly well. I thought about maybe having it working as a mobile terminal or [Home Assistant Dashboard](https://community.home-assistant.io/t/best-option-to-run-dashboard-on-tablet/174802).

It only has offical upgrade to Android 4.4.2 which is really old and applications might not be targeting it anymore. According to [XDA article](https://www.xda-developers.com/android-version-distribution-statistics-android-studio/) only 4% of devices are still running Android that old (and 5,9% culminative of previous versions and this one).

So I went on a journey to find a newer custom ROM for that device.

## Finding Custom ROM

This is no easy task. First of all that tablet was already very cheap when I bought it (around 800PLN or 200$ as of bought in like 2015?). And right now [they're listed](https://allegro.pl/listing?string=lenovo%20a3500) for sale for around 100PLN (25$). So not too many people probably cared about that tablet.

My first target for searching a custom ROM was [XDA forum](https://forum.xda-developers.com/f/lenovo-a3500-roms-kernels-recoveries-other-de.7332/), but they barely had any activity in ROM section. 
This made my research a little bit harder. 

## More than a single internet

For exotic / unpopular devices English-based internet may not always be enough. [First Page](https://www.google.com/search?client=firefox-b-d&q=a3500+custom+rom) of google results returns me just barely any useful links for finding newer ROMs. 

This is where using different kind of internets comes in. See, there is not only Google available (and I don't mean Bing / DuckDuckGo as alternative). There are search engines such as [yandex](https://yandex.com/) which helps you navigate Russian internet, and [baidu](https://www.baidu.com/) which helps you navigate Chinese internet. For electronic devices research, it's always good to try to use different internets and see whether there is any information there.

## Searching Russian-based internet

I don't speak Russian, even though I'm from Poland, but I learned by myself a little bit of Cyrillic for the purpose of reading the Russian language. A nice benefit of being from Eastern European is that most of the languages share similar words for many things, even if they're written using different symbols. So I search for ["Lenovo a3500-fl rom"](https://yandex.ru/search/?lr=10472&text=lenovo+a3500-fl+rom) and I saw a new forum available for finding what I need - [4pda](https://4pda.to/forum/index.php?showtopic=624077).

There I found a list of Custom ROMs maintained by them under spoiler button: "Неофициальные прошивки" (Not using translate - is it "Neoficjialine Proshiwki?"). There I found RR([ResurrectRemix](https://resurrectionremix.com/)) 5.8.8 with last update on 24.02.2019 (!) and Android 7.1.1. So that was a lot newer than what I had.

# Flashing new firmware (Custom ROM, Recovery)

After I found a new ROM, I had to somehow get it onto my device. For that we need a so-called custom recovery. There are two big recovery projects, [CWM](https://www.clockworkmod.com/) and [TWRP](https://www.clockworkmod.com/).

Of course none of them offer recovery for my device as the support has never really been there, so I resorted to using an unofficial recovery build of TWRP.

- [TWRP 3.11 for Lenovo A3500-FL](https://forum.xda-developers.com/t/recovery-mt6582-twrp-3-11-for-lenovo-a3500.3684225/)

For flashing the recovery, that is installing it onto the device, I had to use custom mediatek flashing tool. Happily, there is [kind-of-official(?) site](https://spflashtool.com/) offering download of such tool.

What this tool does is that it allows to use so-called "Download Mode" of your device to flash whatever you want onto it. It is available to use before anything hash even started.

- [SP_FLASH_TOOL_V5.1924](https://spflashtool.com/download/)

I used Windows 10 for flashing the device, as I was just familiar with the process of doing it on Windows.

## Flashing Recovery

After I got both recovery and tool to flash the recovery, we need to do flashing of recovery. To do that we need to:
- Perform full format of the device
- Flash the recovery module itself 

For full formatting you just go to tab **Format** and from there you can choose **Auto Format Flash** with option **Format whole flash except bootloader**. 

You will loose everything on your tablet.

After you do that, you should be able to flash the new recovery. For that you need so called `MT6582_Android_scatter.txt` file, which you can [find here for MT6582 (under Firmware dir)](https://firmwarefile.com/lenovo-a3500-fl). You also get whole Original ROM in case anything goes wrong.

If you have scatter file, you need to load it in the program under the **scatter-loading** section. 

After selecting scatter, you need to uncheck everything in sections below, and check only **Recovery** section and select the `.img` file from TWRP package that you downloaded.

To flash the device:
- Turn it completely off
- Click **Download** button in flash tool
- Connect the device through USB without turning it on. 
- Flashing tool should do its work and tell you that it finished successfully.

Now you should be able to boot into recovery by holding **Power + Vol UP + Vol DOWN** buttons.

## Flashing new ROM

- After you boot into recovery, you should now see an interface of TWRP. 
- You can now connect USB cable to be able to access its file system. 
- Download the custom ROM zip and put it into some folder inside the device (like `/TWRP`). You **can't put it directly without any folder** (at least it didn't work on Windows for me)
- You also need to download and add onto the device [fix for storage](https://forum.xda-developers.com/t/installed-resurrection-remix-no-external-storage-pop-up.3922231/). Without that storage will be inaccessible.
- Now in TWRP, go to `Install` section, and select from your selected folder two files: `Custom ROM.zip` and `storage.xml.zip`
- Confirm by swiping it to install. 
- It might take 5-10 mins.
- At the end you should get an option to `wipe dalvik cache` - do that also.

## Unbricking device

In case your device doesn't boot:
- you need to once again open the flashing tool
- select same scatter file from that 1GB firmware archive from previous paragraphs
- Now instead of deselecting everything, keep everything selected (**unselect `PRELOADER` to be sure to not break your device completely - it should be fine without it**)
- (Optional) Change the recovery image (if you want to still try doing it, if you want to go back to how it originally was keep everything unchanged). 
- Click download button
- Connect the device
- Wait for it to finish

That way you will just reflash a whole new firmware onto the device guaranteeing that it boots if nothing else broke.

In case it connecting the device doesn't do anything, you might got it stuck in some kind of a dead / boot loop, and you need to disassemble it to disconnect the battery. 

If that still doesn't work, your tablet is dead (you might try to flash the eMMC chip directly, but if you're at this stage, you either know what you're doing or not)

# Booting device after flashing

So after everything I mentioned, I boot up the device and I was able to use it right away after waiting a few minutes on booting screen.


