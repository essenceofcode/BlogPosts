# Linux Style Line Feeds in Docker Desktop on Windows
Recently I was creating a new image using a dockerfile and encountered a very strange error during the build.  One of the steps was generating an error like this:

```
./my-script.sh: 1: ./my-script.sh: Syntax error: word unexpected
```

The cause of this wasn't obvious and it took me a little bit to understand what was happening.  It turned out to be a line ending compatibility issue between Windows and Linux.

I was building a Linux image using Docker Desktop on Windows.  So the development environment for my scripts was Windows 10.  When I created my file in Windows it was adding a carriage return(CR) and a line feed(LF) character to the end of every line.  In this case I was creating a bash script that would be copied into the container and run by the Dockerfile during a subsequent step.  This type of line feed doesn't work correctly in Linux, which is where the script was was actually running after being copied into the running container.

## The Age Old Battle - LF vs CRLF
Different operating systems use different standards for handling line endings.  In this case Windows wants to use both the CR and LF characters (CRLF) and Linux uses just the LF character.  In older versions of the Mac operating system, only the CR character was used (OSX now uses LF).  These differing standards can make moving files between operating systems a bit cumbersome and can cause some difficult to diagnose issues.

In this case it resulted in the mysterious error message above which did not make the underlying issue immediately apparent.

## Initial fix
The first thing I did to fix this issue was to switch the line endings on the Windows file before it was copied into the image.  This was easy enough to do with a modern editor like Visual Studio Code.  I switched the line feed setting for the file in the editor and it worked!  The setting is even conveniently displayed in the status bar at the bottom of the document:

![](./CodeCRLFSetting.png)

Clicking the setting allows you to quickly switch the line endings from CRLF to LF for the file.  I did this, and voila, it worked!

## Git for Windows Preferred Setting AutoCRLF
Of course I'm putting my Dockerfile into Git so that it can be rebuilt on a build server and by other developers on my team.  My fix above of switching the line feed setting worked great locally, but as soon as I pulled the image down on another Windows machine it had the exact same error again!  This is because the recommended setting for line endings in Git on Windows is autocrlf when you want developers to be able to work cross-platform.  This will store your line endings in git as LF, but will convert them back to crlf when you do a checkout on a Windows machine.

When I did this, it switched the line endings on my bash script back to CRLF, causing the same build problem again!   Of course this happened a few days later, so I had to figure it out all over again..  :-)

## Options for solving
So how do we solve this on a more permanent basis?  There are a couple of options:

### .gitattributes file
Placing a [.gitattributes](https://git-scm.com/book/en/v2/Customizing-Git-Git-Attributes) file in a Git source controlled folder allows you to set Git attributes (like the line feed settings) at the folder or file level.  In my case the file would look something like:

~~~
my-script.sh text eol=lf
~~~

Where my-script.sh is the script I was copying into the Linux image.  The attributes file is setting the line endings to line feeds only.

### Using Dockerfile Run
Another option for resolving this issue is to just take the bash commands that are in the bash script and move them directly into a single RUN command in the Dockerfile.  As an example, I had a bash script with these commands to start sql server in my linux image and then run a database restore:

~~~
( opt/mssql/bin/sqlservr & )  | grep -q "Service Broker manager has started" \
   && opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD} \
      -Q 'RESTORE DATABASE mydb FROM DISK = "/var/opt/mssql/backup/mydb.bak" \ 
      WITH MOVE "mydb_Data" TO "/var/opt/mssql/data/mydb.mdf", \ 
      MOVE "mydb_Index_Data" TO "/var/opt/mssql/data/mydb.ndf", \
      MOVE "mydb_Log" TO "/var/opt/mssql/data/mydb.ldf"'
~~~

I took these commands and added them to my image.  So my image commands went from:
~~~
COPY ./restore-integration-data.sh .

RUN ./restore-integration-data.sh $SA_PASSWORD
~~~
To this:
~~~
RUN ( opt/mssql/bin/sqlservr & )  | grep -q "Service Broker manager has started" \
   && opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P ${SA_PASSWORD} \
      -Q 'RESTORE DATABASE mydb FROM DISK = "/var/opt/mssql/backup/mydb.bak" \ 
      WITH MOVE "mydb_Data" TO "/var/opt/mssql/data/mydb.mdf", \ 
      MOVE "mydb_Index_Data" TO "/var/opt/mssql/data/mydb.ndf", \
      MOVE "mydb_Log" TO "/var/opt/mssql/data/mydb.ldf"'
~~~

This is the solution I ended up using.  As long as the run command is relatively short, this seems easier to understand and less complex than having to deal with an external file and Git attributes.  This solution also has the advantage of not having to deal with the Linux file permissions on the script.