(in-package "CLSD/RAW")

(defcenum event-state
  (:off 0)
  (:on 1)
  (:oneshot -1))

(defcenum event-loop-state
  :initial
  :armed
  :pending
  :running
  :exiting
  :finished
  :preparing)

(defconstant +event-priority-important+ -100)
(defconstant +event-priority-normal+ 0)
(defconstant +event-priority-idle+ 100)

(defconstant +event-signal-procmask+ (ash 1 30))

(define-sd-func event default :int
  (ret :pointer))

(define-sd-func event new :int
  (ret :pointer))

(define-sd-func event ref :pointer
  (e :pointer))

(define-sd-func event unref :pointer
  (e :pointer))

(define-sd-func event add-io :int
  (e :pointer)
  (ret :pointer)
  (fd :int)
  (events :uint32)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-time :int
  (e :pointer)
  (ret :pointer)
  (clock :int)
  (usec :uint64)
  (accuracy :uint64)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-time-relative :int
  (e :pointer)
  (ret :pointer)
  (clock :int)
  (usec :uint64)
  (accuracy :uint64)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-signal :int
  (e :pointer)
  (ret :pointer)
  (sig :int)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-child :int
  (e :pointer)
  (ret :pointer)
  (pid :int)
  (options :int)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-child-pidfd :int
  (e :pointer)
  (ret :pointer)
  (pidfd :int)
  (options :int)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-inotify :int
  (e :pointer)
  (ret :pointer)
  (path :string)
  (mask :uint32)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-inotify-fd :int
  (e :pointer)
  (ret :pointer)
  (fd :int)
  (mask :uint32)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-defer :int
  (e :pointer)
  (ret :pointer)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-post :int
  (e :pointer)
  (ret :pointer)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-exit :int
  (e :pointer)
  (ret :pointer)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event add-memory-pressure :int
  (e :pointer)
  (ret :pointer)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func event prepare :int
  (e :pointer))

(define-sd-func event wait :int
  (e :pointer)
  (timeout :uint64))

(define-sd-func event dispatch :int
  (e :pointer))

(define-sd-func event run :int
  (e :pointer)
  (timeout :uint64))

(define-sd-func event loop :int
  (e :pointer))

(define-sd-func event exit :int
  (e :pointer)
  (code :int))

(define-sd-func event now :int
  (e :pointer)
  (clock :int)
  (ret :pointer))

(define-sd-func event get-fd :int
  (e :pointer))

(define-sd-func event get-state :int
  (e :pointer))

(define-sd-func event get-tid :int
  (e :pointer)
  (ret :pointer))

(define-sd-func event get-exit-code :int
  (e :pointer)
  (ret :pointer))

(define-sd-func event set-watchdog :int
  (e :pointer)
  (b :int))

(define-sd-func event get-watchdog :int
  (e :pointer))

(define-sd-func event get-iteration :int
  (e :pointer)
  (ret :pointer))

(define-sd-func event set-signal-exit :int
  (e :pointer)
  (b :int))

(define-sd-func event set-exit-on-idle :int
  (e :pointer)
  (b :int))

(define-sd-func event get-exit-on-idle :int
  (e :pointer))

(define-sd-func event-source ref :pointer
  (s :pointer))

(define-sd-func event-source unref :pointer
  (s :pointer))

(define-sd-func event-source disable-unref :pointer
  (s :pointer))

(define-sd-func event-source get-event :pointer
  (s :pointer))

(define-sd-func event-source get-userdata :pointer
  (s :pointer))

(define-sd-func event-source set-userdata :pointer
  (s :pointer)
  (userdata :pointer))

(define-sd-func event-source set-description :int
  (s :pointer)
  (description :string))

(define-sd-func event-source get-description :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source set-prepare :int
  (s :pointer)
  (callback :pointer))

(define-sd-func event-source get-pending :int
  (s :pointer))

(define-sd-func event-source get-priority :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source set-priority :int
  (s :pointer)
  (priority :int64))

(define-sd-func event-source get-enabled :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source set-enabled :int
  (s :pointer)
  (enabled :int))

(define-sd-func event-source get-io-fd :int
  (s :pointer))

(define-sd-func event-source set-io-fd :int
  (s :pointer)
  (fd :int))

(define-sd-func event-source get-io-fd-own :int
  (s :pointer))

(define-sd-func event-source set-io-fd-own :int
  (s :pointer)
  (own :int))

(define-sd-func event-source get-io-events :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source set-io-events :int
  (s :pointer)
  (events :uint32))

(define-sd-func event-source get-io-revents :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source get-time :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source set-time :int
  (s :pointer)
  (usec :uint64))

(define-sd-func event-source set-time-relative :int
  (s :pointer)
  (usec :uint64))

(define-sd-func event-source get-time-accuracy :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source set-time-accuracy :int
  (s :pointer)
  (usec :uint64))

(define-sd-func event-source get-time-clock :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source get-signal :int
  (s :pointer))

(define-sd-func event-source get-child-pid :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source get-child-pidfd :int
  (s :pointer))

(define-sd-func event-source get-child-pidfd-own :int
  (s :pointer))

(define-sd-func event-source set-child-pidfd-own :int
  (s :pointer)
  (own :int))

(define-sd-func event-source get-child-process-own :int
  (s :pointer))

(define-sd-func event-source set-child-process-own :int
  (s :pointer)
  (own :int))

(define-sd-func event-source send-child-signal :int
  (s :pointer)
  (sig :int)
  (si :pointer)
  (flags :unsigned-int))

(define-sd-func event-source get-inotify-mask :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source get-inotify-path :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source set-memory-pressure-type :int
  (s :pointer)
  (ty :string))

(define-sd-func event-source set-memory-pressure-period :int
  (s :pointer)
  (threshold-usec :uint64)
  (window-usec :uint64))

(define-sd-func event-source set-destroy-callback :int
  (s :pointer)
  (callback :pointer))

(define-sd-func event-source get-destroy-callback :int
  (s :pointer)
  (ret :pointer))

(define-sd-func event-source get-floating :int
  (s :pointer))

(define-sd-func event-source set-floating :int
  (s :pointer)
  (b :int))

(define-sd-func event-source get-exit-on-failure :int
  (s :pointer))

(define-sd-func event-source set-exit-on-failure :int
  (s :pointer)
  (b :int))

(define-sd-func event-source set-ratelimit :int
  (s :pointer)
  (interval-usec :uint64)
  (burst :unsigned-int))

(define-sd-func event-source get-ratelimit :int
  (s :pointer)
  (ret-interval-usec :pointer)
  (ret-burst :pointer))

(define-sd-func event-source is-ratelimited :int
  (s :pointer))

(define-sd-func event-source set-ratelimit-expire-callback :int
  (s :pointer)
  (callback :pointer))

(define-sd-func event-source leave-ratelimit :int
  (s :pointer))

(define-sd-func event trim-memory :void)
