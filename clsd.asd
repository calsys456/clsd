(asdf:defsystem clsd
  :author "The Calendrical System"
  :description "libsystemd Bindings for Common Lisp"
  :license "0BSD"
  :depends-on (cffi)
  :components ((:file "package")
               (:file "raw/package")
               (:file "raw/sd-login")
               (:file "raw/sd-event")
               (:file "raw/sd-journal")
               (:file "raw/sd-device")
               (:file "raw/sd-daemon")
               (:file "sd-login")
               (:file "sd-device")
               (:file "sd-journal")))
