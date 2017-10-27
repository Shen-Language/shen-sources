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

ShenClVersion=2.2.0
UrlRoot=https://github.com/Shen-Language/shen-cl/releases/download
ShenClTag=v$(ShenClVersion)
ShenClFolderName=shen-cl-$(ShenClTag)-$(OSName)-prebuilt
ShenClArchiveName=$(ShenClFolderName)$(ArchiveSuffix)
ShenClArchiveUrl=$(UrlRoot)/$(ShenClTag)/$(ShenClArchiveName)
BinaryName=.$(Slash)shen-cl$(Slash)shen$(BinarySuffix)

ReleaseArchiveName=ShenOSKernel-$(GitVersion)$(ArchiveSuffix)

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
	$(BinaryName) -e "(do (load \"make.shen\") (make))"

#
# Dependency retrieval
#

.PHONY: fetch
fetch:
ifeq ($(OSName),windows)
	$(PS) "Invoke-WebRequest -Uri $(ShenClArchiveUrl) -OutFile $(ShenClArchiveName)"
	$(PS) "Expand-Archive $(ShenClArchiveName) -DestinationPath $(ShenClFolderName)"
	$(PS) "if (Test-Path $(ShenClArchiveName)) { Remove-Item $(ShenClArchiveName) -Force -ErrorAction Ignore }"
	$(PS) "if (Test-Path shen-cl) { Remove-Item shen-cl -Recurse -Force -ErrorAction Ignore }"
	$(PS) "Rename-Item $(ShenClFolderName) shen-cl -ErrorAction Ignore"
else
	wget $(ShenClArchiveUrl)
	tar xf $(ShenClArchiveName)
	rm -f $(ShenClArchiveName)
	rm -rf shen-cl
	mv $(ShenClFolderName) shen-cl
endif

#
# Packging
#

.PHONY: release
release:
ifeq ($(OSName),windows)
	$(PS) "New-Item -Path release -Force -ItemType Directory"
	$(PS) "Compress-Archive -Force -DestinationPath release\\$(ReleaseArchiveName) -LiteralPath klambda, tests, license.txt"
	# TODO: generate tar
else
	mkdir -p release
	# TODO: generate zip
	tar -vczf release/$(ReleaseArchiveName) klambda tests license.txt
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
	$(PS) "if (Test-Path shen-cl) { Remove-Item shen-cl -Recurse -Force -ErrorAction Ignore }"
else
	rm -rf shen-cl
endif
