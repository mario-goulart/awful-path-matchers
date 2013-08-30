(use awful awful-path-matchers)

(page-template (lambda (content . args) content))

(enable-sxml #t)

(define-page (path-match "foo" <int>)
  (lambda (n)
    n))

(define-page (path-match "foo" <int> <int>)
  (lambda (a b)
    (* a b)))

(define-page (path-match "alist-ref" string->symbol)
  (lambda (key)
    (or (alist-ref key '((a . 1)
                         (b . 2)
                         (c . 3)))
        "no match")))

(define-page (path-match "string" <string>)
  (lambda (s)
    s))

(define-page (path-match "string-and-int" <string> <int>)
  (lambda (s n)
    (conc s "-" n)))
