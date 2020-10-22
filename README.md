# :zap: Docker Web Server :zap: NGINX + PHP-FPM + PostgreSQL :zap:

Um único container de aproximadamente 180MB, configurado para servir arquivos estáticos e aplicações PHP sobre a stack LEPP ( Linux + NGINX + PHP-FPM + PostgreSQL ). Já possui o composer pronto para ser usado no diretório de trabalho e o xdebug habilitado pronto para ser facilmente configurado e utilizado.

Agora que já sabe do que se trata, bora pegar um :coffee: e colocar as mãos na maassa

## Detalhes do repositório

Você pode usar essa configuração Docker, como ambiente base no desenvolvimento de projetos que utilizem PHP e PostgreSQL. A estrutura de arquivos e pastas está dessa forma:

```
./
├── config  # docker configuration files
│   ├── start
│   ├── nginx.conf
│   ├── php.ini
│   └── xdebug.ini
│
├── src     # starter code-bases
│   ├── index.html
│   └── index.php
│
├── .env-example
├── .gitignore
├── Dockerfile
├── README.md
└── docker-compose.yaml-example
```

É possível usar essa configuração do docker de 2 formas. A primeira é criando uma imagem do dockerfile e então roda-la em um container. A segunda é usar uma configuração do docker-compose para facilitar as configurações necessárias no momento da inicialização do container. Então vamos ver como usar as 2 formas:

Antes de mais nada, renomeie o arquivo `.env-example` na raiz do diretório para `.env`. Ele já possui uma configuração básica inical para você testar sem ter que alterar qualquer diretiva, mas depois de configurado, será possível servir 3 domínios locais sendo um localhost contendo o resultado da função `phpinfo()`, uma aplicação PHP com domínio local personalizado, e outra aplicação estática. Mas para melhor entendimento aqui está a lista de configurações possíveis do `.env`:

- `HOST_API` - Domínio local para acessar a aplicação PHP. (Lembre que esse domínio também deve estar no arquivo hosts para consiguir acessa-lo depois pelo navegador)

- `HOST_APP` - Domínio local para acessar a aplicação estática

- `HOST_API_DIR` - Diretório local onde está localizado seu projeto PHP

- `HOST_APP_DIR` - Diretório local onde está localizado sua aplicação estático / frontend

- `HOST_NGINX_PORT` - Porta local que será redirecionada para a porta 8080 do container ( é utilizado um usuário sem privilégios de root no container, por isso o nginx não pode usar a porta 8080 ao invés da pora 80 )

- `HOST_PG_PORT` - Porta local que será redirecionada para a porta 5432 do container ( PostgreSQL )

- `XDEBUG_HOST` - Host remoto que o xdebug escutará ( Geralmente o IPv4 do computador local, mas no windows será mais cômodo usar o IP fixo do adaptador de rede padrão usado pelo Hyper-V )

- `XDEBUG_PORT` - Porta remota que o xdebug escutará

- `XDEBUG_IDE_KEY` - Chave da IDE utilizada ( o padrão para o VScode e PHPStorm são vscode e PHPSTORM respectivamente )

- `DB_DATABASE` - Nome da base de dados que o postgres vai criar

- `DB_USERNAME` - Nome do usuário que o postgres vai criar

- `DB_PASSWORD` - Senha do usuário que o postgres vai criar

Obs.: A aplicação PHP que chamei de api é a principal aplicação que essa imagem está configurada para servir, então o diretório de trabalho padrão dentro do container será a raiz desse projeto ( /var/projects/api ) e é esperado que o início da aplicação ( index.php ) esteja sob o subdiretório public pois foi configurado pensando na estrutura de arquivos utilizada pelo framework Laravel.

### Criar imagem e rodar num container

Para conseguir rodar essa imagem num container é necessário montar a localmente para depois poder usá-la e para isso usamos o comando do docker `docker build -t <image-name>:<image-tag> <dokerfile-dir>` como o exemplo a baixo:

```bash
docker build -t web-server:stable .
```
Com a imagem montada podemos rodar o container com o comando do docker `docker run <options> <image>:<image-tag>`. Para as opções desse comando vamos usar estes:

- `-d`
- `-p` | `--ports <local-port>:<container-port>`
- `--env-file <env-file-path>`
- `--name <container-name>`

Um exemplo para rodar o container com a configuração inicial é o camando abaixo:

```bash
docker run -d --env-file .env -p 80:8080 --name web-server web-server:stable
```

Acessando o localhost em seu navegador ou o IP 127.0.0.1 já deverá ser possível ver as informações do PHP que está sendo utilizado geradas pela função `phpinfo();`. Mas para rodar um container com suas aplicações será necessário informar onde elas estão localmente, então vamos usar mais uma opção:

- `-v` | `--volume <local-path>:<container-path>`

Um exemplo seria o comando a baixo:

```
docker run -d --env-file .env -v ~/path/to/api-code-base:/var/projects/api -v ~/path/to/app-code-base:/var/projects/app -p 80:8080 -p 5432:5432 --name web-server web-server:stable
```

Note que agora estou passando dois diretórios com a flag -v que vai usar o conteúdo do diretório local no diretório remoto do container informado depois do `:`. Além disso também estou usando a flag -p para informar que a porta 5432 local deve ser redirecionada para a porta 5432 remota do container, isso é necessário quando utilizar um SGBD como o PgAdmin 4 para manipular o banco de dados localmente.

Agora você já sabe como inicializar um container usando uma imagem montada manualmente, parabéns!

### Usar o docker-compose

Se configurar o arquivo .env conforme especificado sobre o título `Detalhes do repositório`, basta usar o comando `docker-compose up -d` para que o container seja inicializado com todas as opções do arquivo .env. Fácil né?! 

## Usar os serviços do container no terminal local

Os serviços do container como php, psql, composer e etc poderão ser usados diretamente do seu terminal local usado pela IDE usando o comando `docker exec <options> <container-name> <command>`. Alguns exemplos:

```
docker exec -it web-server php -v
docker exec -it web-server postgres --version
docker exec -it web-server psql -U postgres
docker exec -it web-server psql <dbname> <pguser>
docker exec -it web-server composer install
```
OBS.: A flag -it é usada para informar que o output do comando no terminal local deverá ser interativo, ou seja, deverá se comportar exatamente como se estivesse no console do próprio container.

## Configuração do Xdebug na IDE

Com a diretivas do arquivo .env configuradas, o xdebug vai estar configurado para se conectar ao host remoto, mas para que tudo funcione conforme esperado é necessário configurar a IDE para que seja aberta uma sessão de debug, o Xdebug reconheça isso e aí sim se conectar de fato ao a IDE.

### VSCode PHP Debug

No VScode com a extensão PHP Debug instalada, o arquivo `.vscode/launch.json` deve possuir as propriedades `port` e `pathMappings` que vão ser usadas para criar um server local para debug. Em `port` deve ser configurado a mesma porta configurada no arquivo .env, e em `pathMappings` devem ser informados os diretórios  remoto e local que serão mapeados e possuem a raiz do projeto PHP que queremos debugar.

```
"configurations": [
  {
    "name": "Listen for XDebug",
    "type": "php",
    "request": "launch",
    "port": 9999,
    "pathMappings": {
      "/var/projects/api":"${workspaceRoot}"
    }
  }
]
```
O padrão é `"pathMappings": { "<container-path>":"<local-path>" }`

### PHPStorm PHP Debug

No PHPStorm é necessário cadastrar ou alterar um server local de debug e depois informar à IDE para utiliza-lo. Nesse caso com o Projeto aberto no PHPStorm, acesse o menu de debug no canto superior direito e selecione a opção `Edit configurations`, a tela de configurações gerais de debug será aberta.

Primeiro adicione um novo server por clicar no botão `+` no canto superior esquerdo, selecionar o tipo `PHP Remote Debug`, e configurar os campos:
- `Name` - Nome do server de debug, padrão é xDebug
- `Host` - Host que vai usar o server, padrão é 127.0.0.1
- `Port` - Mesma porta configurada no arquivo .env, padrão 9999
- `Debugger` - Xdebug

Obs.: É necessário marcar a opção `Use path mappings` para configurar qual diretório local será mapeado para o diretório remoto do container que armazena a raiz do seu projeto PHP.

Com o server de debug já cadastrado, na tela de configurações gerais de debug do PHPStorm é possível marcar a opção `Filter debug connection by IDE key`, selecionar o `Server` que apenas foi cadastrado e informar a `IDE Key` que será utilizada na sessão de debug no Xdebug.

:coffe: :coffe: :coffe: 

Espero que tenha gostado do conteúdo. Fique a vontade para enviar sugestões, ou entre em cotato comigo:

- E-mail: `iiaan.fr@gmail.com`

:smile: :smile: :smile: