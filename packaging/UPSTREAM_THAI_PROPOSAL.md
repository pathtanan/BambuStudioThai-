# Upstream proposal: Thai localization improvements for Official Bambu Studio

Prepared for: https://github.com/bambulab/BambuStudio/issues/new/choose

Suggested issue title:
**Thai localization: community review and official Windows language availability**

Suggested issue text:

Hello Bambu Studio maintainers,

We would like to contribute improved Thai translations and help make the official Windows experience consistently available in Thai.

We have tested a community localization at https://github.com/pathtanan/BambuStudioThai-/tree/thai-mod and corrected terminology in the desktop interface, including 3D-printing terms such as ironing, seam, bridge, infill, extruder and support. We have also worked on the embedded DeviceWeb/Filament Manager strings.

We noticed the upstream code already includes `wxLANGUAGE_THAI`, `bbl/i18n/th/BambuStudio_th.po` and `resources/i18n/th/BambuStudio.mo`, but an official Windows build used for testing did not offer a complete Thai UI. Manually copying a catalog into the official program translated only some pages.

A separately compiled fork displayed Thai but encountered `BAMBU_NETWORK_SIGNED_ERROR (-26)` when trying to submit print jobs. We do not request bypassing plugin authentication or binary signing. We want Thai users to retain the genuine official build with full cloud, printer, AMS and camera functionality.

Would you accept a focused PR improving the Thai gettext catalog and adding/repairing React DeviceWeb Thai strings? Are there additional build/release requirements for shipping Thai as a selectable language on Windows?

Thank you.

## Submission checklist

- [ ] Align `.po` with the exact upstream version/template (`msgmerge`).
- [ ] Review context-sensitive strings separately; do not globally translate `Part` to "เพิ่มบนผิวงาน".
- [ ] Compile gettext `.mo` from reviewed `.po`.
- [ ] Keep React/DeviceWeb translations matched to target upstream commit.
- [ ] Test menu language selection, print-job upload, LAN, Bambu Cloud, printer status, camera and AMS on an **official signed build**.
- [ ] Submit source catalogs and code through a focused PR, not a forked installer.

## Access limitation

The GitHub integration returned HTTP 403 `Resource not accessible by integration` when attempting to create an issue in `bambulab/BambuStudio`. An owner of this account can use the official "New issue" UI to submit the above message. No upstream issue or PR has been opened yet.
