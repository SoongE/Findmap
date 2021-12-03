# Findmap: 웹서핑의 지도

<div align="center">
<p align="center">
    <img src="https://lab.hanium.or.kr/21_HF144/21_hf144/uploads/f5aea3f4cfe4daa986392a3805c36976/logo.png" alt="logo" width="250" height="250"/>
</p>
<h4 align="center">AI기반 검색, 검색결과, 게시글 추천 SNS 서비스</h4>
<p align="center">
    <a href="https://lab.hanium.or.kr/21_HF144/21_hf144/commits/main">
        <img alt="pipeline status" src="https://lab.hanium.or.kr/21_HF144/21_hf144/badges/main/pipeline.svg" /></a>
    <a href="https://lab.hanium.or.kr/21_HF144/21_hf144/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/license-Apache--2.0-blue"></a>
    <a href="https://findmap.atlassian.net/">
        <img src="https://img.shields.io/static/v1?label=sprint 4&message=96%&color=green"></a>
    <br/>
    <img src="https://img.shields.io/badge/NPM-7.21.1-CB3837?style=flat-square&logo=npm"/>
    <img src="https://img.shields.io/badge/NodeJS-16.9-339933?style=flat-square&logo=Node.js"/>
    <img src="https://img.shields.io/badge/NginX-1.21.3-009639?style=flat-square&logo=nginx"/>
    <img src="https://img.shields.io/badge/MySQL-3.8-4479A1?style=flat-square&logo=mysql"/>
    <br/>
    <img src="https://img.shields.io/badge/Python-3.8-3776AB?style=flat-square&logo=python"/>
    <img src="https://img.shields.io/badge/Torch-1.8.1-EE4C2C?style=flat-square&logo=pytorch"/>
    <img src="https://img.shields.io/badge/Flask-2.0.2-000000?style=flat-square&logo=flask"/>
    <br/>
    <img src="https://img.shields.io/badge/Dart-2.15.0-0175C2?style=flat-square&logo=dart"/>
    <img src="https://img.shields.io/badge/Kotlin-1.3.50-0095D5?style=flat-square&logo=kotlin"/>
    <img src="https://img.shields.io/badge/Swift-4.2-FA7343?style=flat-square&logo=swift"/>
    <img src="https://img.shields.io/badge/Flutter-2.6.0-02569B?style=flat-square&logo=flutter"/>
</p>
<p align="center">
  <a href="#overview">Overview</a></a> * 
  <a href="#features">Features</a></a> * 
  <a href="#contributors">Contributors</a> * 
  <a href="#architecture">Architecture</a> * 
  <a href="#license">License</a> * 
  <a href="#reference">Reference</a>
</p>
<p align="center">
    Findmap은 2021 한이음 "21_HF144 빅데이터, AI기반 컨버전스 콘텐츠 마인드맵 앱개발" 프로젝트로 진행된 결과물입니다.
    <br/>
    상업적 목적을 띄고 있지 않으며, 팀 <b>Ajou Nice</b>에 의해 개발되었습니다.
    <br/>
    🏆2021 한이음 공모전 동상 수상🏆
    <br/>
    🏆ACK2021 우수상 수상🏆
</p>
</div>
## Overview

‘Findmap’은 Find와 Mindmap의 map을 합친 단어로 사용자들이 웹서핑할 때 헤매지 않도록 지도(맞춤 검색 결과, 맞춤 게시글 추천) 또는 마인드맵(맞춤 검색어)을 그려주어 방향성을 정해주고자 하는 이중적인 의미를 담아 만든 애플리케이션이다. 

‘Findmap’은 검색 시 사용자의 데이터를 기반으로 **맞춤 검색 결과**를 보여주고, 사용자가 검색할 것 같은 단어를 **예측해서 추천 검색어를 제시**한다. 또한, 검색 중 저장하고 싶은 게시글이 있을 때 나만의 아카이브에 **스크랩**하고 관리할 수 있다. 이와 더불어 **SNS** 기능을 추가해서 다른 사람들과 게시글을 공유하며 소통할 수 있다.

## Features

#### 검색어 추천

Findmap AI로 **적절한 검색어를 제공**하여 원활한 웹서핑 가능

#### 실시간 검색어

화젯거리인 검색어를 통해 **최신 트렌드 예측** 가능

#### 맞춤형 검색 결과

Findmap AI로 **검색 결과를 사용자 취향에 맞게 정렬**하여 검색 시간 최소화

####  맞춤형 게시글 추천

사용자의 취향을 바탕으로 **관심 있어 할 만한 글 제공**

#### 스크랩

원하는 글을 나만의 아카이브에 바로 **저장**

#### SNS

팔로우, 팔로잉 기능과 공유 기능을 통해 사용자 간 **상호작용** 가능

## Contributors

|                       **🐈 우다현**                        |                       **🐕 박지윤**                        |                       **🦅 승현수**                        |                       **🐣 오승민**                        |
| :-------------------------------------------------------: | :-------------------------------------------------------: | :-------------------------------------------------------: | :-------------------------------------------------------: |
| ![](https://avatars.githubusercontent.com/u/60066586?v=4) | ![](https://avatars.githubusercontent.com/u/51026374?v=4) | ![](https://avatars.githubusercontent.com/u/72781752?v=4) | ![](https://avatars.githubusercontent.com/u/53206234?v=4) |
|      [@defwdahyun0](https://github.com/defwdahyun0)       |         [@PrimWILL](https://github.com/PrimWILL)          |     [@SeungHyeon12](https://github.com/SeungHyeon12)      |           [@Rhcsky](https://github.com/rhcsky)            |
|                    Leader, Node Server                    |                        ML, Flutter                        |                     ML, Flask Server                      |                        PM, Flutter                        |

## Architecture

![System Architecture](https://lab.hanium.or.kr/21_HF144/21_hf144/uploads/a57b853151fb2ac57b6384dc09f615c7/system_architecture.png)

[API docs](https://lab.hanium.or.kr/21_HF144/21_hf144/wikis/home)

## License

`Findmap` project is [licensed](./LICENSE) under the terms of **the Apache License 2.0**.

## Reference

[PORORO](https://github.com/kakaobrain/pororo)

[FastText](https://github.com/facebookresearch/fastText)

[KoBERT](https://github.com/SKTBrain/KoBERT)



