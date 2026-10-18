# Bambu Studio Thai Language Patch (TEST)

Installs Thai gettext translations **over the Spanish translation slot** of an existing, genuine Bambu Studio Windows installation. It intentionally does **not** change `bambu-studio.exe`, `BambuStudio.dll`, the Network Plugin, firmware, or certificates.

## Installation
1. Install genuine Bambu Studio from Bambu Lab, and close it.
2. Run `BambuStudio_Thai_Language_Patch_Setup.exe` as administrator.
3. Confirm the official Bambu Studio folder. The patch requires `bambu-studio.exe` and `resources\i18n\es\BambuStudio.mo`.
4. Relaunch Official Bambu Studio and select **Español** in Preferences > Language. This is a temporary compatibility workaround; the list will still show Español.
5. Check Thai desktop menus; test login, AMS, camera, printer connectivity and print upload.

## Rollback
Uninstall **Bambu Studio Thai Language Patch** in Windows Apps & Features. The installer backs up the original Spanish `.mo` to `%ProgramFiles%\BambuStudioThaiPatch\original_es.mo`. Do not delete that backup manually.

## Limitations / cautions
- This is an **unverified test installer**. Build success does not guarantee official application compatibility.
- Desktop strings that do not have a matching gettext entry remain untranslated.
- DeviceWeb/Filament Manager React translations are **not** installed by this initial patch, because swapping bundled JS across releases requires exact version testing.
- Close Bambu Studio before installing/uninstalling.
- Do not run this twice without uninstalling it first. If the official application is upgraded, uninstall this patch and test again after the update.
- Do not distribute as an official Bambu Lab product; clearly label as independent community translation.

## Source
- NSIS script: `packaging/thai-patch.nsi`
- GitHub Actions build: `.github/workflows/build_thai_patch.yml`
- Translated catalog: `resources/i18n/th/BambuStudio.mo`
