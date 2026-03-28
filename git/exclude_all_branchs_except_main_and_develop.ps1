git checkout main

# local
git branch | Where-Object { $_ -notmatch '^\*' -and $_ -notmatch '\b(main|develop)\b' } | ForEach-Object { git branch -D $_.Trim() }

# remote
git branch -r | Where-Object { $_ -notmatch '^\*' -and $_ -notmatch '\b(origin/main|origin/develop)\b' } | ForEach-Object { git push origin --delete $_.Trim().Replace('origin/', '') }
