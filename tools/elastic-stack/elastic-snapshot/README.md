# Elastic Snapshot

# Requisitos

Antes de iniciar é necessário executar as etapas de configuração do IAM contidas nesta [documentação](https://www.elastic.co/guide/en/cloud/current/ec-migrate-from-aws.html)

Para que a execução do script funcione é necessário realizar a instalação das bibliotecas do Python

```bash
pip3 install --user -r ./requirements.txt
```

Além dos requisitos do Python, precisamos instalar o plugin do S3 no ElasticSearch. Mais detalhes podem ser vistos na [documentação](https://www.elastic.co/guide/en/elasticsearch/plugins/6.3/repository-s3.html):

```bash
elasticsearch-plugin install repository-s3
```

Após a instalação do plugin é necessário o restart do ElasticSearch.

# Opções

**STATUS** - Exibe o status de um procedimento de snapshot em execução.

**INDEX** - Lista os indices e suas estatísticas

**REGISTER** - Registra um repositório S3 para armazenar o Snapshot

**RESTORE** - Inicia o procedimento de restore de um snapshot

**SNAPSHOT** - Inicia o procedimento de snapshot