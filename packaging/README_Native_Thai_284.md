# Thai language patch for signed Official Bambu Studio 2.8.4.57

This patch is a **TEST**, not a Bambu Lab release. It modifies only two resource areas of a genuine Bambu Studio installation:

- `resources/i18n/th/BambuStudio.mo`: merges reviewed Thai UI terms with catalog from upstream tag `v02.08.04.57`.
- `resources/web/device_page/dist/`: recompiles the *matching upstream* DeviceWeb/Filament Manager with reviewed Thai translations.

It never replaces `bambu-studio.exe`, `BambuStudio.dll`, network plugins or any authentication/signing component.

## Requirements
1. Bambu Studio **Official 2.8.4.57** installed (not the compiled `thai-mod` fork, and not official 2.8.2.61).
2. Close Bambu Studio completely, including background tasks.
3. Uninstall the previous **Español-based** Thai patch first, using Windows Installed Apps. Do not manually delete its backup.
4. Launch the latest `BambuStudio_Thai_Official_2.8.4_Patch_Setup.exe` as administrator.
5. Check the detected Official install folder; click Install.
6. Open the genuine application and choose **ภาษาไทย / Thai** in Preferences > Language. Restart if asked.

## Recovery / repeated install
- The first install saves the original Thai catalog and DeviceWeb folder inside `<Official Studio>\resources\ThaiLanguagePatch`.
- Running the patch again on the **same install** keeps the original backups; it must not overwrite them.
- Uninstall via Windows Installed Apps > **Bambu Studio Thai Language Patch (Official 2.8.4)**. The original catalog and web folder are restored.
- Uninstall before upgrading the main Bambu Studio release. Do not delete the backup directory before uninstalling.

## Scope and cautions
- The 3D panel renders Thai correctly only if **the Official executable includes the NotoSansThai-enabled ImGui code**, as at upstream tag `v02.08.04.57`. The installer checks for the matching executable file version and bundled NotoSansThai font files.
- Filename/version checks do not independently prove the identity of every executable; obtain the base installer from Bambu Lab.
- `Text > Part` still needs an upstream context-specific code fix. The generic gettext `Part` uses **ชิ้นส่วน**, not **ตอน**. The desired context-specific label is **เพิ่มบนผิวงาน**.
- Not all embedded web pages use this DeviceWeb bundle; incomplete translations may still remain.
- Build success does not prove print-job upload, AMS or cloud login compatibility; test on your own printer before distribution.

## Build
- GitHub Actions: `.github/workflows/build_thai_native_284.yml`
- NSIS installer: `packaging/native-thai-284.nsi`
- Catalog merge: `tools/prepare_patch_catalog.py` and `tools/merge_native_catalog.py`
- DeviceWeb merge: `tools/merge_native_web.py`
