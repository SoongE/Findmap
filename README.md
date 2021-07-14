## 빅데이터, AI기반 컨버전스 콘텐츠 마인드맵 앱개발

[![CI status](https://lab.hanium.or.kr/21_HF144/21_hf144/badges/main/pipeline.svg)](https://lab.hanium.or.kr/21_HF144/21_hf144/commits/main)

### Dockerizing flutter, flask, nodejs with Docker-Compose and Docker-Machine

**Stack:**
- Docker v1.11.1
- Docker Compose v1.7.1
- Docker Machine v0.7.0
- Nginx
- MySQL
- NodeJS API -> Main Server, Express behind Nginx reverse-proxy for high-performance http requests and json handling
- Python API -> Flask / Flask-RESTful behind Nginx reverse-proxy for data science (Python 2.7 for PyLucene integration)
- flutter

**Getting up and running:**
- Install Docker Toolbox - https://docs.docker.com/engine/getstarted/step_one/
- Run the following from a terminal within this project root: Becouse of privacy files, you can't run.
    
**Verify proper docker build from the browser:**
- Retrieve docker-machine ip address from the terminal/cmd prompt:

    `docker-machine ip`
    
- Static assets served from Nginx:
    - http://docker-machine-ip/
- Flask API REST end-point:
    - http://docker-machine-ip/flask-api/user
    - http://docker-machine-ip/flask-api/users
- NodeJS API REST end-point:
    - http://docker-machine-ip/node-api/user
    - http://docker-machine-ip/node-api/users
    
Reminder: "docker-machine-ip" above refers to the host IP of the docker-machine returned from the terminal on this command:

    docker-machine ip

Cheers!