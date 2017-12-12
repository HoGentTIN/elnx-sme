# File server with Samba/Vsftpd

## Learning goals

- Being able to set up and test a Samba file server
    - Understanding the configuration of Samba, and being able to adapt it for a specific situation
    - Being able to systematically troubleshoot problems with the configuration of a Samba server.
- Being able to set up an FTP server with Vsftpd
    - Understanding the configuration of Vsftpd, and being able to adapt it for a specific situation
    - Being able to systematically troubleshoot problems with the configuration of a Vsftpd server.
- Being able to control acces to files and directories on the Linux filesystem and through network services
    - Understanding Linux user permissions on files and directories
    - Understanding SELinux labels/contexts, and being able to apply these
- Being able to use SELinux
    - Turn SELinux on or off
    - Querying and setting SELinux boolean settings
    - Determining the cause of SELinux-related problems (`avc denial`)

## Assignment

The goal of this lab assignment is to set up a file share suitable for an SME. It can be accessed through two separate network protocols:

- SMB (Windows network neighbourhood)
- FTP

The host name and IP address are specified in the host overview in the README. Services should be accessible from your host system. Accessing the Samba share should be possible by entering `\\files\` in the Windows file explorer, or `smb://files/` in Linux's Nautilus file manager.

By reusing existing Ansible roles, a part of the complexity of this assignment is mitigated. However, it is important to be aware of what happens on the server, what the contents of the configuration files are. When you need to troubleshoot a system, this is essential.

- The setup is completely automated using Ansible
- The included file <avalon-employees.csv> contains a list of all users of the file server. Every user should get an account to access the file server. Every business unit has its own share, and there's also a public one:
    - management
    - technical (software development)
    - sales
    - it (system administration)
    - public
- Add an entry for yourself. You are part of business unit `it`.
- Every user has read and write access to the share of their own business unit, and `public`.
- If a user has write access to a share, they should also be able to modify files owned by other users
- Every user has read and write access to their personal folder (`/home/${USER}`) on the server
- The share `technical` is visible for employees outside of their unit, but not writeable
- The shares `it` and `sales` are visible to management, but not writeable
- The share `management` is completely inaccessible for employees outside of this unit
- Only users in the `it` group can get shell access into the server
- Printer sharing is turned off
- Anonymous browsing on the file server is prohibited, users need an account in order to view the shares

Tip: access management is best done through user groups. Create a user group for each share, and only specify access rights for groups. When you would have to add new users later, it suffices to add them to the group for their business unit to give the correct access rights.

## Testing

For testing purposes, the users have a password that is identical to their name. Adapt the variables at the beginning of the script, if necessary (particularly `admin_user` and `admin_password`).

Currently, most test cases are skipped, because failing tests will probably timeout which takes a lot of time. Remove the lines with the command `skip` at the beginning of a test case to execute it.
