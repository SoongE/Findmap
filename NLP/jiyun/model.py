from pororo import Pororo

class Model:

    def __init__(self):
        self.summ = Pororo(task="summarization", model="abstractive", lang="ko")
        self.zsl = Pororo(task="zero-topic")
        pass

    def summarize(self, contents):
        # summarize contents of the page
        return self.summ(contents)

    def categorize(self, contents, category_list):
        # categorize contents
        return self.zsl(contents, category_list)
