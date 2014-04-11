#lang racket

(require racket/udp
         "packet.rkt")

(define (dhcp-discover? dhcp-packet) 
  (equal? (hash-ref! (dhcp-packet-options dhcp-packet)))
(define (dhcp-request? dhcp-packet) )
(define (dhcp-decline? dhcp-packet) )
(define (dhcp-release? dhcp-packet) )
(define (dhcp-inform? dhcp-packet) )
  
(define (verify-option dhcp-packet code value) 
  )