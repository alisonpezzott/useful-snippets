git checkout --orphan new-history
git add -A
git commit -m "Beta version"  
git branch -D main
git branch -m main
git push -u origin main --force
