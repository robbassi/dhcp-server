#lang racket

(require "packet.rkt")

(define response-socket (udp-open-socket))
(udp-bind! response-socket #f 68)
(define packets '())
(define (listen)
  (define buffer (make-bytes 576))
  (udp-receive! response-socket buffer)
  (let ((packet (bytes->dhcp-packet buffer)))
    (set! packets (cons packet packets))
    (printf "~v\n" packet))
  (listen))