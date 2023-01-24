#! /bin/zsh

FREESPACE=`diskutil info / | grep "Container Free Space" | awk '{print $6}'`
FREESPACE="${FREESPACE:1}"
SPACENEEDED=8600000000
SCRIPTDIR=$0:A:h
PBZXBIN="$SCRIPTDIR/pbzx"
TICK="\xE2\x9c\x85\x0a"
CROSS="\xe2\x9d\x8c\x0a"
BEER="\xf0\x9f\x8d\xba"
MUSIC="\xf0\x9f\x8e\xb5"
EXL="\xe2\x9d\x97\x00"
BOX="\xf0\x9f\x93\xa6"
HAMMER="\xF0\x9F\x94\xA8"
SIGN="\xE2\x9C\x8D\xEF\xB8\x8F"
PROMPTTXT="Press [ENTER] to continue or [CTRL+C] to cancel"
EXITTXT="Press [ENTER] to exit"
ITURL="http://swcdn.apple.com/content/downloads/17/32/061-26589-A_8GJTCGY9PC/25fhcu905eta7wau7aoafu8rvdm7k1j4el/InstallESDDmg.pkg"
ITPATCH="42534449464634309a00000000000000610000000000000080b10c020000
0000425a68393141592653594e96c7a5000087fedb7edc0a208e10010000
0410020000d040004202c2005050012000890953440d0034d0000048a0a0
c868d0d034d3d09881193128d629f1d972270c09411d43ed7a2ee58e1948
354a14581540005f8062e9d43b91497896110bf2a7bbe780cc8692a53126
8b1e2cb41ab0cfb1504dc0212f4fcb340d02358496730f8181f8bb9229c2
848274b63d28425a6839314159265359ce734d6900000079d8f100420000
40400001000028000210000040000a20007505494d3401ea029540001bfa
df4e3221ae02a8a8196a214a814a20912405d387cd9877e685dde1249115
03e7e2ee48a70a1219ce69ad20425a683931415926535983bb9f23000001
860000024000200030802a6911c5dc914e142420eee7c8c0"


# debug variables.
# FREESPACE=80000000000

echo "> ITUNES 12.9.5.5 PATCHER+INSTALLER $MUSIC"
echo ""
echo "> This script will:"
echo "> 1. Download MacOS 10.14.6 updater (5.54GB)"
echo ">    This is the only official place hosting the latest iTunes release."
echo "> 2. Extract the iTunes.app bundle from this updater."
echo "> 3. Patch the app to run on newer versions of OSX and ARM processors"
echo ">    without requiring SIP to be disabled."
echo "> 4. Codesign the patched application (mandatory for ARM macs)."
echo "> 5. Install the app into /Applications"
echo ""
read "?$PROMPTTXT"
echo ""
echo "IMPORTANT $EXL"
echo "This script makes no changes or patches to your MacOS installation."
echo "It only patches the iTunes app bundle, which can be deleted at any time."
echo ""
echo "You will require:"
printf "> 8.6GB of free space (8.4GB will be freed after install)  "
if [ $FREESPACE -gt $SPACENEEDED ];
	then printf $TICK; NOSPACE=0;
	else printf $CROSS; NOSPACE=1; 
	fi

if [ $NOSPACE -ne 0 ];
	then echo "Current Free Space: $(( FREESPACE / 1000000 ))MB"
	echo "Please Free Up $(( $((SPACENEEDED - FREESPACE)) / 1000000  ))MB on your root filesystem, then run this script again."
	read "?$EXITTXT"
	exit 1
fi

if [[ ! -f $PBZXBIN ]];
	then echo "Error: Cannot find bundled pbzx binary. Please ensure you run this script in the directory it came in."
	exit 1
fi
	
read "?$PROMPTTXT"
echo ""
# Set up working directory 
TMP=`mktemp -d`
cd $TMP

#Download installer package
echo "Downloading InstallESDDmg.pkg to $TMP"
curl --output-dir "$TMP" -O "$ITURL"
echo ""

# It's a box within a box within a box
echo "Extracting iTunes (be patient, this takes a while) $BOX"
echo "Expect a delay after the filenames appear on screen"
pkgutil --expand-full $TMP/InstallESDDmg.pkg $TMP/installer

##mount the dmg. quit if we fail.
MOUNTPOINT=`hdiutil mount $TMP/installer/InstallESD.dmg`
if [ $? != 0 ]; then
	i=0
	while [ $i -lt 4 ]
		do
		if [[ $i = 3 ]]
			then; echo "Unable to mount InstallESD.dmg. Aborting"; exit 1; fi
		echo "DMG mount error. Retry"
		i=$(( i + 1 ))
		sleep 3
		MOUNTPOINT=`hdiutil mount $TMP/installer/InstallESD.dmg`
		if [[ $? = 0 ]]; then
			i=4
		fi
	done
fi

MOUNTPOINT=`echo $MOUNTPOINT | grep /Volumes | awk '{print $3}'`

#######****
## must add error handling for the mount.
#### try mounting it once.
#### While loop, add one if repeated fails, and then on third fail, abort.
#### on completion, hdiutil info or something and get the mount point that way.

$PBZXBIN $MOUNTPOINT/Packages/Core.pkg | cpio -idv "./Applications/iTunes.app"
# I would like a way to terminate this once itunes has extracted.
#at present it continues traversing the whole huge archive, and iTunes is right at the beginning!

#Let's eject the installer disk now. We have what we want.
hdiutil eject $MOUNTPOINT

echo "Extraction Complete"
echo "$HAMMERNow Patching iTunes"
echo ""

BUNDLE="$TMP/Applications/iTunes.app"
ITBINDIR="$TMP/Applications/iTunes.app/Contents/MacOS"
BINPATCH="$TMP/patch"

#Patch the info.plist

plutil -replace CFBundleGetInfoString -string 'iTunes 13.9.9' $BUNDLE/Contents/Info.plist
plutil -replace CFBundleShortVersionString -string 13.9.9 $BUNDLE/Contents/Info.plist
plutil -replace CFBundleVersion -string 13.9.9 $BUNDLE/Contents/Info.plist
 

# These binary patches were generated by using install_name_tool to redirect to the SYSTEM libgnsdk Libraries (STILL dual arch and still v3.06.1 on Monterey)
# You can use install_name_tool if you prefer. I used bspatch because install_name_tool requires xcode command line tools to be installed.
# Later I realised homebrew also requires the xcode command line tools so 🤷️

# while [[ $OPTION != 1 && $OPTION != 2 ]]
# do
# 	echo "1. binpatch"
# 	echo "2. install_name_tool"
# 	read OPTION
# done

# if [[ $OPTION = 1 ]]; then
echo "$ITPATCH" | xxd -r -p - > "$BINPATCH"
bspatch $ITBINDIR/iTunes $ITBINDIR/iTunes-new $BINPATCH
rm $ITBINDIR/iTunes
mv $ITBINDIR/iTunes-new $ITBINDIR/iTunes
chmod 755 $ITBINDIR/iTunes
# elif [[ $OPTION = 2 ]]; then
# 
# # THIS IS HOW I GENERATED THE BIN PATCHES.
# install_name_tool -change @executable_path/../Frameworks/libgnsdk_dsp.3.06.1.dylib /System/Library/PrivateFrameworks/AMPLibrary.framework/Versions/A/Frameworks/libgnsdk_dsp.3.06.1.dylib "$ITBINDIR"/iTunes
# install_name_tool -change @executable_path/../Frameworks/libgnsdk_manager.3.06.1.dylib /System/Library/PrivateFrameworks/AMPLibrary.framework/Versions/A/Frameworks/libgnsdk_manager.3.06.1.dylib "$ITBINDIR"/iTunes
# install_name_tool -change @executable_path/../Frameworks/libgnsdk_musicid.3.06.1.dylib /System/Library/PrivateFrameworks/AMPLibrary.framework/Versions/A/Frameworks/libgnsdk_musicid.3.06.1.dylib "$ITBINDIR"/iTunes
# install_name_tool -change @executable_path/../Frameworks/libgnsdk_submit.3.06.1.dylib /System/Library/PrivateFrameworks/AMPLibrary.framework/Versions/A/Frameworks/libgnsdk_submit.3.06.1.dylib "$ITBINDIR"/iTunes
# fi

#Codesign
touch $BUNDLE
echo ""
echo "$SIGNCodesigning bundle with self identifier - please enter sudo password"
sudo codesign -s - -f --deep $BUNDLE

ditto $BUNDLE /Applications/iTunes.app


echo "All Done, cleaning up now."
echo "Deleting temp directory."


mv $TMP/InstallESDDmg.pkg ~/Downloads/
rm -r $TMP

echo "Job Done."
echo "InstallESDDMG.pkg moved to Downloads folder. If iTunes works you can delete it."
echo "If iTunes is working you can delete this now."


open /Applications/iTunes.app