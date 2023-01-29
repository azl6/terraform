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

1. Flag -var no terraform plan

  Ao executar `terraform plan`, podemos informar a flag **-var \<VAR>=\<VALUE>**

  ```bash
  terraform plan -var "myvar=VALUE"
  ```
2. Arquivo terraform.tfvars

  Podemos também especificar variáveis dentro do arquivo **terraform.tfvars**. Essas variáveis terão prioridade sobre a **default** definida em um bloco **variable**

3. Especificando um arquivo de variável cujo nome difere de terraform.tfvars

  É possível fazê-lo, especificando a flag -var-file=\<FILE> no momento da execução do `terraform plan`

  ```bash
  terraform plan -var-file=<MY_FILE>
  ```

4. Usando environment-variables com o prefixo TF_VAR

  Basta definir uma env variable com o prefixo TF_VAR_, e o Terraform a utilizará

  ```bash
  export TF_VAR_INSTANCE_TYPE="t2.micro"
  ```