#
# Identify environment information
#

ifeq ($(OS),Windows_NT)
	OSName=windows
else ifeq ($(shell uname -s),Darwin)
	OSName=macos
else
	OSName=linux
endif

Tag=$(shell git tag -l --contains HEAD)

ifeq ("$(Tag)","")
	GitVersion=$(shell git rev-parse --short HEAD)
else
	GitVersion=$(Tag:shen-%=%)
endif

#
# Set OS-specific variables
#

ifeq ($(OSName),windows)
	Slash=\\\\
	ArchiveSuffix=.zip
	BinarySuffix=.exe
	PS=powershell.exe -Command
else
	Slash=/
	ArchiveSuffix=.tar.gz
	BinarySuffix=
endif

#
# Set shared variables
#

ShenSchemeVersion=0.43
UrlRoot=https://github.com/tizoc/shen-scheme/releases/download
ShenSchemeTag=v$(ShenSchemeVersion)
ifeq ($(OSName),windows)
	ShenSchemeRawArch=$(PROCESSOR_ARCHITECTURE)
else
	ShenSchemeRawArch=$(shell uname -m)
endif

ifneq ($(filter arm64 aarch64,$(ShenSchemeRawArch)),)
	ShenSchemeArch=arm64
else ifneq ($(filter x86_64 amd64 AMD64,$(ShenSchemeRawArch)),)
	ShenSchemeArch=x64
else
	ShenSchemeArch=$(ShenSchemeRawArch)
endif

ifeq ($(OSName),macos)
	ShenSchemeAssetOSName=macOS
else
	ShenSchemeAssetOSName=$(OSName)
endif

ShenSchemePlatformName=$(ShenSchemeAssetOSName)-$(ShenSchemeArch)
ShenSchemeFolderName=shen-scheme-$(ShenSchemeTag)-$(ShenSchemePlatformName)-bin
ShenSchemeArchiveName=$(ShenSchemeFolderName)$(ArchiveSuffix)
ShenSchemeArchiveUrl=$(UrlRoot)/$(ShenSchemeTag)/$(ShenSchemeArchiveName)
ShenSchemeExtractRoot=shen-scheme-extract

ifndef Shen
ifdef SHEN
	Shen=$(SHEN)
else
	Shen=.$(Slash)shen-scheme$(Slash)bin$(Slash)shen-scheme$(BinarySuffix)
endif
endif

ReleaseFolderName=ShenOSKernel-$(GitVersion)
ReleaseZip=$(ReleaseFolderName).zip
ReleaseTar=$(ReleaseFolderName).tar
ReleaseTarGz=$(ReleaseTar).gz

#
# KLambda rendering
#

.DEFAULT: klambda
.PHONY: klambda klambda-kernel klambda-stlib
klambda:
	$(MAKE) klambda-kernel
	$(MAKE) klambda-stlib

klambda-kernel:
ifeq ($(OSName),windows)
	$(PS) "if (Test-Path klambda) { Remove-Item klambda -Recurse -Force -ErrorAction Ignore }"
	$(PS) "New-Item -Path klambda -Force -ItemType Directory"
else
	rm -rf klambda
	mkdir -p klambda
endif
	$(Shen) eval -l make.shen -e "(make)"

klambda-stlib:
ifeq ($(OSName),windows)
	$(PS) "New-Item -Path klambda -Force -ItemType Directory"
else
	mkdir -p klambda
endif
	$(Shen) eval -l make-stlib.shen -e "(make-stlib)"

#
# Dependency retrieval
#

.PHONY: fetch
fetch:
ifeq ($(OSName),windows)
	$(PS) "Invoke-WebRequest -Uri $(ShenSchemeArchiveUrl) -OutFile $(ShenSchemeArchiveName)"
	$(PS) "if (Test-Path $(ShenSchemeExtractRoot)) { Remove-Item $(ShenSchemeExtractRoot) -Recurse -Force -ErrorAction Ignore }"
	$(PS) "Expand-Archive $(ShenSchemeArchiveName) -DestinationPath $(ShenSchemeExtractRoot)"
	$(PS) "if (Test-Path $(ShenSchemeArchiveName)) { Remove-Item $(ShenSchemeArchiveName) -Force -ErrorAction Ignore }"
	$(PS) "if (Test-Path shen-scheme) { Remove-Item shen-scheme -Recurse -Force -ErrorAction Ignore }"
	$(PS) "$$Direct = '$(ShenSchemeExtractRoot)$(Slash)bin$(Slash)shen-scheme$(BinarySuffix)'; $$Nested = '$(ShenSchemeExtractRoot)$(Slash)$(ShenSchemeFolderName)$(Slash)bin$(Slash)shen-scheme$(BinarySuffix)'; if (Test-Path $$Direct) { Rename-Item $(ShenSchemeExtractRoot) shen-scheme } elseif (Test-Path $$Nested) { Rename-Item '$(ShenSchemeExtractRoot)$(Slash)$(ShenSchemeFolderName)' shen-scheme; Remove-Item $(ShenSchemeExtractRoot) -Recurse -Force -ErrorAction Ignore } else { throw 'Could not locate shen-scheme binary in extracted archive.' }"
else
	wget $(ShenSchemeArchiveUrl)
	rm -rf $(ShenSchemeExtractRoot)
	mkdir -p $(ShenSchemeExtractRoot)
	tar xf $(ShenSchemeArchiveName) -C $(ShenSchemeExtractRoot)
	rm -f $(ShenSchemeArchiveName)
	rm -rf shen-scheme
	if [ -x "$(ShenSchemeExtractRoot)/bin/shen-scheme$(BinarySuffix)" ]; then mv $(ShenSchemeExtractRoot) shen-scheme; \
	else ExtractedDir=$$(find $(ShenSchemeExtractRoot) -mindepth 1 -maxdepth 1 -type d | head -n 1); \
	  if [ -n "$$ExtractedDir" ] && [ -x "$$ExtractedDir/bin/shen-scheme$(BinarySuffix)" ]; then mv "$$ExtractedDir" shen-scheme; rmdir $(ShenSchemeExtractRoot); \
	  else echo "Could not locate shen-scheme binary in extracted archive." >&2; exit 1; fi; fi
endif

#
# Packging
#

.PHONY: release
release:
ifeq ($(OSName),windows)
	$(PS) "New-Item -Path release -Force -ItemType Directory"
	$(PS) "if (Test-Path $(ReleaseFolderName)) { Remove-Item $(ReleaseFolderName) -Recurse -Force -ErrorAction Ignore }"
	$(PS) "New-Item -Path $(ReleaseFolderName) -Force -ItemType Directory"
	$(PS) "Copy-Item -Recurse assets $(ReleaseFolderName)"
	$(PS) "Copy-Item -Recurse doc $(ReleaseFolderName)"
	$(PS) "Copy-Item -Recurse extensions $(ReleaseFolderName)"
	$(PS) "Copy-Item -Recurse klambda $(ReleaseFolderName)"
	$(PS) "Copy-Item -Recurse sources $(ReleaseFolderName)"
	$(PS) "Copy-Item -Recurse lib $(ReleaseFolderName)"
	$(PS) "Copy-Item -Recurse tests $(ReleaseFolderName)"
	$(PS) "Copy-Item CHANGELOG.md $(ReleaseFolderName)"
	$(PS) "Copy-Item LICENSE.txt $(ReleaseFolderName)"
	$(PS) "Copy-Item README.md $(ReleaseFolderName)"
	$(PS) "Compress-Archive -Force -DestinationPath release\\$(ReleaseZip) -LiteralPath $(ReleaseFolderName)"
	7z a -ttar -so $(ReleaseTar) $(ReleaseFolderName) | 7z a -si release\\\\$(ReleaseTarGz)
	$(PS) "if (Test-Path $(ReleaseFolderName)) { Remove-Item $(ReleaseFolderName) -Recurse -Force -ErrorAction Ignore }"
else
	mkdir -p release
	rm -rf $(ReleaseFolderName)
	mkdir -p $(ReleaseFolderName)
	cp -rf assets doc extensions klambda lib sources tests CHANGELOG.md LICENSE.txt README.md $(ReleaseFolderName)
	zip -r release/$(ReleaseZip) $(ReleaseFolderName)
	tar -vczf release/$(ReleaseTarGz) $(ReleaseFolderName)
	rm -rf $(ReleaseFolderName)
endif

#
# Cleanup
#

.PHONY: clean
clean:
ifeq ($(OSName),windows)
	$(PS) "if (Test-Path klambda) { Remove-Item klambda -Recurse -Force -ErrorAction Ignore }"
	$(PS) "if (Test-Path release) { Remove-Item release -Recurse -Force -ErrorAction Ignore }"
else
	rm -rf klambda release
endif

.PHONY: pure
pure: clean
ifeq ($(OSName),windows)
	$(PS) "if (Test-Path shen-scheme) { Remove-Item shen-scheme -Recurse -Force -ErrorAction Ignore }"
else
	rm -rf shen-scheme
endif
