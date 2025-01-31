#### Github Workflow

Below are the steps each team member is expected to follow when making changes to the main repository. 

1. Each member should have their own fork of the main repository. Create a fork with the button at 
the upper right corner of the main repo's screen. 
2. Clone Fork *git clone git@github.com:user_name/repo-name.git*
3. Add remotes (upstream)
	- *git remote add upstream git@github.com:main_user_name/repo-name.git*
 - To check if added successfully:
 - - *git remote -v* 


4. Sync with main
- git fetch upstream main 
- git rebase upstream/main
- git log To check that most recent updates are at the top.
- git push -f origin master To push synced main branch to your personal fork.

5. Whenever working on a new feature or change create a new feature branch. 
 - git checkout -b new-branch-name
 - git branch To check you've successfully created the new branch. 

6. Make changes to existing codebase on your branch. Stage changes for commit by 'add'.
 - git add file-name
 - OR git add -A To add all changes made to staging area.

7. Check that changes are in staging area.
 - git status

8. Commit staged changes with message. 
 - git commit -m "Your commit message"

9. Sync the feature branch with main before pushing. 
 -  While on feature branch:
 - git fetch upstream main 
 - git rebase upstream/main
 - git log Verify that your newest changes are on top of previous commits in main. 

10. Push to main.
 + a. If a PR has not been opened yet: 
	- git push -u origin branch-name
 	- git branch -vv To check if remote tracking has been set up.
 + b. If commiting to existing PR:
	- git push -f To push synced feature branch to your fork. 

11. Create Pull Request (PR).
 - Go to the main repo website from your browser. When you refresh you should receive a pop-up to create a new PR. 
 - Request a review from team-mates and communicate before approving your changes and merging into main. 

12. Ensure all team-mates are OK with new code and select 'Squash and Merge' to add your code changes into main.

13. Delete your local and remote branches that were used for the changes. 

Delete from local branch (ensure you are on main branch and *not* on feature branch):
 - git branch -D branch-name

Delete from public repo/remote
 - git push --delete origin branch-name

14. Repeat process whenever new changes to main are made. 
