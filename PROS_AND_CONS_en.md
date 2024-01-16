👈 [Back to README_en.md](README_en.md)

# Advantages and disadvantages of Basic Backup
On a Synology NAS system, Hyper Backup usually takes care of the comprehensive backup of shared folders, packages and LUNs. Basic Backup is therefore an alternative - or supplementary - backup software, which differs from Hyper Backup to a greater or lesser extent in its range of functions and mode of operation. The main differences and the associated advantages and disadvantages of both systems are summarised in the table below.  

## Differences between Basic Backup and Hyper Backup

| Feature | Basic&nbsp;Backup | Hyper&nbsp;Backup |
| --- | :---: | :---: |
| **Data Backup** |
| Backed-up data is stored unencrypted directly in the file system | 🟢 | 🟢 |
| Backed up data is stored in Synology's backup format (.hbk), encrypted if necessary | 🔴 | 🟢 |
| **Data backup versions** |
| Backup versions are stored unencrypted directly in the file system using hard links | 🟢 | 🔴 |
| Backup versions are stored encrypted in Synology's backup format (.hbk) if necessary | 🔴 | 🟢 |
| **Restore** |
| Restoring backed up data is supported	| 🔴 | 🟢 |
| Backing up and restoring certain applications (packages) is supported	 | 🔴 | 🟢 |
| **Use of externally connected USB/SATA data carriers** |
| An external data carrier can be selected as a backup destination<br />***Note:** If an external data carrier is specified as a backup destination using Basic Backup, it can be identified by its UUID instead of its mount point. In this case, the mount point is redirected internally to the correct device, if necessary.* | 🟢 | 🟢 |
| Data backup sources from an external data carrier can be selected<br />***Note:** Backing up from external data carriers may be subject to errors, as the mount point of the device may change in the meantime. In this case, the mount point is not adjusted by determining the UUID.* | 🟢 | 🔴 |
| A local data backup can be made from an external data carrier to another external data carrier. | 🟢 | 🔴 |
| **Use of remote servers on the LAN or via the Internet** |
| Local backup sources of the Synology NAS can be backed up to a remote server (Push Backup) | 🟢 | 🟢 |
| Remote backup sources can be backed up to the local Synology NAS (Pull Backup). | 🟢 | 🔴 |
| Wake up a remote server before starting the backup (Wake on LAN) | 🟢 | 🔴 |
| Shutting down a remote server after the backup has finished (shutdown) | 🟢 | 🔴 |
| Shared remote folders attached via the File Station can be selected as backup source or destination<br />***Note:** Backing up from or to attached, shared remote folders may be error-prone, as rsync may have problems with delta encoding or differential storage here.*| 🟢 | 🔴 |
| **Other** |
| Creating a detailed data backup protocol | 🟢 | 🔴 |
| Visual and/or acoustic signal output via the LEDs or the loudspeaker of the Synology NAS | 🟢 | 🔴 |
