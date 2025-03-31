$envVars = Get-Content "C:\temp\env_vars.json" | ConvertFrom-Json
foreach ($var in $envVars.PSObject.Properties) { [System.Environment]::SetEnvironmentVariable($var.Name, $var.Value, "Process") }