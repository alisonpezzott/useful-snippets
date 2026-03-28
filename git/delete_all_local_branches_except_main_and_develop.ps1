git branch | Where-Object { $_ -notmatch '^\*' -and $_ -notmatch '\b(main|develop)\b' } | ForEach-Object { git branch -D $_.Trim() }
