; Bambu Studio Thai Language Patch - resources only, no binary changes.
Unicode true
!include "LogicLib.nsh"
!include "FileFunc.nsh"

Name "Bambu Studio Thai Language Patch"
OutFile "BambuStudio_Thai_Language_Patch_Setup.exe"
InstallDir "$PROGRAMFILES64\Bambu Studio"
RequestExecutionLevel admin
SetCompressor /SOLID lzma
ShowInstDetails show
ShowUninstDetails show

Page directory
Page instfiles
UninstPage uninstConfirm
UninstPage instfiles

Var BackupRoot
Var CatalogDir
Var WebDir

Function .onInit
  StrCpy $BackupRoot "$PROGRAMFILES64\BambuStudioThaiPatch"
  StrCpy $CatalogDir "$INSTDIR\resources\i18n\es"
FunctionEnd

Section "Install Thai language patch" SEC_MAIN
  StrCpy $CatalogDir "$INSTDIR\resources\i18n\es"
  StrCpy $BackupRoot "$PROGRAMFILES64\BambuStudioThaiPatch"
  IfFileExists "$INSTDIR\bambu-studio.exe" +3 0
    MessageBox MB_ICONSTOP "Official Bambu Studio was not found in the selected folder. Please select the folder containing bambu-studio.exe."
    Abort
  IfFileExists "$CatalogDir\BambuStudio.mo" +3 0
    MessageBox MB_ICONSTOP "Spanish language catalog was not found. This patch needs an official Bambu Studio install with Spanish support."
    Abort
  ; Reuse the original-language backup when reinstalling/upgrading the same patch.
  ; Never overwrite the original backup with already-translated text.
  IfFileExists "$BackupRoot\original_es.mo" existing_backup new_backup

  existing_backup:
    ReadRegStr $R0 HKLM "Software\BambuStudioThaiLanguagePatch" "OfficialInstallDir"
    StrCmp $R0 "$INSTDIR" backup_ready
    MessageBox MB_ICONSTOP "A previous patch backup exists, but its registered Bambu Studio folder differs or is missing. Backup was preserved at $BackupRoot\original_es.mo. Please uninstall the earlier patch or inspect the backup before continuing."
    Abort

  new_backup:
    CreateDirectory "$BackupRoot"
    CopyFiles /SILENT "$CatalogDir\BambuStudio.mo" "$BackupRoot\original_es.mo"
    IfErrors 0 backup_ready
      MessageBox MB_ICONSTOP "Failed to back up the original Spanish translation. No language files were changed."
      Abort

  backup_ready:
  SetOutPath "$CatalogDir"
  File "/oname=BambuStudio.mo" "build_payload\BambuStudio.mo"
  IfErrors 0 +3
    MessageBox MB_ICONSTOP "Could not install Thai catalog. Restore backup from $BackupRoot\original_es.mo."
    Abort
  SetOutPath "$BackupRoot"
  WriteUninstaller "$BackupRoot\Uninstall_Thai_Patch.exe"
  WriteRegStr HKLM "Software\BambuStudioThaiLanguagePatch" "OfficialInstallDir" "$INSTDIR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiLanguagePatch" "DisplayName" "Bambu Studio Thai Language Patch"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiLanguagePatch" "UninstallString" '"$BackupRoot\Uninstall_Thai_Patch.exe"'
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiLanguagePatch" "DisplayIcon" "$INSTDIR\bambu-studio.exe"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiLanguagePatch" "DisplayVersion" "0.1-test"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiLanguagePatch" "NoModify" 1
  ; Reuse the FIRST backup of the official DeviceWeb files.
  StrCpy $WebDir "$INSTDIR\resources\web\device_page\dist"
  IfFileExists "$BackupRoot\original_web_dist\index.html" web_install web_check
  web_check:
    IfFileExists "$WebDir\index.html" web_backup web_missing
  web_backup:
    Rename "$WebDir" "$BackupRoot\original_web_dist"
    IfErrors web_backup_failed web_install
  web_install:
    RMDir /r "$WebDir"
    SetOutPath "$WebDir"
    File /r "build_payload\device_page\dist\*.*"
    IfErrors web_write_failed web_complete
  web_backup_failed:
    MessageBox MB_ICONSTOP "Could not save original DeviceWeb. Please close Bambu Studio and try again."
    Abort
  web_write_failed:
    MessageBox MB_ICONSTOP "Thai DeviceWeb install failed. The original web files remain backed up at $BackupRoot\original_web_dist."
    Abort
  web_missing:
    DetailPrint "DeviceWeb not found. Only the desktop Thai catalog was installed."
  web_complete:
  MessageBox MB_ICONINFORMATION "Thai desktop and DeviceWeb translations installed or updated. Open the official Bambu Studio and choose Español in Preferences > Language. The visible desktop UI should now use Thai translations.$\r$\n$\r$\nTest cloud login and printing before distribution."
SectionEnd

Section "Uninstall"
  StrCpy $BackupRoot "$PROGRAMFILES64\BambuStudioThaiPatch"
  ReadRegStr $INSTDIR HKLM "Software\BambuStudioThaiLanguagePatch" "OfficialInstallDir"
  IfFileExists "$INSTDIR\bambu-studio.exe" +3 0
    MessageBox MB_ICONSTOP "Original Bambu Studio path was not found. Keep backup at $BackupRoot\original_es.mo and restore manually."
    Abort
  IfFileExists "$BackupRoot\original_es.mo" 0 noBackup
    ; Restore only the language resource. Leave the official EXE and DLL untouched.
    CopyFiles /SILENT "$BackupRoot\original_es.mo" "$INSTDIR\resources\i18n\es\BambuStudio.mo"
    IfErrors 0 restored
      MessageBox MB_ICONSTOP "Restore failed. Backup remains at $BackupRoot\original_es.mo"
      Abort
    restored:
      ; Restore original web resources and preserve the backup on failure.
      IfFileExists "$BackupRoot\original_web_dist\index.html" restore_web skip_web_restore
      restore_web:
        RMDir /r "$INSTDIR\resources\web\device_page\dist"
        Rename "$BackupRoot\original_web_dist" "$INSTDIR\resources\web\device_page\dist"
        IfErrors 0 skip_web_restore
          MessageBox MB_ICONSTOP "DeviceWeb restore failed; backup remains at $BackupRoot\original_web_dist."
          Abort
      skip_web_restore:
      Delete "$BackupRoot\original_es.mo"
      Delete "$BackupRoot\Uninstall_Thai_Patch.exe"
      RMDir "$BackupRoot"
      DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiLanguagePatch"
      DeleteRegKey HKLM "Software\BambuStudioThaiLanguagePatch"
      Goto complete
  noBackup:
    MessageBox MB_ICONSTOP "Backup was not found at $BackupRoot\original_es.mo. Nothing was changed."
    Abort
  complete:
SectionEnd
