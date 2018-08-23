;;; initfile --- Summary:
;;; Commentary:
;; Emacs 25.1 and newer tested
;;; Code:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configuration/Customization:
;; Defines global variables that are later used to customize and set
;; up packages.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Specify the ycmd server command and path to the ycmd directory *inside* the
;; cloned ycmd directory
(defvar my:ycmd-server-command '("python" "/usr/bin/ycmd"))
(defvar my:ycmd-extra-conf-whitelist '("~/.ycm_extra_conf.py"))
(defvar my:ycmd-global-config "~/.ycm_extra_conf.py")
;; In order to get python code completion with ycmd+jedi you must specify
;; the path to the python executable you're using.
(defvar my:ycmd-python-binary-path "/usr/bin/python")

;; Set to t if you want to use ycmd-goto in C/C++/Rust mode
(defvar my:use-ycmd-goto t)

;; Specify the jupyter executable name, and the start dir of the server
(defvar my:jupyter_location (executable-find "jupyter"))
(defvar my:jupyter_start_dir "/home/song")

;; Compilation command for C/C++
(defvar my:compile-command "clang++ -Wall -Wextra -std=c++11 ") 
;; Which theme to use. Either: spacemacs-dark, or sourcerer
(defvar my:use-theme "spacemacs-dark")

;; Set my:use-dvorak-bindings to t if you use a Dvorak keyboard layout
(defvar my:use-dvorak-bindings t)

;; Set my:use-evil-mode to t if you want to use Evil mode
;;
;; Note: Currently there is a warning about evil-want-integration not
;;       being set to nil during compilation that I haven't figured out
;;       how to fix yet.
(defvar my:use-evil-mode nil)

(setq evil-want-integration nil)

;; Set my:byte-compile-init to t if you want to compile the init file.
;; This will improve startup time by ~2-3 times, but makes getting certain
;; packages to load correctly more difficult. Most of the packages work
;; correctly with a byte-compiled init file.
(defvar my:byte-compile-init t)

;; Force Emacs to try to start a server. On macOS checking if a server is
;; started doesn't always work correctly so this is a workaround for that.
(defvar my:force-server-start nil)

;; TEX is installed in a different location on macOS
(when (string-equal system-type "darwin")
  (setenv "PATH" (concat (getenv "PATH") ":/Library/TeX/texbin/"))
  (setq exec-path (append exec-path '("/Library/TeX/texbin/")))
  (setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set packages to install
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq package-archives '(("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))
;; Disable package initialize after us.  We either initialize it
;; anyway in case of interpreted .emacs, or we don't want slow
;; initizlization in case of byte-compiled .emacs.elc.
(setq package-enable-at-startup nil)
;; Ask package.el to not add (package-initialize) to .emacs.
(setq package--init-file-ensured t)
;; set use-package-verbose to t for interpreted .emacs,
;; and to nil for byte-compiled .emacs.elc
(eval-and-compile
  (setq use-package-verbose (not (bound-and-true-p byte-compile-current-file))))
;; Add the macro generated list of package.el loadpaths to load-path.
(mapc #'(lambda (add) (add-to-list 'load-path add))
      (eval-when-compile
        (require 'package)
        (package-initialize)
        ;; Install use-package if not installed yet.
        (unless (package-installed-p 'use-package)
          (package-refresh-contents)
          (package-install 'use-package))
        ;; (require 'use-package)
        (let ((package-user-dir-real (file-truename package-user-dir)))
          ;; The reverse is necessary, because outside we mapc
          ;; add-to-list element-by-element, which reverses.
          (nreverse
           (apply #'nconc
                  ;; Only keep package.el provided loadpaths.
                  (mapcar #'(lambda (path)
                              (if (string-prefix-p package-user-dir-real path)
                                  (list path)
                                nil))
                          load-path))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; By default Emacs triggers garbage collection at ~0.8MB which makes
;; startup really slow. Since most systems have at least 64MB of memory,
;; we increase it during initialization.
(setq gc-cons-threshold 64000000)
(add-hook 'after-init-hook #'(lambda ()
                               ;; restore after startup
                               (setq gc-cons-threshold 800000)))

;; Extra plugins and config files are stored here
(if (not (file-directory-p "~/.emacs.d/plugins/"))
    (make-directory "~/.emacs.d/plugins/"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/plugins"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start emacs server if not already running
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (or my:force-server-start
          (and (fboundp 'server-running-p) (not (server-running-p))))
  (server-start))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; General Tweaks
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; turn on highlight matching brackets when cursor is on one
(show-paren-mode t)
;; Overwrite region selected
(delete-selection-mode t)
;; Show column numbers by default
(setq column-number-mode t)
;; Use CUA to delete selections
(setq cua-mode t)
(setq cua-enable-cua-keys nil)
;; Prevent emacs from creating a bckup file filename~
(setq make-backup-files nil)
;; Settings for searching
(setq-default case-fold-search t ;case insensitive searches by default
              search-highlight t) ;hilit matches when searching
;; Highlight the line we are currently on
(global-hl-line-mode t)
;; Disable the toolbar at the top since it's useless
(if (functionp 'tool-bar-mode) (tool-bar-mode -1))

;; Remove trailing white space upon saving
;; Note: because of a bug in EIN we only delete trailing whitespace
;; when not in EIN mode.
(add-hook 'before-save-hook
          (lambda ()
            (when (not (derived-mode-p 'ein:notebook-multilang-mode))
              (delete-trailing-whitespace))))

;; Auto-wrap at 80 characters
(setq-default auto-fill-function 'do-auto-fill)
(setq-default fill-column 80)
(turn-on-auto-fill)
;; Disable auto-fill-mode in programming mode
(add-hook 'prog-mode-hook (lambda () (auto-fill-mode -1)))

;; Global Keyboard Shortcuts
;; Set help to C-?
(global-set-key (kbd "C-?") 'help-command)
;; Set mark paragraph to M-?
(global-set-key (kbd "M-?") 'mark-paragraph)
;; Set backspace to C-h
(global-set-key (kbd "C-h") 'delete-backward-char)
;; Set backspace word to M-h
(global-set-key (kbd "M-h") 'backward-kill-word)
;; Use meta+tab word completion
(global-set-key (kbd "M-TAB") 'dabbrev-expand)
;; Easy undo key
(global-set-key (kbd "C-/") 'undo)
;; Comment or uncomment the region
(global-set-key (kbd "C-c ;") 'comment-or-uncomment-region)
;; Indent after a newline, if required by syntax of language
(global-set-key (kbd "C-m") 'newline-and-indent)
;; Load the compile ocmmand
(global-set-key (kbd "C-c C-c") 'compile)

;; We don't want to type yes and no all the time so, do y and n
(defalias 'yes-or-no-p 'y-or-n-p)
;; Disable the horrid auto-save
(setq auto-save-default nil)

;; Disable the menu bar since we don't use it, especially not in the
;; terminal
(when (and (not (eq system-type 'darwin)) (fboundp 'menu-bar-mode))
  (menu-bar-mode -1))

;; Don't ring the bell
(setq ring-bell-function 'ignore)

;; Non-nil means draw block cursor as wide as the glyph under it.
;; For example, if a block cursor is over a tab, it will be drawn as
;; wide as that tab on the display.
(setq x-stretch-cursor t)

;; Dont ask to follow symlink in git
(setq vc-follow-symlinks t)

;; Check (on save) whether the file edited contains a shebang, if yes,
;; make it executable from
;; http://mbork.pl/2015-01-10_A_few_random_Emacs_tips
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)

;; Highlight some keywords in prog-mode
(add-hook 'prog-mode-hook
          (lambda ()
            ;; Highlighting in cmake-mode this way interferes with
            ;; cmake-font-lock, which is something I don't yet understand.
            (when (not (derived-mode-p 'cmake-mode))
              (font-lock-add-keywords
               nil
               '(("\\<\\(FIXME\\|TODO\\|BUG\\|DONE\\)"
                  1 font-lock-warning-face t))))))

;; Setup use-package
(eval-when-compile
  (require 'use-package))
(use-package bind-key
  :ensure t)
;; so we can (require 'use-package) even in compiled emacs to e.g. read docs
(use-package use-package
  :commands use-package-autoload-keymap)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; esup: Emacs StartUp Profiler
;;       - Profile the load time of the Emacs init file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package esup
  :ensure t
  :init
  (setq esup-child-max-depth 0)
  ;; Use a hook so the message doesn't get clobbered by other messages.
  (add-hook
   'emacs-startup-hook
   (lambda ()
     (message "Emacs ready in %s with %d garbage collections."
              (format "%.2f seconds"
                      (float-time
                       (time-subtract after-init-time before-init-time)))
              gcs-done))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable terminal emacs to copy and paste from system clipboard
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Note: this uses C-c before C-w, M-w, and M-y
;; From: https://stackoverflow.com/questions/64360/how-to-copy-text-from-emacs-to-another-application-on-linux
(defun my-copy-to-xclipboard(arg)
  "Copy the selection ARG to the X11 clipboard."
  (interactive "P")
  (cond
   ((not (use-region-p))
    (message "Nothing to yank to X-clipboard"))
   ((and (not (display-graphic-p))
         (/= 0 (shell-command-on-region
                (region-beginning) (region-end) "xsel -i -b")))
    (message "Error: Is program `xsel' installed?"))
   (t
    (when (display-graphic-p)
      (call-interactively 'clipboard-kill-ring-save))
    (message "Yanked region to X-clipboard")
    (when arg
      (kill-region  (region-beginning) (region-end)))
    (deactivate-mark))))

(defun my-cut-to-xclipboard()
  "Cut the selection to the X11 clipboard."
  (interactive)
  (my-copy-to-xclipboard t))

(defun my-paste-from-xclipboard()
  "Paste the selection from the X11 clipboard."
  (interactive)
  (if (display-graphic-p)
      (clipboard-yank)
    (insert (shell-command-to-string "xsel -o -b"))))

(global-set-key (kbd "C-c C-w") 'my-cut-to-xclipboard)
(global-set-key (kbd "C-c M-w") 'my-copy-to-xclipboard)
;; Use C-c M-y instead of C-c C-y so it works in Python mode too.
(global-set-key (kbd "C-c M-y") 'my-paste-from-xclipboard)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; async - library for async/thread processing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package async
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; s is used by ycmd, origami, etc and sometimes during Emacs
;; upgrades disappears so we try to install it on its own.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package s
  :ensure t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically compile and save ~/.emacs.el
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when my:byte-compile-init
  (defun byte-compile-init-files (file)
    "Automatically compile FILE."
    (interactive)
    (save-restriction
      ;; Suppress the warning when you setq an undefined variable.
      (if (>= emacs-major-version 23)
          (setq byte-compile-warnings '(not free-vars obsolete))
        (setq byte-compile-warnings
              '(unresolved
                callargs
                redefine
                obsolete
                noruntime
                cl-warnings
                interactive-only)))
      (byte-compile-file (expand-file-name file))))

  ;; Add a post-save hook that checks if ~/.emacs.el exists and if the file
  ;; name of the current buffer is ~/.emacs.el or the symbolically linked
  ;; file.
  (add-hook
   'after-save-hook
   (function
    (lambda ()
      (when (and (string= (file-truename "~/.emacs.el")
                          (file-truename (buffer-file-name)))
                 (file-exists-p "~/.emacs.el"))
        (byte-compile-init-files "~/.emacs.el")))))

  ;; Byte-compile again to ~/.emacs.elc if it is outdated. We use file-truename
  ;; to follow symbolic links so that ~/.emacs.el can be symbolically linked to
  ;; the location where the .emacs.el is stored.
  (when (file-newer-than-file-p
         (file-truename "~/.emacs.el")
         (file-truename "~/.emacs.elc"))
    (byte-compile-init-files "~/.emacs.el")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auto-package-update
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto update packages once a week
(use-package auto-package-update
  :ensure t
  :commands (auto-package-update-maybe)
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t)
  (auto-package-update-maybe)
  (add-hook 'auto-package-update-before-hook
          (lambda () (message "I will update packages now")))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; diminish - Hide the minor modes in the mode line for more room
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package diminish
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function diminish "diminish.el"))
  :config
  (diminish 'abbrev-mode)
  (diminish 'eldoc-mode)
  (diminish 'auto-revert-mode)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ivy config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ivy
  :ensure t
  :diminish ivy-mode
  :commands (ivy-mode)
  :config
  (when my:byte-compile-init
    (require 'ivy))
  (ivy-mode t)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  (setq ivy-wrap t)
  (global-set-key (kbd "C-c C-r") 'ivy-resume)
  ;; Show #/total when scrolling buffers
  (setq ivy-count-format "%d/%d ")
  )

(use-package swiper
  :ensure t
  :bind (("C-s" . swiper)
         ("C-r" . swiper))
  )

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("<f1> f" . counsel-describe-function)
         ("<f1> v" . counsel-describe-variable)
         ("<f1> l" . counsel-find-library)
         ("<f2> i" . counsel-info-lookup-symbol)
         ("<f2> u" . counsel-unicode-char)
         ("C-c g" . counsel-git-grep)
         ("C-c j" . counsel-git)
         ("C-c k" . counsel-ag)
         ("C-c r" . counsel-rg)
         ("C-x l" . counsel-locate)
         :map minibuffer-local-map
         ("C-r" . counsel-minibuffer-add)
         )
  :config
  (if (executable-find "rg")
      ;; use ripgrep instead of grep because it's way faster
      (setq counsel-grep-base-command
            "rg -i -M 120 --no-heading --line-number --color never '%s' %s"
            counsel-rg-base-command
            "rg -i -M 120 --no-heading --line-number --color never %s .")
    (warn "\nWARNING: Could not find the ripgrep executable. It "
          "is recommended you install ripgrep."))
  )

;; Use universal ctags to build the tags database for the project.
;; When you first want to build a TAGS database run 'touch TAGS'
;; in the root directory of your project.
(use-package counsel-etags
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function counsel-etags-virtual-update-tags "counsel-etags.el")
    (declare-function counsel-etags-guess-program "counsel-etags.el")
    (declare-function counsel-etags-locate-tags-file "counsel-etags.el"))
  :bind (
         ("M-." . counsel-etags-find-tag-at-point)
         ("M-t" . counsel-etags-grep-symbol-at-point))
  :config
  ;; Ignore files above 800kb
  (setq counsel-etags-max-file-size 800)
  ;; Ignore build directories for tagging
  (add-to-list 'counsel-etags-ignore-directories '"build*")
  (add-to-list 'counsel-etags-ignore-directories '".vscode")
  (add-to-list 'counsel-etags-ignore-filenames '".clang-format")
  ;; Don't ask before rereading the TAGS files if they have changed
  (setq tags-revert-without-query t)
  ;; Don't warn when TAGS files are large
  (setq large-file-warning-threshold nil)
  ;; How many seconds to wait before rerunning tags for auto-update
  (setq counsel-etags-update-interval 180)
  ;; Set up auto-update
  (add-hook
   'prog-mode-hook
   (lambda () (add-hook 'after-save-hook
                        (lambda ()
                          (counsel-etags-virtual-update-tags)))))

  ;; The function provided by counsel-etags is broken (at least on Linux)
  ;; and doesn't correctly exclude directories, leading to an excessive
  ;; amount of incorrect tags. The issue seems to be that the trailing '/'
  ;; in e.g. '*dirname/*' causes 'find' to not correctly exclude all files
  ;; in that directory, only files in sub-directories of the dir set to be
  ;; ignore.
  (defun my-scan-dir (src-dir &optional force)
    "Create tags file from SRC-DIR. \
     If FORCE is t, the commmand is executed without \
     checking the timer."
    (let* ((find-pg (or
                     counsel-etags-find-program
                     (counsel-etags-guess-program "find")))
           (ctags-pg (or
                      counsel-etags-tags-program
                      (format "%s -e -L" (counsel-etags-guess-program
                                          "ctags"))))
           (default-directory src-dir)
           ;; run find&ctags to create TAGS
           (cmd (format
                 "%s . \\( %s \\) -prune -o -type f -not -size +%sk %s | %s -"
                 find-pg
                 (mapconcat
                  (lambda (p)
                    (format "-iwholename \"*%s*\"" p))
                  counsel-etags-ignore-directories " -or ")
                 counsel-etags-max-file-size
                 (mapconcat (lambda (n)
                              (format "-not -name \"%s\"" n))
                            counsel-etags-ignore-filenames " ")
                 ctags-pg))
           (tags-file (concat (file-name-as-directory src-dir) "TAGS"))
           (doit (or force (not (file-exists-p tags-file)))))
      ;; always update cli options
      (when doit
        (message "%s at %s" cmd default-directory)
        (async-shell-command cmd)
        (visit-tags-table tags-file t))))

  (setq counsel-etags-update-tags-backend
        (lambda ()
          (interactive)
          (let* ((tags-file (counsel-etags-locate-tags-file)))
            (when tags-file
              (my-scan-dir (file-name-directory tags-file) t)
              (run-hook-with-args
               'counsel-etags-after-update-tags-hook tags-file)
              (unless counsel-etags-quiet-when-updating-tags
                (message "%s is updated!" tags-file))))))
  )

;; Set up projectile
(use-package projectile
  :ensure t
  :diminish projectile-mode
  :defer 1
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function projectile-mode "projectile.el"))
  :config
  (projectile-mode t)
  (setq projectile-enable-caching t)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  )

(use-package counsel-projectile
  :ensure t
  :after projectile
  :bind (("C-x M-f" . counsel-projectile-find-file))
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function counsel-projectile-mode "counsel-projectile.el"))
  :config
  (counsel-projectile-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Window numbering
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package window-numbering installed from package list
;; Allows switching between buffers using meta-(# key)
(use-package window-numbering
  :ensure t
  :config
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function window-numbering-mode "window-numbering.el"))
  (window-numbering-mode t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wgrep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; wgrep allows you to edit all files in a grep result. For example,
;; you can use C-c g or C-c r to search all files in a project, then
;; use C-c C-o to enter ivy-occur mode, followed by 'w' to make
;; the grep results buffer editable, then you can edit the results
;; however you wish.
(use-package wgrep
  :ensure t
  :defer 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ripgrep
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package ripgrep
  :ensure t
  :defer 1)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Edit server to allow editing of things in Chrome with Emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package edit-server
  :ensure t
  :config
  (progn
    (eval-when-compile
      ;; Silence missing function warnings
      (declare-function edit-server-start "edit-server-start.el"))
    (when (daemonp) (edit-server-start))
    (add-hook 'edit-server-start-hook
              (lambda ()
                (when (string-match "github.com" (buffer-name))
                  (markdown-mode)))))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Origami - Does code folding, ie hide the body of an
;; if/else/for/function so that you can fit more code on your screen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package origami
  :ensure t
  :commands (origami-mode)
  :bind (:map origami-mode-map
              ("C-c o :" . origami-recursively-toggle-node)
              ("C-c o a" . origami-toggle-all-nodes)
              ("C-c o t" . origami-toggle-node)
              ("C-c o o" . origami-show-only-node)
              ("C-c o u" . origami-undo)
              ("C-c o U" . origami-redo)
              ("C-c o C-r" . origami-reset)
              )
  :config
  (setq origami-show-fold-header t)
  ;; The python parser currently doesn't fold if/for/etc. blocks, which is
  ;; something we want. However, the basic indentation parser does support
  ;; this with one caveat: you must toggle the node when your cursor is on
  ;; the line of the if/for/etc. statement you want to collapse. You cannot
  ;; fold the statement by toggling in the body of the if/for/etc.
  (add-to-list 'origami-parser-alist '(python-mode . origami-indent-parser))
  :init
  (add-hook 'prog-mode-hook 'origami-mode)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Rainbow Delimiters -  have delimiters be colored by their depth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package rainbow-delimiters
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function rainbow-delimiters-mode "rainbow-delimiters.el"))
  (add-hook 'prog-mode-hook #'rainbow-delimiters-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Beacon-mode: flash the cursor when switching buffers or scrolling
;;              the goal is to make it easy to find the cursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package beacon
  :ensure t
  :diminish beacon-mode
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function beacon-mode "beacon.el"))
  :config
  (beacon-mode t))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; which-key: when you pause on a keyboard shortcut it provides
;;            suggestions in a popup buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package which-key
  :ensure t
  :diminish which-key-mode
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function which-key-mode "which-key.el"))
  :config
  (which-key-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; avy: always fast jump to char inside the current view buffer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package avy
  :ensure t
  :bind (("M-c" . avy-goto-char-2)
         ("M-s" . avy-goto-word-1))
  ;; Set keys for Dvorak mode instead of qwerty
  :init
  (when my:use-dvorak-bindings
    (setq avy-keys '(?a ?o ?e ?u ?i ?d ?h ?t ?n ?s
                        ?A ?O ?E ?U ?I ?D ?H ?T ?N ?S
                        ?p ?y ?f ?g ?c ?r ?l
                        ?P ?Y ?F ?G ?C ?R ?L))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; zzz-to-char: replaces the built-in zap-to-char with avy-like
;;              replacement options
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package zzz-to-char
  :ensure t
  :bind ("M-z" . zzz-up-to-char))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use undo-tree to navigate undo history
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode
  :defer 1
  :config
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function global-undo-tree-mode "undo-tree.el"))
  (global-undo-tree-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; visual-regexp-steroids
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package visual-regexp-steroids
  :ensure t
  :bind (("C-c v r" . vr/query-replace)
         ("C-c v m" . vr/mc-mark)
         ("C-M-s" . vr/isearch-forward)
         ("C-M-r" . vr/isearch-backward))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RealGud - https://github.com/realgud/realgud
;; A rewrite of GUD
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package realgud
  :ensure t
  :defer 2
  :init
  (setenv "TERM" "dumb")
  :config
  (setq realgud:pdb-command-name "python -m pdb"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Python mode settings
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq-default python-indent 4)
(setq-default python-indent-offset 4)
(add-hook 'python-mode-hook
          (lambda ()
            (setq tab-width 4)))
(setq-default pdb-command-name "python -m pdb")
(use-package elpy
  :ensure t
  :commands (elpy-enable)
  :after python
  :config
  (elpy-enable)
  )

(use-package yapfify
  :ensure t
  :init
  (add-hook 'python-mode-hook 'yapf-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Clang-format
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clang-format can be triggered using C-c C-f
;; Create clang-format file using google style
;; clang-format -style=google -dump-config > .clang-format
(use-package clang-format
  :ensure t
  :bind (("C-c C-f" . clang-format-region))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; clang-rename
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (not (file-directory-p "~/.emacs.d/plugins/"))
    (make-directory "~/.emacs.d/plugins/"))
(if (not (file-exists-p "~/.emacs.d/plugins/emacs-clang-rename.el"))
    (url-copy-file
     "https://raw.githubusercontent.com/nilsdeppe/emacs-clang-rename/master/emacs-clang-rename.el"
     "~/.emacs.d/plugins/emacs-clang-rename.el"))
(when (file-exists-p "~/.emacs.d/plugins/emacs-clang-rename.el")
    (use-package emacs-clang-rename
      :bind (("C-c c p" . emacs-clang-rename-at-point)
             ("C-c c q" . emacs-clang-rename-qualified-name)
             ("C-c c a" . emacs-clang-rename-qualified-name-print))
      ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Modern C++ code highlighting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package modern-cpp-font-lock
  :ensure t
  :diminish modern-c++-font-lock-mode
  :init
  (eval-when-compile
      ;; Silence missing function warnings
    (declare-function modern-c++-font-lock-global-mode
                      "modern-cpp-font-lock.el"))
  :config
  (modern-c++-font-lock-global-mode t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; C++ keys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package cc-mode
  :ensure t
  :defer t
  :init
  (add-to-list 'auto-mode-alist '("\\.tpp\\'" . c++-mode))
  :config
  (define-key c++-mode-map (kbd "C-c C-c") 'compile)
  (define-key c++-mode-map (kbd "C-c C-k") 'kill-compilation)
  (setq compile-command my:compile-command)
  (use-package google-c-style
    :ensure t
    :config
    ;; This prevents the extra two spaces in a namespace that Emacs
    ;; otherwise wants to put... Gawd!
    (add-hook 'c-mode-common-hook 'google-set-c-style)
    ;; Autoindent using google style guide
    (add-hook 'c-mode-common-hook 'google-make-newline-indent)
    )
  )

;; Change tab key behavior to insert spaces instead
(setq-default indent-tabs-mode nil)

;; Set the number of spaces that the tab key inserts (usually 2 or 4)
(setq c-basic-offset 2)
;; Set the size that a tab CHARACTER is interpreted as
;; (unnecessary if there are no tab characters in the file!)
(setq tab-width 2)

;; We want to be able to see if there is a tab character vs a space.
;; global-whitespace-mode allows us to do just that.
;; Set whitespace mode to only show tabs, not newlines/spaces.
(use-package whitespace
  :ensure t
  :diminish global-whitespace-mode
  :init
  (eval-when-compile
      ;; Silence missing function warnings
      (declare-function global-whitespace-mode "whitespace.el"))
  :config
  (setq whitespace-style '(tabs tab-mark))
  ;; Turn on whitespace mode globally.
  (global-whitespace-mode t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package: ycmd (YouCompleteMeDaemon)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up YouCompleteMe for emacs:
;; https://github.com/Valloric/ycmd
;; https://github.com/abingham/emacs-ycmd
(defvar my:python-location (executable-find (nth 0 my:ycmd-server-command)))
(if (not my:python-location)
    (message
     "Could not start YouCompleteMeDaemon because the python executable could
not be found.\nSpecified executable is: '%s'\nPlease set my:ycmd-server-command
appropriately in ~/.emacs.el.\n" (nth 0 my:ycmd-server-command)))
(if (not (file-directory-p (nth 1 my:ycmd-server-command)))
    (message "Could not YouCompleteMeDaemon because the specified directory does
not exist.\nSpecified directory is: '%s'
Please set my:ycmd-server-command appropriately in ~/.emacs.el.\n"
             (nth 1 my:ycmd-server-command)))
(if (and my:python-location
         (file-directory-p (nth 1 my:ycmd-server-command)))
    (use-package ycmd
      :ensure t
      :diminish ycmd-mode
      :hook (prog-mode . global-ycmd-mode)
      :init
      (eval-when-compile
        ;; Silence missing function warnings
        (declare-function global-ycmd-mode "ycmd.el"))
      (add-hook 'after-init-hook #'global-ycmd-mode)
      :config
      (progn
        (set-variable 'ycmd-server-command my:ycmd-server-command)
        (set-variable 'ycmd-extra-conf-whitelist my:ycmd-extra-conf-whitelist)
        (set-variable 'ycmd-global-config my:ycmd-global-config)
        (set-variable 'ycmd-python-binary-path my:ycmd-python-binary-path)
        (setq ycmd-force-semantic-completion t)
        ;; Use "C-c y" instead of "C-c Y" for the prefix
        (define-key ycmd-mode-map ycmd-keymap-prefix nil)
        (setq ycmd-keymap-prefix (kbd "C-c y"))
        ;; Switch around some of the ycmd keybindings to make them easier to
        ;; use. Mainly, fewer capital letters.
        (setq ycmd-command-map
              (let ((map (make-sparse-keymap)))
                (define-key map "b" 'ycmd-parse-buffer)
                (define-key map "o" 'ycmd-open)
                (define-key map "c" 'ycmd-close)
                (define-key map "." 'ycmd-goto)
                (define-key map "gi" 'ycmd-goto-include)
                (define-key map "gd" 'ycmd-goto-definition)
                (define-key map "gD" 'ycmd-goto-declaration)
                (define-key map "gm" 'ycmd-goto-implementation)
                (define-key map "gp" 'ycmd-goto-imprecise)
                (define-key map "gr" 'ycmd-goto-references)
                (define-key map "gt" 'ycmd-goto-type)
                (define-key map "s" 'ycmd-toggle-force-semantic-completion)
                (define-key map "v" 'ycmd-show-debug-info)
                (define-key map "V" 'ycmd-version)
                (define-key map "d" 'ycmd-show-documentation)
                (define-key map "C" 'ycmd-clear-compilation-flag-cache)
                (define-key map "O" 'ycmd-restart-semantic-server)
                (define-key map "t" 'ycmd-get-type)
                (define-key map "p" 'ycmd-get-parent)
                (define-key map "f" 'ycmd-fixit)
                (define-key map "r" 'ycmd-refactor-rename)
                (define-key map "x" 'ycmd-completer)
                map))

        (define-key ycmd-mode-map ycmd-keymap-prefix ycmd-command-map)
        ;; Only override the CTags shortcut if my:use-ycmd-goto is t
        (when my:use-ycmd-goto
          (add-hook 'c-mode-common-hook
                    '(lambda ()
                       (local-set-key (kbd "M-.") 'ycmd-goto))))

        (use-package company-ycmd
          :ensure t
          :init
          (eval-when-compile
            ;; Silence missing function warnings
            (declare-function company-ycmd-setup "company-ycmd.el"))
          :config
          (company-ycmd-setup)
          )

        (use-package flycheck-ycmd
          :ensure t
          :init
          (add-hook 'c-mode-common-hook 'flycheck-ycmd-setup)
          (add-hook 'rust-mode-hook 'flycheck-ycmd-setup)
          )

        ;; Add displaying the function arguments in mini buffer using El Doc
        (require 'ycmd-eldoc)
        (add-hook 'ycmd-mode-hook 'ycmd-eldoc-setup))
      ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set up code completion with company
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package company
  :ensure t
  :diminish company-mode
  :config
  ;; Zero delay when pressing tab
  (setq company-idle-delay 0)
  (add-hook 'after-init-hook 'global-company-mode)
  ;; remove unused backends
  (setq company-backends (delete 'company-semantic company-backends))
  (setq company-backends (delete 'company-eclim company-backends))
  (setq company-backends (delete 'company-xcode company-backends))
  (setq company-backends (delete 'company-clang company-backends))
  (setq company-backends (delete 'company-bbdb company-backends))
  (setq company-backends (delete 'company-oddmuse company-backends))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Configure flycheck
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Note: For C++ we use flycheck-ycmd
(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :defer t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function global-flycheck-mode "flycheck.el"))
  :config
  ;; Turn flycheck on everywhere
  (global-flycheck-mode t)
  ;; There are issues with company mode and flycheck in terminal mode.
  ;; This is outlined at:
  ;; https://github.com/abingham/emacs-ycmd
  (when (not (display-graphic-p))
    (setq flycheck-indication-mode nil))
  )
(use-package flycheck-pyflakes
  :ensure t
  :after python)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; string-inflection
;; used for switching between different cases, eg CamelCase,
;; lowerCamelCase, snake_case, and SCREAMING_SNAKE_CASE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package string-inflection
  :ensure t
  :defer t
  :bind (("C-c c i" . string-inflection-cycle)
         ("C-c c l" . string-inflection-lower-camelcase)
         ("C-c c c" . string-inflection-camelcase)
         ("C-c c s" . string-inflection-underscore)
         ("C-c c u" . string-inflection-upcase))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; multiple-cursors  - https://github.com/magnars/multiple-cursors.el
;; Allows you to have multiple cursors on different lines so you can
;; easily edit multiple lines at once.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package multiple-cursors
  :ensure t
  :bind (("M-n" . mc/mark-next-like-this)
         ("M-p" . mc/mark-previous-like-this)
         ("C-c m a" . mc/mark-all-like-this)
         ("C-c m e" . mc/edit-lines))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org-Mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq org-log-done 'time
      org-todo-keywords '((sequence "TODO" "INPROGRESS" "DONE"))
      org-todo-keyword-faces '(("INPROGRESS" .
                                (:foreground "blue" :weight bold))))
(use-package writegood-mode
  :ensure t
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function writegood-mode "writegood-mode.el"))
  (add-hook 'org-mode-hook #'writegood-mode)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; vlf - handle open very large files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package vlf
  :ensure t
  :config
  (require 'vlf-setup))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; web-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package web-mode
  :ensure t
  :mode (("\\.phtml\\'" . web-mode)
         ("\\.tpl\\.php\\'" . web-mode)
         ("\\.[agj]sp\\'" . web-mode)
         ("\\.as[cp]x\\'" . web-mode)
         ("\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.djhtml\\'" . web-mode)
         ("\\.html?\\'" . web-mode))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ein - ipython notebooks in gui emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Only launch if the executable exists.
(if (and my:jupyter_location
         my:jupyter_start_dir)
    ;; Skewer mode is used by ein for running javascript in the notebook
    (use-package skewer-mode
      :ensure t
      :defer t)
    (use-package ein
      :ensure t
      :requires skewer-mode
      :commands (ein:jupyter-server-start)
      :defer 5
      :config
      (when my:byte-compile-init
        (require 'ein)
        (require 'ein-loaddefs)
        (require 'ein-notebook)
        (require 'ein-subpackages))
      ;; when editing the emacs.el file, we do not want to start a new
      ;; Jupyter server each time we save, so we only start a new Jupyter
      ;; server if there currently isn't one running.
      (defvar my-found-ein-server nil)
      (dolist (my-current-process (process-list))
        (when (string-match "EIN: Jupyter*" (process-name my-current-process))
          (setq my-found-ein-server t))
        )
      (when (not my-found-ein-server)
        (ein:jupyter-server-start my:jupyter_location my:jupyter_start_dir))
      )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; autopair
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically at closing brace, bracket and quote
(use-package autopair
  :ensure t
  :diminish autopair-mode
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function autopair-global-mode "autopair.el"))
  :config
  (autopair-global-mode t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load hungry Delete, caus we're lazy
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Set hungry delete:
(use-package hungry-delete
  :ensure t
  :diminish hungry-delete-mode
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function global-hungry-delete-mode "hungry-delete.el"))
  :config
  (global-hungry-delete-mode t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Syntax Highlighting in CUDA
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load CUDA mode so we get syntax highlighting in .cu files
(use-package cuda-mode
  :ensure t
  :mode (("\\.cu\\'" . cuda-mode)
         ("\\.cuh\\'" . cuda-mode)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Flyspell Mode for Spelling Corrections
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package flyspell
  :ensure t
  :diminish flyspell-mode
  :hook ((text-mode . flyspell-mode)
         (prog-mode . flyspell-prog-mode)
         (org-mode . flyspell-mode))
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function flyspell-goto-next-error "flyspell.el")
    (declare-function flyspell-mode "flyspell.el")
    (declare-function flyspell-prog-mode "flyspell.el"))
  (setq flyspell-issue-welcome-flag nil)
  :config
  (defun flyspell-check-next-highlighted-word ()
    "Custom function to spell check next highlighted word."
    (interactive)
    (flyspell-goto-next-error)
    (ispell-word))

  (global-set-key (kbd "<f7>") 'flyspell-buffer)
  (global-set-key (kbd "<f8>") 'flyspell-correct-previous)
  (global-set-key (kbd "<f9>") 'flyspell-correct-next)
  )
(use-package flyspell-correct-ivy
  :ensure t
  :after flyspell)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Magit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package magit
  :ensure t
  :after (ivy)
  :commands (magit-checkout)
  :bind (("M-g M-s" . magit-status)
         ("M-g M-c" . 'magit-checkout)
         )
  :init
  (use-package dash
    :ensure t)
  :config
  (add-hook 'magit-mode-hook (lambda () (setq whitespace-mode -1)))
  (setq magit-completing-read-function 'ivy-completing-read)
  )
(use-package magit-gerrit
  :ensure t
  :after magit
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GitGutter
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package git-gutter
  :ensure t
  :diminish git-gutter-mode
  :defer 2
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function global-git-gutter-mode "git-gutter.el"))
  :config
  ;; If you enable global minor mode
  (global-git-gutter-mode t)
  ;; Auto update every 5 seconds
  (custom-set-variables
   '(git-gutter:update-interval 5))

  ;; Set the foreground color of modified lines to something obvious
  (set-face-foreground 'git-gutter:modified "purple")
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; gitignore-mode: highlighting in gitignore files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package gitignore-mode
  :ensure t
  :diminish gitignore-mode
  :mode (".gitignore"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; cmake-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package cmake-mode
  :ensure t
  :mode ("CMakeLists.txt" ".cmake")
  :hook (cmake-mode . (lambda ()
                        (add-to-list 'company-backends 'company-cmake)))
  :config
  (use-package cmake-font-lock
    :ensure t
    :defer t
    :commands (cmake-font-lock-activate)
    :hook (cmake-mode . (lambda ()
                          (cmake-font-lock-activate)
                          (font-lock-add-keywords
                           nil '(("\\<\\(FIXME\\|TODO\\|BUG\\|DONE\\)"
                                  1 font-lock-warning-face t)))))
    )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Bazel-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (not (file-directory-p "~/.emacs.d/plugins/"))
    (make-directory "~/.emacs.d/plugins/"))
(if (not (file-exists-p "~/.emacs.d/plugins/bazel-mode.el"))
    (url-copy-file
     "https://raw.githubusercontent.com/codesuki/bazel-mode/master/bazel-mode.el"
     "~/.emacs.d/plugins/bazel-mode.el"))
(if (file-exists-p "~/.emacs.d/plugins/bazel-mode.el")
    (use-package bazel-mode
      :mode ("BUILD" "\\.bazel\\'" "\\.bzl'" "WORKSPACE\\'")
      )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; protobuf-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (not (file-directory-p "~/.emacs.d/plugins/"))
    (make-directory "~/.emacs.d/plugins/"))
(if (not (file-exists-p "~/.emacs.d/plugins/protobuf-mode.el"))
    (url-copy-file
     "https://raw.githubusercontent.com/google/protobuf/master/editors/protobuf-mode.el"
     "~/.emacs.d/plugins/protobuf-mode.el"))
(if (file-exists-p "~/.emacs.d/plugins/protobuf-mode.el")
    (use-package protobuf-mode
      :mode ("\\.proto")
      )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; yaml-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package yaml-mode
  :ensure t
  :mode (".yml" ".yaml"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; json-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package json-mode
  :ensure t
  :mode (".json" ".imp"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; rust-mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Note: ycmd is used for completion. However, you'll need to modify
;; racerd slightly to get that to work. Comment out the sections:
;; if config.print_http_logs {
;;     chain.link_before(log_before);
;; }
;; and
;; if config.print_http_logs {
;;     chain.link_after(log_after);
;; }
;; calls in third_party/racerd/src/http/mod.rs in the function
;; 'serve', then rebuild ycmd.
(use-package rust-mode
  :ensure t
  :mode ("\\.rs\\'")
  :init
  (when my:byte-compile-init
    (require 'rust-mode))
  (use-package flycheck-rust
    :ensure t
    :after rust-mode)

  :config
  (defun my:rust-mode-hook()
    (set (make-local-variable 'compile-command) "cargo run")
    (eval-when-compile
      ;; Silence missing function warnings
      (declare-function flycheck-rust-setup "flycheck-rust.el"))
    (add-hook 'flycheck-mode-hook #'flycheck-rust-setup)
    )
  (add-hook 'rust-mode-hook 'my:rust-mode-hook)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup Dockerfile mode
;; 1. Download file from GitHub
;; 2. Load mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (not (file-directory-p "~/.emacs.d/plugins"))
    (make-directory "~/.emacs.d/plugins"))
(if (not (file-exists-p "~/.emacs.d/plugins/dockerfile-mode.el"))
    (url-copy-file
     "https://raw.githubusercontent.com/spotify/dockerfile-mode/master/dockerfile-mode.el"
     "~/.emacs.d/plugins/dockerfile-mode.el"))
(use-package dockerfile-mode
  :mode ("Dockerfile"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Package: yasnippet
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package yasnippet
  :ensure t
  :diminish yas-minor-mode
  :commands (yas-reload-all)
  :init
  (eval-when-compile
    ;; Silence missing function warnings
    (declare-function yas-global-mode "yasnippet.el"))
  :defer 5
  :config
  (yas-global-mode t)
  (yas-reload-all))
(use-package yasnippet-snippets
  :ensure t
  :after yasnippet
  :config
  (yas-reload-all))
;; Apparently the company-yasnippet backend shadows all backends that
;; come after it. To work around this we assign yasnippet to a different
;; keybind since actual source completion is vital.
(use-package company-yasnippet
  :bind ("C-M-y" . company-yasnippet)
  :after (yasnippet)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load asm-mode when opening assembly files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package asm-mode
  :mode ("\\.s\\'"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Use markdown-mode for markdown files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package markdown-mode
  :ensure t
  :mode (".md" ".markdown")
  :config
  (define-key markdown-mode-map (kbd "M-p") nil)
  (define-key markdown-mode-map (kbd "M-n") nil))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; auctex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package tex-site
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  ;; When we byte-compile we need to have the autoloads loaded in order to
  ;; properly get auctex working, otherwise auctex is not loaded correctly
  :init
  (load "auctex-autoloads" nil t)
  :config
  (setq-default TeX-auto-save t
                TeX-parse-self t
                TeX-source-correlate-start-server t)
  (cond
   ((string-equal system-type "windows-nt") ; Microsoft Windows
    (progn
      (message "Windows does not have a PDF viewer set for auctex")))
   ((string-equal system-type "darwin") ; Mac OS X
    (setq-default
     TeX-view-program-list
     '(("Skim"
        "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g %n %o %b")
       )
     TeX-view-program-selection '((output-pdf "Skim"))))
   ((string-equal system-type "gnu/linux") ; linux
    (setq-default TeX-view-program-list
                  '(("Evince" "evince --page-index=%(outpage) %o"))
                  TeX-view-program-selection '((output-pdf "Evince")))))
  (add-hook 'LaTeX-mode-hook 'TeX-source-correlate-mode)
  (add-hook 'LaTeX-mode-hook 'auto-fill-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-mode)
  (add-hook 'LaTeX-mode-hook 'flyspell-buffer)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (setq-default reftex-plug-into-AUCTeX t)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Appearance
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; The deeper blue theme is loaded but the resulting text
;; appears black in Aquamacs. This can be fixed by setting
;; the font color under Menu Bar->Options->Appearance->Font For...
;; and then setting "Adopt Face and Frame Parameter as Frame Default"
(when (string-equal my:use-theme "spacemacs-dark")
  (use-package spacemacs-common
    :ensure spacemacs-theme
    :config (load-theme 'spacemacs-dark t)))

(when (string-equal my:use-theme "sourcerer")
  (use-package sourcerer-theme
    :ensure t
    :config
    (load-theme 'sourcerer t))

  (set-face-background 'hl-line "#372E2D")
  ;; The minibuffer default colors with my theme are impossible to read,
  ;; so change them to something better using ivy-minibuffer-match-face.

  (custom-set-faces
   ;; custom-set-faces was added by Custom.
   ;; If you edit it by hand, you could mess it up, so be careful.
   ;; Your init file should contain only one such instance.
   ;; If there is more than one, they won't work right.
   '(default
      ((((type tty) (background dark)) (:background "nil"))))
   '(company-preview
     ((t (:background "#073642" :foreground "#2aa198"))))
   '(company-preview-common
     ((t (:foreground "#93a1a1" :underline t))))
   '(company-scrollbar-bg
     ((t (:background "#073642" :foreground "#2aa198"))))
   '(company-scrollbar-fg
     ((t (:foreground "#002b36" :background "#839496"))))
   '(company-template-field
     ((t (:background "#7B6000" :foreground "#073642"))))
   '(company-tooltip
     ((t (:background "black" :foreground "DeepSkyBlue1"))))
   '(company-tooltip-annotation
     ((t (:foreground "#93a1a1" :background "#073642"))))
   '(company-tooltip-common
     ((t (:foreground "#93a1a1" :underline t))))
   '(company-tooltip-common-selection
     ((t (:foreground "#93a1a1" :underline t))))
   '(company-tooltip-mouse
     ((t (:background "DodgerBlue4" :foreground "CadetBlue1"))))
   '(company-tooltip-selection
     ((t (:background "DodgerBlue4" :foreground "CadetBlue1"))))
   '(header-line
     ((t (:background "#003366"))))
   '(ivy-minibuffer-match-face-1
     ((((class color) (background light)) (:background "#555555"))
      (((class color) (background dark)) (:background "#555555"))))
   '(ivy-minibuffer-match-face-2
     ((t (:background "#314f30" :weight bold))))
   '(ivy-minibuffer-match-face-3
     ((t (:background "#48225b" :weight bold))))
   '(ivy-minibuffer-match-face-4
     ((t (:background "#680a0a" :weight bold))))
   '(which-func ((t (:foreground "#8fb28f"))))))

;; I don't care to see the splash screen
(setq inhibit-splash-screen t)

;; Hide the scroll bar
(scroll-bar-mode -1)

;(defvar my-font-size 90)
(defvar my-font-size 110)
;; Make mode bar small
(set-face-attribute 'mode-line nil  :height my-font-size)
;; Set the header bar font
(set-face-attribute 'header-line nil  :height my-font-size)
;; Set default window size and position
(setq default-frame-alist
      '((top . 0) (left . 0) ;; position
        (width . 110) (height . 90) ;; size
        ))
;; Enable line numbers on the LHS
(global-linum-mode -1)
;; Set the font to size 9 (90/10).
(set-face-attribute 'default nil :height my-font-size)

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Enable which function mode and set the header line to display both the
;; path and the function we're in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(which-function-mode t)

;; Remove function from mode bar
(setq mode-line-misc-info
      (delete (assoc 'which-func-mode
                     mode-line-misc-info) mode-line-misc-info))


(defmacro with-face (str &rest properties)
  "Used to set the face of STR with PROPERTIES."
  `(propertize ,str 'face (list ,@properties)))

(defun sl/make-header ()
  "."
  (let* ((sl/full-header (abbreviate-file-name buffer-file-name))
         (sl/header (file-name-directory sl/full-header))
         (sl/drop-str "[...]")
         )
    (if (> (length sl/full-header)
           (window-body-width))
        (if (> (length sl/header)
               (window-body-width))
            (progn
              (concat (with-face sl/drop-str
                                 :background "blue"
                                 :weight 'bold
                                 )
                      (with-face (substring sl/header
                                            (+ (- (length sl/header)
                                                  (window-body-width))
                                               (length sl/drop-str))
                                            (length sl/header))
                                 ;; :background "red"
                                 :weight 'bold
                                 )))
          (concat
           (with-face sl/header
                      ;; :background "red"
                      :foreground "red"
                      :weight 'bold)))
      (concat (if window-system ;; In the terminal the green is hard to read
                  (with-face sl/header
                             ;; :background "green"
                             ;; :foreground "black"
                             :weight 'bold
                             :foreground "#8fb28f"
                             )
                (with-face sl/header
                           ;; :background "green"
                           ;; :foreground "black"
                           :weight 'bold
                           :foreground "blue"
                           ))
              (with-face (file-name-nondirectory buffer-file-name)
                         :weight 'bold
                         ;; :background "red"
                         )))))

(defun sl/display-header ()
  "Create the header string and display it."
  ;; The dark blue in the header for which-func is terrible to read.
  ;; However, in the terminal it's quite nice
  (if window-system
      (custom-set-faces
       '(which-func ((t (:foreground "#8fb28f")))))
    (custom-set-faces
     '(which-func ((t (:foreground "blue"))))))
  ;; Set the header line
  (setq header-line-format
        (list "-"
              '(which-func-mode ("" which-func-format))
              '("" ;; invocation-name
                (:eval (if (buffer-file-name)
                           (concat "[" (sl/make-header) "]")
                         "[%b]"))))))
;; Call the header line update
(add-hook 'buffer-list-update-hook 'sl/display-header)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Powerline theme
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; powerline theme where the modes are on the right side.
(use-package powerline
  :ensure t
  :config
  (defun powerline-right-theme ()
    "Setup a mode-line with major and minor modes on the right side."
    (interactive)
    (setq-default
     mode-line-format
     '("%e"
       (:eval
        (let* ((active (powerline-selected-window-active))
               (mode-line-buffer-id
                (if active 'mode-line-buffer-id 'mode-line-buffer-id-inactive))
               (mode-line (if active 'mode-line 'mode-line-inactive))
               (face0 (if active 'powerline-active0 'powerline-inactive0))
               (face1 (if active 'powerline-active1 'powerline-inactive1))
               (face2 (if active 'powerline-active2 'powerline-inactive2))
               (separator-left
                (intern (format "powerline-%s-%s"
                                (powerline-current-separator)
                                (car powerline-default-separator-dir))))
               (separator-right
                (intern (format "powerline-%s-%s"
                                (powerline-current-separator)
                                (cdr powerline-default-separator-dir))))
               (lhs (list (powerline-raw "%*" face0 'l)
                          (powerline-buffer-size face0 'l)
                          (powerline-buffer-id `(mode-line-buffer-id ,face0) 'l)
                          (powerline-raw " ")
                          (funcall separator-left face0 face1)
                          (powerline-narrow face1 'l)
                          (powerline-vc face1)))
               (center (list (powerline-raw global-mode-string face1 'r)
                             (powerline-raw "%4l" face1 'r)
                             (powerline-raw ":" face1)
                             (powerline-raw "%3c" face1 'r)
                             (funcall separator-right face1 face0)
                             (powerline-raw " ")
                             (powerline-raw "%6p" face0 'r)
                             (powerline-hud face2 face1)
                             ))
               (rhs (list (powerline-raw " " face1)
                          (funcall separator-left face1 face2)
                          (when (and (boundp 'erc-track-minor-mode)
                                     erc-track-minor-mode)
                            (powerline-raw erc-modified-channels-object
                                           face2 'l))
                          (powerline-major-mode face2 'l)
                          (powerline-process face2)
                          (powerline-raw " :" face2)
                          (powerline-minor-modes face2 'l)
                          (powerline-raw " " face2)
                          (funcall separator-right face2 face1)
                          ))
               )
          (concat (powerline-render lhs)
                  (powerline-fill-center
                   face1 (/ (powerline-width center) 2.0))
                  (powerline-render center)
                  (powerline-fill face1 (powerline-width rhs))
                  (powerline-render rhs)))))))
  (powerline-right-theme)
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; evil-mode: Emacs Vi Layer to use Vi/Vim keybindings in Emacs.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(setq evil-want-integration nil)

(when my:use-evil-mode
  (use-package evil
    :ensure t
    :diminish undo-tree-mode
    :init
    (eval-when-compile
      ;; Silence missing function warnings
      (declare-function evil-mode "evil.el"))
    (setq evil-want-integration nil)
    :config
    (evil-mode t)
    (use-package powerline
      :ensure t
      :config
      (powerline-center-evil-theme))

    ;; There is a warning about evil-want-integration not being set to
    ;; nil during compilation that I haven't figured out how to fix.
    (use-package evil-collection
      :after evil
      :ensure t
      :init
      (when my:byte-compile-init
        ;; We need company-tng when byte-compiling, otherwise don't load it
        ;; since it'll slow down startup times.
        (require 'company-tng))
      (eval-when-compile
        ;; Silence missing function warnings
        (declare-function evil-collection-init "evil-collection.el"))
      :config
      (evil-collection-init)
      )

    (when my:use-dvorak-bindings
      (use-package evil-dvorak
        :ensure t
        :diminish evil-dvorak-mode
        :init
        (eval-when-compile
          ;; Silence missing function warnings
          (declare-function global-evil-dvorak-mode "evil-dvorak.el"))
        :config (global-evil-dvorak-mode t)))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Below are configurations that are unique to my work
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load c++-mode when opening charm++ interface files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-to-list 'auto-mode-alist '("\\.ci\\'" . c++-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load SpEC files in specinput mode
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if (file-exists-p "~/.emacs.d/plugins/specinput-mode.el")
    (use-package specinput-mode
      :mode ("\\.input\\'" "\\.output\\'")
      ))

(add-to-list 'auto-mode-alist '("\\.def\\'" . bash-mode))
(add-to-list 'auto-mode-alist '("\\.env\\'" . bash-mode))
(add-to-list 'auto-mode-alist '("\\.toplevel\\'" . perl-mode))

(provide '.emacs)
;;; .emacs ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (flycheck-ycmd company-ycmd ycmd zzz-to-char yasnippet-snippets yapfify yaml-mode writegood-mode window-numbering which-key wgrep web-mode vlf visual-regexp-steroids use-package string-inflection ssh spacemacs-theme rust-mode rtags ripgrep realgud rainbow-delimiters powerline origami org-evil org-ac neotree multiple-cursors modern-cpp-font-lock magithub magit-gerrit json-mode ido-select-window hungry-delete google-c-style gitignore-mode git-gutter git flyspell-correct-ivy flycheck-rust flycheck-pyflakes evil-leader evil-collection esup elpy ein edit-server diminish cuda-mode counsel-projectile counsel-etags cmake-mode cmake-ide clang-format beacon autopair auto-package-update auctex afternoon-theme ac-clang))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(which-func ((t (:foreground "#8fb28f")))))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set evil leader
(require 'evil-leader)
(global-evil-leader-mode)
(evil-leader/set-leader ",")
(evil-leader/set-key
  "e" 'find-file
  "b" 'switch-to-buffer
  "k" 'kill-buffer
  "o" 'switch-to-next-buffer)

; vim evil mode
;(setq evil-want-integration nil)
(require 'evil)
(when (require 'evil-collection nil t)
  (evil-collection-init))
(evil-mode 1)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(with-eval-after-load 'evil-maps
                      (define-key evil-motion-state-map (kbd ":") 'evil-repeat-find-char)
                      (define-key evil-motion-state-map (kbd ";") 'evil-ex))

;;(require 'rtags) ;; optional, must have rtags installed
;;(cmake-ide-setup)


;; define the global key to swith window
;(global-set-key (kbd "C-x <up>") 'windmove-up)
;(global-set-key (kbd "C-x <down>") 'windmove-down)
;(global-set-key (kbd "C-x <left>") 'windmove-left)
;(global-set-key (kbd "C-x <right>") 'windmove-right)

(global-set-key (kbd "C-k") 'windmove-up)
(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-l") 'windmove-right)



(global-linum-mode 1) ; alway show line numbers



(require 'yasnippet)
