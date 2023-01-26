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

# Exemplo 1 e a criação simples de uma instância EC2

Nesse caso, o **Access Key ID** e **Secret Access Key** já existem como variáveis de ambiente, inicializadas no **~/.bashrc**

```bash
# "aws_instance" se refere a criação de uma instância EC2
# "myec2" se refere ao nome da instância

provider "aws" {
  region     = "sa-east-1"
  access_key = "CREDENCIAIS-AQUI"
  secret_key = "CREDENCIAIS-AQUI"
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

provider "aws" {
  # Configuration options
}
```

Ao executar `terraform init`, o arquivo `.terraform.lock.hcl` será criado, com as limitações fornecidas no manifesto.

Ao alterar a versão no manifesto para uma versão fora da constraint informada no primeiro, **não teremos sucesso**, porque o arquivo de lock nos bloqueia de fazê-lo. Para executarmos `terraform init` com sucesso após "violarmos" uma constraint, usamos a flag **-upgrade**:

```bash
terraform init -upgrade
```


