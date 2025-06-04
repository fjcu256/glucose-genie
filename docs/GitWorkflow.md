# Github Workflow

Below are the steps each team member is expected to follow when making changes to the main repository. 

## Getting Started

Each member should have a fork of the main `glucose-genie` repository.

### 1. Create a fork using the button at 
the upper right corner of the browser version of the main repo's home screen [home screen](https://github.com/fjcu256/glucose-genie). 

### 2. Clone Fork 

Create a new directory on your Mac where you will be working on the code locally. Go to the folder and clone your fork. 

`git clone git@github.com:fjcu256/glucose-genie.git`

### 3. Add remotes (upstream)
`git remote add upstream git@github.com:user_name/repo-name.git`

To check if added successfully: `git remote -v`

## Continuous Development
The following steps should always be taken when adding new code to the main branch. We will follow a continous PR workflow where all changes will be made locally on a new feature branch ontop the existing main branch. When changes are made the developer will create a PR and request a review from the team. Once the PR is approved, the PR can be merged into the main branch. 

### 1. Sync with main
Synchronizing the fork with the main branch should always be done before creating a new feature branch. 

```
git fetch upstream main
git rebase upstream/main
```
To check that the most recent updates are at the top:

 `git log` 

To push the synced main branch to your origin: 

`git push -f origin main`

### 2. Create new feature branch 
Whenever working on a new feature or code change create a new feature branch. 
```
 git checkout -b <new-branch-name>
 ```
 To check the new branch was successfully created: `git branch`

### 3. Add changes to staging
Make changes to existing codebase on your branch. 
Add changes to the staging area in order to commit:
`git add <file_name>` or `git add -A` to add all changes to the staging area. 

To check that changes are in the staging area:

`git status`

### 4. Commit staged changes with message
After changes are in staging you can commit the change and add a commit message.
```
git commit -m "Your commit message"
```

### 5. Sync with main before pushing
Sync the feature branch with the main branch before pushing to ensure that all of your new changes are ontop of the existing codebase and any new changes from other contributors that may have been made while working on your own feature. 

From the feature branch:
```
git fetch upstream main 
git rebase upstream/main
```
Use `git log` to verify that your newest changes are ontop of the newest commits in the main branch. 

### 6. Push to main

#### If a PR has not been created:

``` 
git push -u origin <branch-name>
```

Use `git branch -vv` to check that remote tracking has been set up.

#### If commiting to an existing PR:

```
git push origin <branch-name>
```
Depending on whether new changes have been made while the developer was working on the feature branch, a force push may be required. 

```
 git push -f origin <branch-name>
```

### 7. Create Pull Request (PR)
After the developer pushes new changes on a new feature branch to their remote a PR needs to be made and opened for review before the new changes can be commited in the main branch. 
 - Go to the main repo website from your browser. After refreshing, a pop-up will appear to create a new PR. 
 - Request a review from teammates to look over the code changes, leave comments and suggestions for any changes that need to be made before merging. 
 - Once the PR is approved, **Squash and Merge** the changes into the main branch.

### 8. Delete branches
Delete your local and remote branches that were used for the new changes. 

Delete from local branch (ensure you are on main branch and *not* on feature branch):
```
git branch -D <branch-name>
```
Delete from public repo/remote:
```
git push --delete origin <branch-name>
```
### 9. Repeat steps 1-8 whenever new changes to main are made. 

## Approving a PR
Our team requires at least one other person to pull the PR, build the project and check the behavior that was implemented in addition to a code review any time changes to code are made. 

In order to pull and test another PR locally:
1. Go to the PR in GitHub and note the **ID** of the PR to checkout.
Example:
- New stuff added is in a PR: `#22`
- The **ID** is `22`
2. Pull the PR locally. 
`$git fetch origin pull/<ID>/head:BRANCH-NAME`

`BRANCH_NAME` is the name of the branch you are creating locally to pull the PR into. 

3. Switch into the PR
`$git switch BRANCH-NAME`

4. Attempt a build in Xcode and ensure the functionality of the application is expected.  
