(in-package "CLSD")

(defvar *devices* nil
  "A list of all device objects created.")

(defvar *device-enumerators* nil
  "A list of all device enumerator pointers created.")

(defclass device ()
  ((object :initarg :object
           :accessor device-object)))

(defmethod initialize-instance ((self device)
                                &key
                                  object
                                  syspath
                                  devnum
                                  subsystem sysname
                                  device-id
                                  stat-rdev
                                  devname
                                  path
                                  ifname
                                  ifindex
                                  parent suffix

                                  (record-p t))
  (if object
      (setf (slot-value self 'object) object)
      (with-slots (object) self
        (macrolet ((new-from (&rest args)
                     (let ((fname (intern (format nil "DEVICE-NEW-FROM-~{~A~^-~}" args)
                                          "CLSD/RAW"))
                           (cname (format nil "sd_device_new_from_~{~A~^_~}"
                                          (mapcar #'translate-underscore-separated-name args))))
                       `(with-foreign-object (ret :pointer)
                          (let ((result (,fname ret ,@args)))
                            (if (minusp result)
                                (error 'systemd-error :func ,cname
                                                      :args (list ret ,@args)
                                                      :errno result)
                                (setf object (mem-ref ret :pointer))))))))
          (cond (syspath (new-from syspath))
                (devnum (new-from devnum))
                ((and subsystem sysname) (new-from subsystem sysname))
                ((or subsystem sysname)
                 (error "Must provide both subsystem and sysname"))
                (device-id (new-from device-id))
                (stat-rdev (new-from stat-rdev))
                (devname (new-from devname))
                (path (new-from path))
                (ifname (new-from ifname))
                (ifindex (new-from ifindex))
                ((and parent suffix)
                 (with-foreign-object (ret :pointer)
                   (let ((result (clsd/raw:device-new-child ret parent suffix)))
                     (if (minusp result)
                         (error 'systemd-error :func "sd_device_new_child"
                                               :args (list ret parent suffix)
                                               :errno result)
                         (setf object (mem-ref ret :pointer))))))
                (t (error "Incorrect initialization arguments for device"))))))
  (when record-p
    (push self *devices*)))

(defun device-unref (device)
  (check-type device device)
  (with-slots (object) device
    (clsd/raw:device-unref object)
    (setf object nil)
    (setf *devices* (delete device *devices*))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (macrolet ((def-get (name type)
               (let* ((fname (concatenate 'string "DEVICE-GET-" (symbol-name name)))
                      (fsym (intern fname "CLSD"))
                      (cfun (intern fname "CLSD/RAW"))
                      (cname (format nil "sd_device_get_~A"
                                     (translate-underscore-separated-name name))))
                 `(progn
                    (defun ,fsym (device)
                      (check-type device device)
                      (with-slots (object) device
                        (with-foreign-object (ret :pointer)
                          (let ((result (,cfun object ret)))
                            (if (minusp result)
                                (error 'systemd-error :func ,cname
                                                      :args (list object ret)
                                                      :errno result)
                                (mem-ref ret ,type))))))
                    (export ',fsym)))))
    (def-get syspath :string)
    (def-get subsystem :string)
    (def-get driver-subsystem :string)
    (def-get devtype :string)
    (def-get devnum :int)
    (def-get ifindex :int)
    (def-get driver :string)
    (def-get devpath :string)
    (def-get devname :string)
    (def-get sysname :string)
    (def-get sysnum :string)
    (def-get action :int)
    (def-get seqnum :uint64)
    (def-get diskseq :uint64)
    (def-get device-id :string)

    (def-get usec-initialized :uint64)
    (def-get usec-since-initialized :uint64)))

(defun device-initialized-p (device)
  (check-type device device)
  (with-slots (object) device
    (let ((result (clsd/raw:device-get-is-initialized object)))
      (case (signum result)
        (-1 (error 'systemd-error :func "sd_device_get_initialized"
                                  :args (list object)
                                  :errno result))
        (0 nil)
        (1 t)))))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (macrolet ((def-get-iter (name)
               (let* ((fsym       (intern (format nil "DEVICE-GET-~AS" name) "CLSD"))
                      (cfun-first (intern (format nil "DEVICE-GET-~A-FIRST" name) "CLSD/RAW"))
                      (cfun-next  (intern (format nil "DEVICE-GET-~A-NEXT" name) "CLSD/RAW")))
                 `(progn
                    (defun ,fsym (device)
                      ,(format nil "Return a list of all ~As of DEVICE." name)
                      (check-type device device)
                      (with-slots (object) device
                        (loop for result = (,cfun-first object) then (,cfun-next object)
                              until (null-pointer-p result)
                              collect result)))
                    (export ',fsym)))))
    (def-get-iter tag)
    (def-get-iter current-tag)
    (def-get-iter devlink)
    (def-get-iter sysattr)))

(defun device-get-properties (device)
  (check-type device device)
  (with-slots (object) device
    (loop for result = (with-foreign-object (ret :pointer)
                         (cons (clsd/raw:device-get-property-first object ret) (mem-ref ret :string)))
            then (with-foreign-object (ret :pointer)
                   (cons (clsd/raw:device-get-property-next object ret) (mem-ref ret :string)))
          until (null-pointer-p result)
          collect result)))

(defun device-get-children (device)
  (check-type device device)
  (with-slots (object) device
    (loop for result = (with-foreign-object (ret :pointer)
                         (cons (make-instance 'device
                                              :object (clsd/raw:device-get-child-first object ret))
                               (mem-ref ret :string)))
            then (with-foreign-object (ret :pointer)
                   (cons (make-instance 'device
                                        :object (clsd/raw:device-get-child-next object ret))
                         (mem-ref ret :string)))
          until (null-pointer-p result)
          collect result)))

(defun device-has-tag-p (device tag)
  (check-type device device)
  (check-type tag string)
  (with-slots (object) device
    (let ((result (clsd/raw:device-has-tag object tag)))
      (case (signum result)
        (-1 (error 'systemd-error :func "sd_device_has_tag"
                                  :args (list object tag)
                                  :errno result))
        (0 nil)
        (1 t)))))

(defun device-has-current-tag-p (device tag)
  (check-type device device)
  (check-type tag string)
  (with-slots (object) device
    (let ((result (clsd/raw:device-has-current-tag object tag)))
      (case (signum result)
        (-1 (error 'systemd-error :func "sd_device_has_current_tag"
                                  :args (list object tag)
                                  :errno result))
        (0 nil)
        (1 t)))))

(defun device-get-property-value (device property)
  (check-type device device)
  (check-type property string)
  (with-slots (object) device
    (with-foreign-object (ret :pointer)
      (let ((result (clsd/raw:device-get-property-value object property ret)))
        (if (minusp result)
            (error 'systemd-error :func "sd_device_get_property_value"
                                  :args (list object property ret)
                                  :errno result)
            (mem-ref ret :string))))))

(defun device-get-trigger-uuid (device)
  (check-type device device)
  (with-slots (object) device
    (with-foreign-object (ret :uint64 2)
      (let ((result (clsd/raw:device-get-trigger-uuid object ret)))
        (if (minusp result)
            (error 'systemd-error :func "sd_device_get_trigger_uuid"
                                  :args (list object ret)
                                  :errno result)
            (+ (ash (mem-aref ret :uint64 0) 64)
               (mem-aref ret :uint64 1)))))))

(defun device-get-sysattr-value (device sysattr)
  (check-type device device)
  (check-type sysattr string)
  (with-slots (object) device
    (with-foreign-object (ret-value :pointer)
      (let ((result (clsd/raw:device-get-sysattr-value object sysattr ret-value)))
        (if (minusp result)
            (error 'systemd-error :func "sd_device_get_sysattr_value_with_size"
                                  :args (list object sysattr ret-value ret-size)
                                  :errno result)
            (mem-ref ret-value :string))))))

(defun device-get-sysattr-value-with-size (device sysattr)
  (check-type device device)
  (check-type sysattr string)
  (with-slots (object) device
    (with-foreign-objects ((ret-value :pointer)
                           (ret-size :pointer))
      (let ((result (clsd/raw:device-get-sysattr-value-with-size object sysattr ret-value ret-size)))
        (if (minusp result)
            (error 'systemd-error :func "sd_device_get_sysattr_value_with_size"
                                  :args (list object sysattr ret-value ret-size)
                                  :errno result)
            (values (mem-ref ret-value :string)
                    (mem-ref ret-size :unsigned-long)))))))

(defun device-set-sysattr-value (device sysattr value)
  (check-type device device)
  (check-type sysattr string)
  (check-type value string)
  (with-slots (object) device
    (let ((result (clsd/raw:device-set-sysattr-value object sysattr)))
      (if (minusp result)
          (error 'systemd-error :func "sd_device_set_sysattr_value"
                                :args (list object sysattr value)
                                :errno result)
          value))))

(defun device-trigger (device action)
  (check-type device device)
  (check-type action fixnum)
  (with-slots (object) device
    (let ((result (clsd/raw:device-trigger object action)))
      (if (minusp result)
          (error 'systemd-error :func "sd_device_trigger"
                                :args (list object action)
                                :errno result)
          nil))))

(defun device-trigger-with-uuid (device action)
  (check-type device device)
  (check-type action fixnum)
  (with-slots (object) device
    (with-foreign-object (ret-uuid :uint64 2)
      (let ((result (clsd/raw:device-trigger-with-uuid object action ret-uuid)))
        (if (minusp result)
            (error 'systemd-error :func "sd_device_trigger_with_uuid"
                                  :args (list object action ret-uuid)
                                  :errno result)
            (+ (ash (mem-aref ret-uuid :uint64 0) 64)
               (mem-aref ret-uuid :uint64 1)))))))

(defun device-open (device flags)
  (check-type device device)
  (check-type flags fixnum)
  (with-slots (object) device
    (let ((result (clsd/raw:device-open object flags)))
      (if (minusp result)
          (error 'systemd-error :func "sd_device_open"
                                :args (list object flags)
                                :errno result)
          result))))

(defun enumerate-devices (&key
                            subsystems
                            subsystems-if-not
                            sysattrs
                            sysattrs-if-not
                            properties
                            properties-required
                            sysnames
                            sysnames-if-not
                            tags
                            parents
                            allow-uninitialized-p
                            add-all-parents-p)
  "PROPERTIES and PROPERTIES-REQUIRED shall be an alist of
 ((PROP . VALUE) ...), ALLOW-UNINITIALIZED-P and ADD-ALL-PARENTS-P
shall be boolean, others shall be lists. No argument means enumerate
all devices.

Return two values: a list of device objects matching the given
criteria, and the pointer of the enumerator structure used to
enumerate them.

The pointer of enumerator must be unref with DEVICE-ENUMERATOR-UNREF
when it is no longer needed. Devices returned by the enumerator will
be automatically unref when the enumerator is unrefed, thus they are
not recorded in *DEVICES*."
  (with-foreign-object (enumerator-ptr :pointer)
    (let ((result (clsd/raw:device-enumerator-new enumerator-ptr)))
      (if (minusp result)
          (error 'systemd-error :func "sd_device_enumerator_new"
                                :args (list enumerator-ptr)
                                :errno result)
          (let ((enumerator (mem-ref enumerator-ptr :pointer)))
            (push enumerator *device-enumerators*)
            (handler-case
                (progn
                  (dolist (subsystem subsystems)
                    (let ((res (clsd/raw:device-enumerator-add-match-subsystem enumerator subsystem 1)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_match_subsystem"
                                              :args (list enumerator subsystem)
                                              :errno res))))
                  (dolist (sysattr sysattrs)
                    (let ((res (clsd/raw:device-enumerator-add-match-sysattr enumerator sysattr 1)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_match_sysattr"
                                              :args (list enumerator sysattr)
                                              :errno res))))
                  (dolist (subsystem subsystems-if-not)
                    (let ((res (clsd/raw:device-enumerator-add-match-subsystem enumerator subsystem 0)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_match_subsystem"
                                              :args (list enumerator subsystem)
                                              :errno res))))
                  (dolist (sysattr sysattrs-if-not)
                    (let ((res (clsd/raw:device-enumerator-add-match-sysattr enumerator sysattr 0)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_match_sysattr"
                                              :args (list enumerator sysattr)
                                              :errno res))))
                  (loop for (prop . value) in properties
                        do (let ((res (clsd/raw:device-enumerator-add-match-property enumerator prop value)))
                             (when (minusp res)
                               (error 'systemd-error :func "sd_device_enumerator_add_match_property"
                                                     :args (list enumerator prop value)
                                                     :errno res))))
                  (loop for (prop . value) in properties-required
                        do (let ((res (clsd/raw:device-enumerator-add-match-property-required enumerator prop value)))
                             (when (minusp res)
                               (error 'systemd-error :func "sd_device_enumerator_add_match_property_required"
                                                     :args (list enumerator prop value)
                                                     :errno res))))
                  (dolist (sysname sysnames)
                    (let ((res (clsd/raw:device-enumerator-add-match-sysname enumerator sysname)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_match_sysname"
                                              :args (list enumerator sysname)
                                              :errno res))))
                  (dolist (sysname sysnames-if-not)
                    (let ((res (clsd/raw:device-enumerator-add-nomatch-sysname enumerator sysname)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_nomatch_sysname"
                                              :args (list enumerator sysname)
                                              :errno res))))
                  (dolist (tag tags)
                    (let ((res (clsd/raw:device-enumerator-add-match-tag enumerator tag)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_match_tag"
                                              :args (list enumerator tag)
                                              :errno res))))
                  (dolist (parent parents)
                    (let ((res (clsd/raw:device-enumerator-add-match-parent enumerator parent)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_match_parent"
                                              :args (list enumerator parent)
                                              :errno res))))
                  (when allow-uninitialized-p
                    (let ((res (clsd/raw:device-enumerator-allow-uninitialized enumerator)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_allow_uninitialized"
                                              :args (list enumerator)
                                              :errno res))))
                  (when add-all-parents-p
                    (let ((res (clsd/raw:device-enumerator-add-all-parents enumerator)))
                      (when (minusp res)
                        (error 'systemd-error :func "sd_device_enumerator_add_all_parents"
                                              :args (list enumerator)
                                              :errno res))))
                  (values (loop for device = (clsd/raw:device-enumerator-get-device-first enumerator)
                                  then (clsd/raw:device-enumerator-get-device-next enumerator)
                                until (null-pointer-p device)
                                collect (make-instance 'device :object device :record-p nil))
                          enumerator))
              (error (e)
                (device-enumerator-unref enumerator)
                (signal e))))))))

(defun device-enumerator-unref (enumerator)
  "Unref the enumerator returned by ENUMERATE-DEVICES, and remove it from *DEVICE-ENUMERATORS*.

All devices returned by the enumerator will be automatically unrefed."
  (declare (inline device-enumerator-unref))
  (clsd/raw:device-enumerator-unref enumerator)
  (setf *device-enumerators* (delete enumerator *device-enumerators*)))

(defun device-enumerator-unref-all ()
  "Unref all device enumerators recorded in *DEVICE-ENUMERATORS* and
clear the list.

All devices returned by the enumerators will be automatically unrefed."
  (declare (inline device-enumerator-unref))
  (dolist (enumerator *device-enumerators*)
    (clsd/raw:device-enumerator-unref enumerator))
  (setf *device-enumerators* nil))

(defmacro with-device (var-and-keys &rest body)
  "(WITH-DEVICE (VAR &key KEYS) BODY...)

Bind VAR to a device instance created with the given KEYS using
MAKE-INSTANCE, and execute body."
  (destructuring-bind (var . keys) var-and-keys
    `(let ((,var (make-instance 'device ,@keys)))
       (unwind-protect
            (progn ,@body)
         (device-unref ,var)))))

(defmacro with-enumerated-devices (var-and-keys &rest body)
  "(WITH-ENUMERATED-DEVICES (VAR &key KEYS) BODY...)

Bind VAR to a list of devices enumerated with DEVICE-ENUMERATE, and
execute body."
  (let ((enumerator (gensym "DEVICE-ENUMERATOR-")))
    (destructuring-bind (var . keys) var-and-keys
      `(multiple-value-bind (,var ,enumerator)
           (enumerate-devices ,@keys)
         (unwind-protect
              (progn ,@body)
           (device-enumerator-unref ,enumerator))))))

(defmacro do-enumerated-devices (var-and-keys &rest body)
  "(DO-ENUMERATED-DEVICES (VAR &key KEYS) BODY...)

Bind VAR to each device enumerated with DEVICE-ENUMERATE, and execute
body for each one using DOLIST."
  (let ((devices (gensym "DEVICES-"))
        (enumerator (gensym "DEVICE-ENUMERATOR-")))
    (destructuring-bind (var . keys) var-and-keys
      `(multiple-value-bind (,devices ,enumerator)
           (enumerate-devices ,@keys)
         (unwind-protect
              (dolist (,var ,devices)
                ,@body)
           (device-enumerator-unref ,enumerator))))))


(defun device-monitor-new ()
  (with-foreign-object (ret :pointer)
    (let ((result (clsd/raw:device-monitor-new ret)))
      (if (minusp result)
          (error 'systemd-error :func "sd_device_monitor_new"
                                :args (list ret)
                                :errno result)
          (mem-ref ret :pointer)))))

(export '(device device-object
          device-unref
          device-initialized-p
          device-get-properties device-get-children
          device-has-tag-p device-has-current-tag-p
          device-get-property-value device-get-trigger-uuid
          device-get-sysattr-value-with-size device-get-sysattr-value
          device-set-sysattr-value device-trigger
          device-trigger-with-uuid device-open
          enumerate-devices
          with-device with-enumerated-devices do-enumerated-devices
          device-monitor-new))
