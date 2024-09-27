;;; centered-buffers.el --- Center buffers in window -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Luis Roel

;; Author: Luis Roel <luisroelsde@gmail.com.com>
;; Version: 0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: convenience, frames
;; URL: https://github.com/taylor-shift

;;; Commentary:

;; This package provides functionality to center buffers in the window.
;; It's particularly useful for users with large screens who want to avoid
;; neck strain by keeping content centered.

;; To use, add (require 'centered-buffers) to your init file and bind
;; `toggle-centered-buffers' to a convenient key.

;;; Code:

(defvar centered-buffers-mode nil
  "Toggle for centered buffers mode.")

(defvar-local centered-buffers-centered nil
  "Whether this buffer is currently centered.")

(defvar centered-buffers-original-display-buffer-alist nil
  "Storage for the original \='display-buffer-alist'\=.")

(defun centered-buffers-center-windows ()
  "Center the side windows."
  (when centered-buffers-mode
    (let* ((frame-width (frame-width))
           (buffer-width (/ frame-width 2))
           (margin (/ (- frame-width buffer-width) 2)))
      (dolist (window (window-list))
        (with-current-buffer (window-buffer window)
          (unless centered-buffers-centered
            (set-window-margins window margin margin)
            (setq centered-buffers-centered t)))))))

(defun centered-buffers-reset-windows ()
  "Reset window margins."
  (dolist (window (window-list))
    (with-current-buffer (window-buffer window)
      (when centered-buffers-centered
        (set-window-margins window 0 0)
        (setq centered-buffers-centered nil)))))

(defun centered-buffers-toggle-centered-buffers ()
  "Toggle the centered buffers mode."
  (interactive)
  (setq centered-buffers-mode (not centered-buffers-mode))
  (if centered-buffers-mode
      (centered-buffers-enable-centered-buffers)
    (centered-buffers-disable-centered-buffers))
  (force-mode-line-update)
  (message "Centered buffers mode %s" (if centered-buffers-mode "enabled" "disabled")))

(defun centered-buffers-enable-centered-buffers ()
  "Enable centered buffers mode."
  (setq centered-buffers-original-display-buffer-alist display-buffer-alist)
  (setq display-buffer-alist
        '((".*" (display-buffer-in-side-window)
           (side . right)
           (window-width . 0.5))))
  (setq window-sides-vertical nil)
  (add-hook 'window-configuration-change-hook #'centered-buffers-center-windows)
  (centered-buffers-center-windows))

(defun centered-buffers-disable-centered-buffers ()
  "Disable centered buffers mode."
  (setq display-buffer-alist centered-buffers-original-display-buffer-alist)
  (remove-hook 'window-configuration-change-hook #'centered-buffers-center-windows)
  (centered-buffers-reset-windows)
  (balance-windows))

(provide 'centered-buffers)
;;; centered-buffers.el ends here
