"""
Custom Iterator:
The iterator protocol requires two methods:
       1.  __iter__() → returns the iterator object
       2. __next__() → returns the next item, and raises StopIteration when finished

"""


class Counter:

    def __init__(self, value):
        self.value = value
        self.current = 0

    def __iter__(self):
        return self

    def __next__(self):
        if self.current >= self.value:
            raise StopIteration
        self.current += 1
        return self.current

# “Give me one item at a time.” 
counter = Counter(5)

for num in counter:
    print(num)
