git checkout main

# local
git branch | Where-Object { $_ -notmatch 'main' } | ForEach-Object { git branch -D $_.Trim() }

# remote
git branch -r | Where-Object { $_ -notmatch 'origin/main' } | ForEach-Object { git push origin --delete $_.Trim().Replace('origin/', '') }