#lang racket

(require (only-in file/sha1
                  bytes->hex-string)
         (only-in racket/function
                  identity)
         "util.rkt")

(provide bytes->dhcp-packet
         dhcp-packet->bytes
         (struct-out dhcp-packet))

(define-struct dhcp-packet
  (op htype hlen hops xid secs flags ciaddr yiaddr 
   siaddr giaddr chaddr sname file options) #:transparent)

(define rfc2131-packet-segments 
  '((1 . number) (1 . number) (1 . number) (1 . number)
    (4 . hex) (2 . number) (2 . number) (4 . ip-addr)
    (4 . ip-addr) (4 . ip-addr) (4 . ip-addr) (16 . hex)
    (64 . string) (128 . string) (340 . options)))

(define rfc2132-options
  '#hash((1 . ip-addr)
         (3 . ip-addr)
         (6 . ip-addr)
         (12 . string)
         (50 . ip-addr)
         (53 . number)
         (54 . ip-addr)
         (55 . list)
         (60 . string)
         (61 . hex)
         (81 . string)
         (116 . number)))

(define *magic-cookie* '(99 130 83 99))

(define (magic-cookie? bytes)
  (equal?  *magic-cookie* (bytes->list bytes)))

(define (bytes->option-pairs bytes (header-length 2))
  (let ((size (bytes-length bytes)))
    (if (> size header-length)
        (let* ((code (bytes-ref bytes 0))
               (value-length (bytes-ref bytes 1))
               (end (+ header-length value-length)))
          (if (>= size end)
              (if (equal? code 255)
                  '()
                  (let ((value (subbytes bytes header-length end))
                        (type (if (hash-has-key? rfc2132-options code)
                                  (hash-ref rfc2132-options code) '()))
                        (rest (subbytes bytes end)))
                    (cons (cons code ((get-transition type) value))
                          (bytes->option-pairs rest))))
              (error "Not enough bytes for option")))
        '())))

(define (dhcp-options->bytes dhcp-options)
  (apply bytes-append
         (apply bytes *magic-cookie*)
         (append
          (for/list ((option (hash->list dhcp-options)))
            (let* ((option-code (car option))
                   (option-type (if (hash-has-key? rfc2132-options option-code)
                                    (hash-ref rfc2132-options option-code) '()))
                   (transition (get-transition option-type 'to))
                   (value-bytes (transition (cdr option))))
              (apply bytes-append  
                     (bytes (car option))
                     (bytes (bytes-length value-bytes)) 
                     (list value-bytes))))
          (list (bytes 255)))))
  
(define (check-cookie bytes)
  (if (magic-cookie? (subbytes bytes 0 4))
        (subbytes bytes 4)
        (error "Invalid cookie")))

(define bytes->dhcp-options 
  (compose make-hash bytes->option-pairs check-cookie))

;; Type Transitions
;; defines the transitions of bytes->type and type->bytes
(define transitions
  `#hash((list . (,bytes->list . ,list->bytes))
         (ip-addr . (,bytes->list . ,list->bytes))
         (hex . (,bytes->hex-string . ,hex-string->bytes))
         (number . (,bytes->number . ,number->bytes))
         (string . (,bytes->string . ,string->bytes/utf-8))
         (options . (,bytes->dhcp-options . ,dhcp-options->bytes))))

;; locate the appropriate transition or identity
(define (get-transition type (direction 'from))
  (if (hash-has-key? transitions type)
      ((if (equal? direction 'from) car cdr) 
       (hash-ref transitions type))
      identity))

;; API

(define (bytes->dhcp-packet bytes)
  (apply make-dhcp-packet 
         (for/list ((i (in-naturals))
                    (segment rfc2131-packet-segments))
           (let* ((offset (apply + (map car (sublist rfc2131-packet-segments 0 i))))
                  (segment-length (car segment))
                  (segment-type (cdr segment))
                  (segment-bytes (subbytes bytes offset (+ offset segment-length))))
             ((get-transition segment-type) segment-bytes)))))

(define (dhcp-packet->bytes dhcp-packet)
  (apply bytes-append
         (for/list ((value (rest (vector->list (struct->vector dhcp-packet))))
                    (segment rfc2131-packet-segments))
           (let* ((segment-length (car segment))
                  (segment-type (cdr segment))
                  (transition (get-transition segment-type 'to))
                  (value-bytes (transition value))
                  (length-diff (- segment-length (bytes-length value-bytes))))
             (if (> length-diff 0)
                 (bytes-append value-bytes (make-bytes length-diff))
                 value-bytes)))))

