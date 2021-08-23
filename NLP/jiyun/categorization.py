import pandas as pd
import fasttext
import datetime as dt


dt1 = dt.datetime.now()
date = dt1.strftime("%m%d%H%M%S")

# supervised learning으로 모델을 학습시킨다
model = fasttext.train_supervised('/home/jiyun/mount/NLP/train_jamo.txt', epoch=30, lr=0.6, dim=50)

# 학습된 모델을 load한다
# model = fasttext.load_model('/home/jiyun/mount/NLP/model/08122054_model.bin')

# test data를 불러온다
test_data = pd.read_csv("/home/jiyun/mount/NLP/test_jamo.txt", sep='\t')

# 특정 경로에 있는 data를 불러와 학습된 모델을 통해 test하고, 정확도를 출력한다.
result = model.test('/home/jiyun/mount/NLP/test_jamo.txt')
print('Precision', result[1])
print('Number of examples:', result[0])

# 예측 카테고리를 3개로 하여 모델의 정확도를 측정
predictions = []
test = test_data.set_index('title').T.to_dict('list')
num = test_data.shape[0]
right = 0
category = dict()

for title, label in test.items():
    pred = model.predict(title, k=3)[0]
    pred_label = [pred[0], pred[1], pred[2]]
    cp = False

    if label[0] not in category:
        category[label[0]] = 0

    for x in pred_label:
        if x == label[0]:
            right += 1
            category[label[0]] += 1
            cp = True
    if not cp:
        # (확인용) 정답을 예측하지 못했을 경우, 무엇으로 예측했는지 확인
        print(f'title: {title} \n pred: {pred_label} \n ans: {label[0]} \n\n')

# 예측 카테고리를 3개로 뽑았을 때의 정확도
accuracy = right / num * 100
print(f'accuracy: {accuracy}')

# 모델을 학습시켰을 경우, 해당 모델을 저장
model.save_model('/home/jiyun/mount/NLP/model/' + date + '_model.bin')

# 각 카테고리 별 정확도 출력
for k, v in category.items():
    print(k, v)
