# :zap: Docker Web Server :zap: NGINX + PHP-FPM + PostgreSQL :zap:

Um único container de aproximadamente 180MB, configurado para servir arquivos estáticos e aplicações PHP sobre a stack LEPP ( Linux + NGINX + PHP-FPM + PostgreSQL ). Já possui o composer pronto para ser usado no diretório de trabalho e o xdebug habilitado pronto para ser facilmente configurado e utilizado.

Agora que já sabe do que se trata, bora pegar um :coffee: e colocar as mãos na massa!

## Instalação Docker

É necessário possuir o docker devidamente instalado, para isso poderá escolher a plataforma utilizada [nessa página](https://docs.docker.com/engine/install/) e seguir os passos da instalação. Não esqueça de reiniciar o sistema operacional após a instalação ser concluída.

## Detalhes do repositório

Você pode usar essa configuração Docker, como ambiente de desenvolvimento em projetos que utilizem PHP e PostgreSQL. A estrutura de arquivos e pastas está da seguinte forma:

```
./
├── php/               # arquivos de configuração do docker
│   ├── config/
│   │   ├── nginx.conf
│   │   ├── php.ini
│   │   └── start
│   │
│   ├── DockerFile-php7
│   └── DockerFile-php8
│
├── src/                  # base de código inicial
│   ├── public/
│   │   └── index.php
│   │
│   └── index.html
│
├── .env-example
├── .gitignore
├── docker-compose.yaml-example
└── README.md
```

É possível usar essa configuração de 2 formas. A primeira é criando uma imagem do dockerfile e então roda-la em um container. A segunda é usar uma configuração do docker-compose para facilitar as configurações necessárias no momento da inicialização do container. Então vamos ver como usar as 2 formas:

Antes de mais nada, renomeie o arquivo `.env-example` na raiz do diretório para `.env`. Ele já possui uma configuração básica inicial para você testar sem ter que alterar qualquer diretiva, mas depois de configurado, será possível servir 3 domínios locais sendo um localhost contendo o resultado da função `phpinfo()`, uma aplicação PHP com domínio local personalizado, e outra aplicação estática também com domínio personalizado. Mas para melhor entendimento aqui está a lista de configurações possíveis do `.env`:

- `HOST_API` - Domínio local para acessar a aplicação PHP através do browser ( Esse domínio também deve estar no arquivo hosts do sistema operacional )

- `HOST_APP` - Domínio local para acessar a aplicação estática através do browser

- `HOST_API_DIR` - Diretório local onde está localizado seu projeto PHP

- `HOST_APP_DIR` - Diretório local onde está localizado sua aplicação estática / frontend

- `HOST_NGINX_PORT` - Porta local que será redirecionada para a porta 8080 do container ( O container será inicializado com usuário sem privilégios de root, por isso o Nginx está configurado para escutar a 8080 ao invés da porta 80 )

- `HOST_PG_PORT` - Porta local que será redirecionada para a porta 5432 do container ( PostgreSQL )

- `PHP_DIR` - Define a versão do PHP que será utilizada php7 ou php8 até o momento

- `XDEBUG_HOST` - Host remoto que o xDebug usará para conexão ( IPv4 do computador local na rede atual )

- `XDEBUG_PORT` - Porta remota que o xDebug usará para conexão

- `XDEBUG_IDE_KEY` - Chave de sessão utilizada para conexão ( o padrão para o VScode e PHPStorm são `vscode` e `PHPSTORM` respectivamente )

- `DB_DATABASE` - Nome da base de dados que o postgres vai criar

- `DB_USERNAME` - Nome do usuário que o postgres vai criar

- `DB_PASSWORD` - Senha do usuário que o postgres vai criar

Obs.: A aplicação PHP que chamei de api é a aplicação padrão que será servida pelo container, então o diretório de trabalho padrão no container será a raiz desse projeto ( /var/projects/api ) e é esperado que o início da aplicação ( index.php ) esteja no subdiretório ./public seguindo a estrutura de arquivos utilizada pelo Laravel Framework.

### Método 1: Criar imagem e rodar num container

Para conseguir rodar essa imagem num container é necessário montar a localmente para depois poder usá-la e para isso usamos o comando do docker `docker build -t <image-name>:<image-tag> <dokerfile-dir>` como o exemplo a baixo:

```bash
docker build  -t web-server:php7-nginx-pgsql \
              ./php7
```
Com a imagem montada podemos rodar o container com o comando do docker `docker run <options> <image>:<image-tag>`. Para as opções desse comando vamos usar estes:

- `-d`
- `-p` | `--ports <local-port>:<container-port>`
- `--env-file <env-file-path>`
- `--name <container-name>`

Um exemplo para rodar o container com a configuração inicial é o comando abaixo:

```bash
docker run  -d \
            --env-file .env \
            -p 80:8080 \
            --name web-server \
            web-server:php7-nginx-pgsql
```

Acessando o localhost em seu navegador ou o IP 127.0.0.1 já deverá ser possível ver as informações do PHP que está sendo utilizado geradas pela função `phpinfo();`. Mas para rodar um container com suas aplicações será necessário informar onde elas estão localmente, então vamos usar mais uma opção:

- `-v` | `--volume <local-path>:<container-path>`

Um exemplo seria o comando a baixo:

```
docker run  -d \
            --env-file .env \
            -v ~/path/to/api-code-base:/var/projects/api \
            -v ~/path/to/app-code-base:/var/projects/app \
            -p 80:8080 \
            -p 5432:5432 \
            --name web-server \
            web-server:php7-nginx-pgsql
```

Note que agora estou passando dois diretórios com a flag -v que vai usar o conteúdo do diretório local no diretório remoto do container informado depois do `:`. Além disso também estou usando a flag -p para informar que a porta 5432 local deve ser redirecionada para a porta 5432 remota do container, isso é necessário quando utilizar um SGBD como o PgAdmin 4 para manipular o banco de dados localmente.

Agora você já sabe como inicializar um container usando uma imagem montada manualmente, parabéns!

### Método 2: Usar o docker-compose

Depois de configurar o arquivo `.env` conforme especificado antes na seção `Detalhes do repositório`, basta usar o comando `docker-compose up -d` para que o container seja inicializado com todas as opções do arquivo .env ... Fácil, não é?!

## Usar os serviços do container no terminal local

Os serviços do container como php, psql, composer e etc poderão ser usados diretamente do seu terminal local usado pela IDE com o comando `docker exec <options> <container-name> <command>`. Alguns exemplos:

```
docker exec -it web-server php -v
docker exec -it web-server postgres --version
docker exec -it web-server psql -U postgres
docker exec -it web-server psql <dbname> <pguser>
docker exec -it web-server composer install
```
OBS.: A flag `-it` é usada para informar que a saída do comando no terminal local deverá ser interativo, ou seja, deverá se comportar exatamente como se estivesse no console do próprio container.

## Configuração do xDebug na IDE

Com a diretivas do arquivo .env configuradas, o xdebug vai estar configurado para se conectar ao host remoto, mas para que tudo funcione conforme esperado é necessário configurar a IDE para abrir uma sessão de debug quando desejado e o xDebug conseguir estabelecer conexão com a IDE.

### VSCode PHP Debug

No VScode com a extensão PHP Debug instalada, o arquivo `.vscode/launch.json` deve possuir as propriedades `port` e `pathMappings` que vão ser usadas para criar um server local para debug. Em `port` deve ser configurado a mesma porta configurada no arquivo .env, e em `pathMappings` devem ser informados os diretórios remoto e local que serão mapeados com a raiz do projeto PHP.

```
"configurations": [
  {
    "name": "xDebug",
    "type": "php",
    "request": "launch",
    "port": 9000,
    "pathMappings": {
      "/var/projects/api":"${workspaceRoot}"
    }
  }
]
```
O padrão é `"pathMappings": { "<container-path>":"<local-path>" }`

### PHPStorm PHP Debug

No PHPStorm é necessário cadastrar ou alterar um server local de debug para ser usado nas sessões de debug. Nesse caso, com o Projeto aberto no PHPStorm, acesse o menu de debug no canto superior direito e selecione a opção `Edit configurations`, a tela de configurações gerais de debug será aberta.

Clique no botão `+` no canto superior esquerdo, selecione o tipo `PHP Remote Debug`, e configure as opções abaixo:
- `Name` - Nome do server de debug, padrão é xDebug
- `Host` - Host que vai criar a sessão de debug, padrão é 127.0.0.1
- `Port` - Porta que a sessão de debug escutará, a mesma configurada no arquivo .env
- `Debugger` - Xdebug

Obs.: É necessário marcar a opção `Use path mappings` para mapear o diretório local para o diretório remoto do projeto PHP.

Depois de configurar as opções, na tela de configurações gerais de debug é possível marcar a opção `Filter debug connection by IDE key`, selecionar o `Server` que foi cadastrado e informar a `IDE Key` que será utilizada na sessão de debug no Xdebug, a mesma que foi configurada no arquivo .env.

☕ ☕ ☕

### Dicas

#### Git Line endings

Com essa configuração docker você estará desenvolvendo com um ambiente linux, então os arquivos do seu projeto PHP devem obrigatóriamente ter os delimitadores | line endings no padrão unix (LF). Então se você usa o Windows no dia a dia, é importante que configure o git para usar sempre esse padrão por executar o comando abaixo:

```
git config --global core.autocrlf input
```

#### Xdebug WSL

Caso você esteja usando o WSL 2 no windows, será necessário configurar a diretiva `xdebug.remote_host` sempre que reiniciar o Windows, pois o IP do WSL é alterado toda vez que o Windows é reiniciado. Poderá ser mais cômodo usar um shell script para alterar essa configuração manualmente no container através do WSL. Para isso crie um arquivo com o conteúdo a baixo e torne-o executável:

```bash
sudo vi /bin/xdebug-conf
```

```
IP=`ip route | awk '/default/ { print $3 }'`
docker exec -it $1 sed -i -E "s|xdebug.client_host=?.+|xdebug.client_host=$IP|" /etc/$PHP_DIR/conf.d/custom_php.ini
docker exec -it $1 sed -i -E "s|xdebug.client_port=?.+|xdebug.client_port=9000|" /etc/$PHP_DIR/conf.d/custom_php.ini
docker exec -it $1 sed -i -E "s|xdebug.idekey=?.+|xdebug.idekey=vscode|" /etc/$PHP_DIR/conf.d/custom_php.init
docker exec -it $1 rm /run/php7/php-fpm.sock
docker exec -it $1 php-fpm7
```

```bash
sudo chmod +x /bin/xdebug-conf
```

Feito isso, com o container rodando basta usar o comando `xdebug-conf <container-name>`

```bash
xdebug-conf web-server
```

### Contribuir

Espero que tenha gostado do conteúdo. Fique a vontade para enviar sugestões, ou entre em contato comigo:

- E-mail: `iiaan.fr@gmail.com`

😄 😄 😄
