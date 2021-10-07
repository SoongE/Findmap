import tqdm
import pandas as pd

def evaluate(test_df, prediction_result_df):
  groups_with_movie_ids = test_df.groupby(by='keywordidx')
  
  intersection_user_ids = sorted(list(set(list(prediction_result_df.columns)).intersection(set(list(groups_with_movie_ids.indices.keys())))))
  
  print(len(intersection_movie_ids))

  compressed_prediction_df = prediction_result_df.loc[intersection_user_ids][intersection_user_ids]
  # compressed_prediction_df

  # test_df에 대해서 RMSE 계산
  grouped = test_df.groupby(by='userId')
  result_df = pd.DataFrame(columns=['rmse'])
  for userId, group in tqdm(grouped):
      if userId in intersection_user_ids:
          pred_ratings = compressed_prediction_df.loc[userId][compressed_prediction_df.loc[userId].index.intersection(list(group['userId'].values))]
          pred_ratings = pred_ratings.to_frame(name='rating').reset_index().rename(columns={'index':'movieId','rating':'pred_rating'})
          actual_ratings = group[['rating', 'movieId']].rename(columns={'rating':'actual_rating'})

          final_df = pd.merge(actual_ratings, pred_ratings, how='inner', on=['userId'])
          final_df = final_df.round(4) # 반올림

          # if not final_df.empty:
          #     rmse = sqrt(mean_squared_error(final_df['rating_actual'], final_df['rating_pred']))
          #     result_df.loc[userId] = rmse
          #     # print(userId, rmse)
    
  return final_df