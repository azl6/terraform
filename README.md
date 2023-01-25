# Link para a documentação para a AWS

https://registry.terraform.io/providers/hashicorp/aws/latest/docs

# Baixando dependencies de um provider com o terraform init

A execução do comando abaixo deve ser feita **na mesma pasta** onde seu arquivo **.tf** se encontra. 

O Terraform lerá seu arquivo e baixará as dependencies do provider definido no manifesto.

```bash
terraform init
```

# Mostrando recursos a serem criados com o terraform plan

Esse comando nos mostrará o que será criado com um código **.tf**

```bash
terraform plan
```

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

