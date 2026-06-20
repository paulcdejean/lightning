Your current goal is to increase the capabilities of your jail to the point where you can run chores.

In order to do this, this is the pattern you'll follow.

1. Modify terraform files to increase your capabilities. For example to add a read only IAM key to .env
2. Commit the changes. Also write a handoff.md file for the next iteration, as your memory won't persist.
3. If I approve the changes, I'll apply the infrastructure with tofu and my admin  credentials
4. If I decline the changes, my notes will be in feedback.md
5. If I decline the changes, the commit may or may not be reverted. If it is not reverted changes to the container will go through, but tofu will not be applied
6. After that I'll recreate the containerized environment from the jail.containerfile
7. In this way each iteration will have increased capabilities over the previous iteration
8. Eventually things will be set up sufficently to run the chores
