NAME     := MapTidy
DEST_DIR := $(HOME)/addons/versions
VERSION  := $(shell git describe --tags --abbrev=0 2>/dev/null)

ADDON_FILES := \
	MapTidy.toc \
	MapTidy.lua \
	libs/LibStub.lua \
	libs/Krowi_WorldMapButtons/Krowi_WorldMapButtons-1.4.xml \
	libs/Krowi_WorldMapButtons/Krowi_WorldMapButtons-1.4.lua \
	Locales/enUS.lua \
	Locales/frFR.lua \
	Core/Filter.lua \
	Core/Settings.lua \
	Core/Changelog.lua \
	Hooks/WorldMap.lua \
	UI/WorldMapButton.xml \
	UI/Panel.lua \
	UI/MinimapButton.lua \
	UI/ChangelogPopup.lua \
	Textures/icon.tga

.PHONY: zip help

zip:
	@[ -n "$(VERSION)" ] || { echo "Erreur : aucun tag git trouvé. Exemple : git tag v1.0.0"; exit 1; }
	@python3 tools/check-packaging.py $(ADDON_FILES)
	@mkdir -p "$(DEST_DIR)"
	@python3 -c "\
import zipfile; \
dest = '$(DEST_DIR)/$(NAME)-$(VERSION).zip'; \
files = '$(ADDON_FILES)'.split(); \
zf = zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED); \
[zf.write(f, '$(NAME)/' + f) for f in files]; \
zf.close(); \
print('→', dest)"

help:
	@echo "Usage:"
	@echo "  git tag v1.0.0   # créer un tag"
	@echo "  make zip         # génère \$$HOME/addons/versions/$(NAME)-v1.0.0.zip"
