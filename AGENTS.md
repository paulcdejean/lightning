## Important notes

* Chores must be run in order, not in parallel.
* Whenever tofu plan is run, use lock=false to avoid accidently holding the lock.

## Agent requirements

* Github MCP, for checking latest versions of software
* Opentofu MCP, for checking provider versions.

## Chores

* Web fetch or curl shouldn't be used for chores, the needed MCP servers should be installed. Report if they aren't and exit.
* Do these chores for each folder in the git source tree
* Prompt the user to update opentofu if they're not running the latest version
* Update tofu.tf files to set the required version as the latest version
* Update tofu.tf files so all providers are using the latest version
* If any updates are made, run tofu init -upgrade and tofu plan in all folders, and report if they are not clean plans
* Report on any warnings related to deprecations from the providers
* Update the major fedora version if needed, and report if this is updated
* If the EKS version is lower than the latest supported AWS version, then report
