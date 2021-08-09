import sys
import argparse

import torch
import torch.nn as nn
from torchtext import data

from mod_plustexttest import RNNClassifier


def define_argparser():
    '''
    Define argument parser to take inference using pre-trained model.
    '''
    p = argparse.ArgumentParser()

    p.add_argument('--model_fn', required=True)
    p.add_argument('--gpu_id', type=int, default=-1)
    p.add_argument('--batch_size', type=int, default=256)
    p.add_argument('--top_k', type=int, default=1)
    p.add_argument('--max_length', type=int, default=256)
    
    p.add_argument('--drop_rnn', action='store_true')
    
    config = p.parse_args()

    return config


def read_text(max_length=256):

    lines = []

    for line in sys.stdin:
        if line.strip() != '':
            lines += [line.strip().split(' ')[:max_length]]

    return lines


def define_field():
    '''
    To avoid use DataLoader class, just declare dummy fields. 
    With those fields, we can retore mapping table between words and indice.
    '''
    return (
        data.Field(
            use_vocab=True,
            batch_first=True,
            include_lengths=False,
        ),
        data.Field(
            sequential=False,
            use_vocab=True,
            unk_token=None,
        )
    )


def main(config):
    saved_data = torch.load(
        config.model_fn,
        map_location='cpu' if config.gpu_id < 0 else 'cuda:%d' % config.gpu_id
    )

    train_config = saved_data['config']
    rnn_best = saved_data['rnn']
    vocab = saved_data['vocab']
    classes = saved_data['classes']

    vocab_size = len(vocab)
    n_classes = len(classes)

    text_field, label_field = define_field()
    text_field.vocab = vocab
    label_field.vocab = classes

    lines = read_text(max_length=config.max_length)

    with torch.no_grad():
        ensemble = []
        if rnn_best is not None and not config.drop_rnn:
            # rnn 모델 앙상블 -> parameter 설정
            model = RNNClassifier(
                input_size=vocab_size,
                word_vec_size=train_config.word_vec_size,
                hidden_size=train_config.hidden_size,
                n_classes=n_classes,
                n_layers=train_config.n_layers,
                dropout_p=train_config.dropout,
            )
            model.load_state_dict(rnn_best)
            ensemble += [model]
        

        y_hats = []
        # 게산으로 앙상블 게산.
        for model in ensemble:
            if config.gpu_id >= 0:
                model.cuda(config.gpu_id)
           
            model.eval()

            y_hat = []
            for idx in range(0, len(lines), config.batch_size):                
                
                x = text_field.numericalize(
                    text_field.pad(lines[idx:idx + config.batch_size]),
                    device='cuda:%d' % config.gpu_id if config.gpu_id >= 0 else 'cpu',
                )

                y_hat += [model(x).cpu()]
            
            y_hat = torch.cat(y_hat, dim=0)
          
            y_hats += [y_hat]

            model.cpu()
       
        y_hats = torch.stack(y_hats).exp()
        y_hats = y_hats.sum(dim=0) / len(ensemble) # 평균값
      

        probs, indice = y_hats.topk(config.top_k)

        for i in range(len(lines)):
            sys.stdout.write('%s\t%s\n' % (
                ' '.join([classes.itos[indice[i][j]] for j in range(config.top_k)]), 
                ' '.join(lines[i])
            ))


if __name__ == '__main__':
    config = define_argparser()
    main(config)