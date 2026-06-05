"""
Python List:
    - Mutable, Order & Heterogeneous
    - Dynamic

Top Methods:
    - append()
    - extend()
    - insert()
    - remove(first)
    - pop(last): if no index is given
    - count()
    - sort()
    - reverse()
    - copy()
This is a perfect use-case because:
    - Order matters
    - Data changes (mutable)
    - Frequent iteration
    - Occasional sorting

"""
arr = [1, 2, 3, 4, 5, 6, "True", False, "foo", "bar"]
# Example: append
arr.append(7)
print(arr)
# Output: [1, 2, 3, 4, 5, 6, 'True', False, 'foo', 'bar', 7]


stack = [1, 2, 3]
stack.append(4)  # push
print(stack)
stack.pop()
print(stack)
