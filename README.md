# RobCoUOS

RobcoUOS is a recreation of the Robco Unified Operating System from the Fallout series owned by Bethesda Game Studios.
It is meant to be a working and usable operating system that functions as it does in the games (plus some).

RobCoUOS is built upon [MikeOS].

### Current Features

 - Hacking minigame
 - Logon sequence
 - Various user commands

### Planned Features

 - Post logon screen
 - Ability to read and write files
 - Username and password change
 - Varying degrees of difficulty for hacking
 
### Compilation

RobCoUOS requires certain programs to compile and create medium images on windows:

* [PartCopy] - Creates the floppy image
* [NASM] - Netwide Assembler - assembles our x86
* [ImDisk] - Opens the floppy image temportarily to copy files

To write the floppy image to a real floppy I use [WinImage]

License
----

MIT

   [Winimage]: <http://www.winimage.com/download.htm>
   [ImDisk]: <https://sourceforge.net/projects/imdisk-toolkit/>
   [NASM]: <http://www.nasm.us/>
   [PartCopy]: <http://www.virtualobjectives.com.au/utilitiesprogs/partcopy.htm>
   [MikeOS]: <http://mikeos.sourceforge.net/>