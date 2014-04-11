#lang racket

(require racket/udp
         "dhcp.rkt"
         "packet.rkt"
         "ipdb.rkt")
#|
(define in-socket (udp-open-socket))

(udp-bind! socket #f 67)

(let loop ()
  (let* ((buffer (make-bytes 576)))
    (udp-receive! socket buffer)
    (handle-request (bytes->dhcp-packet buffer))))
|#

;(define (listen)
;  (define buffer (make-bytes 576))
;  (udp-receive! socket buffer)
;  (let ((packet (bytes->dhcp-packet buffer)))
;    (set! packets (cons packet packets))
;    (printf "~v\n" packet))
;  (listen))




;; example request
;(udp-send out-socket (dhcp-packet->bytes (dhcp-packet 1 1 6 0 "bb23d886" 3 128 '(0 0 0 0) '(0 0 0 0) '(0 0 0 0) '(0 0 0 0) "a41731f6450000000000000000000000" "" "" '#hash((61 . "01a41731f64500") (12 . "Rob-Laptop") (55 . (1 15 3 6 44 46 47 31 33 121 249 43)) (54 . (192 168 1 52)) (53 . 1) (50 . (192 168 1 34)) (60 . "MSFT 5.0") (81 . "Rob-Laptop")))))

;; actual dhcp message
; (define packet2 #"\1\1\6\0\272\357\271\26\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\204\246\310#\2\332\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0c\202Sc5\1\0012\4\300\250\1\2057\a\1\34\2\3\17\6\f\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0-3.11.6-1-ARCH:x86_64:GenuineIntel\f\6laptop7\16\1y!\3\6\f\17\34*36:;w\377\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0")

(define out-socket (udp-open-socket))
(udp-bind! out-socket #f 67)

(let loop ()
  (define incoming-bytes (make-bytes 576))
  (udp-receive! out-socket incoming-bytes)
  (define packet (bytes->dhcp-packet incoming-bytes))
  (printf "~a\n" packet)
;  (cond
;    ((discover? packet))
;    ((request? packet))
;    ((decline? packet)))
;    ((release? packet))
;    ((inform? packet))
  (loop))


