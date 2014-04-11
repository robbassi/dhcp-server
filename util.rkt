#lang racket

(provide (all-defined-out))

;;;Conversion Functions

(define (bytes->string bytes)
  (string-trim (bytes->string/utf-8 bytes) "\0" #:repeat? #t))

(define (bytes->number bytes)
  (if (equal? (bytes-length bytes) 1)
      (bytes-ref bytes 0)
      (integer-bytes->integer bytes #f)))

(define (number->bytes number)
  (if (number . < . 256)
      (bytes number)
      (integer->integer-bytes number 2 #f)))

(define (hex-string->bytes hex-string)
  (apply bytes (for/list ((i (range 0 (string-length hex-string) 2)))
                 (string->number (substring hex-string i (+ 2 i)) 16))))


;; select a sub-list from a list
(define (sublist lst start end)
  (map (λ (i) 
         (list-ref lst i))
       (range start end)))