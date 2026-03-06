(in-package "CLSD/RAW")

(defconstant +sd-emerg+ "<0>")
(defconstant +sd-alert+ "<1>")
(defconstant +sd-crit+ "<2>")
(defconstant +sd-err+ "<3>")
(defconstant +sd-warning+ "<4>")
(defconstant +sd-notice+ "<5>")
(defconstant +sd-info+ "<6>")
(defconstant +sd-debug+ "<7>")

(defconstant +sd-listen-fds-start+ 3)

(define-sd-func listen fds :int
  (unset-environment :int))

(define-sd-func listen fds-with-names :int
  (unset-environment :int)
  (names :pointer))

(define-sd-func is fifo :int
  (fd :int)
  (path :string))

(define-sd-func is special :int
  (fd :int)
  (path :string))

(define-sd-func is socket :int
  (fd :int)
  (family :int)
  (type :int)
  (listening :int))

(define-sd-func is socket-inet :int
  (fd :int)
  (family :int)
  (type :int)
  (listening :int)
  (port :uint16))

(define-sd-func is socket-sockaddr :int
  (fd :int)
  (type :int)
  (addr :pointer)
  (addr-len :unsigned-int)
  (listening :int))

(define-sd-func is socket-unix :int
  (fd :int)
  (type :int)
  (listening :int)
  (path :string)
  (length :size))

(define-sd-func is mq :int
  (fd :int)
  (path :string))

(defcfun (notify "sd_notify") :int
  (unset-environment :int)
  (state :string))
(export 'notify)

(define-sd-func notifyf :int
  (unset-environment :int)
  (format :string)
  &rest)

(define-sd-func pid notify :int
  (pid :int)
  (unset-environment :int)
  (state :string))

(define-sd-func pid notifyf :int
  (pid :int)
  (unset-environment :int)
  (format :string)
  &rest)

(define-sd-func pid notify-with-fds :int
  (pid :int)
  (unset-environment :int)
  (state :string)
  (fds :pointer)
  (n-fds :unsigned-int))

(define-sd-func pid notifyf-with-fds :int
  (pid :int)
  (unset-environment :int)
  (fds :pointer)
  (n-fds :size)
  (format :string)
  &rest)

(define-sd-func notify barrier :int
  (unset-environment :int)
  (timeout :uint64))

(define-sd-func pid notify-barrier :int
  (pid :int)
  (unset-environment :int)
  (timeout :uint64))

(define-sd-func pidfd get-inode-id :int
  (pidfd :int)
  (ret :pointer))

(defcfun (booted "sd_booted") :int)
(export 'booted)

(define-sd-func watchdog enabled :int
  (unset-environment :int)
  (usec :pointer))
