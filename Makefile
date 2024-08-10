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

ShenSchemeVersion=0.35
UrlRoot=https://github.com/tizoc/shen-scheme/releases/download
ShenSchemeTag=v$(ShenSchemeVersion)
ShenSchemeFolderName=shen-scheme-$(ShenSchemeTag)-$(OSName)-bin
ShenSchemeArchiveName=$(ShenSchemeFolderName)$(ArchiveSuffix)
ShenSchemeArchiveUrl=$(UrlRoot)/$(ShenSchemeTag)/$(ShenSchemeArchiveName)

ifndef Shen
	Shen=.$(Slash)shen-scheme$(Slash)bin$(Slash)shen-scheme$(BinarySuffix)
endif

ReleaseFolderName=ShenOSKernel-$(GitVersion)
ReleaseZip=$(ReleaseFolderName).zip
ReleaseTar=$(ReleaseFolderName).tar
ReleaseTarGz=$(ReleaseTar).gz

#
# KLambda rendering
#

.DEFAULT: klambda
.PHONY: klambda
klambda:
ifeq ($(OSName),windows)
	$(PS) "if (Test-Path klambda) { Remove-Item klambda -Recurse -Force -ErrorAction Ignore }"
	$(PS) "New-Item -Path klambda -Force -ItemType Directory"
else
	rm -rf klambda
	mkdir -p klambda
endif
	$(Shen) eval -l make.shen -e "(make)"

#
# Dependency retrieval
#

.PHONY: fetch
fetch:
ifeq ($(OSName),windows)
	$(PS) "Invoke-WebRequest -Uri $(ShenSchemeArchiveUrl) -OutFile $(ShenSchemeArchiveName)"
	$(PS) "Expand-Archive $(ShenSchemeArchiveName) -DestinationPath $(ShenSchemeFolderName)"
	$(PS) "if (Test-Path $(ShenSchemeArchiveName)) { Remove-Item $(ShenSchemeArchiveName) -Force -ErrorAction Ignore }"
	$(PS) "if (Test-Path shen-scheme) { Remove-Item shen-scheme -Recurse -Force -ErrorAction Ignore }"
	$(PS) "Rename-Item $(ShenSchemeFolderName)$(Slash)$(ShenSchemeFolderName) shen-scheme -ErrorAction Ignore"
	$(PS) "Remove-Item $(ShenSchemeFolderName) -Recurse -Force -ErrorAction Ignore"
else
	wget $(ShenSchemeArchiveUrl)
	mkdir -p $(ShenSchemeFolderName)
	tar xf $(ShenSchemeArchiveName)
	rm -f $(ShenSchemeArchiveName)
	rm -rf shen-scheme
	mv $(ShenSchemeFolderName) shen-scheme
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
	$(PS) "Copy-Item -Recurse stlib $(ReleaseFolderName)"
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
	cp -rf assets doc extensions klambda sources stlib tests CHANGELOG.md LICENSE.txt README.md $(ReleaseFolderName)
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
