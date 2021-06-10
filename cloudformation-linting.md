

```powershell
$jsonErrors = cfn-lint **/*.json -i W
$yamlErrors = cfn-lint **/*.yaml -i W

if ($jsonErrors -or $yamlErrors) 
{
	$jsonErrors | Foreach { $errorString = $errorString + "$($_) `r`n"}
    $yamlErrors | Foreach { $errorString = $errorString + "$($_) `r`n"}
    
    write-error $errorString
}
```