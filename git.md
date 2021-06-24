# Command line instructions

## Git global setup

git config --global user.name "우다현"

git config --global user.email "wdh112139@gmail.com"

## Create a new repository

git clone https://lab.hanium.or.kr/21_HF144/21_hf144.git

cd 21_hf144

touch README.md

git add README.md

git commit -m "add README"

git push -u origin master

## Existing folder

cd existing_folder

git init

git remote add origin https://lab.hanium.or.kr/21_HF144/21_hf144.git

git add .

git commit -m "Initial commit"

git push -u origin master

## Existing Git repository

cd existing_repo

git remote rename origin old-origin

git remote add origin https://lab.hanium.or.kr/21_HF144/21_hf144.git

git push -u origin --all

git push -u origin --tags