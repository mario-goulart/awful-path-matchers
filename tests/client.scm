(use test http-client posix awful)

(define server-uri "http://localhost:8080")

(define (get path/vars)
  (let ((val (with-input-from-request
              (make-pathname server-uri path/vars)
              #f
              read-string)))
    (close-all-connections!)
    val))

(test "2" (get "/foo/2"))

(test "6" (get "/foo/2/3"))
