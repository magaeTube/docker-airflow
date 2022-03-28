# Airflow

## Apache Airflow 란 
* **Python 코드**로 Workflow를 작성하고 스케줄링, 모니터링하는 **오픈소스 플랫폼**
* Apache 재단 Top Level 프로젝트 
* **DAG (Directed Acyclic Graph)** 형태로 Workflow를 작성하여 ETL 작업을 자동화
* 공식 홈페이지 : https://airflow.apache.org/
* 깃허브 : https://github.com/apache/airflow

## Airflow Architecture
![image](https://user-images.githubusercontent.com/78892113/148876654-d409d475-124a-42de-98fb-efac570f51a3.png)
* **Webserver** : UI를 통해서 DAG과 태스크를 실행하고 관리하고 로그를 보는 등의 모니터링이 가능함
* **Scheduler** : 스케줄링된 Workflow를 Trigger하고 실행하기 위해 Executor로 Task를 보냄
* **Executor** : 실행중인 Task를 다루는 역할. 여러 종류가 있는데 각 Executor마다 실행 방식이 다름
  * Sequential Executor : Metadata Database를 SQLite로 이용하여 한번에 1개의 Task만 실행이 가능함
  * Local Executor : Metadata Database로 MySQL 또는 PostgreSQL을 이용하여 Task를 병렬 실행이 가능함
  * Celery Executor : Worker를 Scale out할 수 있는 구조로 (Celery) 실행이 가능함. Celery를 이용하기 위해 RabbitMQ나 Redis가 필요함
  * Kubernetes Executor : Kubernetes를 이용하여 Pod를 생성하며 실행이 가능함
  * 그 외에 Debug Executor, CeleryKubernetes Executor, Dask Executor가 있음
* **Worker** : Task가 실제로 실행되는 것.
* **Metadata Database** : Metadata를 저장하는 데이터베이스
<br><br>
* 현재 Redis를 이용한 <span style="color:red">**CeleryExecutor**</span>를 이용하고 Metadata Database로는 <span style="color:red">**MySQL**</span> 을 이용 

## Airflow Setup
### Local (Docker X)

```commandline
# 환경변수 설정 (필수)
export AIRFLOW_HOME=`pwd`/airflow


# Redis 설치 (Docker)
# CeleryExecutor를 사용할 때 설치
docker network create redis-net
docker run --name airflow_redis -p 6379:6379 --network redis-net -d redis redis-server --appendonly yes


# MySQL Server 설치 (Ubuntu)
# Metadata용 DB (PostgreSQL을 사용한다면 그에 맞게 설치)
sudo apt-get update
sudo apt-get install mysql-server
sudo apt-get install python3-dev libmysqlclient-dev gcc

sudo ufw allow mysql
sudo systemctl start mysql
sudo systemctl enable mysql


# Python venv 설치 및 라이브러리 설치
python3 -m venv venv
source venv/bin/activate

# Docker가 아닌 직접 설치 시에는 requirements.txt에 Airflow 관련 패키지가 있어야함.
pip install -r requirements.txt


# Airflow 실행
# 정상적으로 실행이 되면 $AIRFLOW_HOME 경로에 각 프로세스의 .pid가 생성됨 
airflow webserver -p 8080 -D
airflow scheduler -D
airflow celery worker -D
airflow celery flower -D


# Airflow 중지 
# kill [pid]
```

### Docker
```commandline
# Docker 설치 (Ubuntu)
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common    # 필수 패키지 설치

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -    # GPG Key 인증


# Docker Repository 등록
sudo add-apt-repository \
"deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo systemctl enable docker 
sudo usermod -aG docker $USER


# Version 확인
docker -v


# Docker Compose 설치 (Ubuntu)
sudo curl -L "https://github.com/docker/compose/releases/download/v2.0.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
docker-compose -v


# Airflow 실행 
cd docker-airflow   # Airflow 프로젝트 디렉토리
docker network create airflow
docker-compose build
docker-compose up -d        # PC 1에서 모든걸 실행하고자 할 때 
docker-compose -f docker-compose-webserver.yml up -d    # Webserver, Scheduler, Redis, Flower만 실행하고자 할 때
docker-compose -f docker-compose-worker.yml up -d       # Worker만 실행하고자 할 때 


# 프로세스 확인
docker ps
```

### UI 확인 
**https://[Webserver가 설치된 주소]:8080**