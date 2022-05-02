import-module pester

Describe 'Hello-World' {
    It 'Given no parameters, it writes output to host' {
        Mock Write-Host {}

        hello-world

        Assert-MockCalled Write-Host -Exactly 1 -Scope It -ParameterFilter { $Object -eq "Hello world" }
    }
}