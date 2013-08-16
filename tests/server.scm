(use awful awful-path-matchers)

(page-template (lambda (content . args) content))

(enable-sxml #t)

(define-page (path-match "foo" <int>)
  (lambda (n)
    n))

(define-page (path-match "foo" <int> <int>)
  (lambda (a b)
    (* a b)))
