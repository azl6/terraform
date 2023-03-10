# To review next time

We can have multiple provider instances with the help of **aliases**

Basic commands: terraform refresh, terraform output

Review provisioners (**local-exec** and **remote-exec**). They are **inside the resource block**

Review **TF_LOG** and **TF_LOG_PATH** environment variables. Also, review its options (TRACE, DEBUG, INFO, WARN and ERROR)

A local cannot refer to itself or to variables that directly or indirectly refer to it (There can't be a cycle)

Understand that the sensible flag stops terraform apply from printing its value. However, the value is still written to the .tfstate file

Review functions, especially lookup and element

If the backend supports, TF will lock the state for write operations when someone is already performing an action on it. Terraform also have a way to force unlock. Review this, please

Sentinel is a policy-as-code tool to verify required things, e.g If the launched resource has tags, or if the bucket has encryption enabled

Even if we use the sensible=true flag, the output in the tfstate file won't be encrypted. So, the tfstate file itself should be treated as sensible data. TF Cloud encryps tfstate files, and use TLS for encryption in-flight. S3 as a backend also has this option.

For TF Cloud, when using full-remote operations, commands like t plan can be executed in TF Cloud, with its output streamed to the local terminal

terraform graph is used to generate a DOT file, that can be converted to an image to represent our deployment

Provide variables with the TF_VAR_ prefix

When configuring a diff backend (no backend > backend) for the first time, TF gives us the option to migrate the .tfstate file to the new backend

We don't need to provide every single configuration on the backend configuration. We can provide it on initialization with t init -option1 -option2 -optionn...

By default, provisioners that fail will cause terraform apply to fail. We can use the on_failure={continue,fail} to change this behaviour

Review creation-time provisioners and deletion-time provisioners (using the when flag)

Provide a custom-named .tfvars file with the -var-file= flag on terraform apply

Check the required_providers block

Check the required_version variable, which references Terraform's version!

To fetch values from a map, we use the following syntax: var.varName["key"]

When getting modules from a git repo, by default, the default branch will be used. To change this behaviour, we can use the ref argument (refer to item 55.2)

Explicit resource dependency with the depends_on parameter. It takes a list.

Data source to get the latest update of AMI, for example

Remember the zipmap function, which builds a map out of two lists

The terraform console command provides an interactive console for evaluating expressions.

Difference 0.11 and 0.12 ???${var.instance_type}??? ??? 0.11 var.instance_type ??? 0.12

GitHub is not the supported backend type in Terraform.

terraform refresh considers the current-state to be the "correct", and updates the state file to match it

# Link para a documenta????o para a AWS

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

# Link para o Terraform Registry

https://registry.terraform.io/

# Baixando dependencies de um provider com o terraform init

A execu????o do comando abaixo deve ser feita **na mesma pasta** onde seu arquivo **.tf** se encontra. 

O Terraform ler?? seu arquivo e baixar?? as dependencies do provider definido no manifesto.

```bash
terraform init
```

# Mostrando recursos a serem criados e retornados ao desired-state com o terraform plan

Esse comando nos mostrar?? o que ser?? criado com um c??digo **.tf**

```bash
terraform plan
```

Outra funcionalidade sua ?? a de mostrar quando o **desired-state** da infraestrutura (configura????es definidas no **.tf**) encontra-se diferente do **current-state** (devido a alguma altera????o manual, etc...). Nesse caso, com o **terraform plan**, o Terraform nos avisar?? que eles est??o diferentes (porque no background desse comando, o `terraform refresh tamb??m ?? rodado`), e mostrar?? o que precisa ser alterado para que tudo seja retornado ao **desired-state**. Tais mudan??as s?? ser??o "commitadas" com o **terraform apply**.

# Criando recursos o terraform apply

O **terraform apply** aplica e cria os recursos descritos no manifesto **.tf**, al??m de criar/atualizar o **tfstate** file

```bash
terraform apply
```

# Exemplo simpleEc2 e a cria????o simples de uma inst??ncia EC2

Nesse caso, o **Access Key ID** e **Secret Access Key** j?? existem como vari??veis de ambiente, inicializadas no **~/.bashrc**

```bash
# "aws_instance" se refere a cria????o de uma inst??ncia EC2
# "myec2" se refere ao nome da inst??ncia

provider "aws" {
  region     = "sa-east-1"
}

resource "aws_instance" "myec2" {
   ami = "ami-0b0d54b52c62864d6"
   instance_type = "t2.micro"
}
```

# Deletando recursos com o terraform destroy

Para deletar todos os recursos criados em um diret??rio (estando nele):

```bash
terraform destroy
```

Caso desejemos selecionar o recurso a ser deletado, podemos usar a flag **-target**

```bash
terraform destroy -target aws_instance.myec2
```

**Importante:** O valor do target refere-se ao nome dado ao **resource** em sua cria????o, e.g imagem abaixo:

![image](https://user-images.githubusercontent.com/80921933/214487650-f86e2fba-d83f-4848-93f7-2f81aeb04b31.png)

# Travando a vers??o dos plugins do provider

Alterar abruptamente a vers??o do provider pode nos trazer problemas. 

Para evitar isso, podemos "travar" a vers??o do nosso provider em uma espec??fica (ou em um range espec??fico), seguindo as seguintes regras:

![image](https://user-images.githubusercontent.com/80921933/214776718-6a3b062b-36e3-4090-87d0-1ca17ae741c1.png)

Tais valores devem ser fornecidos no campo a seguir:

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.51.0" ############## Aqui!
    }
  }
}

provider "aws" {}
```

Ao executar `terraform init`, o arquivo `.terraform.lock.hcl` ser?? criado, com as limita????es fornecidas no manifesto.

Ao alterar a vers??o no manifesto para uma vers??o fora da constraint informada no primeiro, **n??o teremos sucesso na execu????o do terraform init**, porque o arquivo de lock nos bloqueia de faz??-lo. Para executarmos `terraform init` com sucesso ap??s "violarmos" uma constraint, usamos a flag **-upgrade**:

```bash
terraform init -upgrade
```
# Exemplo simpleS3Bucket e a utiliza????o dos outputs

Os outputs podem ser utilizados para printarem atributos dos recursos criados. Nesse exemplo, printei o **arn** e **regi??o** do bucket criado referenciando-o pelo seu nome (aws_s3_bucket.myBucket.\<ATRIBUTO>). **Caso nenhum \<ATRIBUTO> seja fornecido, tudo ser?? printado!**

Atributos que podem ser usados como output podem ser encontrados na p??gina do recurso (aws_instance, aws_s3_bucket, etc...),na se????o **Argument Reference** como no seguinte link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#argument-reference

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_s3_bucket" "myBucket" { # Definindo um S3 Bucket
  bucket = "azl6-terraform-bucket"
}

output "bucket_region" { # Printando a regi??o do bucket no output
  value = aws_s3_bucket.myBucket.region
}

output "bucket_arn" { # Printando o arn do bucket no output
  value = aws_s3_bucket.myBucket.arn
}
```

Output:

![image](https://user-images.githubusercontent.com/80921933/215355986-82f52108-b51a-4457-ba49-88011cc4583f.png)

# Exemplo ec2IPWhitelistedOnSG para criar um SG que libera inbound-rule para o IP de uma EC2 tamb??m criada

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "myEc2" {
    ami = "ami-0b0d54b52c62864d6"
    instance_type = "t2.micro"
}

resource "aws_security_group" "mySG" {
  name = "terraform-sg"

  ingress { # Defini????o das inbount rules
    from_port = 80 # Referenciei o IP gerado da EC2 acima
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.myEc2.public_ip}/32"]
  }
}

output "EC2_IP" {
  value = aws_instance.myEc2.public_ip
}

output "SG_VPC_ID" {
  value = aws_security_group.mySG.vpc_id
}
```

# Exemplo usingVariables para referenciar vari??veis definidas em outros arquivos

?? poss??vel referenciar vari??veis definidas em outros arquivos.

Nesse exemplo, o arquivo `variables.tf` serve de origem para as vari??veis.

```bash
variable "customIpCIDR" {
    default = "192.168.0.0/24"
}
```

As vari??veis s??o usadas no arquivo `usingVariables.tf`

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
    region = "sa-east-1"
}

resource "aws_security_group" "mySg" {
    
    ingress {
        description      = "Allow SSH into the instance from custom var IP"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [var.customIpCIDR] # Referenciando IP do variables.tf
    }

        ingress {
        description      = "Allow HTTP into the instance from custom var IP"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = [var.customIpCIDR] # Referenciando IP do variables.tf
    }

        ingress {
        description      = "Allow HTTPS into the instance from custom var IP"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = [var.customIpCIDR] # Referenciando IP do variables.tf
    }

}

output "SG_VPC_ID" {
    value = aws_security_group.mySg.vpc_id
}
```

# Formas de explicitar valores de vari??veis

Se nenhuma vari??vel for fornecida explicitamente, a **default** (definida no bloco variable) ser?? usada.

?? poss??vel especificar vari??veis de diferentes formas:

**1. Flag -var no terraform plan**

  Ao executar `terraform plan`, podemos informar a flag **-var \<VAR>=\<VALUE>**

  ```bash
  terraform plan -var "myvar=VALUE"
  ```
**2. Arquivo terraform.tfvars**

  Podemos tamb??m especificar vari??veis dentro do arquivo **terraform.tfvars**. Essas vari??veis ter??o prioridade sobre a **default** definida em um bloco **variable**. ?? comum utilizar um arquivo para as vari??veis, e popular os seus respectivos valores com o arquivo **terraform.tfvars**

**3. Especificando um arquivo de vari??vel cujo nome difere de terraform.tfvars**

  ?? poss??vel faz??-lo, especificando a flag -var-file=\<FILE> no momento da execu????o do `terraform plan`

  ```bash
  terraform plan -var-file=<MY_FILE>
  ```

**4. Usando environment-variables com o prefixo TF_VAR**

  Basta definir uma env variable com o prefixo TF_VAR_, e o Terraform a utilizar??

  ```bash
  export TF_VAR_INSTANCE_TYPE="t2.micro"
  ```

# Informa????es sobre vari??veis

Em um bloco **variable**, ?? poss??vel especificar explicitamente tipos para as vari??veis:

```bash
variable "myvar"{
  type = <string,number,list,map>
}
``` 

Para referenciar itens em **mapas**, basta usar sua chave.

Para referenciar itens em **lists**, basta usar a posi????o do item

# Provisionando mais de um recurso com o count

Para provisionar duas inst??ncias EC2, podemos repedir seu bloco de cria????o duas vezes. Entretanto, ?? melhor usar a vari??vel **count** para faz??-lo.

```bash
resource "aws_instance" "myec2" {
   ami = "ami-0b0d54b52c62864d6"
   instance_type = "t2.micro"
   count = 2
}
```

# Utilizando o count.index para pegar o n??mero da itera????o feita

Quando utilizamos **count** para provisionar um n??mero espec??fico de recursos, a vari??vel **count.index** fica dispon??vel para ser utilizada. O count funciona como um for-loop.

De tal forma, caso provisionemos a seguinte inst??ncia:

```bash
resource "aws_instance" "myEc2" {
    ami = "ami-0b0d54b52c62864d6"
    instance_type = "t2.micro"
    count = 3

    tags = {
      Name = instance${count.index}
    }
}
```

As inst??ncias ter??o os seguintes nomes: **instance0, instance1, instance2**

# Exemplo countIndexWithValues para provisionar recursos com o count puxando valores customizados de uma lista 

?? poss??vel fornecer valores personalizados para itens dos recursos provisionados, armazenados tais valores em vari??veis, utilizando uma lista, e puxandos-o pelo count.index

Para tal:

**1. Definimos uma variable de list com os valores desejados**

```bash
variable "environments" {
  type = list
  default = ["instance-dev", "instance-hml", "instance-prod"]
}
```

**2. Ao nomear os recursos, puxar os indexes da lista**

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "myEc2" {   # Os recursos provisionados
   ami = "ami-0b0d54b52c62864d6" # ter??o a tag Name vindos da vari??vel
    instance_type = "t2.micro" # environments, definido no outro arquivo
    count = 3                  # nesse diret??rio

    tags = { 
      Name = var.environments[ "${count.index}" ] 
    }
}
```

# Exemplo conditional e provisionando inst??ncias baseado em uma condi????o

Nesse exemplo: 

- A inst??ncia testEc2 s?? ser?? provisionada se a vari??vel isTest for true. 
- A inst??ncia devEc2 s?? ser?? provisionada se a vari??vel isTest for false.

A vari??vel foi criada no arquivo **variables.tf** e um valor foi atribuido a ela no arquivo **terraform.tfvars**

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "testEc2" {
    ami = "ami-0b0d54b52c62864d6"
    instance_type = "t2.micro"
    count = var.isTest == true? 1 : 0 ## Condicional tern??rio b??sico.
}                                      # 
                                       # testEc2 s?? ser?? provisionada se
resource "aws_instance" "devEc2" {     # isTest == true
    ami = "ami-0b0d54b52c62864d6"      # 
    instance_type = "t2.micro"         # devEc2 s?? ser?? provisionada se
    count = var.isTest == true? 0 : 1 ## isTest == false
}
```

# Exemplo locals e a utiliza????o de vari??veis locais

O recurso **locals** pode ser usado para definir vari??veis que ser??o referenciadas naquele escopo do manifesto.

Neste exemplo, o **locals** foi criado para definir as tags da inst??ncia a ser provisionada.

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

locals { # Vari??veis locais
  mytags = {
    Name = "MyName"
    Environment = "Production"
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "name" {
    ami = "ami-0b0d54b52c62864d6"
    instance_type = "t2.micro"

    tags = local.mytags # Utiliza????o das tags do locals
}
```

# Terraform functions

- **lookup:** Busca um registro de um map fornecido. Caso a **key** fornecida bata com alguma key do map, o valor referente ??quela key ser?? retornado. Caso nada bata, o valor **default** ser?? usado

  Sintaxe e utiliza????o: https://developer.hashicorp.com/terraform/language/functions/lookup

- **element:** Retorna de uma lista um valor que corresponde ao index fornecido

  Sintaxe e utiliza????o: https://developer.hashicorp.com/terraform/language/functions/element

- **file:** L?? um arquivo no caminho especificado e retorna o valor como uma string

  Sintaxe e utiliza????o: https://developer.hashicorp.com/terraform/language/functions/file

- **formatdate**: Usada para formatar datas

  Sintaxe e utiliza????o: https://developer.hashicorp.com/terraform/language/functions/formatdate

- **zipmap**: "Gera" um map a partir de duas listas, combinando seus indexes como key-value

  Sintaxe e utiliza????o: https://developer.hashicorp.com/terraform/language/functions/zipmap

- **toset**: Converte uma lista para o formato de SET, que n??o permite duplicatas e n??o ?? indexado

  Sintaxe e utiliza????o: https://developer.hashicorp.com/terraform/language/functions/toset


# Criando uma key-pair para utilizar no SSH das inst??ncias EC2

Primeiro, criamos um recurso do tipo **aws_key_pair**:

```bash
resource "aws_key_pair" "ssh_key" {
  key_name = "login-key"
  public_key = file(/path/to/pub_key/key.pub) # Chave p??blica
}
```

Depois, basta vincul??-la ao recurso de **aws_instance**:

```bash
resource "aws_instance" "myEc2" {
  ami = "ami-12345678"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh_key.key_name # Referenciando a chave p??blica
}
```

# Utiliza????o de um data-source para puxar imagens atualizadas

O recurso **data** pode ser usado para especificar uma origem do dado, nesse caso, uma AMI. No c??digo a seguir, a AMI mais recente ser?? buscada, para qualquer regi??o que for especificada.

```bash
provider "aws" {
  region     = "ap-southeast-1"
  access_key = "YOUR-ACCESS-KEY"
  secret_key = "YOUR-SECRET-KEY"
}

data "aws_ami" "app_ami" {
  most_recent = true ##############
  owners = ["amazon"]             # Bloco definindo que a AMI ser??:
                                  # 1- A mais recente da regi??o selecionada
                                  # 2- Propriet??rias da Amazon
  filter {                        # 3- N??o sei a informa????o "values"
    name   = "name"               # 
    values = ["amzn2-ami-hvm*"] ###
  }
}

resource "aws_instance" "instance-1" {
    ami = data.aws_ami.app_ami.id
   instance_type = "t2.micro"
}
```

# Debugando o terraform plan com logs

Por padr??o, o `terraform plan` n??o tem logs. Entretanto, podemos habilitar diferentes modalidades de log: TRACE, DEBUG, INFO, WARN, ERROR.

Para tal, basta executarmos:

```bash
export TF_LOG=<MODALIDADE> 
```

Agora, ao re-executar `terraform plan`, teremos muitos logs sendo gerados.

Tamb??m ?? poss??vel exportar os logs para um caminho, executando:

```bash
export TF_LOG_PATH=<PATH>
```

# Formatando o c??digo com o terraform fmt

Estando no diret??rio do arquivo, podemos formatar todo o c??digo com o comando:

```bash
terraform fmt
```

# Validando o c??digo

Com o comando abaixo, podemos validar se um manifesto ?? v??lido ou n??o, buscando por erros de sintaxe:

```bash
terraform validate
```

# Exemplo dynamicBlocks e a utiliza????o dos dynamic blocks

Dynamic blocks podem ser usados para percorrer uma lista e criar diversos blocos cuja estrutura se repete, alterando somente os valores encontrados dentro da lista em cada itera????o.

**C??digo sem dynamic blocks** (note a repeti????o do bloco ingress, essa ?? a motiva????o por tr??s da utiliza????o dos dynamic blocks):

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_security_group" "mySg" {
  name        = "terraform-sg"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ "222.222.222.222/32" ]
    }

    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ "222.222.222.222/32" ]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ "222.222.222.222/32" ]
    }
  }

```

**C??digo com dynamic blocks**:

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

variable "inboundPorts" {
  type    = list(number)
  description = "list of ingress ports"
  default = [22, 80, 443]
}

resource "aws_security_group" "mySg" {
  name        = "terraform-dynamicSg"
  description = "This was generated by Terraform with a Dynamic Block for the inbound and outbound rules"

  dynamic "ingress" { ################## Defini????o de um dynamic block
    for_each = var.inboundPorts        # Iteramos pela var inboundPorts
    iterator = ports                   # podemos acessar o valor de cada itera????o
                                       # pelo iterator ports (ports.value)
    content {
      from_port   = ports.value
      to_port     = ports.value
      protocol    = "tcp"
      cidr_blocks = [ "222.222.222.222/32" ]
    }
  }
}
```

# Aplicando taint em recursos do Terraform

O taint ?? utilizado caso queiramos destruir um recurso para depois recri??-lo no `terraform apply`. Muito utilizado quando algum recurso ?? manualmente alterado na Cloud, e precisa ser recriado do zero.

Para executar o taint em um recurso, basta rodar o comando:

```bash
terraform taint aws_instance.myEc2
```

Basta substituir o **aws_instance** pelo recurso desejado e o **myEc2** pelo nome desejado.

# Output com splat expressions

S??o usados para prover o output de atributos de diversos recursos

```bash
resource "aws_iam_user" "lb" {
  name = "iamuser.${count.index}"
  count = 3
  path = "/system/"
}

output "arns" { ################## Ser?? printado o arn
  value = aws_iam_user.lb[*].arn # de TODOS os IAM users
}                              ### que foram criados
```

# Salvando o terraform plan em um arquivo

(Para a prova de certifica????o)

Isso ?? vantajoso porque, caso algu??m altere a configura????o do arquivo original, ainda podemos aplicar o `terraform apply` a partir do arquivo gerado.

```bash
terraform plan -out=<PATH>
```

Depois, basta executar o `terraform apply`, passando o arquivo gerado como par??metro:

```bash
terraform apply <PATH>
```

# Printando outputs ap??s as mudan??as j?? terem sido aplicadas

?? poss??ve usar o comando `terraform output \<OUTPUT_NAME>` para printar outputs ap??s os recursos j?? terem sido aplicados.

No exemplo abaixo, criamos 3 usu??rios IAM:

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_iam_user" "iamUsers" {
  name  = "user.${count.index}"
  path  = "/system/"
  count = 3
}

output "userNames" {
  value = aws_iam_user.iamUsers[*].name
}
```

Com o `terraform output`, obtemos a seguinte sa??da:

![image](https://user-images.githubusercontent.com/80921933/215405027-0a7df17a-95a4-40aa-a974-1f48a77e4664.png)

# Rodando o terraform plan somente em alguns recursos

Podemos escolher rodar o `terraform plan` em somente alguns recursos, de modo a reduzir o numero de "refreshes" a serem feitos. Para isso, os manifestos dos recursos devem estar distribu??dos em diferentes arquivos **.tf**, exemplo: rds.tf, ec2.tf, iam_users.tf... A??, basta "apontarmos" para o arquivo do recurso sem precisar dar refresh nos demais.

```bash
terraform plan -target=<RESOURCE>.<GIVEN_RESOURCE_NAME>
```

# Indicando que n??o precisa dar refresh no terraform plan

Podemos setar a flag **refresh** para **false** ao rodar `terraform plan`. Isso informar?? ao Terraform que ele n??o dever?? fazer o fetch do estado dos recursos deployados. (Aula 48)

```bash
terraform plan -refresh=false
```

# Significado do ~

(Para a certifica????o)

Significa que tem um update rolando, quando rodamos `terraform plan`

# Exemplo forEach e a utiliza????o dele

O for_each pode ser usado para percorrer listas, mapas, etc.

Quando ele ?? usado, cria-se uma nova vari??vel chamada **each**, que pode ser usada para referenciar o objeto da vez da itera????o.

Em um mapa, pode-se chamar **each.key** ou **each.value** para referenciar o key e o value do mapa, respectivamente. Em mapas ou listas de objetos, podemos referenciar atributos dos objetos normalmente, como em: **each.value.person.name**, e por a?? vai.

No exemplo `forEach`, criei uma **variable** com um mapa de objeto, onde o objeto representava a tag de cada EC2 criada.

```bash
variable "ec2Tags" {

  type = map

  default = {

    tag1 = {
      "nome" = "EC2-DEV",
      "environment" = "DEVELOPMENT"
    },
    tag2 = {
      "nome" = "EC2-PROD",
      "environment" = "PRODUCTION"
    }

  }
}
```

Depois, referenciei essa variable no manifesto principal, e usei o mapa para popular os valores das tags.

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "myEc2" {

  for_each = var.ec2Tags # For each na variable

  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"

  tags = {
      "Name"        = each.value.nome ######## Populando dados com o for_each
      "Environment" = each.value.environment # a partir da variable
  }
}
```

# Gerando um grafo representativo do deployment

(Para a certifica????o)

O comando abaixo gerar?? um arquivo DOT, que poder?? ser usado com outros softwares para expor uma representa????o visual do deployment

```bash
terraform graph
```

# Exemplo remoteExec e a execu????o do bootstrap de uma inst??ncia

Documenta????o: https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec

O provisioner **remote-exec** pode ser usado para executar comandos em inst??ncias que acabaram de ser provisionadas.

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "myEc2" {

  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"
  key_name = "MyKeyInAWS" # Deve ser fornecido o nome da chave usada


  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./private/key/here") # Chave privada
  }

  provisioner "remote-exec" {
    inline = [
      "COMMAND 1",
      "COMMAND 2",
      "COMMAND N"
    ]
  }
}
```

# Exemplo localExec e execu????o local de comandos ap??s o deployment

O provisioner **local-exec** ?? usado para executar comandos **LOCAIS** ap??s o deployment de uma inst??ncia. 

```bash
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "COMANDO AQUI"
  }
}
```

# Creation Time and Destroy Time provisioners

**Creation-Time provisioners** s??o o padr??o. S??o executados na cria????o de uma inst??ncia, e n??o precisamos adicionar nenhuma op????o. **(Para a certifica????o)** Se o Creation-Time provisioner **falhar**, o recurso ser?? "taintado" (ou seja, em sua pr??xima atualiza????o, ele ser?? destru??do e re-criado).

**Destroy-Time provisioners** s??o executados antes de um recurso ser destru??do.

```bash
provisioner "remote-exec" {
    when    = destroy
    inline = [
      "sudo yum -y remove nano"
    ]
} 
```

# Informa????es sobre a flag On Failure dos provisioners

![image](https://user-images.githubusercontent.com/80921933/216548098-354948c3-8e9b-47da-ac8e-1be5cb64750a.png)


# Utiliza????o do Null Resource

(Para a certifica????o)

O Null Resource ?? usado para provisionar recursos somente se outros recursos foram provisionados.

Para mais detalhes, consultar aula 61.

# Exemplo simpleEc2Module para a cria????o de um m??dulo simples para uma inst??ncia EC2

Com os m??dulos, podemos declarar blocos de c??digos reutiliz??veis, que podem ser referenciados de outros arquivos.

Nesse exemplo, criei um m??dulo de uma inst??ncia EC2:

```bash
resource "aws_instance" "myEc2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"
}
```

Depois, referenciei esse m??dulo no arquivo principal (indicando o caminho para o m??dulo criado acima):

```bash
module "ec2Module" {
  source = "./simpleEc2Module/"
}
```

(Declarei o provider em um arquivo separado)

Agora, basta rodar os comandos e tudo funcionar?? normalmente.

# Substitui????o de valores em um m??dulo

Ao declarar um m??dulo, podemos ter a necessidade de ter valores din??micos. 

Tal requerimento pode ser atingido com a utiliza????o de vari??veis (o arquivo **variables.tf** deve estar na mesma pasta do child-module)

```bash
resource "aws_instance" "myEC2" {
  ami = "ami-123456"
  instance_type = var.ec2InstanceType # Puxando valor do variable
}
```

Sendo assim, o m??dulo ter?? um valor padr??o, que foi definido na variable.

Quando houver a necessidade de substitu??-lo, podemos faz??-lo na refer??ncia do m??dulo:

```bash
module "meuModulo" {
  source = "/meu/caminho"
  instance_type = "t2.large" # Substituindo o valor padr??o
}
```

# Utilizando locals nos m??dulos para previnir que um valor possa ser reescrito

Ao declarar o m??dulo abaixo:

```bash
resource "aws_instance" "myEC2" {
  ami = "ami-123456"
  instance_type = var.ec2InstanceType # Puxando valor do variable
}
```

Usu??rios que referenciarem tal m??dulo poder??o facilmente alterar o valor da vari??vel **instance_type**. Esse pode ser um comportamento indesejado.

Caso precisemos que um m??dulo **n??o permita altera????o em algumas de suas vari??veis** (mas ainda evitando a necessidade de hard-codar o valor), podemos utilizar **locals**:

```bash
resource "aws_instance" "myEC2" {
  ami = "ami-123456"
  instance_type = local.ec2InstanceType # Referenciando valor do local
}

locals { # Defini????o do local
  ec2InstanceType = t2.micro
}
```

# Referenciando output de um m??dulo pai

(Aula 67 para futuras refer??ncias)

![image](https://user-images.githubusercontent.com/80921933/216578140-b1f452b1-8331-4d65-82bf-e67724d54bf9.png)

# Exemplo workspaces e opera????es com eles no Terraform

Para cada ambiente criado - **dev** e **prod** por exemplo - precisamos de um **instance_type** padr??o.

Para esse requisito, podemos utilizar os **workspaces**.

Para criar novos workspaces, usaremos os seguintes comandos:

```bash
terraform workspace new dev && \
terraform workspace new prod
```

Agora, considerando o seguinte requisito:

- O workspace **dev** deve ter a **instance_type** `t2.micro` como padr??o
- O workspace **prod** deve ter a **instance_type** `t2.large` como padr??o

Para tal, definimos um manifesto com as respectivas **instance_type** para cada ambiente:

```bash
variable "instanceTypes" {
    type = map
    default = {
        dev = "t2.micro",
        prod = "t2.large"
    }
}
```

Agora, podemos usar a fun????o `lookup(map, key)` juntamente a vari??vel `terraform.workspace` (que retorna o workspace atual) para deployar o **instance_type** correto:

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}                                      #-> Deployando o instance_type adequado
                                       #
resource "aws_instance" "myEc2" {      #############################
    ami = "ami-0b0d54b52c62864d6"                                  #
    instance_type = lookup(var.instanceTypes, terraform.workspace) #
}
```

Agora basta selecionar o workspace desejado e deployar.

# Implementando Terraform Backends

Obs: Nesse tutorial, foi usado o S3 como refer??ncia. Para mais op????es de backend, consultar a documenta????o: [INSERIR LINK AQUI]

O Terraform Backend consiste no local onde o `terraform.tfstate` ser?? armazenado.

Para configurar o S3 como backend, podemos:

- Criar o arquivo **provider.tf**
  
  ```bash
  touch privider.tf
  ```

- Inserir nele o seguinte conte??do:

  ```bash
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "4.53.0"
      }
    }

    backend "s3" { #########################
      bucket = "s3-terraform-backend-azl6" # Configura????es
      key    = "4/terraform.tfstate"       # backend
      region = "sa-east-1"                 #
    }
  }

  provider "aws" {
    region = "sa-east-1"
  }
  ```

Pronto! Agora, ao rodar o `terraform apply`, nosso arquivo ser?? direcionado para o bucket especificado na configura????o.

# Informa????es sobre state locking

Quando algu??m est?? usando um arquivo .tf para deployar/destruir recursos, um arquivo chamado **.terraform.tfstate.lock.info** ?? criado no diret??rio, para indicar que ele est?? "lockado". Quando isso acontece, outros usu??rios n??o conseguem performar a????es naquele diret??rio. Quando a a????o do primeiro usu??rio finalizar, o arquivo some, e o diret??rio ficar?? livre para receber novos comandos.

Ao tentar rodar opera????es em um diret??rio lockado, teremos um erro: 

![image](https://user-images.githubusercontent.com/80921933/217188917-45ebbee5-6d28-4758-85c4-de549ec6d82f.png)

Tamb??m ?? poss??vel usar o comando **force-unlock** para for??ar a exclus??o do arquivo de lock.

# Informa????o sobre state lock com S3 no backend

Quando usamos o S3 como backend, ele n??o armazena o arquivo de lock (.terraform.tfstate.lock.info). Para que seja poss??vel armazen??-lo usando o S3 como backend, devemos:

- Criar uma tablela no DynamoDB com uma partition-key com o nome de "LockID" no formato de String
- Referenciar o nome da tabela criada no manifesto do backend

  ```bash
      backend "s3" { 
      bucket = "s3-terraform-backend-azl6" 
      key    = "4/terraform.tfstate"       
      region = "sa-east-1"
      dynamodb_table = <DYNAMODB_TABLE_NAME> # Referenciando a tabela                 
    }
  ```

Pronto! Agora, o state lock ser?? armazenado nessa tabela.

# Comando state

`terraform state list`: Printa os recursos gerenciados pelo Terraform que est??o no arquivo **terraform.tfstate**

`terraform state mv <RECURSO_ANTIGO> <RECURSO_NOVO>`: Usado para renomear recursos, ex: \<RECURSO_ANTIGO> = **aws_instance.NomeAntigo** e \<RECURSO_NOVO> = **aws_instance.NomeNovo**. Isso ?? usado porque, caso alteremos o nome diretamente pelo arquivo de manifesto, o recurso ser?? destru??do e re-criado. Esse approach nos permite a n??o precisar destruir o recurso. 

`terraform state pull`: Puxa os dados atualizados do **terraform.tfstate** que est?? em um backend personalizado (e.g S3)

`terraform state rm <RECURSO>`: Remove recursos do **terraform.tfstate**. Tais recursos removidos continuam rodando, por??m, n??o ser??o mais gerenciados pelo Terraform. Isso significa que, caso esse recurso continue declarado nos arquivos **.tf**, o Terraform tentar?? **recri??-lo**, j?? que ele n??o est?? mais sendo gerenciado no **terraform.tfstate**

`terraform state show <RECURSO>`: Printa detalhes de um recurso espec??fico rodando na cloud.

# Terraform remote state

O **terraform_remote_state** ?? uma vari??vel capaz de se conectar com o backend (bucket S3) de outro projeto e referenciar seus outputs. 

Por exemplo, quando temos duas equipes: **Networking** e **Seguran??a**. 

A equipe de **Networking** usa o bucket-1 para armazenar seu **terraform.tfstate**. Eles criaram um Elastic IP. A equipe de **Seguran??a** precisa referenciar o arquivo **terraform.tfstate** da equipe de **Networking**, pegar o output que informa qual IP foi gerado, e whitelist??-lo no ingress de um security-group a ser criado.

Isso ?? poss??vel com o **terraform_remote_state**.

Para tal, declaramos o seguinte recurso:

```bash
data "terraform_remote_state" "elasticIpEquipeNetworking" {
  backend = "s3"

  config = {
    bucket = "<BUCKET>" 
    key    = "<KEY>/terraform.tfstate"
    region = "<REGI??O>"               
  }
}
```

Essa declara????o informa o arquivo **.tfstate** que o recurso **terraform_remote_state** ir?? referenciar, al??m de sua localiza????o (bucket)

Depois, basta referenciarmos esse recurso em nosso ingress do security-group. Note que o arquivo **terraform.tfstate** tem um output declarado:

![image](https://user-images.githubusercontent.com/80921933/217208249-4ecb780a-aaf7-418c-b3a2-553ced0aa3e0.png)

Para referenciar esse output (e o IP gerado), basta utilizarmos o seguinte caminho: **data.terraform_remote_state.elasticIpEquipeNetworking.outputs.eip_address**

```bash


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["${data.terraform_remote_state.elasticIpEquipeNetworking.outputs.eip_address}/32"] # Referenciando o IP da equipe de Networking
  }
}
```

# Terraform Import

?? poss??vel mapear infraestrutura que foi criada manualmente para o Terraform. Para tal, usamos o comando `terraform import`

Caso j?? tenhamos uma EC2 criada (ou qualquer outro recurso), **devemos criar um manifesto para ela, com todos os atributos da inst??ncia EC2 que foi manualmente criada**. Depois, rodamos:

```bash
terraform import <RECURSO>.<NOME_RECURSO> <ID_DO_RECURSO_NA_CLOUD>
```

Caso as informa????es do manifesto batam com as informa????es da inst??ncia criada manualmente, um arquivo **terraform.tfstate** ser?? criado, com as informa????es da inst??ncia.

# M??ltiplas configura????es de regi??o nos providers

Podemos ter o requisito de deployar recursos em mais de uma regi??o. Por??m, ao declarar dois blocos de provider, teremos um erro.

```bash
provider "aws" {
  region = "sa-east-1" ##
}                       # Configura????es de providers
                        # referenciando regi??es diferentes
provider "aws" {        #
  region = "us-east-1" ##
}
```

Para resolver o erro gerado nesse caso, podemos definir o campo **alias** nos providers:

```bash
provider "aws" {
  region = "sa-east-1" 
}                       
                        
provider "aws" { 
  alias  = usa ######## Definindo o campo alias
  region = "us-east-1" 
}
```

Agora, no recurso a ser deployado, basta selecionarmos o provider pelo **alias** definido. Essa inst??ncia ser?? deployada na regi??o us-east-1:

```bash
resource "aws_instance" "myEc2" {
   ami = "ami-0b0d54b52c62864d6"
   instance_type = "t2.micro"
   provider = "aws.usa" # Referenciando o alias criado
}
```

# M??ltiplas configura????es de conta nos providers

Caso tenhamos o requisito de deployar recursos em diferentes contas, podemos usar os perfis definidos no arquivo $HOME/.aws/credentials

![image](https://user-images.githubusercontent.com/80921933/217220352-57589222-292f-4466-9474-946c4c8a3a0e.png)

Selecionando um perfil no arquivo, basta inform??-lo nas configura????es do provider, e selecionar o provider na hora de realizar o deploy de um recurso (da mesma forma feita no ??ltimo t??pico).

```bash
provider "aws" {
  region  = "sa-east-1"
  alias   = "brazil"
  profile = "account02"
}
```

# Sensitive parameters

Alguns outputs s??o sens??veis. Podemos optar por n??o mostr??-los no output.

![image](https://user-images.githubusercontent.com/80921933/217221319-c3091c54-8d65-4627-aab1-b3de3eeb0f70.png)


Quando a flag **sensitive** ?? setada como TRUE, o output ter?? o seguinte resultado:

![image](https://user-images.githubusercontent.com/80921933/217221511-e1103ac1-e9f6-4d3e-9467-f454b30c01a5.png)

Entretando, o campo n??o ser?? encryptado ou escondido no arquivo **.tfstate**


# Integra????o com o Hashicorp Vault

![image](https://user-images.githubusercontent.com/80921933/217223525-83d0a65a-52b9-4c22-9527-95921b5a758c.png)

Nota importante para a certifica????o:

![image](https://user-images.githubusercontent.com/80921933/217223686-13e7fb34-7a10-4b98-846c-1d6b37d362a7.png)
