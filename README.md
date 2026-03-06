# CLSD - libsystemd Bindings for Common Lisp

Here we provide a set of CFFI raw bindings for `sd-daemon.h`, `sd-device.h`,
`sd-event.h`, `sd-journal.h` and `sd-login.h` in `CLSD/RAW` package, plus a set
of fine-grained high-level bindings for `sd-device.h`, `sd-journal.h` and
`sd-login.h` in the package `CLSD`, all in the `CLSD` ASDF system.

## Usage

### sd-login

```common-lisp
(clsd:get-seats) ; => ("seat0"), 1
(clsd:get-sessions) ; => ("28" "27" "26" "24" "23" "2" "3"), 7
(clsd:get-uids) ; => (0 1000), 2
(clsd:get-machine-names) ; => NIL, 0

(clsd:session-get-leader (first (clsd:get-sessions))) ; => 93609 (17 bits, #x16DA9)
(clsd:pid-get-session (clsd:session-get-leader (first (clsd:get-sessions)))) ; => "28"

(clsd:uid-get-sessions 0) ; => ("28" "27" "26" "24" "23"), 5
(clsd:session-get-uid (first (clsd:uid-get-sessions 0))) ; => 0 (0 bits, #x0, #o0, #b0)
```

### sd-device

```common-lisp
(clsd:with-device (dev :path "/dev/vda")
  (clsd:device-get-syspath dev)) ; => "/sys/devices/pci0000:00/0000:00:05.0/virtio1/block/vda"

;; Macroexpand to
(let ((dev (make-instance 'clsd:device :path "/dev/vda")))
  (unwind-protect
       (progn (clsd:device-get-syspath dev))
    (clsd:device-unref dev)))
    
;; Enumerate

(clsd:with-enumerated-devices (devices :subsystems '("tty"))
  (length devices)) ; => 103 (7 bits, #x67, #o147, #b1100111)

(clsd:do-enumerated-devices (dev :subsystems '("tty"))
  (print (clsd:device-get-devname dev)))
; "/dev/ttyS0" 
; "/dev/ttyS1" 
; "/dev/ttyS2" 
; "/dev/ttyS3" 
; "/dev/console" 
; "/dev/ptmx" 
; "/dev/ptyp0" 
; ...  => NIL
```

## sd-journal

```common-lisp
(journal-send :notice "Hello, journal!" :user-unit "my-app" :code-file "sd-journal.lisp" :code-line "123" :code-func "my-function")
```

and inside `journalctl -xe`

```
...
Mar 06 21:56:32 calsys-nix-dev sbcl[114083]: Hello, journal!
```

Shorthand function `journal-print`:

```common-lisp
(journal-print :info "Critical error: ~A." (sb-int:strerror 1))
```

Also recommend `log4cl/syslog`.

We don't provide high-level journal querying API (like for
`sd_journal_get_data`), as they're not documented in [systemd
documentation](https://www.freedesktop.org/software/systemd/man/latest/sd-journal.html)

## Monitor

To use the monitors like `sd_login_monitor` or `sd_device_monitor` in systemd
API, the [iolib](https://github.com/sionescu/iolib) is a good facility. A
proof-of-concept piece of code can be like following:

```common-lisp
(let ((event-base (make-instance 'iolib:event-base))
      (monitor (clsd:login-monitor-new "session")))
  (iolib:set-io-handler event-base (clsd/raw:login-monitor-get-fd monitor) :read
                        (lambda (fd event-type errorp)
                          (clsd/raw:login-monitor-flush monitor)
                          (let ((sessions (get-sessions)))
                            ...)))
  (loop (iolib:event-dispatch event-base)))
```

You may want to integrate it with existing event-loop libraries like
[Sento](https://github.com/mdbergmann/cl-gserver), or write a event loop
yourself.

----------------
Acknowledgements
----------------

Thanks our sister Simone, and our lover misaka18931, who love and support us.

Supporting Neurodivisity & Transgender & Plurality!

🏳️‍🌈🏳️‍⚧️
