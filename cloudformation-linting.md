
# AWS CloudFormation Linting in Team City and GitHub

> TLDR; Use cfn-lint in your build pipeline to ensure the quality of AWS CloudFormation templates as part of your code build and deployment process.

It's important to ensure the quality of **all** the code artifacts your team is creating.  Even if it's configuration as code.   We have been using CloudFormation templates for provisioning our AWS environments.  There's a great Python package provided by AWS called [cfn-lint](https://github.com/aws-cloudformation/cfn-lint) that you can use to lint your CloudFormation templates and ensure they are syntactically correct and well-formed.  

We integrated this tool into our build pipeline in Team City and GitHub by adding a PowerShell build step:

```powershell
$yamlErrors = cfn-lint **/*.yaml -i W

if ($yamlErrors) 
{
    $yamlErrors | Foreach { $errorString = $errorString + "$($_) `r`n"}
    write-error $errorString
}
```

This runs cfn-lint against all files ending with .yaml in any subdirectories of the current folder.  This works well since our CloudFormation templates are currently under the same root folder.  If you have CloudFormation templates distributed differently you may need different directory and glob patterns.

> The -i W tells cfn-lint to ignore warnings so that only errors are reported in the build pipeline.  

### Team City VCS Trigger
In our Team City  build we have a VCS build trigger that watches for new branches or commits to existing branches and kicks off the build task to lint the templates.   You can even configure this build trigger to only run when the file matches a given expression and only run it when there are changes to CloudFormation templates.

### Team City Commit Status Publisher
Then we use a commit status publisher build feature to report the results of the build back to GitHub.  These show up in GitHub as checks and can even be used as branch constraints.  Allowing you to prevent merging into the main branch without a successful run of the build.

