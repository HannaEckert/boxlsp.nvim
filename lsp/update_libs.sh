#!/usr/bin/bash

currentDirectory=$(cd $(dirname "$0") >/dev/null 2>&1; pwd -P)

downloadUrl=$(
	curl -s https://api.github.com/repos/ortus-boxlang/vscode-boxlang/releases/latest | \
	grep browser_download_url | cut -d '"' -f 4
)

if [ "x" = "x$downloadUrl" ] ; then
	echo "Unable to retrieve boxlang lsp download url."
	exit 1
fi

# Find latest ColdFusion Builder Version:
latestVersion=$(echo $downloadUrl | sed -r "s/.*\/release\/(.*)\/vscode-boxlang.*/\1/")

currentVersion="0"
currentVersionInfoFile="$currentDirectory/lsp.version"
if [ -f $currentVersionInfoFile ] ; then
	currentVersion=$(cat $currentDirectory/lsp.version)
fi

if [ $latestVersion = $currentVersion ] ; then
	exit 0
fi

extensionFile="$currentDirectory/extension.zip"

# Download latest BoxLang LSP Package:
wget $downloadUrl -O "$extensionFile" 1>/dev/null 2>/dev/null

if [ ! -f "$extensionFile" ] ; then
	echo "Unable to download boxlang lsp extension version $latestVersion."
	exit 1
fi

libs=$(unzip -l "$extensionFile" | grep .jar | grep -v miniserver | sed -r "s/.* (.*)$/\1/")

if [ "x" = "x$libs" ] ; then
	echo "Could not find any suitable jars within the boxlang lsp extension."
	rm $extensionFile
	exit 1
fi

# Reset the target lib folder
targetLibFolder="$currentDirectory/lib"
if [ -d "$targetLibFolder" ] ; then
	rm -r "$targetLibFolder"
	mkdir "$targetLibFolder"
fi

# Extract the lsp libs:
unzip -o -j "$extensionFile" $libs -d "$targetLibFolder" 1>/dev/null 2>/dev/null
rm "$extensionFile" 

echo "$latestVersion" > "$currentVersionInfoFile"
echo "Updated boxlang lsp: $latestVersion"
