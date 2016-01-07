;;;; cl-udmx.asd

(asdf:defsystem #:cl-udmx
  :description "Send DMX commands using uDMX compatible USB device"
  :author "Miko Kuijn"
  :license "GPL"
  :depends-on (#:cl-libusb)
  :serial t
  :components ((:file "package")
               (:file "cl-udmx")))

