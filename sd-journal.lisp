(in-package "CLSD")

(defun syslog-priority (priority)
  (etypecase priority
    ((integer 0 7) priority)
    (keyword (ecase priority
               ((or :emerg :panic) 0)
               (:alert 1)
               (:crit 2)
               ((or :err :error) 3)
               ((or :warning :warn) 4)
               (:notice 5)
               (:info 6)
               (:debug 7)))))

(defun construct-iovec-array-for-fields (fields)
  (let* ((ptr-size (foreign-type-size :pointer))
         (arr (foreign-alloc :pointer :count (* (length fields) 2)))
         (need-to-be-freed (list arr)))
    (loop for i from 0 below (* (length fields) 2) by 2
          for field of-type string in fields
          do (print field)
             (multiple-value-bind (cstr cstr-len)
                 (foreign-string-alloc field :null-terminated-p nil)
               (push cstr need-to-be-freed)
               (setf (mem-aref arr :pointer i) cstr
                     (mem-aref arr :unsigned-long (1+ i)) cstr-len)))
    (values arr (length fields) need-to-be-freed)))

;; We use sd_journal_sendv as it's async-signal-safe and most flexible...

(eval-when (:compile-toplevel :load-toplevel :execute)
  (macrolet ((push-field (field)
               (let ((field-name (string-upcase (translate-underscore-separated-name field))))
                 `(when ,field
                    (push (format nil ,(concatenate 'string field-name "=~A") ,field) fields))))
             (push-fields (fields)
               (cons 'progn (mapcar (lambda (field) `(push-field ,field)) fields)))
             (def ()
               (let ((optional-fields '(message-id
                                        code-file code-line code-func
                                        errno
                                        invocation-id user-invocation-id
                                        syslog-facility syslog-identifier syslog-pid syslog-timestamp
                                        syslog-raw
                                        documentation
                                        tid
                                        unit user-unit)))
                 `(defun journal-send (priority message &key ,@optional-fields)
                    "Write MESSAGE to system journal with PRIORITY.

PRIORITY can be an integer from 0 to 7, or a keyword among :EMERG,
:ALERT, :CRIT, :ERR, :WARNING, :NOTICE, :INFO, and :DEBUG. See
syslog.h or https://man7.org/linux/man-pages/man3/syslog.3.html

Short explaination from syslog.h:

| Quantity | Keyword  | Explaination                     |
|----------|----------|----------------------------------|
| 0        | :EMERG   | system is unusable               |
| 1        | :ALERT   | action must be taken immediately |
| 2        | :CRIT    | critical conditions              |
| 3        | :ERR     | error conditions                 |
| 4        | :WARNING | warning conditions               |
| 5        | :NOTICE  | normal but significant condition |
| 6        | :INFO    | informational                    |
| 7        | :DEBUG   | debug-level messages             |

See
https://www.freedesktop.org/software/systemd/man/latest/systemd.journal-fields.html#
for the explaination of optional fields.

See JOURNAL-PRINT for shorthand method.

Also recommend log4cl/syslog if you don't need the optional fields :)"
                    (let (fields)
                      (push (format nil "MESSAGE=~A" message) fields)
                      (push (format nil "PRIORITY=~A" (syslog-priority priority)) fields)
                      (push-fields ,optional-fields)
                      (multiple-value-bind (arr arr-len need-to-be-freed)
                          (construct-iovec-array-for-fields fields)
                        (unwind-protect
                             (clsd/raw:journal-sendv arr arr-len)
                          (dolist (ptr need-to-be-freed)
                            (foreign-free ptr)))))))))
    (def)))

(defun journal-print (priority control-string &rest format-arguments)
  "Write a journal constructed with
(FORMAT NIL CONTROL-STRING &rest FORMAT-ARGUMENTS) to system with
PRIORITY.

PRIORITY can be an integer from 0 to 7, or a keyword among :EMERG,
:ALERT, :CRIT, :ERR, :WARNING, :NOTICE, :INFO, and :DEBUG. See
syslog.h or https://man7.org/linux/man-pages/man3/syslog.3.html

Short explaination from syslog.h:

| Quantity | Keyword  | Explaination                     |
|----------|----------|----------------------------------|
| 0        | :EMERG   | system is unusable               |
| 1        | :ALERT   | action must be taken immediately |
| 2        | :CRIT    | critical conditions              |
| 3        | :ERR     | error conditions                 |
| 4        | :WARNING | warning conditions               |
| 5        | :NOTICE  | normal but significant condition |
| 6        | :INFO    | informational                    |
| 7        | :DEBUG   | debug-level messages             |

See JOURNAL-SEND for more flexible method.

Also recommend log4cl/syslog, they're basically the same :)"
  (declare (inline journal-print))
  (journal-send priority (apply #'format nil control-string format-arguments)))

(export '(journal-send journal-print))
