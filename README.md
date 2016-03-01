# Persistent SUBST command #

Works the same way as command.com´s native SUBST command, but in a reboot-persistent manner.

## Purpose ##

Command.com´s native `SUBST` command is a great tool, but every drive mapping get´s erased when windows reboots.
The goal is to create a script that can manage reboot-persistent virtual drive mappings.

## When can this be used? ##

  * Temporary stub when the physical drive is missing;
  * Mapping Network drives
  * Operational system limitation for the size of filename (256 characters);
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
