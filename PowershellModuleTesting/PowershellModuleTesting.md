When you're testing PowerShell modules, importing, referencing,  and removing modules can be a little bit tricky. These are some things that I've found to make my tests more reliable.

# Use $PSScriptRoot Environment Variable
Modules should be imported using the $PSSCRIPTROOT environment variable. This environment variable allows the script path to be relative so that the test will execute regardless of the path where it is executed. If you use a normal relative reference (./). the root folder would be the location from which the test session started. With $PSSSRIPTROOT makes the reference relative from the location of the script. This allows Pester to be invoked from any location and still execute the tests correctly.

Example
```powershell
import-module $PSSCRIPTROOT/Copy-DockerImage.psm1
```


# Force Module Loading
For local module imports be sure to -Force the import so that the test will always load the latest module and not a cached version from the previous test execution.

By default, if the module is already imported into the context then PowerShell will not re-import it. This is problematic because if the module file logic has changed, it will *not* be reloaded for the test.

Example
```powershell
import-module $PSSCRIPTROOT/Copy-DockerImage.psm1
```


# Use BeforeAll to Import Modules
Import modules for testing in BeforeAll blocks to ensure the modules are loaded as part of the test execution and to prevent conflicts between tests. When the logic is outside the context of Pester sections it is executed as the files are loaded during discovery. This means all this logic is executed before any of the tests are run. To prevent this, be sure to wrap all setup code, including module importing, in BeforeAll statements.

Example
```powershell
BeforeAll {
    Import-Module $PSScriptRoot/Invoke-Something.psm1 -Force
}
```
 
# Use AfterAll to Remove Modules
To ensure that imported module dependencies do not conflict between tests make sure to remove any imported modules after the test.
```powershell
AfterAll {
    Remove-Module Invoke-Something -Force
}
```

Following these rules should help ensure the reliability of your Pester Module test. Happy Testing!