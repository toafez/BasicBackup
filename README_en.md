English | [Deutsch](README.md)

# ![Package icon](/package/ui/images/icon_24.png) Basic Backup - Package for Synology NAS (DSM 7)
Basic Backup enables GUI-supported, file-based data backup based on rsync, as well as version backup according to the generation principle using hard links. Possible backup sources and destinations are internal volumes and USB/SATA data carriers connected externally to a Synology NAS, as well as rsync-capable remote servers connected via SSH. Via the integrated USB/SATA AutoPilot function, both backup jobs and other Bash scripts can be executed automatically when an external USB/SATA data carrier is connected and, if necessary, automatically ejected again afterwards.

  - _**This might also interest you:** [Differences between Basic Backup and Hyper Backup](PROS_AND_CONS_en.md)_
  
# System requirements
**Basic Backup** is specifically designed for use on **Synology NAS systems** that use the **DiskStation Mangager 7** operating system.

# Installation instructions
Download the **most recent version** of Basic Backup from the [Releases](https://github.com/toafez/BasicBackup/releases) section. Then open the **Package Centre** in the **DiskStation Manager (DSM)**, select the **Manual Installation** button at the top right and follow the **Wizard** to upload and install the new **Package** or the corresponding **.spk file**. This process is identical for both an initial installation and for performing an update.

**After starting** BasicBackup, the locally **installed version** is compared with the version **available** on GitHub. If an update is available, the user is **informed** about it via the app and a corresponding **link** to the corresponding release is displayed. The download and the subsequent update process have already been explained above. 

 - ## Activate Rsync service
    Please activate the **rsync service** in advance. To activate the rsync service, go to **DSM Main Menu** > **Control Panel** > **File Services** and switch to the tab > **rsync**. Activate the checkbox **Enable rsync service**. By default, **port 22** is used as the **SSH encryption port**, which you can adjust if necessary.
    
  - ## Activate SSH Terminal Service (if required)
    Please activate the **SSH Terminal Service** on your local Synology NAS as well as on the remote Synology NAS in advance. To activate the SSH terminal service, go to **DSM main menu** > **Control Panel** > **Terminal & SNMP** and switch to the tab > **Terminal**. Activate the checkbox **Enable SNMP service**. If the **Remote Server** you are using is a device other than a Synology NAS, please make sure that the **SSH Service** is enabled beforehand.
   
  - ## Enable User Home Service (if SSH service is enabled)
    Please also activate the **User Home Service** in advance, as the required SSH connection data is stored in the corresponding User Home folder of the logged-in SSH user. To activate the user home service, go to **DSM main menu** > **Control Panel** > **Users and Group** and switch to the tab > **Advanced**. Under the menu item **User Base**, activate the checkbox **Enable User Home Service**. If the **Remote Server** used is a device other than a Synology NAS, please make sure that a corresponding User Home Service has been activated in advance.

  - ## Extend App Permission
    Under DSM 7, a 3rd_Party application such as Basic Backup (referred to as App in the following) is provided with highly restricted user and group rights. Among other things, this means that system-related commands cannot be executed. For the smooth operation of Basic Backup, however, extended system rights are required, e.g. to be able to access the folder structure of the "shared folders". To extend the app permissions, Basic Backup must be added to the administrators' group, but this can only be done by the user himself. The following instructions describe this process.

    - ### Extending app permissions via the console

      - Log in to the console of your Synology NAS as user **root**.
      - Command to extend app permissions

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh`
 
    - ### Extending app permissions via the task scheduler

      - Open the **Task Scheduler** in **DSM** under **Main Menu** > **Control Panel**.
      - In the **Task Scheduler**, select **Create** > **Scheduled Task** > **Custom Script** via the button.
      - In the pop-up window that now opens in the **General** > **General Settings** tab, give the task a name and select **root** as the user: **root** as the user. Also remove the tick from Activated.
      - In the **Task Settings** tab > **Execute Command** > **Custom Script**, insert the following command into the text field...
      - Command to extend the app permissions

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh`
   
      - Save the entries with **OK** and confirm the subsequent warning message with **OK**.
      - Mark the task you have just created in the overview of the task planner, but **do not** activate it (the line should be highlighted in blue after marking).
      - Execute the task once by pressing the **Execute** button.

  - ## Activate/deactivate USB/SATA AutoPilot function
    Using the integrated USB/SATA AutoPilot function, data backup jobs as well as other Bash scripts can be executed automatically when an external USB/SATA data carrier is connected and, if necessary, automatically ejected again afterwards. For this to work, a so-called UDEF rule must be passed to the system. However, this step can only be carried out by the user. The following instructions describe this process.
    
    - ### Enable/disable USB/SATA AutoPilot via the console.

      - Log in to the console of your Synology NAS as user **root**.
      - Command to **enable** the USB/SATA AutoPilot function

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot start"`

      - Command to **disable** the USB/SATA AutoPilot function

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot stop"`

    - ### Enable/disable USB/SATA AutoPilot via the task scheduler
      - Open the **Task Scheduler** in **DSM** under **Main Menu** > **Control Panel**.
      - In the **Task Scheduler**, select **Create** > **Scheduled Task** > **Custom Script** via the button.
      - In the pop-up window that now opens in the **General** > **General Settings** tab, give the task a name and select **root** as the user: **root** as the user. Also remove the tick from Activated.
      - In the **Task Settings** tab > **Execute Command** > **Custom Script**, insert the following command into the text field...
      - Command to **Enable** the USB/SATA AutoPilot function

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot start"`

      - Command to **disable** the USB/SATA AutoPilot function

        `/usr/syno/synoman/webman/3rdparty/BasicBackup/app_permissions.sh "autopilot stop"`
   
      - Save the entries with **OK** and confirm the subsequent warning message with **OK**.
      - Mark the task you have just created in the overview of the task planner, but **do not** activate it (the line should be highlighted in blue after marking).
      - Execute the task once by pressing the **Execute** button.
      
  - ## Set up an external data carrier for USB/SATA AutoPilot
    - ### Setup via the DSM 
      - From the **DSM Package Centre**, install the **Text Editor** package provided by Synology.
      - Start the **Text Editor** and create a new text file via the **File** > **New** button.
      - If you would like to run a Basic Backup job when you plug in the external disk, insert the following content, replacing **TASKNAME** with the **job name** you want. Example:
      
        ```
        #!/bin/bash
        bash /usr/syno/synoman/webman/3rdparty/BasicBackup/rsync.sh --job-name="TASKNAME"
        ```
        
      - Then save the text file you just created using the **File** button > **Save as...** select the **root directory** of the desired external data carrier, such as **/usbshare**, as the storage location and enter **autopilot** as the file name without the file extension. Confirm your entries by pressing the **Save** button.
      - To ensure that the file autopilot has the attribute **Execute**, open the **File Station** and change to the external data carrier on which the file autopilot is located. Right-click on the autopilot file to open the **Context Menu** and select **Properties**. 
        - If you are offered several checkboxes in the **Permission** tab, which you can use to define the _**read, write and execute permission**_ for _**Owner, Group and Other**_, then make sure that **all** the checkboxes are ticked. Save any changes afterwards using the **Save** button.
        
        - If the checkboxes just mentioned are not offered in the **Authorisation** tab, then create a new authorisation using the **Create** button. Select _**Everyone**_ from the drop-down menu under **User or Group** and _**Allow**_ under **Type**. Under the item **Permissions**, tick all the checkboxes for _**Administration, Read**_ and _**Write**_ and click on the **Done** button. Save your changes by clicking on the **Save** button. 
      - Eject the external data carrier via the DSM. The next time the external data carrier is plugged in, the contents of the script file just created will be executed.

# Version history
- Details of the version history can be found in the file [CHANGELOG](CHANGELOG).

# Developer information
- For backend details, please refer to the [Synology DSM 7.0 Developer Guide](https://help.synology.com/developer-guide/).
- For details on the frontend, please refer to the [Bootstrap Framework](https://getbootstrap.com/)
- For details on jQuery, please refer to the [jQuery API](https://api.jquery.com/)

# Help and discussion
- For help and discussion, please refer to [The German Synology Support Forum](https://www.synology-forum.de/threads/basic-backup.117455/) or [heimnetz.de](https://forum.heimnetz.de/threads/basic-backup-3rdparty-app-fuer-synology-nas-dsm-7.485/)

# License
This program is free software. You can redistribute it and/or modify it under the terms of the **GNU General Public License** as published by the Free Software Foundation; either **version 3** of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful to you, but ** WITHOUT ANY WARRANTY**, even **without the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE**. For details, see the [GNU General Public License](LICENSE) file.
