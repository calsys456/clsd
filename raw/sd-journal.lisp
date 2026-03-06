(in-package "CLSD/RAW")

(defcenum log-priority
  (:emerg 0)
  :alert
  :crit
  :err
  :warning
  :notice
  :info
  :debug)

(defconstant +journal-local-only+ (ash 1 0))
(defconstant +journal-runtime-only+ (ash 1 1))
(defconstant +journal-system+ (ash 1 2))
(defconstant +journal-current-user+ (ash 1 3))
(defconstant +journal-os-root+ (ash 1 4))
(defconstant +journal-all-namespaces+ (ash 1 5))
(defconstant +journal-include-default-namespace+ (ash 1 6))
(defconstant +journal-take-directory-fd+ (ash 1 7))
(defconstant +journal-assume-immutable+ (ash 1 8))

(defcenum journal-wakeup-event
  :nop
  :append
  :invalidate)

(define-sd-func journal print :int
  (priority :int)
  (format :string)
  &rest)

(define-sd-func journal printv :int
  (priority :int)
  (format :string)
  (ap :pointer))

(define-sd-func journal send :int
  (format :string)
  &rest)

(define-sd-func journal sendv :int
  (iov :pointer)
  (n :int))

(define-sd-func journal perror :int
  (message :string))

(define-sd-func journal print-with-location :int
  (priority :int)
  (file :string)
  (line :string)
  (func :string)
  (format :string)
  &rest)

(define-sd-func journal printv-with-location :int
  (priority :int)
  (file :string)
  (line :string)
  (func :string)
  (format :string)
  (ap :pointer))

(define-sd-func journal send-with-location :int
  (file :string)
  (line :string)
  (func :string)
  (format :string)
  &rest)

(define-sd-func journal sendv-with-location :int
  (file :string)
  (line :string)
  (func :string)
  (iov :pointer)
  (n :int))

(define-sd-func journal perror-with-location :int
  (file :string)
  (line :string)
  (func :string)
  (message :string))

(define-sd-func journal stream-fd :int
  (identifier :string)
  (priority :int)
  (level-prefix :int))

(define-sd-func journal stream-fd-with-namespace :int
  (name-space :string)
  (identifier :string)
  (priority :int)
  (level-prefix :int))

(define-sd-func journal open :int
  (ret :pointer)
  (flags :int))

(define-sd-func journal open-namespace :int
  (ret :pointer)
  (name-space :string)
  (flags :int))

(define-sd-func journal open-directory :int
  (ret :pointer)
  (path :string)
  (flags :int))

(define-sd-func journal open-directory-fd :int
  (ret :pointer)
  (fd :int)
  (flags :int))

(define-sd-func journal open-files :int
  (ret :pointer)
  (paths :pointer)
  (flags :int))

(define-sd-func journal open-files-fd :int
  (ret :pointer)
  (fds :pointer)
  (n-fds :unsigned-int)
  (flags :int))

(define-sd-func journal open-container :int
  (ret :pointer)
  (machine :string)
  (flags :int))

(define-sd-func journal close :void
  (j :pointer))

(define-sd-func journal previous :int
  (j :pointer))

(define-sd-func journal next :int
  (j :pointer))

(define-sd-func journal step-one :int
  (j :pointer)
  (advanced :int))

(define-sd-func journal previous-skip :int
  (j :pointer)
  (skip :uint64))

(define-sd-func journal next-skip :int
  (j :pointer)
  (skip :uint64))

(define-sd-func journal get-realtime-usec :int
  (j :pointer)
  (ret :pointer))

(define-sd-func journal get-monotonic-usec :int
  (j :pointer)
  (ret-monotonic :pointer)
  (ret-boot-id :pointer))

(define-sd-func journal get-seqnum :int
  (j :pointer)
  (ret-seqnum :pointer)
  (ret-seqnum-id :pointer))

(define-sd-func journal set-data-threshold :int
  (j :pointer)
  (sz :size))

(define-sd-func journal get-data-threshold :int
  (j :pointer)
  (sz :pointer))

(define-sd-func journal get-data :int
  (j :pointer)
  (field :string)
  (data :pointer)
  (length :pointer))

(define-sd-func journal enumerate-data :int
  (j :pointer)
  (data :pointer)
  (length :pointer))

(define-sd-func journal enumerate-available-data :int
  (j :pointer)
  (data :pointer)
  (length :pointer))

(define-sd-func journal restart-data :void
  (j :pointer))

(define-sd-func journal add-match :int
  (j :pointer)
  (data :pointer)
  (size :size))

(define-sd-func journal add-disjunction :int
  (j :pointer))

(define-sd-func journal add-conjunction :int
  (j :pointer))

(define-sd-func journal flush-matches :void
  (j :pointer))

(define-sd-func journal seek-head :int
  (j :pointer))

(define-sd-func journal seek-tail :int
  (j :pointer))

(define-sd-func journal seek-monotonic-usec :int
  (j :pointer)
  (boot-id :pointer)
  (usec :uint64))

(define-sd-func journal seek-realtime-usec :int
  (j :pointer)
  (usec :uint64))

(define-sd-func journal seek-cursor :int
  (j :pointer)
  (cursor :string))

(define-sd-func journal get-cursor :int
  (j :pointer)
  (ret-cursor :pointer))

(define-sd-func journal test-cursor :int
  (j :pointer)
  (cursor :string))

(define-sd-func journal get-cutoff-realtime-usec :int
  (j :pointer)
  (from :pointer)
  (to :pointer))

(define-sd-func journal get-cutoff-monotonic-usec :int
  (j :pointer)
  (boot-id :pointer)
  (from :pointer)
  (to :pointer))

(define-sd-func journal get-usage :int
  (j :pointer)
  (ret-bytes :pointer))

(define-sd-func journal query-unique :int
  (j :pointer)
  (field :string))

(define-sd-func journal enumerate-unique :int
  (j :pointer)
  (data :pointer)
  (length :pointer))

(define-sd-func journal enumerate-available-unique :int
  (j :pointer)
  (data :pointer)
  (length :pointer))

(define-sd-func journal restart-unique :void
  (j :pointer))

(define-sd-func journal enumerate-fields :int
  (j :pointer)
  (field :pointer))

(define-sd-func journal restart-fields :void
  (j :pointer))

(define-sd-func journal get-fd :int
  (j :pointer))

(define-sd-func journal get-events :int
  (j :pointer))

(define-sd-func journal get-timeout :int
  (j :pointer)
  (timeout-usec :pointer))

(define-sd-func journal process :int
  (j :pointer))

(define-sd-func journal wait :int
  (j :pointer)
  (timeout-usec :uint64))

(define-sd-func journal reliable-fd :int
  (j :pointer))

(define-sd-func journal get-catalog :int
  (j :pointer)
  (ret :pointer))

(define-sd-func journal get-catalog-for-message-id :int
  (id :pointer)
  (ret :pointer))

(define-sd-func journal has-runtime-files :int
  (j :pointer))

(define-sd-func journal has-persistent-files :int
  (j :pointer))
