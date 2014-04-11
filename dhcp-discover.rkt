#lang racket

(require racket/udp)

(define req-socket (udp-open-socket))
(define res-socket (udp-open-socket))
(define req-buffer (make-bytes 548))
(define res-buffer (make-bytes 548))
(define dgram (apply bytes (append 
                            '(1) ;; 
                            )))

(udp-bind! res-socket #f 68)
(udp-connect! req-socket "255.255.255.255" 67)
(udp-send req-socket #"")
(udp-receive! res-socket res-buffer)
res-buffer