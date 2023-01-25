patch-itunes.sh

# Install iTunes on Modern Version of MacOS

## Script to install 12.9.5.5 on modern versions of MacOS _WITHOUT_ disabling SIP.

A simple script to download and install the latest version of iTunes, and patch it to run on modern version of MacOS and M1 Processors.

This is complicated because:

1. The only official place to download it is bundled with the MacOS 10.14.6 updater.  
2.	The app binary itself uses executable_path expansion to link to its bundled gracenote libraries. This causes Arm macs to forbid the code to run due to their security model.

Tools like [Retroactive](https://github.com/cormiertyshawn895/Retroactive) suggest a need to disable SIP to get around this problem. This is disadvantageous because it is arguably less secure, and it prevents iOS apps running via catalyst.
By patching the binary you avoid needing to disable SIP.

### This script will simply

1. Download MacOS 10.14.6 updater (5.54GB)"
2. Extract the iTunes.app bundle from the updater."
3. Patch the app to refer link to the OS bundled gracenote libraries with Absolute path instead.
4. Codesign the patched application (mandatory for ARM macs)."
5. Install the app into /Applications."

### ISSUE

For whatever reason, iTunes will CRASH with "An unknown error occured (13021)." if the following file is not present.

	~/Music/iTunes/iTunes Library.itl
	
If not, iTunes will instead attempt to create iTunes Library files in ~/.Trash, and crash with a "deny(1) file-write-data" error. How strange.

As long as something, anything, is present at ~/Music/iTunes/iTunes Library.itl, iTunes will run. If it's not a real library file, iTunes will create one its place, and also create the following files.

	~/Music/iTunes/iTunes Library Extras.itdb
	~/Music/iTunes/iTunes Library Genius.itdb
	~/Music/iTunes/Album Artwork
	~/Music/iTunes/iTunes Media
	~/Music/iTunes/Previous iTunes Libraries

This script will create a dummy file at ~/Music/iTunes/iTunes Library.itl so that iTunes will run.


## Usage

	git clone https://github.com/nyreed/patch-itunes
	cd patch-itunes
	./patch-itunes

follow the prompts.

## Tested
Script tested on Monterey 12.5.1 in an M1 VM and 12.6.2 on an M1 mac, and 12.6 on an intel mac.

On launch you get "An unknown error occured -42408", I think relating to iTunes Store connectivity (which doesn't work.) 
Apparently disabling iTunes Store in Restrictions makes the message go away.

I guess the Retroactive guys have iTunes store working at the expense of turning off SIP.

iTunes
Working: Playing Music  
Not Working: iTunes Store, Update Genius.  
Not Tested: Anything else. Some clever people in the [Retroactive Project](https://github.com/cormiertyshawn895/Retroactive) know more about this I think. They have instructions on iPod sync and things.

### Why?

I don't know. I liked to sort by iTunes library by "Date Added". When I tried to import my library into the new Music app, that data is lost. Also the search bar is in the wrong place in the music app.

## Thanks

Bundled the pbzx tool fork from [https://github.com/NiklasRosenstein/pbzx](https://github.com/NiklasRosenstein/pbzx)  
Info.plist patch instruction from [MacRumors](https://forums.macrumors.com/threads/itunes-12-6-5-3-on-apple-silicon.2354390/)
