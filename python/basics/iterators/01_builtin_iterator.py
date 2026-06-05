arr = [1, 2, 3, 4, 5, 6]
it = iter(arr)
print(next(it))
print(next(it))
print(next(it))
print(next(it))
print(next(it))
print(next(it))
print(next(it)) # It will not run
"""
Traceback (most recent call last):
  File "example-01.py", line 9, in <module>
    print(next(it))
          ^^^^^^^^
StopIteration
"""


