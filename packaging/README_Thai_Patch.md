# Bambu Studio Thai — One-click Official Patch (TEST)

**Purpose:** apply Thai translations to a genuine, digitally signed Windows Bambu Studio installation. No EXE, DLL, network plugin, certificate, or Bambu account data is modified.

## Install
1. Close **Bambu Studio Official 02.08.02.61** completely.
2. Run BambuStudio_Thai_Language_Patch_Setup.exe as administrator.
3. Select the folder containing the genuine bambu-studio.exe (normally C:\Program Files\Bambu Studio).
4. The installer backs up the original Spanish gettext catalog and original DeviceWeb folder under C:\Program Files\BambuStudioThaiPatch.
5. Restart Bambu Studio. Select **Español** in Preferences > Language. Thai will be shown via the Spanish slot, because the stock installation did not expose a working Thai selector during testing.
6. Verify desktop menus, Filament Manager, Login, camera, AMS and an actual print job before distributing.

## Changes bundled in one EXE
- Existing Thai desktop translation catalog with 3D navigation cube labels converted to ASCII English where the signed ImGuizmo renderer cannot display Thai glyphs (Front, Back, Top, Bottom, camera-context Left and Right).
- Terminology corrections for World coordinates, Operation, and the generic Part key.
- The React DeviceWeb/Filament Manager build from the matching source, with both es/es_ES aliases set to Thai.
- Backups, safe repeat installation to the same folder, and an uninstall rollback.

## Known limitations
- **Text > Part** requires a context-specific source change to read **เพิ่มบนผิวงาน** without breaking the generic **Part** menu. A translation-only patch cannot isolate that instance, so for now all generic Part labels use **ชิ้นส่วน** rather than the earlier incorrect **ตอน**.
- Other UI elements using Front/Back/Top/Bottom or Camera Left/Right translation keys will display English because those keys are shared with the navigation cube.
- No changes to other embedded web pages beyond DeviceWeb are guaranteed.
- The bundled web page must be retested for each Bambu Studio version. **Only test with the matching 02.08.02.61 installation first.**

## Restore
Close Official Bambu Studio. In Windows Installed apps, uninstall **Bambu Studio Thai Language Patch**. The original Spanish catalog and DeviceWeb directory will be restored from C:\Program Files\BambuStudioThaiPatch. Do not delete this backup by hand. Uninstall before upgrading the Official Bambu Studio version.

This is a community test translation, not an official Bambu Lab release.
