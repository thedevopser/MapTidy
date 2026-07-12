NAME     := MapTidy
DEST_DIR := $(HOME)/projets/addons/MapTidy/versions
VERSION  := $(shell git describe --tags --abbrev=0 2>/dev/null)

# Fichiers du code addon, listés explicitement (garde-fou check-packaging).
# libs/ est ajouté récursivement au zip (AceGUI-3.0 chargé via libs/embeds.xml,
# non listé fichier par fichier dans le .toc).
ADDON_FILES := \
	MapTidy.toc \
	MapTidy.lua \
	libs/LibStub.lua \
	libs/embeds.xml \
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
import os, zipfile; \
name = '$(NAME)'; \
dest = '$(DEST_DIR)/$(NAME)-$(VERSION).zip'; \
files = '$(ADDON_FILES)'.split(); \
libs = [os.path.join(dp, f) for dp, _, fs in os.walk('libs') for f in fs]; \
seen = set(); \
zf = zipfile.ZipFile(dest, 'w', zipfile.ZIP_DEFLATED); \
[ (zf.write(p, name + '/' + p), seen.add(p)) for p in files + libs if p not in seen ]; \
zf.close(); \
print('→', dest)"

help:
	@echo "Usage:"
	@echo "  git tag v1.0.0   # créer un tag"
	@echo "  make zip         # génère \$$HOME/addons/versions/$(NAME)-v1.0.0.zip"
