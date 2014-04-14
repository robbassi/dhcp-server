#lang racket

#|

 handles the storage of leases, and determines availibility of 
 addresses, generates offers based on subnet defined in config
 
 config format:

   bind_address = '(192 168 1 2)
   subnet = '(255 255 255 192)

 from these options it can be derived that the ip pool range goes 
 from 192.168.1.1 - 192.168.1.62

|#

;(define bind-address '(192 168 0 111))
;(define subnet '(255 255 0 0))
;(define reserved '((192 168 0 52)))

(define leases #hash())

(define-struct lease
  (mac-address ip-address state time))

;; reserve an ip for the given mac address
;; if a requested ip is provided, try and reserve it
(define (reserve-ip mac-address #:requested-ip [requested-ip #f])
  #t) ; returns ip

;; bind a previously reserved ip for a given mac-address
(define (lease-ip mac-address ip-address)
  #t) ; returns lease

;; check if the given ip-address is reserved or leased
(define (is-available? ip-address)
  #t)

;; check if the mac-address has an exisitng binding
(define (get-binding mac-address)
  #t)

;; increment an ip address based on the subnet, returns #f if limit reached
(define (increment-ip ip-addr subnet)
  (letrec ([done? #f]
           [next-ip-addr (reverse (for/list ([index (range 0 4)]
                                             [segment (reverse ip-addr)]
                                             [limit (reverse (max-segments subnet))])
                                    (if (and (not done?) (> limit 0))
                                        (if (< segment limit)
                                            (begin
                                              (set! done? #t)
                                              (add1 segment))
                                            (if (= index 0) 1 0))
                                        (if (not done?) 
                                            #f
                                            segment))))])
    (if (member #f next-ip-addr)
        #f
        next-ip-addr)))

;; based on the subnet, determine the maximum host numbers per segment, 
;; a 0 signifies the host segment
(define (max-segments subnet)
  (map - '(255 255 255 254) subnet))

;; development - given a starting ip exhaust all the addresses on the subnet
(define (generate-block start-ip subnet)
  (define next (increment-ip start-ip subnet))
  (if next
      (cons start-ip (generate-block next subnet))
      (list start-ip)))