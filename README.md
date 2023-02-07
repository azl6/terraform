# Link para a documentação para a AWS

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

# Link para o Terraform Registry

https://registry.terraform.io/

# Baixando dependencies de um provider com o terraform init

A execução do comando abaixo deve ser feita **na mesma pasta** onde seu arquivo **.tf** se encontra. 

O Terraform lerá seu arquivo e baixará as dependencies do provider definido no manifesto.

```bash
terraform init
```

# Mostrando recursos a serem criados e retornados ao desired-state com o terraform plan

Esse comando nos mostrará o que será criado com um código **.tf**

```bash
terraform plan
```

Outra funcionalidade sua é a de mostrar quando o **desired-state** da infraestrutura (configurações definidas no **.tf**) encontra-se diferente do **current-state** (devido a alguma alteração manual, etc...). Nesse caso, com o **terraform plan**, o Terraform nos avisará que eles estão diferentes, e mostrará o que precisa ser alterado para que tudo seja retornado ao **desired-state**. Tais mudanças só serão "commitadas" com o **terraform apply**.

# Criando recursos o terraform apply

O **terraform apply** aplica e cria os recursos descritos no manifesto **.tf**

```bash
terraform apply
```

# Exemplo simpleEc2 e a criação simples de uma instância EC2

Nesse caso, o **Access Key ID** e **Secret Access Key** já existem como variáveis de ambiente, inicializadas no **~/.bashrc**

```bash
# "aws_instance" se refere a criação de uma instância EC2
# "myec2" se refere ao nome da instância

provider "aws" {
  region     = "sa-east-1"
}

resource "aws_instance" "myec2" {
   ami = "ami-0b0d54b52c62864d6"
   instance_type = "t2.micro"
}
```

# Deletando recursos com o terraform destroy

Para deletar todos os recursos criados em um diretório (estando nele):

```bash
terraform destroy
```

Caso desejemos selecionar o recurso a ser deletado, podemos usar a flag **-target**

```bash
terraform destroy -target aws_instance.myec2
```

**Importante:** O valor do target refere-se ao nome dado ao **resource** em sua criação, e.g imagem abaixo:

![image](https://user-images.githubusercontent.com/80921933/214487650-f86e2fba-d83f-4848-93f7-2f81aeb04b31.png)

# Travando a versão dos plugins do provider

Alterar abruptamente a versão do provider pode nos trazer problemas. 

Para evitar isso, podemos "travar" a versão do nosso provider em uma específica (ou em um range específico), seguindo as seguintes regras:

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

Ao executar `terraform init`, o arquivo `.terraform.lock.hcl` será criado, com as limitações fornecidas no manifesto.

Ao alterar a versão no manifesto para uma versão fora da constraint informada no primeiro, **não teremos sucesso na execução do terraform init**, porque o arquivo de lock nos bloqueia de fazê-lo. Para executarmos `terraform init` com sucesso após "violarmos" uma constraint, usamos a flag **-upgrade**:

```bash
terraform init -upgrade
```
# Exemplo simpleS3Bucket e a utilização dos outputs

Os outputs podem ser utilizados para printarem atributos dos recursos criados. Nesse exemplo, printei o **arn** e **região** do bucket criadom referenciando-o pelo seu nome (aws_s3_bucket.myBucket.\<ATRIBUTO>). **Caso nenhum \<ATRIBUTO> seja fornecido, tudo será printado!**

Atributos que podem ser usados como output podem ser encontrados na página do recurso (aws_instance, aws_s3_bucket, etc...),na seção **Argument Reference** como no seguinte link: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket#argument-reference

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

output "bucket_region" { # Printando a região do bucket no output
  value = aws_s3_bucket.myBucket.region
}

output "bucket_arn" { # Printando o arn do bucket no output
  value = aws_s3_bucket.myBucket.arn
}
```

Output:

![image](https://user-images.githubusercontent.com/80921933/215355986-82f52108-b51a-4457-ba49-88011cc4583f.png)

# Exemplo ec2IPWhitelistedOnSG para criar um SG que libera inbound-rule para o IP de uma EC2 também criada

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

  ingress { # Definição das inbount rules
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

# Exemplo usingVariables para referenciar variáveis definidas em outros arquivos

É possível referenciar variáveis definidas em outros arquivos.

Nesse exemplo, o arquivo `variables.tf` serve de origem para as variáveis.

```bash
variable "customIpCIDR" {
    default = "192.168.0.0/24"
}
```

As variáveis são usadas no arquivo `usingVariables.tf`

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

# Formas de explicitar valores de variáveis

Se nenhuma variável for fornecida explicitamente, a **default** (definida no bloco variable) será usada.

É possível especificar variáveis de diferentes formas:

**1. Flag -var no terraform plan**

  Ao executar `terraform plan`, podemos informar a flag **-var \<VAR>=\<VALUE>**

  ```bash
  terraform plan -var "myvar=VALUE"
  ```
**2. Arquivo terraform.tfvars**

  Podemos também especificar variáveis dentro do arquivo **terraform.tfvars**. Essas variáveis terão prioridade sobre a **default** definida em um bloco **variable**. É comum utilizar um arquivo para as variáveis, e popular os seus respectivos valores com o arquivo **terraform.tfvars**

**3. Especificando um arquivo de variável cujo nome difere de terraform.tfvars**

  É possível fazê-lo, especificando a flag -var-file=\<FILE> no momento da execução do `terraform plan`

  ```bash
  terraform plan -var-file=<MY_FILE>
  ```

**4. Usando environment-variables com o prefixo TF_VAR**

  Basta definir uma env variable com o prefixo TF_VAR_, e o Terraform a utilizará

  ```bash
  export TF_VAR_INSTANCE_TYPE="t2.micro"
  ```

# Informações sobre variáveis

Em um bloco **variable**, é possível especificar explicitamente tipos para as variáveis:

```bash
variable "myvar"{
  type = <string,number,list,map>
}
``` 

Para referenciar itens em **mapas**, basta usar sua chave.

Para referenciar itens em **lists**, basta usar a posição do item

# Provisionando mais de um recurso com o count

Para provisionar duas instâncias EC2, podemos repedir seu bloco de criação duas vezes. Entretanto, é melhor usar a variável **count** para fazê-lo.

```bash
resource "aws_instance" "myec2" {
   ami = "ami-0b0d54b52c62864d6"
   instance_type = "t2.micro"
   count = 2
}
```

# Utilizando o count.index para pegar o número da iteração feita

Quando utilizamos **count** para provisionar um número específico de recursos, a variável **count.index** fica disponível para ser utilizada. O count funciona como um for-loop.

De tal forma, caso provisionemos a seguinte instância:

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

As instâncias terão os seguintes nomes: **instance0, instance1, instance2**

# Exemplo countIndexWithValues para provisionar recursos com o count puxando valores customizados de uma lista 

É possível fornecer valores personalizados para itens dos recursos provisionados, armazenados tais valores em variáveis, utilizando uma lista, e puxandos-o pelo count.index

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
   ami = "ami-0b0d54b52c62864d6" # terão a tag Name vindos da variável
    instance_type = "t2.micro" # environments, definido no outro arquivo
    count = 3                  # nesse diretório

    tags = { 
      Name = var.environments[ "${count.index}" ] 
    }
}
```

# Exemplo conditional e provisionando instâncias baseado em uma condição

Nesse exemplo: 

- A instância testEc2 só será provisionada se a variável isTest for true. 
- A instância devEc2 só será provisionada se a variável isTest for false.

A variável foi criada no arquivo **variables.tf** e um valor foi atribuido a ela no arquivo **terraform.tfvars**

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
    count = var.isTest == true? 1 : 0 ## Condicional ternário básico.
}                                      # 
                                       # testEc2 só será provisionada se
resource "aws_instance" "devEc2" {     # isTest == true
    ami = "ami-0b0d54b52c62864d6"      # 
    instance_type = "t2.micro"         # devEc2 só será provisionada se
    count = var.isTest == true? 0 : 1 ## isTest == false
}
```

# Exemplo locals e a utilização de variáveis locais

O recurso **locals** pode ser usado para definir variáveis que serão referenciadas naquele escopo do manifesto.

Neste exemplo, o **locals** foi criado para definir as tags da instância a ser provisionada.

```bash
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

locals { # Variáveis locais
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

    tags = local.mytags # Utilização das tags do locals
}
```

# Terraform functions

- **lookup:** Busca um registro de um map fornecido. Caso a **key** fornecida bata com alguma key do map, o valor referente àquela key será retornado. Caso nada bata, o valor **default** será usado

  Sintaxe e utilização: https://developer.hashicorp.com/terraform/language/functions/lookup

- **element:** Retorna de uma lista um valor que corresponde ao index fornecido

  Sintaxe e utilização: https://developer.hashicorp.com/terraform/language/functions/element

- **file:** Lê um arquivo no caminho especificado e retorna o valor como uma string

  Sintaxe e utilização: https://developer.hashicorp.com/terraform/language/functions/file

- **formatdate**: Usada para formatar datas

  Sintaxe e utilização: https://developer.hashicorp.com/terraform/language/functions/formatdate

- **zipmap**: "Gera" um map a partir de duas listas, combinando seus indexes como key-value

  Sintaxe e utilização: https://developer.hashicorp.com/terraform/language/functions/zipmap

- **toset**: Converte uma lista para o formato de SET, que não permite duplicatas e não é indexado

  Sintaxe e utilização: https://developer.hashicorp.com/terraform/language/functions/toset


# Criando uma key-pair para utilizar no SSH das instâncias EC2

Primeiro, criamos um recurso do tipo **aws_key_pair**:

```bash
resource "aws_key_pair" "ssh_key" {
  key_name = "login-key"
  public_key = file(/path/to/pub_key/key.pub) # Chave pública
}
```

Depois, basta vinculá-la ao recurso de **aws_instance**:

```bash
resource "aws_instance" "myEc2" {
  ami = "ami-12345678"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ssh_key.key_name # Referenciando a chave pública
}
```

# Utilização de um data-source para puxar imagens atualizadas

O recurso **data** pode ser usado para especificar uma origem do dado, nesse caso, uma AMI. No código a seguir, a AMI mais recente será buscada, para qualquer região que for especificada.

```bash
provider "aws" {
  region     = "ap-southeast-1"
  access_key = "YOUR-ACCESS-KEY"
  secret_key = "YOUR-SECRET-KEY"
}

data "aws_ami" "app_ami" {
  most_recent = true ##############
  owners = ["amazon"]             # Bloco definindo que a AMI será:
                                  # 1- A mais recente da região selecionada
                                  # 2- Proprietárias da Amazon
  filter {                        # 3- Não sei a informação "values"
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

Por padrão, o `terraform plan` não tem logs. Entretanto, podemos habilitar diferentes modalidades de log: TRACE, DEBUG, INFO, WARN, ERROR.

Para tal, basta executarmos:

```bash
export TF_LOG=<MODALIDADE> 
```

Agora, ao re-executar `terraform plan`, teremos muitos logs sendo gerados.

Também é possível exportar os logs para um caminho, executando:

```bash
export TF_LOG_PATH=<PATH>
```

# Formatando o código com o terraform fmt

Estando no diretório do arquivo, podemos formatar todo o código com o comando:

```bash
terraform fmt
```

# Validando o código

Com o comando abaixo, podemos validar se um manifesto é válido ou não, buscando por erros de sintaxe:

```bash
terraform validate
```

# Exemplo dynamicBlocks e a utilização dos dynamic blocks

Dynamic blocks podem ser usados para percorrer uma lista e criar diversos blocos cuja estrutura se repete, alterando somente os valores encontrados dentro da lista em cada iteração.

**Código sem dynamic blocks** (note a repetição do bloco ingress, essa é a motivação por trás da utilização dos dynamic blocks):

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

**Código com dynamic blocks**:

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

  dynamic "ingress" { ################## Definição de um dynamic block
    for_each = var.inboundPorts        # Iteramos pela var inboundPorts
    iterator = ports                   # podemos acessar o valor de cada iteração
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

O taint é utilizado caso queiramos destruir um recurso para depois recriá-lo no `terraform apply`. Muito utilizado quando algum recurso é manualmente alterado na Cloud, e precisa ser recriado do zero.

Para executar o taint em um recurso, basta rodar o comando:

```bash
terraform taint aws_instance.myEc2
```

Basta substituir o **aws_instance** pelo recurso desejado e o **myEc2** pelo nome desejado.

# Output com splat expressions

São usados para prover o output de atributos de diversos recursos

```bash
resource "aws_iam_user" "lb" {
  name = "iamuser.${count.index}"
  count = 3
  path = "/system/"
}

output "arns" { ################## Será printado o arn
  value = aws_iam_user.lb[*].arn # de TODOS os IAM users
}                              ### que foram criados
```

# Salvando o terraform plan em um arquivo

(Para a prova de certificação)

Isso é vantajoso porque, caso alguém altere a configuração do arquivo original, ainda podemos aplicar o `terraform apply` a partir do arquivo gerado.

```bash
terraform plan -out=<PATH>
```

Depois, basta executar o `terraform apply`, passando o arquivo gerado como parâmetro:

```bash
terraform apply <PATH>
```

# Printando outputs após as mudanças já terem sido aplicadas

É possíve usar o comando `terraform output \<OUTPUT_NAME>` para printar outputs após os recursos já terem sido aplicados.

No exemplo abaixo, criamos 3 usuários IAM:

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

Com o `terraform output`, obtemos a seguinte saída:

![image](https://user-images.githubusercontent.com/80921933/215405027-0a7df17a-95a4-40aa-a974-1f48a77e4664.png)

# Rodando o terraform plan somente em alguns recursos

Podemos escolher rodar o `terraform plan` em somente alguns recursos, de modo a reduzir o numero de "refreshes" a serem feitos. Para isso, os manifestos dos recursos devem estar distribuídos em diferentes arquivos **.tf**, exemplo: rds.tf, ec2.tf, iam_users.tf... Aí, basta "apontarmos" para o arquivo do recurso sem precisar dar refresh nos demais.

```bash
terraform plan -target=<RESOURCE>.<GIVEN_RESOURCE_NAME>
```

# Indicando que não precisa dar refresh no terraform plan

Podemos setar a flag **refresh** para **false** ao rodar `terraform plan`. Isso informará ao Terraform que ele não deverá fazer o fetch do estado dos recursos deployados. (Aula 48)

```bash
terraform plan -refresh=false
```

# Significado do ~

(Para a certificação)

Significa que tem um update rolando, quando rodamos `terraform plan`

# Exemplo forEach e a utilização dele

O for_each pode ser usado para percorrer listas, mapas, etc.

Quando ele é usado, cria-se uma nova variável chamada **each**, que pode ser usada para referenciar o objeto da vez da iteração.

Em um mapa, pode-se chamar **each.key** ou **each.value** para referenciar o key e o value do mapa, respectivamente. Em mapas ou listas de objetos, podemos referenciar atributos dos objetos normalmente, como em: **each.value.person.name**, e por aí vai.

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

(Para a certificação)

O comando abaixo gerará um arquivo DOT, que poderá ser usado com outros softwares para expor uma representação visual do deployment

```bash
terraform graph
```

# Exemplo remoteExec e a execução do bootstrap de uma instância

Documentação: https://developer.hashicorp.com/terraform/language/resources/provisioners/remote-exec

O provisioner **remote-exec** pode ser usado para executar comandos em instâncias que acabaram de ser provisionadas.

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

# Exemplo localExec e execução local de comandos após o deployment

O provisioner **local-exec** é usado para executar comandos **LOCAIS** após o deployment de uma instância. 

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

**Creation-Time provisioners** são o padrão. São executados na criação de uma instância, e não precisamos adicionar nenhuma opção. **(Para a certificação)** Se o Creation-Time provisioner **falhar**, o recurso será "taintado" (ou seja, em sua próxima atualização, ele será destruído e re-criado).

**Destroy-Time provisioners** são executados antes de um recurso ser destruído.

```bash
provisioner "remote-exec" {
    when    = destroy
    inline = [
      "sudo yum -y remove nano"
    ]
} 
```

# Informações sobre a flag On Failure dos provisioners

![image](https://user-images.githubusercontent.com/80921933/216548098-354948c3-8e9b-47da-ac8e-1be5cb64750a.png)


# Utilização do Null Resource

(Para a certificação)

O Null Resource é usado para provisionar recursos somente se outros recursos foram provisionados.

Para mais detalhes, consultar aula 61.

# Exemplo simpleEc2Module para a criação de um módulo simples para uma instância EC2

Com os módulos, podemos declarar blocos de códigos reutilizáveis, que podem ser referenciados de outros arquivos.

Nesse exemplo, criei um módulo de uma instância EC2:

```bash
resource "aws_instance" "myEc2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"
}
```

Depois, referenciei esse módulo no arquivo principal (indicando o caminho para o módulo criado acima):

```bash
module "ec2Module" {
  source = "./simpleEc2Module/"
}
```

(Declarei o provider em um arquivo separado)

Agora, basta rodar os comandos e tudo funcionará normalmente.

# Substituição de valores em um módulo

Ao declarar um módulo, podemos ter a necessidade de ter valores dinâmicos. 

Tal requerimento pode ser atingido com a utilização de variáveis

```bash
resource "aws_instance" "myEC2" {
  ami = "ami-123456"
  instance_type = var.ec2InstanceType # Puxando valor do variable
}
```

Sendo assim, o módulo terá um valor padrão, que foi definido na variable.

Quando houver a necessidade de substituí-lo, podemos fazê-lo na referência do módulo:

```bash
module "meuModulo" {
  source = "/meu/caminho"
  instance_type = "t2.large" # Substituindo o valor padrão
}
```

# Utilizando locals nos módulos para previnir que um valor possa ser reescrito

Ao declarar o módulo abaixo:

```bash
resource "aws_instance" "myEC2" {
  ami = "ami-123456"
  instance_type = var.ec2InstanceType # Puxando valor do variable
}
```

Usuários que referenciarem tal módulo poderão facilmente alterar o valor da variável **instance_type**. Esse pode ser um comportamento indesejado.

Caso precisemos que um módulo **não permita alteração em algumas de suas variáveis** (mas ainda evitando a necessidade de hard-codar o valor), podemos utilizar **locals**:

```bash
resource "aws_instance" "myEC2" {
  ami = "ami-123456"
  instance_type = local.ec2InstanceType # Referenciando valor do local
}

locals { # Definição do local
  ec2InstanceType = t2.micro
}
```

# Referenciando output de um módulo pai

(Aula 67 para futuras referências)

![image](https://user-images.githubusercontent.com/80921933/216578140-b1f452b1-8331-4d65-82bf-e67724d54bf9.png)

# Exemplo workspaces e operações com eles no Terraform

Para cada ambiente criado - **dev** e **prod** por exemplo - precisamos de um **instance_type** padrão.

Para esse requisito, podemos utilizar os **workspaces**.

Para criar novos workspaces, usaremos os seguintes comandos:

```bash
terraform workspace new dev && \
terraform workspace new prod
```

Agora, considerando o seguinte requisito:

- O workspace **dev** deve ter a **instance_type** `t2.micro` como padrão
- O workspace **prod** deve ter a **instance_type** `t2.large` como padrão

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

Agora, podemos usar a função `lookup(map, key)` juntamente a variável `terraform.workspace` (que retorna o workspace atual) para deployar o **instance_type** correto:

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

Obs: Nesse tutorial, foi usado o S3 como referência. Para mais opções de backend, consultar a documentação: [INSERIR LINK AQUI]

O Terraform Backend consiste no local onde o `terraform.tfstate` será armazenado.

Para configurar o S3 como backend, podemos:

- Criar o arquivo **provider.tf**
  
  ```bash
  touch privider.tf
  ```

- Inserir nele o seguinte conteúdo:

  ```bash
  terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "4.53.0"
      }
    }

    backend "s3" { #########################
      bucket = "s3-terraform-backend-azl6" # Configurações
      key    = "4/terraform.tfstate"       # backend
      region = "sa-east-1"                 #
    }
  }

  provider "aws" {
    region = "sa-east-1"
  }
  ```

Pronto! Agora, ao rodar o `terraform apply`, nosso arquivo será direcionado para o bucket especificado na configuração.

# Informações sobre state locking

Quando alguém está usando um arquivo .tf para deployar/destruir recursos, um arquivo chamado **.terrafor.tfstate.lock.info** é criado no diretório, para indicar que ele está "lockado". Quando isso acontece, outros usuários não conseguem performar ações naquele diretório. Quando a ação do primeiro usuário finalizar, o arquivo some, e o diretório ficará livre para receber novos comandos.

Ao tentar rodar operações em um diretório lockado, teremos um erro: 

