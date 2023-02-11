We can create a new workspace with `t workspace new WORKSPACENAME`

We can select a new workspace with `t workspace select WORKSPACENAME`

We can delete a workspace with `t workspace delete WORKSPACENAME`

We can list our workspaces with `t workspace list`

When we enable workspaces, the variable terraform.workspace becomes available to be used. It will return the current workspace's name and it's frequently used alongside with the lookup() function. This usage allows us to provide different values to parameters depending on our current workspace

Workspaces state files (.tfstate) are managed under the specific's workspace folder, inside of the ?**terraform.tfstate.d** folder

Root-module is the module that has a "module" block, calling a Child-module

Child-module is the declaration of the resource that is going to be called

We can reference a module's output by outputting the desired value through an output block and using the following syntax: module.MODULENAME.OUTPUTNAME

Providers are not needed when using only locals and outputs

Variables with undefined values (like below) don't result in an error. The user will be prompted to provide its value when running `t plan` or `t apply`

```bash
variable "myVar" {}
```

We can list the resources in our state file with `t state list`

We can change the name of a resource in our state file without having to re-create it with `t state mv OLDRESOURCENAME NEWRESOURCENAME`

We can remove resources from our state file with `t state rm RESOURCENAME`

We can show details about a given resource in a state file with `t state show`

We can generate a state file from already-running infrastructure with the `t import DEFINEDINFRASTRUCUTREFILE RESOURCEIDINTHECLOUD` command. The `t import` command **does not generate a manifest for our resources. It simply creates a state file for them**

We can use `t plan` with the `-destroy` flag to check which resources will be destroyed

We can use `t plan` with the `-target` flag to specify a target-file to only refresh its contents, to avoid overloading

We can use `t plan` with the `-refresh=false` flag to not refresh our current infrastructure state. We can even use this flag with the `-target` flag
