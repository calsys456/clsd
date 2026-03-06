(defpackage "CLSD/RAW"
  (:use "CL" "CFFI"))

(in-package "CLSD/RAW")

(define-foreign-library libsystemd
  (:unix "libsystemd.so"))

(use-foreign-library libsystemd)

(defmacro define-sd-func (subject name ret-type &body args)
  (let* ((subject-str (translate-underscore-separated-name subject))
         (name-str (translate-underscore-separated-name name))
         (c-name (concatenate 'string "sd_" subject-str "_" name-str))
         (lisp-name (intern (concatenate
                             'string
                             (symbol-name subject) "-" (symbol-name name))
                            "CLSD/RAW")))
    `(eval-when (:compile-toplevel :load-toplevel :execute)
       (defcfun (,c-name ,lisp-name) ,ret-type
         ,@args)
       (export ',lisp-name))))

(defctype pid :int)
