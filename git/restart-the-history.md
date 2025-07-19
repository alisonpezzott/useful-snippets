```bash
git checkout --orphan new-history
git add -A
git commit -m "Initial commit"  
git branch -D main
git branch -m main
git push -u origin main --force
```
