$token = $env:GITHUB_TOKEN
$username = "YOUR_USERNAME"
$repository = "YOUR_REPOSITORY_NAME"

$headers = @{
    Authorization = "token $token"
    Accept        = "application/vnd.github.v3+json"
}

$body = @{
    private = $false
} | ConvertTo-Json

Invoke-RestMethod -Uri "https://api.github.com/repos/$username/$repository" -Method Patch -Headers $headers -Body $body