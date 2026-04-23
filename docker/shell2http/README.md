# Stack shell2http

Stack docker para definir um container que serve na porta 8080 um serviço web ao qual ao ser acessado automatiza a execução de comandos ou shell scripts linux. A saída padrão do script é capturada e apresentada como *content/text* .

## script incluso

Neste está incluso um script [get_aws_ips.sh](/scripts/get_aws_ips.sh) ao qual, baseado no JSON oficial AWS, busca as faixas de IP correspondentes a cada API de serviço da AWS em diferentes regiões.

### como usar o get_aws_ips.sh

Deve ser passado como parametro a região e o serviço desejado. Exemplos:

- Consulta lista de ranges IPs das APIs S3 na região US/Ohio (us-east-2)

```bash
./get_aws_ips.sh us-east-2 s3
```

- Consulta lista ranges de IPs de serviços EC2 (Elastic IP) em US/N.Virginia

```bash
./get_aws_ips.sh us-east-1 ec2
```

Se a região e/ou serviço forem omitidos, por padrão a lista de **us-east-1 para s3** sera exibida.

## definindo scripts no shell2http

O stack docker possui sessão de build para dispor uma imagem docker customizada que inclui como _entrypoint_ o binário do [shell2http](https://github.com/msoap/shell2http). Sendo assim, basta iniciar o container passando como _command_ os parâmetros para o shell2http iniciar o serviço web e o script a ser executado.

Exemplo de uso básico:

- Definir via [compose.yaml](/docker-compose.yaml) nesse stack um serviço web em **/aws/us-east-1-s3** que quando acessado dispara o script [get_aws_ips.sh](/scripts/get_aws_ips.sh) passando para ele a região e o serviço AWS **us-east-1 s3**

```yaml
services:
  shell2http:
    build: .
  ports:
    - 8080:8080
  command: '/aws/us-east-1-s3 "/scripts/get_aws_ips.sh us-east-1 s3"'
```

O shell2http suporta publicar multiplos serviços web. Sintaxe:

```bash
shell2http [options] /path "script.sh" /path2 "script2.sh"
```

Exemplo no compose:

```yaml
services:
  shell2http:
    build: .
  ports:
    - 8080:8080
  command: '/aws/us-east-1-s3 "/scripts/get_aws_ips.sh us-east-1 s3" /aws/us-east-2-ec2 "/scripts/get_aws_ips.sh us-east-2 ec2"' 
```

Um [docker-compose.yaml](/docker-compose.yaml) mais completo e funcional está disponível e com 4 regiões e serviços comuns pré configurados.

## sobre

Stack docker e scripts: [Franklin Moretti](mailto://fumoretti@gmail.com)  
Shell2http project: [Github msoap/shell2http](https://github.com/msoap/shell2http)  
