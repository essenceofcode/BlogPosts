# Debugging Powershell Modules in VS Code

> TLDR; Use a .ps1 script or Pester test to force the load of the local module file and execute the function.

## Visual Studio Code Powershell Debugging
Microsoft has a created a great [Powershell extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell) for VS Code that makes it easy to work with Powershell files. Once the plugin is installed you get intellisense, syntax highlighting, and even visual debugging for files that have a Powershell extension. This debugger can be easily started by pressing F5 when you're in a Powershell script. Stopping execution on a particular line is as easy as setting a breakpoint by clicking next to a line number.

Some great documentation on using this extension and debugging Powershell in VS Code can be found on the Microsoft Scripting Dev Blog:

https://devblogs.microsoft.com/scripting/debugging-powershell-script-in-visual-studio-code-part-1/

https://devblogs.microsoft.com/scripting/debugging-powershell-script-in-visual-studio-code-part-2/

## Powershell Modules
The official definition of Powershell modules from Microsoft:
> A module is a package that contains PowerShell members, such as cmdlets, providers, functions, workflows, variables, and aliases. The members of this package can be implemented in a PowerShell script, a compiled DLL, or a combination of both. These files are usually grouped together in a single directory.

Powershell modules are a powerful way of sharing useful functionality with others. Instead of copying and running scripts you can use Nuget to install and import modules and pull them from package repositories. If you're writing a script or commandlet to share with others, consider using a module.

## Debugging
One of the tricky parts of working with modules is interactively debugging them. Since they are just functions in a module file, it's not obvious how to invoke them to allow the interactive debugger in VS Code to stop on breakpoints and allow step-through of the script. You can't just execute a module from the command line like you can with a script. Even if it's a local .psm1 file it is necessary to import the file. 

Let's start with a simple example module file:
### hello-world.psm1
```powershell
function Hello-World {

    Write-Host 'Hello world'
}
```

In the VS Code PowerShell integrated console you can import the module:
```powershell
PS C:\github\BlogPosts\PowershellModuleDebugging> import-module .\hello-world.psm1
```
If you set a break point on the Write-Host line of this module and try to run the debugger (F5) you receive this helpful error message:
> Cannot run a document in the middle of a pipeline.

This message is basically because the debugger can't find an entry point to execute the function in the module. You could add this call to the end of the module and it would have an entry point:

### hello-world.psm1
```powershell
function Hello-World {

    Write-Host 'Hello world'
}

Hello-World
```

This works and allows you to debug the module, but now this function will be invoked every time the module is imported. This is not the behavior we would like. We really want the execution and module loading to be separate.

Another problem you may have encountered here is that just adding this Hello-World line to the file above still resulted in the pipeline error message when you pressed F5. This is because the changes you made to the module file have not been imported into the session. You can solve this by re-importing the local module file into the session. However, PowerShell is smart and notices you have previously imported this module with the same version number and will not re-import the new file. So it's necessary to force the module re-load:
```powershell
PS C:\github\BlogPosts\PowershellModuleDebugging>  import-module .\hello-world.psm1 -force
```
Now the new version of the module is loaded into the session and F5 results in running the module. Actually the module executes as you as you re-import it with this statement since you have an entry point to the function on the last line of the module!

If you don't want to have the function execute on module import and you don't want to pollute the module file with an entry point, you could remove the last line of the function call and load the module and kick off the debugger from the integrated console:
```powershell
PS C:\github\BlogPosts\PowershellModuleDebugging>  import-module .\hello-world.psm1 -force

PS C:\github\BlogPosts\PowershellModuleDebugging> hello-world       

[DBG]: PS C:\github\BlogPosts\PowershellModuleDebugging>
Hello world
```
You'll notice that if you set a breakpoint and executed the module in the integrated console that VS Code will have stopped at the breakpoint.  Yay!

However, it does get old typing the force local import-module command and running the function every time you want to test it. This would be especially true if the function had parameters. There are two approaches you can use to make your PowerShell development workflow a little easier:

## Use a Script
One approach to making this a little easier is to add a script file that imports the module and tests it out:
### hello-world-debug.ps1
```powershell
import-module ./hello-world.psm1 -Force

Hello-World
``` 
Now you can run this and any interactive breakpoints set in VS Code for the hello-world module will break the execution and allow for interactive debugging. Every time you want to execute the latest version of the module function you can now just run the script file. This makes it easy to debug and keeps the module clean with only the module functions and no explicit entry point.

## Write Tests
PowerShell scripts and modules deserve good tests just like any other code artifact. The tests are a great way to invoke functions and debug modules. The Pester framework Here's an example of a simple Pester test

### hello-world-test.ps1
```powershell
import-module ./hello-world.psm1 -force
import-module pester

Describe 'Hello-World' {
    It 'Given no parameters, it writes output to host' {
        Mock Write-Host {}

        hello-world

        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "Hello world" }
    }
}
```
Hopefully one of these methods provides a good way to interactively debug PowerShell Modules. 

Happy debugging!