## Chores

* Prompt the user to update opentofu if they're not running the latest version
* Update tofu.tf files to set the required version as the latest version
* Update tofu.tf files so all providers are using the latest version
* If any updates are made, run tofu init -upgrade and tofu plan in all folders, and report if they are not clean plans
* Report on any warnings related to deprecations from the providers
