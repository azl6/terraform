We can create a new workspace with `t workspace new WORKSPACENAME`

We can select a new workspace with `t workspace select WORKSPACENAME`

We can delete a workspace with `t workspace delete WORKSPACENAME`

We can list our workspaces with `t workspace list`

When we enable workspaces, the variable terraform.workspace becomes available to be used. It will return the current workspace's name and it's frequently used alongside with the lookup() function. This usage allows us to provide different values to parameters depending on our current workspace

Workspaces state files (.tfstate) are managed under the specific's workspace folder, inside of the **terraform.tfstate.d** folder

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

To update the provider's configuration, such as backend or any other block/parameter inside of the provider configuration, we can use the `-reconfigure` flag alongside with `t init`

It's possible to have many declared providers using **aliases**

```bash
provider "aws" {
  region = "sa-east-1"
  alias = "br1" #########
}                       #
                        #
provider "aws" {        #
  region = "us-west-1"  #
  alias = "us1" ######### Using aliases!
}                       #
                        #
provider "aws" {        #
  region = "us-east-1"  #
  alias = "us2" #########
}
```

When declaring a resource, we simply need to choose which provider to use

```bash
resource "aws_instance" "MyEC2" {
    ami = "AMI_DA_REGI??O_DO_ALIAS"
    instance_type = "t2.micro"
    provider = "CHOSEN_PROVIDER_NAME"
}
```

`t refresh` considers that the current-state of the infrastructure is the correct one. Therefore, it will update your **.tfstate** file to match the current-state of the infrastructure.

`t output OUTPUTNAME` will output a declared output without needing to run `t apply`

We can use a `remote-exec` provisioner to execute commands on remote instances when they first boot up (bootstrapping). We start by defining a `connection` block to specicy the connection type (in this case, SSH)

```bash
  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = self.public_ip
  }
```

Then, we declare a `provisioner` block of type `remote-exec`, and declare the commands to be run inside of the `inline` block

```bash
provisioner "remote-exec" {

    inline = [
      "touch /tmp/whenDidIFirstGotUp.txt",
      "echo \"this instance got first up at $(date)\" >> /tmp/whenDidIFirstGotUp.txt"
    ]
  }
```

The provisioner `local-exec` works the same way, however, it is to run commands **in my local machine**. Besides that, we use the `command` key word instead of the `inline` block that was used on `remote-exec`

```bash
  provisioner "local-exec" {

    command = "touch whenIFirstBooted.txt && echo \"My instance first booted up on $(date)\" >> whenIFirstBooted.txt"
  }
```

The `TF_LOG` environment variable can be used when we want logs when executing `t plan` and `t apply`

The `TF_LOG_PATH` environment variable can be used when we want **to direct logs to a file** when executing `t plan` and `t apply`

Locals can't reference themselves, directly or indirectly

When someone is running `t apply`, the `terraform.lock.hcl` file is created. This lock is to prevent that any other person tries to perform write operations while the lock is owned by someone else. We can force the unlock by running `terraform force-unlock LOCKID

Sentinel is a policy-as-code tool, to verify whether resources are "compliant" when we're launching them with Terraform. We can add rules such as "every security-group shouldn't allow SSH from 0.0.0.0/0", etc...

`t graph` is a command that can be used to generate a DOT file, which can be thrown in 3rd party softwares to analyze the launched infrastructure

The prefix **TF_VAR_** can be used to provide values to variables, e.g: 

```bash
export TF_VAR_dev="t2.micro"
export TF_VAR_prod="t2.large"
```

If we're using no backend and want to migrate to a new one (e.g S3), Terraform gives us the option to migrate our **.tfstate** file to it

We can provide `t init` configurations through the CLI when running it

Failing provisioners (local-exec or remote-exec) will cause `t apply` to fail. We can change this behaviour with the **on_failure** flag, setting it to either **continue** or **fail** (default) depending on our requirement

By default, provisioners are **creation-time provisioners**, which means they will run once the instance starts. If we need to run a script once an instance dies, that's a **deletion-time provisioner**. These take the **when** flag setted to **destroy**

By default, the **.tfvars** searched by Terraform is named **terraform.tfvars**. If we need to use a custom name, such as **custom.tfvars**, we can use the flag **-var-file=VARFILENAME** to specify it

The `required_providers` block (inside the `terraform` block) will inform to TF which provider it will use, so it can download the needed files

The `required_version` parameter references the required Terraform's version. When the configurations are applied, Terraform will store the constraints in the **.tfstate** file, and in case someone tries to apply something out of the defined constraint, Terraform will throw an error

To fetch values from a map, we use the following syntax: var.myVar["key"]

When fetching modules from git repositories, it will be pulled from the main/master branch by default. If we need to change this behaviour, we can use the ref argument

For **implicit dependency**, Terraform can identify in which order the resources should be created. For **explicit dependency**, we explicitly tell Terraform that a resource depends on another with the **depends_on** keyword, which takes a list

We can use a data-source to fetch the latest AMI in each region, for example

The `terraform console` command can be used to start a TF program that takes inputs

Difference 0.11 and 0.12: ???${var.instance_type}??? ??? 0.11, var.instance_type ??? 0.12. In 0.11 it was more verbose.

Github is not a supported backend in Terraform.

With taint, the resource will be re-created on next terraform apply operation.
