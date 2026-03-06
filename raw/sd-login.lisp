(in-package "CLSD/RAW")

(define-sd-func pid get-session :int
  (pid pid)
  (ret-session :pointer))

(define-sd-func pid get-owner-uid :int
  (pid pid)
  (ret-uid :pointer))

(define-sd-func pid get-unit :int
  (pid pid)
  (ret-unit :pointer))

(define-sd-func pid get-user-unit :int
  (pid pid)
  (ret-unit :pointer))

(define-sd-func pid get-slice :int
  (pid pid)
  (ret-slice :pointer))

(define-sd-func pid get-user-slice :int
  (pid pid)
  (ret-slice :pointer))

(define-sd-func pid get-machine-name :int
  (pid pid)
  (ret-machine :pointer))

(define-sd-func pid get-cgroup :int
  (pid pid)
  (ret-cgroup :pointer))

(define-sd-func pidfd get-session :int
  (pidfd :int)
  (ret-session :pointer))

(define-sd-func pidfd get-owner-uid :int
  (pidfd :int)
  (ret-uid :pointer))

(define-sd-func pidfd get-unit :int
  (pidfd :int)
  (ret-unit :pointer))

(define-sd-func pidfd get-user-unit :int
  (pidfd :int)
  (ret-unit :pointer))

(define-sd-func pidfd get-slice :int
  (pidfd :int)
  (ret-slice :pointer))

(define-sd-func pidfd get-user-slice :int
  (pidfd :int)
  (ret-slice :pointer))

(define-sd-func pidfd get-machine-name :int
  (pidfd :int)
  (ret-machine :pointer))

(define-sd-func pidfd get-cgroup :int
  (pidfd :int)
  (ret-cgroup :pointer))

(define-sd-func peer get-session :int
  (fd :int)
  (ret-session :pointer))

(define-sd-func peer get-owner-uid :int
  (fd :int)
  (ret-uid :pointer))

(define-sd-func peer get-unit :int
  (fd :int)
  (ret-unit :pointer))

(define-sd-func peer get-user-unit :int
  (fd :int)
  (ret-unit :pointer))

(define-sd-func peer get-slice :int
  (fd :int)
  (ret-slice :pointer))

(define-sd-func peer get-user-slice :int
  (fd :int)
  (ret-slice :pointer))

(define-sd-func peer get-machine-name :int
  (fd :int)
  (ret-machine :pointer))

(define-sd-func peer get-cgroup :int
  (fd :int)
  (ret-cgroup :pointer))

(define-sd-func uid get-state :int
  (uid :unsigned-int)
  (ret-state :pointer))

(define-sd-func uid get-display :int
  (uid :unsigned-int)
  (ret-display :pointer))

(define-sd-func uid get-login-time :int
  (uid :unsigned-int)
  (ret-usec :pointer))

(define-sd-func uid is-on-seat :int
  (uid :unsigned-int)
  (require-active :int)
  (seat :string))

(define-sd-func uid get-sessions :int
  (uid :unsigned-int)
  (require-active :int)
  (ret-sessions :pointer))

(define-sd-func uid get-seats :int
  (uid :unsigned-int)
  (require-active :int)
  (ret-seats :pointer))

(define-sd-func session is-active :int
  (session :string))

(define-sd-func session is-remote :int
  (session :string))

(define-sd-func session get-state :int
  (session :string)
  (ret-state :pointer))

(define-sd-func session get-uid :int
  (session :string)
  (ret-uid :pointer))

(define-sd-func session get-username :int
  (session :string)
  (ret-username :pointer))

(define-sd-func session get-seat :int
  (session :string)
  (ret-seat :pointer))

(define-sd-func session get-start-time :int
  (session :string)
  (ret-usec :pointer))

(define-sd-func session get-service :int
  (session :string)
  (ret-service :pointer))

(define-sd-func session get-type :int
  (session :string)
  (ret-type :pointer))

(define-sd-func session get-class :int
  (session :string)
  (ret-clazz :pointer))

(define-sd-func session get-desktop :int
  (session :string)
  (ret-desktop :pointer))

(define-sd-func session get-display :int
  (session :string)
  (ret-display :pointer))

(define-sd-func session get-leader :int
  (session :string)
  (ret-leader :pointer))

(define-sd-func session get-remote-host :int
  (session :string)
  (ret-remote-host :pointer))

(define-sd-func session get-remote-user :int
  (session :string)
  (ret-remote-user :pointer))

(define-sd-func session get-tty :int
  (session :string)
  (ret-tty :pointer))

(define-sd-func session get-vt :int
  (session :string)
  (ret-vtnr :pointer))

(define-sd-func seat get-active :int
  (seat :string)
  (ret-session :pointer)
  (ret-uid :pointer))

(define-sd-func seat get-sessions :int
  (seat :string)
  (ret-sessions :pointer)
  (ret-uids :pointer)
  (ret-n-uids :pointer))

(define-sd-func seat can-multi-session :int
  (seat :string))

(define-sd-func seat can-tty :int
  (seat :string))

(define-sd-func seat can-graphical :int
  (seat :string))

(define-sd-func machine get-class :int
  (machine :string)
  (ret-clazz :pointer))

(define-sd-func machine get-ifindices :int
  (machine :string)
  (ret-ifindices :pointer))

(define-sd-func get seats :int
  (ret-seats :pointer))

(define-sd-func get sessions :int
  (ret-sessions :pointer))

(define-sd-func get uids :int
  (ret-users :pointer))

(define-sd-func get machine-names :int
  (ret-machines :pointer))

(define-sd-func login-monitor new :int
  (category :string)
  (ret :pointer))

(define-sd-func login-monitor unref :pointer
  (m :pointer))

(define-sd-func login-monitor flush :int
  (m :pointer))

(define-sd-func login-monitor get-fd :int
  (m :pointer))

(define-sd-func login-monitor get-events :int
  (m :pointer))

(define-sd-func login-monitor get-timeout :int
  (m :pointer)
  (ret-timeout-usec :pointer))
