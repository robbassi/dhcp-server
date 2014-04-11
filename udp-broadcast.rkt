#lang racket

(require racket/udp)
(define socket (udp-open-socket))
(define buffer (bytes 1 2 3 4))

(udp-connect! socket "192.168.1.255" 67)
(udp-send socket (string->bytes/utf-8 "some data"))