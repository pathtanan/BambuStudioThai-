; Resource-only Thai patch for Bambu Studio Official 2.8.4.57
Unicode true
Name "Bambu Studio Thai Language Patch (Official 2.8.4)"
OutFile "BambuStudio_Thai_Official_2.8.4_Patch_Setup.exe"
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
Var ThaiMo
Var WebDir

Section "Install native Thai language" SecMain
  StrCpy $ThaiMo "$INSTDIR\resources\i18n\th\BambuStudio.mo"
  StrCpy $WebDir "$INSTDIR\resources\web\device_page\dist"
  StrCpy $BackupRoot "$INSTDIR\resources\ThaiLanguagePatch"
  IfFileExists "$INSTDIR\bambu-studio.exe" found_exe missing_exe
  missing_exe:
    MessageBox MB_ICONSTOP "Official Bambu Studio was not found in this folder. Select the directory containing bambu-studio.exe."
    Abort
  found_exe:
    GetDLLVersion "$INSTDIR\bambu-studio.exe" $0 $1
    IfErrors unsupported_version
    IntOp $2 $0 >> 16
    IntOp $3 $0 & 0xFFFF
    IntOp $4 $1 >> 16
    IntOp $5 $1 & 0xFFFF
    DetailPrint "Detected Bambu Studio version: $2.$3.$4.$5"
    StrCmp $2 "2" +2 unsupported_version
    StrCmp $3 "8" +2 unsupported_version
    StrCmp $4 "4" +2 unsupported_version
    StrCmp $5 "57" +2 unsupported_version
    Goto version_ok
  unsupported_version:
    MessageBox MB_ICONSTOP "This patch is ONLY for Bambu Studio Official 2.8.4.57. Your version is not supported. Nothing was changed."
    Abort
  version_ok:
    IfFileExists "$PROGRAMFILES64\BambuStudioThaiPatch\original_es.mo" legacy_found no_legacy
  legacy_found:
    MessageBox MB_ICONSTOP "Older Español Thai patch detected. Uninstall it first before installing this new native Thai patch. No changes made."
    Abort
  no_legacy:
    IfFileExists "$ThaiMo" mo_present required_missing
  mo_present:
    IfFileExists "$WebDir\index.html" web_present required_missing
  web_present:
    IfFileExists "$INSTDIR\resources\fonts\NotoSansThai-Regular.ttf" regular_present required_missing
  regular_present:
    IfFileExists "$INSTDIR\resources\fonts\NotoSansThai-Bold.ttf" backups required_missing
  required_missing:
    MessageBox MB_ICONSTOP "Official Thai language, font, or DeviceWeb resource is missing. Nothing was changed."
    Abort

  backups:
    IfFileExists "$BackupRoot\patch.ini" reuse_backup first_install
  reuse_backup:
    ReadINIStr $R0 "$BackupRoot\patch.ini" "Patch" "StudioPath"
    StrCmp $R0 "$INSTDIR" check_backup incompatible_backup
  incompatible_backup:
    MessageBox MB_ICONSTOP "An existing backup belongs to another Studio folder. Nothing changed."
    Abort
  check_backup:
    IfFileExists "$BackupRoot\original_th.mo" check_web_backup missing_backup
  check_web_backup:
    IfFileExists "$BackupRoot\original_web_dist\index.html" apply_patch missing_backup
  missing_backup:
    MessageBox MB_ICONSTOP "Original Official resource backup is incomplete. Nothing changed."
    Abort
  first_install:
    CreateDirectory "$BackupRoot"
    CopyFiles /SILENT "$ThaiMo" "$BackupRoot\original_th.mo"
    IfErrors cannot_backup
    Rename "$WebDir" "$BackupRoot\original_web_dist"
    IfErrors cannot_backup
    WriteINIStr "$BackupRoot\patch.ini" "Patch" "StudioPath" "$INSTDIR"
    WriteINIStr "$BackupRoot\patch.ini" "Patch" "RequiredVersion" "2.8.4.57"
    Goto apply_patch
  cannot_backup:
    MessageBox MB_ICONSTOP "Could not back up original files. Close Bambu Studio and try again. Existing backup is preserved."
    Abort

  apply_patch:
    SetOutPath "$INSTDIR\resources\i18n\th"
    File "/oname=BambuStudio.mo" "native_payload\BambuStudio.mo"
    IfErrors install_failed
    RMDir /r "$WebDir"
    SetOutPath "$WebDir"
    File /r "native_payload\device_page\dist\*.*"
    IfErrors install_failed
    WriteUninstaller "$BackupRoot\Uninstall_Thai_Patch.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiNativePatch" "DisplayName" "Bambu Studio Thai Language Patch (Official 2.8.4)"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiNativePatch" "UninstallString" '"$BackupRoot\Uninstall_Thai_Patch.exe"'
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiNativePatch" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiNativePatch" "DisplayVersion" "2.8.4.57-test"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiNativePatch" "NoModify" 1
    MessageBox MB_ICONINFORMATION "Thai desktop and Filament Manager installed. Open Official Bambu Studio and select Thai in Preferences > Language. The original EXE and DLL are unchanged."
    Goto completed
  install_failed:
    MessageBox MB_ICONSTOP "Thai patch installation was interrupted. Original files remain at $BackupRoot. Do not delete the backup. Run the uninstaller to restore."
    Abort
  completed:
SectionEnd

Section "Uninstall"
  ReadRegStr $INSTDIR HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiNativePatch" "InstallLocation"
  StrCmp $INSTDIR "" missing_backup_data
  StrCpy $BackupRoot "$INSTDIR\resources\ThaiLanguagePatch"
  StrCpy $ThaiMo "$INSTDIR\resources\i18n\th\BambuStudio.mo"
  StrCpy $WebDir "$INSTDIR\resources\web\device_page\dist"
  IfFileExists "$BackupRoot\original_th.mo" check_web_restore missing_backup_data
  check_web_restore:
    IfFileExists "$BackupRoot\original_web_dist\index.html" do_restore missing_backup_data
  do_restore:
    CopyFiles /SILENT "$BackupRoot\original_th.mo" "$ThaiMo"
    IfErrors restore_failed
    RMDir /r "$WebDir"
    Rename "$BackupRoot\original_web_dist" "$WebDir"
    IfErrors restore_failed
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\BambuStudioThaiNativePatch"
    Delete "$BackupRoot\original_th.mo"
    Delete "$BackupRoot\patch.ini"
    Delete "$BackupRoot\Uninstall_Thai_Patch.exe"
    RMDir "$BackupRoot"
    MessageBox MB_ICONINFORMATION "Original Official Thai catalog and DeviceWeb restored."
    Goto done
  missing_backup_data:
    MessageBox MB_ICONSTOP "Original backup was not found. Nothing was removed."
    Abort
  restore_failed:
    MessageBox MB_ICONSTOP "Restore failed; original files are preserved at $BackupRoot."
    Abort
  done:
SectionEnd
