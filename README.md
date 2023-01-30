# Link para a documentação para a AWS

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

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

  sintaxe:

  1. lookup(\<map>, key, default) <br>
  2. lookup(\<map>, key) 

  exemplos:

  lookup({key="valor1", key2="valor2"}, key1) RETORNA valor1 <br>
  lookup({key="valor1", key2="valor2"}, key2) RETORNA valor2 

<br>

- **element:** Retorna de uma lista um valor que corresponde ao index fornecido

  sintaxe:

  1. element(\<list>, index)

  exemplos:

  element(["a", "b", "c"], 0) RETORNA a <br>
  element(["a", "b", "c"], 1) RETORNA b <br>
  element(["a", "b", "c"], 2) RETORNA c 

<br>

- **file:** Lê um arquivo no caminho especificado e retorna o valor como uma string

  sintaxe: 

  1. file(\<path/to/file/file.txt>)

<br>

**formatdate**: Usada para formatar datas

sintaxe e utilização: https://developer.hashicorp.com/terraform/language/functions/formatdate


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

