# IIS ASP.NET Core Hosting Bundle 500.19 Error

> ## TLDR; Re-install the latest hosting bundle;
\
Recently I was upgrading the IIS ASP.NET Core Hosting Bundle to ensure the server had the latest patch release (3.1.8).  Just to keep the server installations clean, I wanted to also remove all the previous versions of the core hosting bundle so that I only had the single required version.  To do this I followed the following process:

- Installed ASP.NET Core Hosting Bundle 3.1.8.
- Removed all previous versions of the hosting bundle and runtimes from the machine.

The uninstalls and installs went smoothly, but when I was done I was receiving a 500 error from my ASP.NET Core application.  Specifically error 500.19.  I was able to see the exact error in the IIS logs.

I'm fairly new to supporting .NET Core in an operational fashion, so I was confused why this was happening. The first thing I did was look at the troubleshooting tips in Microsoft's documentation: [Troubleshoot ASP.NET Core on Azure App Service and IIS](https://docs.microsoft.com/en-us/aspnet/core/test/troubleshoot-azure-iis?view=aspnetcore-3.1) 

There was a lot of really good information here about troubleshooting issues with application starts in the IIS ASP.NET Core Module, so I tried several of the techniques.

First I checked all the usual places for information as to why this was happening.  I checked the event viewer and the custom error logging in the app and there were no entries at all.  

I then tried enabling the core module's stdout debugging log:
```xml
<aspNetCore processPath="dotnet"
      arguments=".\MyApp.dll"
      stdoutLogEnabled="true"
      stdoutLogFile=".\logs\stdout"
      hostingModel="InProcess">
```

But even after restarting the application pool there was no stdout log files generated!

At first I thought maybe there was a dependency in my application that the new runtime was not able to load.  So I did some research and came to the conclusion that the latest patch version of this runtime should be fully compatible with all of my dependent Nuget packages.  I'd only upgraded to a new patch version of the runtime (not even a minor version upgrade).  

To test this theory I logged onto the console of the machine directly and ran the executable for my ASP.NET Core application.  It loaded and ran with fine with no errors to the console. So there were no runtime issues with my application.

Then I found this part of the documentation which details [how the ASP.NET Core module is added to the IIS applicationhost.config file and where the module is located](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/aspnet-core-module?view=aspnetcore-3.1#module-schema-and-configuration-file-locations)

I could see that the module was no longer registered in the applicationhost.config.  This is why the application could not load and why I wasn't seeing any errors from my application or even the .NET Core hosting module.  It wasn't even loading!  

A re-install of the latest Core Hosting bundle completely resolved the issue and I could see that the module was setup correctly in the applicationhost.config file.

I this issue was related to the fact that I ran the uninstalls after the installs.  Since the uninstalls of the old hosting bundles were performed after the installation of the latest version, the uninstall had removed the module setup in the applicationhost.config.  

> **Important safety tip:**  If you're cleaning up old versions of the .NET Core hosting bundle, make sure to do an install of the latest version *after* you've uninstalled the older versions.