#lang racket

(require racket/udp
         "packet.rkt")

(provide dhcp-packet-type
         bytes->dhcp-packet
         dhcp-packet->bytes
         (struct-out dhcp-packet))

(define (dhcp-packet-type dhcp-packet)
  (match (hash-ref (dhcp-packet-options dhcp-packet) 53)
    [1 'discover]
    [3 'request]
    [4 'decline]
    [7 'release]
    [8 'inform]))