# OVOS PHAL PLUGIN OSM INSTALLER

The PHAL Plugin provides GUI interfaces and API for OVOS OSM.

## Installation

Plugin Support Two Installation Methods:

1. Install from Github URL

Note: PIP install from URL will not install the .desktop file and icon if installing to a venv or virtual environment, so you need to manually install them to the system or user directory.

Note: PIP install will attempt to install the .desktop file and icon to the system directory, or user directory if the system directory is not writable. If this is not a virtual environment.

```
pip install git+https://github.com/OpenVoiceOS/ovos-PHAL-plugin-osm-installer
```

2. Manual Install from Git Clone

```
git clone https://github.com/OpenVoiceOS/ovos-PHAL-plugin-osm-installer
cd ovos-PHAL-plugin-osm-installer
cp -r res/desktop/osm-skill.desktop ~/.local/share/applications/
cp -r res/icon/osm-skill.svg ~/.local/share/icons/
pip install .
```
