# $if---anaphoric if with named subexpressions

For when you want to refer to a subexpression of condition from the true/false body.

## Examples
The comments show the name of the preceeding expression.

```scheme
($if (or (< 10 3) ;; $1
         (listp
          '(1 2 3) ;; $3
          ) ;; $2
         ) ;; $0
    (list $1 $2 (-sum $3))
  (do-some-stuff)) => (nil t 6)

($if (not
      (listp
       '(1 2 3) ;; $2
       ) ;; $1
      ) ;; $0
    (do-some-stuff)
  $2) => (1 2 3)

($if (+ 1 2 3 4) $0) => 10
;; this is equivalent to (--if-let (...) it) from dash
```
