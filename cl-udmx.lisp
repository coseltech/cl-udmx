;;;; cl-udmx.lisp

(in-package #:cl-udmx)

(defconstant +usbdev-shared-vendor+ #X16C0)
(defconstant +usbdev-shared-product+ #X05DC)

(defconstant +cmd-set-single-channel+ 1)
(defconstant +cmd-set-channel-range+ 2)

(defconstant +usb-type-vendor+ (cffi:foreign-enum-value 'libusb-ffi::type :vendor))
(defconstant +usb-recip-device+ (cffi:foreign-enum-value 'libusb-ffi::recip :device))
(defconstant +usb-endpoint-out+ (cffi:foreign-enum-value 'libusb-ffi::endpoint :out))
(defconstant +flags+ (logior +usb-type-vendor+ +usb-recip-device+ +usb-endpoint-out+))

(defun send-single-channel (device channel level)
  "Send single level [0, 255] to channel [0, 512]"
  (let ((buffer (grid:make-foreign-array '(unsigned-byte 8) :dimensions 8)))
    (cl-libusb:usb-control-msg device +flags+ +cmd-set-single-channel+ level channel buffer 5000)))

(defun send-channel-range (device start levels)
  (let ((amount (length levels))
        (buffer (grid:make-foreign-array '(unsigned-byte 8) :initial-contents levels)))
    (cl-libusb:usb-control-msg device +flags+ +cmd-set-channel-range+ amount start buffer 5000)))

(defun find-devices (&optional serial)
  "Gets device handle for uDMX device, optional argument serial specifies serial nuber"
  (remove-if-not (lambda (device)
                   (let ((was-open (cl-libusb:usb-open-p device)))
                     (unless was-open (cl-libusb:usb-open device))
                     (unwind-protect (and
                                      (string-equal (cl-libusb:usb-get-string device :manufacturer) "www.anyma.ch")
                                      (string-equal (cl-libusb:usb-get-string device :serial-number) (or serial "ilLUTZminator001"))
                                      (string-equal (cl-libusb:usb-get-string device :product) "uDMX"))
                       (unless was-open (cl-libusb:usb-close device)))))
   (cl-libusb:usb-get-devices-by-ids +USBDEV-SHARED-VENDOR+
                                     +USBDEV-SHARED-PRODUCT+)))

(defun find-device ()
  (first (find-devices)))

(defun open-device (device)
       (cl-libusb:usb-open device))

(defun close-device (device)
  (cl-libusb:usb-close device))

(defun get-open-device ()
  (open-device (find-device)))

