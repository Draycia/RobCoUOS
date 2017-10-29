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
 - Permanent lockout (with bypass)
 
### Guide on use

Upon boot you have a few options. 
 - Run various programs like `mem`
 - Logon with username/password
 - Go through the hacking sequence and minigame
 
Default username is `admin` and password is `BURIED`.

To start the hacking minigame you need to go through the necessary command sequence.
```
>SET TERMINAL/INQUIRE
>SET FILE/PROTECTION=OWNER:RWED ACCOUNTS.F
>SET HALT/RESTART MAINT
>RUN DEBUG/ACCOUNTS.F
```
Once in the minigame, typing anything but the words in the data chunk triggers undefined behaviour.
You have 4 tries to get the right password or you're locked out until reboot.
 
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