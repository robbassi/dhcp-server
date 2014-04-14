#lang racket

(require racket/udp
         "dhcp.rkt"
         (prefix-in tcp: "ipdb.rkt"))

(define (start)
  (define (listen socket)
    (define buffer (make-bytes 576))
    (udp-receive! socket buffer)
    (handle-request (bytes->dhcp-packet buffer))
    (listen socket))
  (define socket (udp-open-socket))
  (udp-bind! socket #f 67)
  (listen socket)
  (udp-close socket))

(define (handle-request dhcp-packet)
  (match (dhcp-packet-type dhcp-packet)
    ['discover (printf "DHCPDISCOVER: ~a\n" dhcp-packet)]
    ['request (printf "DHCPREQUEST: ~a\n" dhcp-packet)]
    ['decline (printf "DHCPDECLINE: ~a\n" dhcp-packet)]
    ['release (printf "DHCPRELEASE: ~a\n" dhcp-packet)]
    ['inform (printf "DHCPINFORM: ~a\n" dhcp-packet)]))

(start)