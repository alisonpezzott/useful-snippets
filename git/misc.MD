### Git Bash  

|Command|Action|
|:---|:---|
|`git init`|Start the local repo|
|`git add <file>`|Add the file to stage|  
|`git add .`|Àdd all the filtes to stage|
|`git commit -m "message"`|Put current staged chages to the HEAD|   
|`git branch`|List all local branches|
|`git branch -a`|List all branhches, remotes inclusive|
|`git checkout -b <branch>`|Create and switch to a new local branch|
|`git log`|Show the history of commits|
|`git log --oneline`|Show the summarized history of commits|  
|`git remote -v`|Show the remote repo vinculed to the local repo|  
|`git remote add origin <url>`|Link the local repo with the remote repo|  
|`git push`|Sync the remote repo with the local repo|
|`git status`|Check the status of repo
|`git merge <branch>`|Merge the branch into current branch|
|`git pull`|Update local repo with the remote|
|`git clone <url>`|Clone remote into local|  
|`git push origin --delete <branch>`|Delete the remote branch|  
|`git branch -D <branch>`|Delete the local branch|
|`git pull origin <branch>`|Sync the current local branch with the remote branch|  
|`git config --global user.name`|config the local username|  
|`git config --global user.email`|Config the local email|  

### GitHub CLI  

|Command|Action|
|:---|:---|
|`gh repo create <repo> --public`|Create a new repo|  
|`gh repo delete <repo>`|Delete the repo|  
|`gh auth refresh -h github.com -s delete_repo`|Define the scope to allow delete|
