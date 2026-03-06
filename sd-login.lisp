(in-package "CLSD")

(eval-when (:compile-toplevel :load-toplevel :execute)
  (macrolet ((def-get (arg field type)
               (let* ((fname (concatenate 'string (symbol-name arg) "-GET-" (symbol-name field)))
                      (fsym (intern fname "CLSD"))
                      (cfun (intern fname "CLSD/RAW"))
                      (cname (format nil "sd_~A_get_~A"
                                     (string-downcase arg)
                                     (translate-underscore-separated-name field))))
                 `(progn
                    (defun ,fsym (,arg)
                      (with-foreign-object (ret :pointer)
                        (let ((result (,cfun ,arg ret)))
                          (if (minusp result)
                              (error 'systemd-error :func ,cname :args '(,arg) :errno result)
                              ,(if (eq type :string)
                                   `(unwind-protect
                                         (mem-ref ret :string)
                                      (foreign-free (mem-ref ret :pointer)))
                                   `(mem-ref ret ,type))))))
                    (export ',fsym))))
             (def (field type)
               (cons 'progn
                     (loop for arg in '(pid pidfd peer)
                           collect `(def-get ,arg ,field ,type)))))
    (def session :string)
    (def owner-uid 'uid)
    (def unit :string)
    (def user-unit :string)
    (def slice :string)
    (def user-slice :string)
    (def machine-name :string)
    (def cgroup :string)

    (def-get uid state :string)
    (def-get uid display :string)
    (def-get uid login-time :uint64)

    (def-get session state :string)
    (def-get session uid 'uid)
    (def-get session username :string)
    (def-get session seat :string)
    (def-get session start-time :uint64)
    (def-get session service :string)
    (def-get session type :string)
    (def-get session class :string)
    (def-get session desktop :string)
    (def-get session display :string)
    (def-get session leader 'pid)
    (def-get session remote-host :string)
    (def-get session remote-user :string)
    (def-get session tty :string)
    (def-get session vt :uint)

    (def-get machine class :string)))

(defun uid-is-on-seat (uid seat &optional require-active)
  (declare (inline uid-is-on-seat)
           (type fixnum uid)
           (type boolean require-active)
           (type string seat))
  (= 1 (clsd/raw:uid-is-on-seat uid (if require-active 1 0) seat)))

(defun uid-get-sessions (uid &optional require-active)
  "Returns sessions of the user.
If REQUIRE-ACTIVE is T, only active sessions are returned.

The second value is the number of sessions returned."
  (declare (type fixnum uid)
           (type boolean require-active))
  (with-foreign-object (ret :pointer)
    (let ((result (clsd/raw:uid-get-sessions uid (if require-active 1 0) ret)))
      (if (minusp result)
          (error 'systemd-error :func "sd_uid_get_sessions" :args (list uid require-active) :errno result)
          (values (unwind-protect
                       (let ((lst (mem-ref ret :pointer)))
                         (unless (null-pointer-p lst)
                           (loop for i from 0
                                 until (null-pointer-p (mem-aref lst :pointer i))
                                 collect (mem-aref lst :string i)
                                 do (foreign-free (mem-aref lst :pointer i)))))
                    (foreign-free (mem-ref ret :pointer)))
                  result)))))

(defun uid-get-seats (uid &optional require-active)
  "Returns a list of seats (string) of the user is on.
if REQUIRE-ACTIVE is T, this will look for active seats only.

The second value is the number of seats returned."
  (declare (type fixnum uid)
           (type boolean require-active))
  (with-foreign-object (ret :pointer)
    (let ((result (clsd/raw:uid-get-seats uid (if require-active 1 0) ret)))
      (if (minusp result)
          (error 'systemd-error :func "sd_uid_get_seats" :args (list uid require-active) :errno result)
          (values (unwind-protect
                       (let ((lst (mem-ref ret :pointer)))
                         (unless (null-pointer-p lst)
                           (loop for i from 0
                                 until (null-pointer-p (mem-aref lst :pointer i))
                                 collect (mem-aref lst :string i)
                                 do (foreign-free (mem-aref lst :pointer i)))))
                    (foreign-free (mem-ref ret :pointer)))
                  result)))))

(defun session-is-active (session)
  "Returns T if the session is active."
  (declare (inline session-is-active)
           (type string session))
  (= 1 (clsd/raw:session-is-active session)))

(defun session-is-remote (session)
  "Returns T if the session is remote."
  (declare (inline session-is-remote)
           (type string session))
  (= 1 (clsd/raw:session-is-remote session)))

(defun seat-get-active (seat)
  "Returns the active session and active uid of the seat as two values.

Either value may be NIL, respectively."
  (declare (type string seat))
  (with-foreign-objects ((session :pointer)
                         (uid :pointer))
    (let ((result (clsd/raw:seat-get-active seat session uid)))
      (if (minusp result)
          (error 'systemd-error :func "sd_seat_get_active" :args (list seat) :errno result)
          (values (unless (null-pointer-p (mem-ref session :pointer))
                    (unwind-protect
                         (mem-ref session :string)
                      (foreign-free (mem-ref session :pointer))))
                  (unless (null-pointer-p (mem-ref uid :pointer))
                    (mem-ref uid 'uid)))))))

(defun seat-get-sessions (seat)
  "Returns a list of sessions on the seat.

Returns 3 values:
- the list of sessions
- the list of uids of the session belongs to
- the number of sessions."
  (declare (type string seat))
  (with-foreign-objects ((sessions :pointer)
                         (uids :pointer))
    (let ((result (clsd/raw:seat-get-sessions seat sessions uids (null-pointer))))
      (if (minusp result)
          (error 'systemd-error :func "sd_seat_get_sessions" :args (list seat) :errno result)
          (values (unwind-protect
                       (let ((lst (mem-ref sessions :pointer)))
                         (unless (null-pointer-p lst)
                           (loop for i from 0
                                 until (null-pointer-p (mem-aref lst :pointer i))
                                 collect (mem-aref lst :string i)
                                 do (foreign-free (mem-aref lst :pointer i)))))
                    (foreign-free (mem-ref sessions :pointer)))
                  (unwind-protect
                       (let ((lst (mem-ref uids :pointer)))
                         (unless (null-pointer-p lst)
                           (loop for i from 0
                                 until (null-pointer-p (mem-aref lst :pointer i))
                                 collect (mem-aref lst 'uid i))))
                    (foreign-free (mem-ref uids :pointer)))
                  result)))))

(defun seat-can-tty (seat)
  "Returns T if the seat can use TTYs."
  (declare (inline seat-can-tty)
           (type string seat))
  (= 1 (clsd/raw:seat-can-tty seat)))

(defun seat-can-graphical (seat)
  "Returns T if the seat is graphics compatible."
  (declare (inline seat-can-graphical)
           (type string seat))
  (= 1 (clsd/raw:seat-can-graphical seat)))

(defun machine-get-ifindices (machine)
  "Returns a list of network interface indices of the machine.

The second value is the number of indices returned."
  (declare (type string machine))
  (with-foreign-object (ret :pointer))
    (let ((result (clsd/raw:machine-get-ifindices machine ret)))
      (if (minusp result)
          (error 'systemd-error :func "sd_machine_get_ifindices" :args (list machine) :errno result)
          (values (unwind-protect
                       (let ((lst (mem-ref ret :pointer)))
                         (unless (null-pointer-p lst)
                           (loop for i from 0
                                 until (null-pointer-p (mem-aref lst :pointer i))
                                 collect (mem-aref lst :int i))))
                    (foreign-free (mem-ref ret :pointer)))
                  result))))

(export '(uid-is-on-seat
          uid-get-sessions uid-get-seats
          session-is-active session-is-remote
          seat-get-active seat-get-sessions seat-can-tty seat-can-graphical
          machine-get-ifindices))

(eval-when (:compile-toplevel :load-toplevel :execute)
  (macrolet ((def-get (what type)
               (let* ((what-name (string-downcase what))
                      (fname (concatenate 'string "GET-" (symbol-name what)))
                      (fsym (intern fname "CLSD"))
                      (cfun (intern fname "CLSD/RAW"))
                      (cname (concatenate 'string "sd_get_" what-name)))
                 `(progn
                    (defun ,fsym ()
                      ,(format nil "Returns a list of ~A.

The second value is the number of ~A returned."
                               what-name what-name)
                      (with-foreign-object (ret :pointer)
                        (let ((result (,cfun ret)))
                          (if (minusp result)
                              (error 'systemd-error :func ,cname :args nil :errno result)
                              (values (unwind-protect
                                           (let ((lst (mem-ref ret :pointer)))
                                             (unless (null-pointer-p lst)
                                               (loop for i from 0
                                                     until (null-pointer-p (mem-aref lst :pointer i))
                                                     collect (mem-aref lst ,type i)
                                                     ,@(when (eq type :string)
                                                         '(do (foreign-free (mem-aref lst :pointer i)))))))
                                        (foreign-free (mem-ref ret :pointer)))
                                      result)))))
                    (export ',fsym)))))
    (def-get seats :string)
    (def-get sessions :string)
    (def-get uids 'uid)
    (def-get machine-names :string)))

(defun login-monitor-new (category)
  (with-foreign-object (ret :pointer)
    (let ((result (clsd/raw:login-monitor-new category ret)))
      (if (minusp result)
          (error 'systemd-error :func "sd_login_monitor_new"
                                :args (list category ret)
                                :errno result)
          (mem-ref ret :pointer)))))

(export 'login-monitor-new)
