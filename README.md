# Persistent SUBST command #

Works the same way as command.com´s native SUBST command, but in a reboot-persistent manner.

## Purpose ##

Command.com´s native `SUBST` command is a great tool, but every drive mapping get´s erased when windows reboots.
PSubst creates reboot-persistent virtual drive mappings.

To do this, PSubst requires administrative rights, so there is an in-built elevation function that is called when needed.

## Usage ##

Run `psubst.bat /?` for usage instructions.
Note: arguments can be specified in any order.

## When can this be used? ##

  * Temporary subst when the physical drive is missing;
  * Mapping Network drives
  * Bypass Windows limitation for the size of filepath (256 characters);
  * Working of some application within own space;
  * Emulation of other operational systems.
  * Personal files organization


## Related links ##
  * [Original PSUBST home](https://github.com/ildar-shaimordanov/psubst)
  * [SUBST home](http://technet.microsoft.com/en-us/library/bb491006.aspx)
  * [Persistent subst for NT-clones (by Alexander Telyatnikov)](http://alter.org.ua/en/docs/win/persist_subst/)
  * [C++ coded PSUBST (by Alexander Telyatnikov)](http://alter.org.ua/en/soft/win/psubst/)
  * [Overview of file systems FAT, HPFS and NTFS (Microsoft knowledge base page in Russian)](http://support.microsoft.com/kb/100108)
  * [How NTFS Works](http://technet.microsoft.com/en-us/library/cc781134.aspx)
