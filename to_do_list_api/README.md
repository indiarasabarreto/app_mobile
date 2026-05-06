# task-list: Aplicação de Gestão de Tarefas para Equipes

![Banner do Projeto](https://via.placeholder.com/1200x400?text=task-list+Flutter+e+Django)

## Visão Geral

O `task-list` é uma aplicação robusta desenvolvida para otimizar a organização e o gerenciamento de tarefas em equipes. Combinando um frontend intuitivo em **Flutter** com um backend poderoso em **Django REST Framework**, esta solução oferece uma experiência fluida para a criação, acompanhamento e conclusão de atividades.

## Funcionalidades Principais

*   **Criação e Gerenciamento de Tarefas:** Adicione novas tarefas com título, seção, responsável e status de conclusão.
*   **Organização por Seção:** Agrupe tarefas em seções para uma visualização mais clara e organizada.
*   **Atribuição de Responsáveis:** Designe tarefas a membros específicos da equipe.
*   **Controle de Status:** Marque tarefas como concluídas para acompanhar o progresso.
*   **API RESTful:** Backend escalável e bem estruturado para integração com diversas plataformas.

## Tecnologias Utilizadas

### Frontend (Mobile)

*   **Flutter:** Framework de UI do Google para a construção de aplicações nativas compiladas para mobile, web e desktop a partir de uma única base de código. (Nota: O código-fonte do frontend Flutter não está incluído neste repositório, que foca exclusivamente no backend.)

### Backend (API)

*   **Python:** Linguagem de programação principal.
*   **Django:** Framework web de alto nível para desenvolvimento rápido e design pragmático.
*   **Django REST Framework:** Toolkit flexível para construir APIs web robustas.
*   **SQLite:** Banco de dados leve e integrado, utilizado para desenvolvimento e testes.
*   **Gunicorn:** Servidor WSGI para aplicações Python.
*   **django-cors-headers:** Para lidar com políticas de Cross-Origin Resource Sharing (CORS).

## Como Rodar o Backend Localmente

Siga os passos abaixo para configurar e executar o backend da aplicação em seu ambiente local.

### Pré-requisitos

Certifique-se de ter o Python 3.x e o `pip` instalados em sua máquina.

### 1. Clonar o Repositório

```bash
git clone https://github.com/indiarasabarreto/task-list.git
cd task-list/to_do_list_api
```

### 2. Criar e Ativar um Ambiente Virtual

É altamente recomendável usar um ambiente virtual para gerenciar as dependências do projeto.

```bash
python3 -m venv venv
source venv/bin/activate  # No Linux/macOS
# venv\Scripts\activate   # No Windows
```

### 3. Instalar as Dependências

```bash
pip install -r ../requirements.txt
```

### 4. Rodar as Migrações do Banco de Dados

```bash
python manage.py makemigrations tasks
python manage.py migrate
```

### 5. Criar um Superusuário (Opcional)

Para acessar o painel administrativo do Django:

```bash
python manage.py createsuperuser
```

Siga as instruções no terminal para criar seu usuário.

### 6. Iniciar o Servidor de Desenvolvimento

```bash
python manage.py runserver
```

O backend estará disponível em `http://127.0.0.1:8000/`.

## Estrutura do Projeto (Backend)

*   `to_do_list_api/`: Configurações principais do projeto Django.
*   `tasks/`: Aplicação Django contendo os modelos, serializadores, views e URLs para o gerenciamento de tarefas.
    *   `models.py`: Define o modelo `Task` com campos como título, seção, responsável, status de conclusão, data de criação e atualização.
    *   `serializers.py`: Converte instâncias do modelo `Task` em formatos JSON/XML e vice-versa.
    *   `views.py`: Contém a lógica para as operações CRUD (Create, Read, Update, Delete) das tarefas, utilizando `ModelViewSet`.
    *   `urls.py`: Define as rotas da API para as tarefas.

## Endpoints da API (Exemplos)

Todos os endpoints estão sob `/tasks/`.

| Método | Endpoint         | Descrição                               |
| :----- | :--------------- | :-------------------------------------- |
| `GET`  | `/tasks/`        | Lista todas as tarefas.                 |
| `POST` | `/tasks/`        | Cria uma nova tarefa.                   |
| `GET`  | `/tasks/{id}/`   | Recupera uma tarefa específica por ID.  |
| `PUT`  | `/tasks/{id}/`   | Atualiza uma tarefa específica por ID.  |
| `DELETE`| `/tasks/{id}/`   | Exclui uma tarefa específica por ID.    |

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.

## Autor

**Indiara dos Santos Sá Barreto**
*   [GitHub](https://github.com/indiarasabarreto)
*   [LinkedIn](https://www.linkedin.com/in/indiara-sa-barreto/)

## Licença

Este projeto está licenciado sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes. (Nota: O arquivo LICENSE não foi encontrado no repositório, mas é uma boa prática incluí-lo.)
