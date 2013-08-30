(use test http-client posix awful)

(define server-uri "http://localhost:8080")

(define (get path/vars)
  (let ((val (with-input-from-request
              (make-pathname server-uri path/vars)
              #f
              read-string)))
    (close-all-connections!)
    val))

(test-begin "awful-path-matchers")

(test-begin "<int>")
(test "2" (get "/foo/2"))
(test "6" (get "/foo/2/3"))
(test 'ok (handle-exceptions exn
            'ok
            (get "/foo/2.0")))
(test-end "<int>")

(test-begin "alist-ref")
(test "1" (get "/alist-ref/a"))
(test "2" (get "/alist-ref/b"))
(test "3" (get "/alist-ref/c"))
(test "no match" (get "/alist-ref/d"))
(test-end "alist-ref")

(test-begin "<string>")
(test "foo" (get "/string/foo"))
(test "foo-42" (get "/string-and-int/foo/42"))
(test-end "<string>")

(test-begin "<number>")
(test "43.0" (get "/number/42.0"))
(test-end "<number>")

(test-begin "sanitize-matchers")
(test "42" (get "/sane/42"))
(test-end "sanitize-matchers")

(test-end "awful-path-matchers")
