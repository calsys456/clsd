(in-package "CLSD/RAW")

(defcenum device-action
  :add
  :remove
  :change
  :move
  :online
  :offline
  :bind
  :unbind
  :max)

(define-sd-func device ref :pointer
  (device :pointer))

(define-sd-func device unref :pointer
  (device :pointer))

(define-sd-func device new-from-syspath :int
  (ret :pointer)
  (syspath :string))

(define-sd-func device new-from-devnum :int
  (ret :pointer)
  (type :int)
  (devnum :uint64))

(define-sd-func device new-from-subsystem-sysname :int
  (ret :pointer)
  (subsystem :string)
  (sysname :string))

(define-sd-func device new-from-device-id :int
  (ret :pointer)
  (id :string))

(define-sd-func device new-from-stat-rdev :int
  (ret :pointer)
  (st :pointer))

(define-sd-func device new-from-devname :int
  (ret :pointer)
  (devname :string))

(define-sd-func device new-from-path :int
  (ret :pointer)
  (path :string))

(define-sd-func device new-from-ifname :int
  (ret :pointer)
  (ifname :string))

(define-sd-func device new-from-ifindex :int
  (ret :pointer)
  (ifindex :int))

(define-sd-func device new-child :int
  (ret :pointer)
  (device :pointer)
  (suffix :string))

(define-sd-func device get-parent :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-parent-with-subsystem-devtype :int
  (device :pointer)
  (subsystem :string)
  (devtype :string)
  (ret :pointer))

(define-sd-func device get-syspath :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-subsystem :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-driver-subsystem :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-devtype :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-devnum :int
  (device :pointer)
  (devnum :pointer))

(define-sd-func device get-ifindex :int
  (device :pointer)
  (ifindex :pointer))

(define-sd-func device get-driver :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-devpath :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-devname :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-sysname :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-sysnum :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-action :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-seqnum :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-diskseq :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-device-id :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-is-initialized :int
  (device :pointer))

(define-sd-func device get-usec-initialized :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-usec-since-initialized :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-tag-first :string
  (device :pointer))

(define-sd-func device get-tag-next :string
  (device :pointer))

(define-sd-func device get-current-tag-first :string
  (device :pointer))

(define-sd-func device get-current-tag-next :string
  (device :pointer))

(define-sd-func device get-devlink-first :string
  (device :pointer))

(define-sd-func device get-devlink-next :string
  (device :pointer))

(define-sd-func device get-property-first :string
  (device :pointer)
  (value :pointer))

(define-sd-func device get-property-next :string
  (device :pointer)
  (value :pointer))

(define-sd-func device get-sysattr-first :string
  (device :pointer))

(define-sd-func device get-sysattr-next :string
  (device :pointer))

(define-sd-func device get-child-first :pointer
  (device :pointer)
  (ret-suffix :pointer))

(define-sd-func device get-child-next :pointer
  (device :pointer)
  (ret-suffix :pointer))

(define-sd-func device has-tag :int
  (device :pointer)
  (tag :string))

(define-sd-func device has-current-tag :int
  (device :pointer)
  (tag :string))

(define-sd-func device get-property-value :int
  (device :pointer)
  (key :string)
  (value :pointer))

(define-sd-func device get-trigger-uuid :int
  (device :pointer)
  (ret :pointer))

(define-sd-func device get-sysattr-value-with-size :int
  (device :pointer)
  (sysattr :string)
  (ret-value :pointer)
  (ret-size :pointer))

(define-sd-func device get-sysattr-value :int
  (device :pointer)
  (sysattr :string)
  (ret-value :pointer))

(define-sd-func device set-sysattr-value :int
  (device :pointer)
  (sysattr :string)
  (value :string))

(define-sd-func device trigger :int
  (device :pointer)
  (action :int))

(define-sd-func device trigger-with-uuid :int
  (device :pointer)
  (action :int)
  (ret-uuid :pointer))

(define-sd-func device open :int
  (device :pointer)
  (flags :int))

(define-sd-func device-enumerator new :int
  (ret :pointer))

(define-sd-func device-enumerator ref :pointer
  (enumerator :pointer))

(define-sd-func device-enumerator unref :pointer
  (enumerator :pointer))

(define-sd-func device-enumerator get-device-first :pointer
  (enumerator :pointer))

(define-sd-func device-enumerator get-device-next :pointer
  (enumerator :pointer))

(define-sd-func device-enumerator get-subsystem-first :pointer
  (enumerator :pointer))

(define-sd-func device-enumerator get-subsystem-next :pointer
  (enumerator :pointer))

(define-sd-func device-enumerator add-match-subsystem :int
  (enumerator :pointer)
  (subsystem :string)
  (match :int))

(define-sd-func device-enumerator add-match-sysattr :int
  (enumerator :pointer)
  (sysattr :string)
  (value :string)
  (match :int))

(define-sd-func device-enumerator add-match-property :int
  (enumerator :pointer)
  (property :string)
  (value :string))

(define-sd-func device-enumerator add-match-property-required :int
  (enumerator :pointer)
  (property :string)
  (value :string))

(define-sd-func device-enumerator add-match-sysname :int
  (enumerator :pointer)
  (sysname :string))

(define-sd-func device-enumerator add-nomatch-sysname :int
  (enumerator :pointer)
  (sysname :string))

(define-sd-func device-enumerator add-match-tag :int
  (enumerator :pointer)
  (tag :string))

(define-sd-func device-enumerator add-match-parent :int
  (enumerator :pointer)
  (parent :pointer))

(define-sd-func device-enumerator allow-uninitialized :int
  (enumerator :pointer))

(define-sd-func device-enumerator add-all-parents :int
  (enumerator :pointer))

(define-sd-func device-monitor new :int
  (ret :pointer))

(define-sd-func device-monitor ref :pointer
  (m :pointer))

(define-sd-func device-monitor unref :pointer
  (m :pointer))

(define-sd-func device-monitor get-fd :int
  (m :pointer))

(define-sd-func device-monitor get-events :int
  (m :pointer))

(define-sd-func device-monitor get-timeout :int
  (m :pointer)
  (ret :pointer))

(define-sd-func device-monitor set-receive-buffer-size :int
  (m :pointer)
  (size :size))

(define-sd-func device-monitor attach-event :int
  (m :pointer)
  (event :pointer))

(define-sd-func device-monitor detach-event :int
  (m :pointer))

(define-sd-func device-monitor get-event :pointer
  (m :pointer))

(define-sd-func device-monitor get-event-source :pointer
  (m :pointer))

(define-sd-func device-monitor set-description :int
  (m :pointer)
  (description :string))

(define-sd-func device-monitor get-description :int
  (m :pointer)
  (ret :pointer))

(define-sd-func device-monitor is-running :int
  (m :pointer))

(define-sd-func device-monitor start :int
  (m :pointer)
  (callback :pointer)
  (userdata :pointer))

(define-sd-func device-monitor stop :int
  (m :pointer))

(define-sd-func device-monitor receive :int
  (m :pointer)
  (ret :pointer))

(define-sd-func device-monitor filter-add-match-subsystem-devtype :int
  (m :pointer)
  (subsystem :string)
  (devtype :string))

(define-sd-func device-monitor filter-add-match-tag :int
  (m :pointer)
  (tag :string))

(define-sd-func device-monitor filter-add-match-sysattr :int
  (m :pointer)
  (sysattr :string)
  (value :string)
  (match :int))

(define-sd-func device-monitor filter-add-match-parent :int
  (m :pointer)
  (device :pointer)
  (match :int))

(define-sd-func device-monitor filter-update :int
  (m :pointer))

(define-sd-func device-monitor filter-remove :int
  (m :pointer))
