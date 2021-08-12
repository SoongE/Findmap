import torchtext
version = list(map(int, torchtext.__version__.split('.')))
if version[0] <= 0 and version[1] < 9:
    from torchtext import data
else:
    from torchtext.legacy import data


class DataLoader(object):
    

    def __init__(
        self, train_fn,
        batch_size=64,
        valid_ratio=.2,
        device=-1,
        max_vocab=999999,
        min_freq=1,
        use_eos=False,
        shuffle=True,
    ):
        
        super().__init__()

        
        self.label = data.Field(
            sequential=False,
            use_vocab=True,
            unk_token=None
        )
        self.text = data.Field(
            use_vocab=True,
            batch_first=True,
            include_lengths=False,
            eos_token='<EOS>' if use_eos else None,
        )

        
        train, valid = data.TabularDataset(
            path=train_fn,
            format='tsv', 
            fields=[
                ('label', self.label),
                ('text', self.text),
            ],
        ).split(split_ratio=(1 - valid_ratio))

       
        self.train_loader, self.valid_loader = data.BucketIterator.splits(
            (train, valid),
            batch_size=batch_size,
            device='cuda:%d' % device if device >= 0 else 'cpu',
            shuffle=shuffle,
            sort_key=lambda x: len(x.text),
            sort_within_batch=True,
        )

        
        self.label.build_vocab(train)
        self.text.build_vocab(train, max_size=max_vocab, min_freq=min_freq)