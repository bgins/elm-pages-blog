---
{
  'type': 'blog',
  'author': 'Brian Ginsburg',
  'title': 'Haskell Merge Sort',
  'description': 'Haskell merge sort is fun and easy',
  'image': '/images/blog/mergesort/mergesort.jpg',
  'image-attribution': 'Kelsie DiPerna',
  'draft': false,
  'published': '2017-09-11',
}
---

One of the things I love about Haskell is its expressiveness. What is
full of process in an imperative language is often a simple
description in Haskell. As an example, consider one possible merge sort
implementation.

## merge

The `merge` function merges two sorted lists. The heads of each list
are compared, and the smaller element is prepended to a merge on the remaining
lists. When one list is empty, the other list holds the largest elements in
sorted order, and we can append these.

```haskell
merge :: Ord a => [a] -> [a] -> [a]
merge xs [] = xs
merge [] ys = ys
merge (x:xs) (y:ys)
  | x <= y = x : merge xs (y:ys)
  | otherwise = y : merge (x:xs) ys
```

The resulting list is sorted regardless of the length of the input lists.

```haskell
λ> merge [2,5,6] [1,3,4]
[1,2,3,4,5,6]
λ> merge [2,5,6] [1,3,4,7,8]
[1,2,3,4,5,6,7,8]
λ> merge [2,5,6,7,8] [1,3,4]
[1,2,3,4,5,6,7,8]
λ> merge [2,9,10] [1,3,4,7,8]
[1,2,3,4,7,8,9,10]
```

If one list is empty, the other list is immediately returned. If both lists are
empty, an empty list is returned.

```haskell
λ> merge [1,2,3] []
[1,2,3]
λ> merge [] [1,2,3]
[1,2,3]
λ> merge [] []
[]
```

## halve

The `halve` function splits a list into two halves with the `take` and `drop` functions.

```haskell
halve :: [a] -> ([a],[a])
halve xs = (take half xs, drop half xs)
    where half = length xs `div` 2
```

A couple of examples to demonstrate halving.

```haskell
λ> halve [1,2,3,4,5,6]
([1,2,3],[4,5,6])
λ> halve [1,2,3,4,5,6,7]
([1,2,3],[4,5,6,7])
λ> halve [1]
([],[1])
λ> halve []
([],[])
```

## msort

The `msort` function implements merge sort by recursively halving a list and
merging the sorted lists as they return. The merge starts by assembling
zero- and one-element lists returned from the `halve` base cases.

```haskell
msort :: Ord a => [a] -> [a]
msort [] = []
msort [x] = [x]
msort xs = merge (msort (fst halves)) (msort (snd halves))
    where halves = halve xs
```

The `msort` function can be tested on base cases and simple lists of even and
odd length.

```haskell
λ> msort []
[]
λ> msort [3]
[3]
λ> msort [3,1,2]
[1,2,3]
λ> msort [3,1,5,2]
[1,2,3,5]
λ> msort [3,1,5,2,5]
[1,2,3,5,5]
```

In terms of speed, a good low-level implementation of merge sort will outperform
the Haskell version. But Haskell provides another benefit.

## Type Inference

Notice that our merge sort implementation has stayed general by only using type
variables. This means we can sort `Char`, `String`, `Float`, and any other type
in the `Ord` typeclass.

```haskell
λ> msort ['a','c','f','b']
"abcf"
λ> msort ["erg","ech","ezh"]
["ech","erg","ezh"]
λ> msort [2.3, 1.1, 9.9, 5.4]
[1.1,2.3,5.4,9.9]
```

Alternative representations can also be inferred. The largest 64-bit integer is
9,223,372,036,854,775,807. What happens if we want to sort larger values?
Haskell will infer that we must be working with the arbitrary precision
`Integer` type instead of the bounded `Int` type.

```haskell
λ> msort [0,9223372036854775807,9223372036854775809,9223372036854775808]
[0,9223372036854775807,9223372036854775808,9223372036854775809]
```

## Conclusion

Expressiveness and type inference are a couple of the benefits of a Haskell
merge sort. The benefits should be weighed against the performance cost. A
Haskell merge sort implementation is probably not the best choice in some cases,
but it is a nice choice when you can make it.
