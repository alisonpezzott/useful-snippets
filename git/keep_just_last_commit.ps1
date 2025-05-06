git checkout main
git reset --soft $(git rev-list --max-parents=0 HEAD)
git commit -m "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git push --force