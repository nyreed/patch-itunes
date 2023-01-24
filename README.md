patch-itunes.sh

# Install iTunes on Modern Version of MacOS

##Script to install 12.9.5.5 on modern versions of MacOS _WITHOUT_ disabling SIP.

A simple script to download and install the latest version of iTunes, and patch it to run on modern version of MacOS and M1 Processors.

This is complicated because:

1. The only official place to download it is bundled with the MacOS 10.14.6 updater.  
2.	The app binary itself uses executable_path expansion to link to its bundled gracenote libraries. This causes Arm macs to forbid the code to run due to their security model.

Tools like Retroactive suggest a need to disable SIP to get around this problem. This is disadvantageous because it is arguably less secure, and it prevents iOS apps running via catalyst.
By patching the binary you avoid needing to disable SIP.

###This script will simply

1. Download MacOS 10.14.6 updater (5.54GB)"
2. Extract the iTunes.app bundle from the updater."
3. Patch the app to refer link to the OS bundled gracenote libraries with Absolute path instead.
4. Codesign the patched application (mandatory for ARM macs)."
5. Install the app into /Applications."


## Usage

	git clone https://github.com/nyreed/patch-itunes
	cd patch-itunes
	./patch-itunes

follow the prompts.

## Tested
Script tested on Monterey 12.5.1 in an M1 VM and 12.6.2 on an M1 mac, and 12.6 on an intel mac.

The resulting app bundle might not run for you…
Strangely the app will only run on my M1 mac. The same binary 
that runs on the M1 fails to run properly in the VM or on the intel mac. 
The app runs, but immediately crashes with "An unknown error occurred 
(13021)."
It is not a codesigning issue as the app does run briefly. I think 
it's an issue with the environment. Very strange… 
Let me know how it goes for you…

iTunes (if it runs)
Tested: Playing Music
Not Tested: Anything else.


## Issues.

The update is packaged in an 8GB archive in Apple's proprietary pbzx format.
(it's actually a pbzx archive inside a disk image inside a xar archive…)
This format has no index and no way to easily extract specified files.
Unfortunately this script currently traverses the whole thing, even thought the desired files are right at the beginning of the archive.
I don't know the best way to terminate the process after the itunes files are extracted.

### Why?

I don't know. I liked to sort by iTunes library by "Date Added". When I tried to import my library into the new Music app, that data is lost.

## Thanks

Bundled the pbzx tool fork from [https://github.com/NiklasRosenstein/pbzx](https://github.com/NiklasRosenstein/pbzx)  
Info.plist patch instruction from [MacRumors](https://forums.macrumors.com/threads/itunes-12-6-5-3-on-apple-silicon.2354390/)
