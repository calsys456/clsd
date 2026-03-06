(defpackage "CLSD"
  (:use "CL" "CFFI"))

(in-package "CLSD")

(define-foreign-library libsystemd
  (:unix "libsystemd.so"))

(use-foreign-library libsystemd)

(defcfun strerror :string
  (errno :int))

(defctype pid :int)
(defctype uid :uint)

(define-condition systemd-error (error)
  ((func :initarg :func
         :reader systemd-error-func)
   (args :initarg :args
         :reader systemd-error-args)
   (errno :initarg :errno
          :reader systemd-error-errno))
  (:report (lambda (condition stream)
             (format stream "~A(~{~A~^, ~}): ~A"
                     (systemd-error-func condition)
                     (systemd-error-args condition)
                     (strerror (- (systemd-error-errno condition)))))))
