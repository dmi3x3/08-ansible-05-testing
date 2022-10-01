# Домашнее задание к занятию "08.05 Тестирование Roles"

## Подготовка к выполнению
1. Установите molecule: `pip3 install "molecule==3.5.2"`
2. Выполните `docker pull aragast/netology:latest` -  это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри

## Основная часть

Наша основная цель - настроить тестирование наших ролей. Задача: сделать сценарии тестирования для vector. Ожидаемый результат: все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s centos8` внутри корневой директории clickhouse-role, посмотрите на вывод команды.
2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
  
  Добавил ubuntu:latest, centos:7, centos:8

Ошибки - molecule попросил изменить имя роли c vector-role на vector в vector-role/meta/main.yml

4. Добавьте несколько assert'ов в verify.yml файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска, etc). Запустите тестирование роли повторно и проверьте, что оно прошло успешно.

добавил проверку версии vector, т.к. с проверкой конфига проблема, если в нем указан недоступный в данный момент сервер кликхаус проверка завершается с ошибкой.

```shell
that: "'{{ vector_version.rc }}' == '0'"
```
5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

Ответ:  [vector-role с molecule](https://github.com/dmi3x3/vector-role/tree/1.1.0)

### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example)
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo - путь до корня репозитория с vector-role на вашей файловой системе.
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.

```shell
_________________ summary _______________________
  py37-ansible210: commands succeeded
  py37-ansible30: commands succeeded
  py39-ansible210: commands succeeded
  py39-ansible30: commands succeeded
  congratulations :)
root@13113f4d6bcf:/opt/vector-role#
```

4. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.
5. Пропишите правильную команду в `tox.ini` для того чтобы запускался облегчённый сценарий.
6. Запустите команду `tox`. Убедитесь, что всё отработало успешно.
```shell
TASK [vector-role : Create vector.toml] ****************************************
ok: [centos7s]

PLAY RECAP *********************************************************************
centos7s                   : ok=12   changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Idempotence completed successfully.
INFO     Running centos7_lite > verify
INFO     Running Ansible Verifier

PLAY [Verify] ******************************************************************

TASK [Get Vector version] ******************************************************
ok: [centos7s]

TASK [Assert Vector instalation] ***********************************************
ok: [centos7s] => {
    "changed": false,
    "msg": "All assertions passed"
}

PLAY RECAP *********************************************************************
centos7s                   : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Verifier completed successfully.
INFO     Running centos7_lite > destroy

PLAY [Destroy] *****************************************************************

TASK [Destroy molecule instance(s)] ********************************************
changed: [localhost] => (item={'command': '/usr/sbin/init', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'wheel', 'container': 'docker'}, 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7s', 'pre_build_image': True, 'privileged': True, 'tmpfs': ['/run', '/tmp'], 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:ro']})

TASK [Wait for instance(s) deletion to complete] *******************************
FAILED - RETRYING: Wait for instance(s) deletion to complete (300 retries left).
FAILED - RETRYING: Wait for instance(s) deletion to complete (299 retries left).
FAILED - RETRYING: Wait for instance(s) deletion to complete (298 retries left).
changed: [localhost] => (item={'started': 1, 'finished': 0, 'ansible_job_id': '350503966011.114969', 'results_file': '/root/.ansible_async/350503966011.114969', 'changed': True, 'failed': False, 'item': {'command': '/usr/sbin/init', 'env': {'ANSIBLE_USER': 'ansible', 'DEPLOY_GROUP': 'deployer', 'SUDO_GROUP': 'wheel', 'container': 'docker'}, 'image': 'docker.io/pycontribs/centos:7', 'name': 'centos7s', 'pre_build_image': True, 'privileged': True, 'tmpfs': ['/run', '/tmp'], 'volumes': ['/sys/fs/cgroup:/sys/fs/cgroup:ro']}, 'ansible_loop_var': 'item'})

PLAY RECAP *********************************************************************
localhost                  : ok=2    changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
_________________________________________________________________________________________________ summary __________________________________________________________________________________________________
  py37-ansible210: commands succeeded
  py37-ansible30: commands succeeded
  py39-ansible210: commands succeeded
  py39-ansible30: commands succeeded
  congratulations :)
```
7. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получиться два сценария molecule и один tox.ini файл в репозитории. Ссылка на репозиторий являются ответами на домашнее задание. Не забудьте указать в ответе теги решений Tox и Molecule заданий.


Описание:
1. Molecule.
 БОльшая часть времени ушла на настройку и подготовку стека для запуска тестов. Vector использует systemd для запуска сервиса.
Поэтому требовался контейнер с рабочим systemd, в этой области давние проблемы между разработчиками docker и systemd.
В общем случае для использования systemd в контейнере, требуется при запуске контейнера добавить параметр privileged: true (docker-compose или molecule.yml)
или --privileged=True (при запуске docker из консоли) и подключение каталога cgroup с хост-системы - volumes: - /sys/fs/cgroup:/sys/fs/cgroup:ro или -v /sys/fs/cgroup:/sys/fs/cgroup.
Еще одна немаловажная деталь: в качестве docker-init должен быть указан процесс /lib/systemd/systemd или его симлинк /usr/sbin/init иначе любая команда с systemctl будет аварийно заканчиваться с сообщением

```shell
System has not been booted with systemd as init system (PID 1). Can't operate.
Failed to connect to bus: Host is down
```

Но в контейнерах с centos 7 и 8 systemd так и не заработал, пришлось применить ["эмулятор" systemd на python](https://github.com/gdraheim/docker-systemctl-replacement), который обладает ограниченным функционалом, по сравнению с оригинальным systemctl.
Скрипт systemctl-replacement охватывает функциональные возможности диспетчера служб, в котором выполняются команды вида - systemctl start xx. Это достигается за счет разбора *.service файлов.
Чтобы упростить себе задачу и ускорить пподготовку к тесту, в molecule.yml использовал параметр pre_build_image: true, контейнер запускался без Dockerfile (со своим Dockerfile пщ-умолчанию), поэтому установку systemctl.py скрипта производил в pre_tasks файла converge.yml


Контейнер с ubuntu удалось запустить с systemd, причем исключительно без проброса /sys/fs/cgroup. 
Здесь было удобнее использовать  pre_build_image: false и создать свой Dockerfile, с необходимым набором пакетов.

2. Tox.

Из-за того, что в качестве docker-init в tox образе используется /bin/bash, я получил ошибку при запуске tox:
```shell
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible210/bin/molecule test -s compatibility --destroy=always (exited with code 1)
```
и соответственно
```shell
______________________________ summary ___________________________________
ERROR:   py37-ansible210: commands failed
ERROR:   py37-ansible30: keyboardinterrupt
ERROR:   py39-ansible210: undefined
ERROR:   py39-ansible30: undefined
```
запустил c /usr/sbin/init

```shell
docker run --privileged=True -v /home/dmitriy/docker_for_molecule/roles_test/vector-role:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /usr/sbin/init
```
из другой консоли подключился

```shell
docker exec -ti sharp_jennings /bin/bash
```

в данном образе нет docker
```shell
[root@942cd1eef7ec vector-role]# docker
bash: docker: command not found
[root@942cd1eef7ec vector-role]# yum install docker
Failed loading plugin "product-id": No module named 'urllib3.packages.six'
Failed loading plugin "upload-profile": No module named 'urllib3.packages.six'
Failed loading plugin "subscription-manager": No module named 'urllib3.packages.six'
Red Hat Universal Base Image 8 (RPMs) - BaseOS                                                                                                                              4.7 kB/s | 3.8 kB     00:00    
Red Hat Universal Base Image 8 (RPMs) - BaseOS                                                                                                                              2.2 MB/s | 803 kB     00:00    
Red Hat Universal Base Image 8 (RPMs) - AppStream                                                                                                                            34 kB/s | 4.2 kB     00:00    
Red Hat Universal Base Image 8 (RPMs) - AppStream                                                                                                                           5.6 MB/s | 3.0 MB     00:00    
Red Hat Universal Base Image 8 (RPMs) - CodeReady Builder                                                                                                                    23 kB/s | 3.8 kB     00:00    
Red Hat Universal Base Image 8 (RPMs) - CodeReady Builder                                                                                                                    60 kB/s |  20 kB     00:00    
Dependencies resolved.
============================================================================================================================================================================================================
 Package                                       Architecture                        Version                                                               Repository                                    Size
============================================================================================================================================================================================================
Installing:
 podman-docker                                 noarch                              2:4.1.1-2.module+el8.6.0+15917+093ca6f8                               ubi-8-appstream                               63 k
Upgrading:
 podman                                        x86_64                              2:4.1.1-2.module+el8.6.0+15917+093ca6f8                               ubi-8-appstream                               12 M
 podman-catatonit                              x86_64                              2:4.1.1-2.module+el8.6.0+15917+093ca6f8                               ubi-8-appstream                              350 k

Transaction Summary
============================================================================================================================================================================================================
Install  1 Package
Upgrade  2 Packages

Total download size: 13 M
Is this ok [y/N]: y
Downloading Packages:
(1/3): podman-docker-4.1.1-2.module+el8.6.0+15917+093ca6f8.noarch.rpm                                                                                                       343 kB/s |  63 kB     00:00    
(2/3): podman-catatonit-4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64.rpm                                                                                                    1.5 MB/s | 350 kB     00:00    
(3/3): podman-4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64.rpm                                                                                                              6.9 MB/s |  12 MB     00:01    
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                                                                                       7.1 MB/s |  13 MB     00:01     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Preparing        :                                                                                                                                                                                    1/1 
  Running scriptlet: podman-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64                                                                                                                              1/1 
  Upgrading        : podman-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64                                                                                                                              1/5 
  Upgrading        : podman-catatonit-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64                                                                                                                    2/5 
  Installing       : podman-docker-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.noarch                                                                                                                       3/5 
  Cleanup          : podman-catatonit-2:4.0.2-6.module+el8.6.0+14877+f643d2d6.x86_64                                                                                                                    4/5 
  Cleanup          : podman-2:4.0.2-6.module+el8.6.0+14877+f643d2d6.x86_64                                                                                                                              5/5 
  Running scriptlet: podman-2:4.0.2-6.module+el8.6.0+14877+f643d2d6.x86_64                                                                                                                              5/5 
  Verifying        : podman-docker-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.noarch                                                                                                                       1/5 
  Verifying        : podman-catatonit-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64                                                                                                                    2/5 
  Verifying        : podman-catatonit-2:4.0.2-6.module+el8.6.0+14877+f643d2d6.x86_64                                                                                                                    3/5 
  Verifying        : podman-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64                                                                                                                              4/5 
  Verifying        : podman-2:4.0.2-6.module+el8.6.0+14877+f643d2d6.x86_64                                                                                                                              5/5 

Upgraded:
  podman-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64                                           podman-catatonit-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.x86_64                                          
Installed:
  podman-docker-2:4.1.1-2.module+el8.6.0+15917+093ca6f8.noarch                                                                                                                                              

Complete!
```
После его установки ( в качестве docker используется podman), ошибка меняется.
```shell
CRITICAL Failed to pre-validate.

{'driver': [{'name': ['unallowed value docker']}]}
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible30/bin/molecule test -s compatibility --destroy=always (exited with code 1)
```
нет связи docker c molecule, доустанавливаю molecule-docker

```shell
[root@942cd1eef7ec vector-role]# /opt/vector-role/.tox/py37-ansible30/bin/python -m pip install molecule-docker
Collecting molecule-docker
  Downloading molecule_docker-1.1.0-py3-none-any.whl (16 kB)
Requirement already satisfied: selinux in ./.tox/py37-ansible30/lib/python3.7/site-packages (from molecule-docker) (0.2.1)
Requirement already satisfied: molecule>=3.4.0 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from molecule-docker) (3.4.0)
Requirement already satisfied: ansible-compat>=0.5.0 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from molecule-docker) (1.0.0)
Collecting docker>=4.3.1
  Downloading docker-6.0.0-py3-none-any.whl (147 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 147.2/147.2 KB 2.1 MB/s eta 0:00:00
Requirement already satisfied: requests in ./.tox/py37-ansible30/lib/python3.7/site-packages (from molecule-docker) (2.28.1)
Requirement already satisfied: cached-property~=1.5 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from ansible-compat>=0.5.0->molecule-docker) (1.5.2)
Requirement already satisfied: subprocess-tee>=0.3.5 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from ansible-compat>=0.5.0->molecule-docker) (0.3.5)
Requirement already satisfied: PyYAML in ./.tox/py37-ansible30/lib/python3.7/site-packages (from ansible-compat>=0.5.0->molecule-docker) (5.4.1)
Requirement already satisfied: urllib3>=1.26.0 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from docker>=4.3.1->molecule-docker) (1.26.12)
Collecting websocket-client>=0.32.0
  Downloading websocket_client-1.4.1-py3-none-any.whl (55 kB)
     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 55.0/55.0 KB 10.5 MB/s eta 0:00:00
Requirement already satisfied: packaging>=14.0 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from docker>=4.3.1->molecule-docker) (21.3)
Requirement already satisfied: rich>=9.5.1 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from molecule>=3.4.0->molecule-docker) (12.5.1)
Requirement already satisfied: click<9,>=8.0 in ./.tox/py37-ansible30/lib/python3.7/site-packages (from molecule>=3.4.0->molecule-docker) (8.1.3)
```
опять ошибка
```shell
Installing 'community.docker:3.1.0' to '/root/.ansible/collections/ansible_collections/community/docker'
Downloading https://galaxy.ansible.com/download/community-docker-3.1.0.tar.gz to /root/.ansible/tmp/ansible-local-347jo11v0ui/tmp317lg8nz
[0;31mERROR! Unexpected Exception, this is probably a bug: <urlopen error _ssl.c:1074: The handshake operation timed out>[0m
to see the full traceback, use -vvv

WARNING  An error occurred during the test sequence action: 'dependency'. Cleaning up.
INFO     Running compatibility > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running compatibility > destroy
INFO     Sanity checks: 'docker'
```

Такую ошибку можно исправить, пересобрав python (./configure --with-ssl-default-suites=openssl), поэтому взял более удобный для себя образ ubuntu (systemd на нем работает стабильно) и собрал [контейнер на нем](Dockerfile)
добавил туда переустановку molecule-docker (pip3 install molecule-docker).

создание контейнера

```shell
docker build -t tox_u_vector .
```

строка запуска:

```shell
docker run --privileged=True --name tox_roles -v ~/netology/run-mnt-homeworks_1/08-ansible-05-testing/roles/vector-role:/opt/vector-role/ -w /opt/vector-role tox_u_vector
```

tox выполнился без ошибок.
```shell
```shell
_________________ summary _______________________
  py37-ansible210: commands succeeded
  py37-ansible30: commands succeeded
  py39-ansible210: commands succeeded
  py39-ansible30: commands succeeded
  congratulations :)
root@13113f4d6bcf:/opt/vector-role#
```

во время решения ошибок tox, приходилось постоянно запускать и преравать его, очень помог ключ -r, --recreate force recreation of virtual environments (default: False)
т.к. без него tox валился с ошибками без видимых причин.


Ответ:
1. molecule
#### [vector-role с molecule](https://github.com/dmi3x3/vector-role/tree/1.1.0) 
#### [molecule](https://github.com/dmi3x3/vector-role/tree/1.1.0/molecule)

2. tox
#### [vector-role для tox](https://github.com/dmi3x3/vector-role/tree/1.2.0)
#### [molecule](https://github.com/dmi3x3/vector-role/tree/1.2.0/molecule)
#### [tox.ini для centos7_lite](https://github.com/dmi3x3/vector-role/blob/1.2.0/tox.ini)

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли lighthouse.
2. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
3. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
4. Выложите свои roles в репозитории. В ответ приведите ссылки.

---

### Как оформить ДЗ?

Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.

---
