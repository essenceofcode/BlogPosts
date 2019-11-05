# Docker for Windows and Line Feeds
Recently I was working on a dockerfile to create a new Docker image and ran into a very strange issue during the build.  One of the steps was generating an error like this:

```
Put error here!
```

It wasn't obvious and it took me a little bit to understand what was happening.  It turned out to be a line ending compatibility issue between Windows and Linux.

I was building a Linux image using Docker for Windows.  So the development environment for my scripts and Linux container was Windows 10.  When I created my file in Windows it was adding a carriage return(CR) and a line feed(LF) character to the end of every line.  In this case I was creating a bash script that would be copied into the container and run by the Dockerfile and a subsequent step.  This type of line feed doesn't work correctly in Linux, which is where the image was actually running.

## The Age Old Battle - LF vs CRLF
Different operating systems use different standards for handling line endings.  In this case Windows wants to use both the CR and LF characters (CRLF) and Linux uses just the LF character.  In older versions of the Mac operating system, only the CR character was used (OSX now uses LF).  These differing standards can make moving files between the different operating systems a bit cumbersome and can cause some difficult to diagnose issues.

In this case it resulted in the error above which did not make the underlying issue immediately apparent.

## Initial fix
The first thing I did to fix this issue was to switch the line endings on the Windows file before it was copied into the image.  This was easy enough to do with a modern editor like Visual Studio Code.  I switched the line feed setting for the file in the editor and it worked!  The setting is even conveniently displayed in the status bar at the bottom of the document:

![](./CodeCRLFSetting.png)

Clicking the setting allows you to quickly switch the line endings from CRLF to LF for the file.  I did this and voila, it worked correctly in my image!

## Git for Windows Preferred Setting AutoCRLF
Of course I'm putting my Dockerfile into git so that it can be rebuilt on a build server and by other developers on my team.  My fix above of switching the line feed setting worked great locally, but as soon as I pulled the image down on another machine it had the exact same error again!

## Options for solving

### .gitattributes file

### Using Dockerfile Run