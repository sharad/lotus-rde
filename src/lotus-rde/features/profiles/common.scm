

(define-module (lotus-rde features profiles common)
  #:use-module (rde features)
  #:use-module (rde predicates)
  #:use-module (rde system services admin)
  #:use-module (lotus-rde features profiles)
  #:export (feature-common-profile))


(define* (feature-common-profile)

  (define* (get-home-services config)
    (list
     ;; 01-doc
     (simple-service
      'common-doc
      home-doc-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(poppler
                      ghostscript
                      evince
                      gv
                      emacs-org-asciidoc
                      emacs-org-pdftools
                      emacs-ebib))))))
     ;; 01-tool
     (simple-service
      'common-tool
      home-tool-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(fzf
                      ghq
                      gita
                      baobab
                      ncdu
                      catdoc
                      pinfo
                      bool
                      slscroll
                      tabbed
                      complgen
                      progress
                      date2name
                      bitwise
                      chrpath
                      dtach
                      rdfind
                      gpsbabel
                      xurls

                      unrar

                      binutils
                      pkg-config
                      patchelf
                      dosfstools
                      rpm
                      picocom
                      cloud-utils

                      rde
                      gnu-pw-mgr
                      bidiv
                      cpulimit
                      recutils
                      global
                      fasd
                      rcs
                      darcs
                      xmlstarlet


                      emacs-difftastic
                      emacs-helm-comint
                      emacs-dired-quick-sort
                      emacs-dall-e-shell
                      emacs-i-ching
                      emacs-lobsters
                      emacs-gnus-desktop-notify
                      emacs-on
                      emacs-kodi-remote
                      emacs-wget
                      emacs-w3m
                      emacs-xmlgen
                      emacs-sops
                      emacs-discourse-mode
                      emacs-helm-pass
                      emacs-helm-org-ql
                      emacs-spark
                      emacs-pdd
                      emacs-gt))))))
     ;; 01-crypto
     (simple-service
      'common-crypto
      home-crypto-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-security
     (simple-service
      'common-security
      home-security-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(keepassxc
                      keepassxc-browser-icecat

                      gnupg
                      paperkey
                      keychain
                      pinentry
                      pinentry-tty
                      pinentry-rofi
                      pinentry-gtk2
                      pinentry-efl

                      opensc
                      pcsc-lite
                      softhsm
                      ccid
                      tpm2-tools
                      oath-toolkit

                      cryfs
                      encfs
                      gocryptfs
                      sirikali
                      tomb
                      git-crypt
                      transcrypt
                      ccrypt
                      ecryptfs-utils
                      ecryptfs-simple

                      pkcs11-provider
                      python-pkcs11-provider
                      pkcs11-helper

                      gpgme
                      qgpgme
                      signify
                      volume-key
                      pass-coffin


                      openssl
                      gnutls

                      openldap
                      keyutils

                      pinentry-emacs))))))
     ;; 01-x
     (simple-service
      'common-x
      home-x-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                '(xhost
                  xauth
                  xkill
                  xvkbd
                  svkbd
                  showmethekey

                  emacs-xelb))))))
     ;; 01-dev
     (simple-service
      'common-dev
      home-dev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(docker-cli
                      docker-compose
                      podman

                      kubectl
                      k9s
                      helm-kubernetes
                      kompose

                      python-fire
                      python-wrapper
                      python-flake8
                      python-pyflakes
                      python-importmagic
                      python-epc
                      python-sexpdata
                      python-gitlab
                      python-git-review
                      python-paramiko
                      python-scp

                      git-tools
                      git-extras
                      git-lfs
                      git-watch
                      git-gwatch
                      git-spice
                      git-issue
                      stgit
                      tig
                      myrepos
                      pre-commit

                      direnv
                      direvent

                      rust-usrhttpd


                      gcc-toolchain
                      gdb
                      autoconf
                      automake
                      libtool
                      flex
                      bison
                      guile
                      guildhall
                      go
                      gopls
                      rust
                      rust-analyzer
                      cargo
                      erlang
                      elixir
                      ghc
                      idris
                      swi-prolog
                      gprolog
                      vala
                      r
                      r-ggplot2
                      r-cowplot
                      php
                      python-pip
                      python-netifaces
                      python-lxml
                      python-gitlab
                      python-argcomplete
                      python-jinja2
                      doxygen

                      cl-asdf
                      cl-fad
                      cl-slime-swank
                      sbcl-ironclad
                      perl-yaml
                      perl-xml-compile
                      perl-xml-libxslt



                      guile-studio

                      emacs-claude-code-ide
                      emacs-llm
                      emacs-llm-tool-collection
                      emacs-ellama
                      emacs-llama
                      emacs-gptel-quick
                      emacs-ob-gptel
                      emacs-ollama-buddy
                      emacs-mcp

                      emacs-lsp-booster
                      emacs-lsp-treemacs
                      emacs-treemacs
                      emacs-treemacs-extra
                      emacs-dape
                      emacs-anaconda-mode
                      emacs-pythonic
                      emacs-clojure-ts-mode
                      emacs-devicetree-ts-mode
                      emacs-raku-mode
                      emacs-typst-ts-mode
                      emacs-numpydoc
                      emacs-xref-union

                      emacs-eslint-fix
                      emacs-flymake-eslint
                      emacs-json-simple-flymake

                      emacs-forgejo
                      emacs-orgit-forge
                      emacs-pr-review
                      emacs-magit-tbdiff
                      emacs-git-gutter-transient
                      emacs-ssh-tunnels
                      emacs-direnv

                      emacs-emacsql
                      emacs-consumer
                      emacs-arei
                      emacs-el-job))))))

     ;; 01-text
     (simple-service
      'common-text
      home-text-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(recoll
                      recoll-cli
                      enscript

                      emacs-markov-text
                      emacs-org-count-words
                      emacs-org-mem
                      emacs-org-rainbow-tags
                      emacs-org-supertag
                      emacs-org-social
                      emacs-org-notify
                      emacs-howm
                      emacs-jinx))))))
     ;; 01-dynamic-hash
     (simple-service
      'common-dynamic-hash
      home-dynamic-hash-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-net
     (simple-service
      'common-net
      home-net-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 91-build-heavy
     (simple-service
      'common-build-heavy
      home-build-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-essential
     (simple-service
      'common-essential
      home-essential-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(emacs
                      sbcl
                      sbcl-linedit
                      sbcl-alexandria

                      bc
                      wget
                      zip
                      unzip
                      cpio
                      rsync
                      jq
                      yq
                      gojq
                      whois
                      pwgen
                      xmlstarlet
                      libxml2
                      libxslt
                      atool
                      shellcheck
                      lsof
                      parted



                      glibc
                      glibc-locales
                      coreutils
                      diffutils
                      findutils
                      tar
                      patch
                      sed
                      grep
                      gawk
                      moreutils
                      make
                      mbake

                      glibc-locales
                      vim
                      dos2unix
                      iproute2
                      tree
                      time
                      curl
                      perl
                      python
                      ruby
                      kbd
                      xkeyboard-config
                      lesspipe
                      man-pages
                      units))))))
     ;; 01-emacs
     (simple-service
      'common-emacs
      home-emacs-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-editor
     (simple-service
      'common-editor
      home-editor-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(meld
                      emacs-with-editor
                      emacs-restart-emacs
                      emacs-spacemacs-theme
                      emacs-doric-themes
                      emacs-spaceline
                      emacs-spaceline-all-the-icons
                      emacs-spacious-padding
                      emacs-winum
                      emacs-compat
                      emacs-treesit-auto
                      emacs-window-tool-bar
                      emacs-ultra-scroll
                      emacs-smarttabs
                      emacs-repeat-fu
                      emacs-keymap-popup
                      emacs-frames-only-mode
                      emacs-ergoemacs-mode
                      emacs-packed
                      emacs-load-relative
                      emacs-xpm
                      emacs-quiet
                      emacs-blight
                      emacs-literate-elisp
                      emacs-pcre2el))))))
     ;; 71-sysdev
     (simple-service
      'common-sysdev
      home-sysdev-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 60-lengthy
     (simple-service
      'common-lengthy
      home-lengthy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-simple
     (simple-service
      'common-simple
      home-simple-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 01-console
     (simple-service
      'common-console
      home-console-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(nushell
                      rlwrap
                      netcat-openbsd
                      mosh
                      autossh
                      ncftp
                      lftp
                      sshpass

                      eless))))))
     ;; 90-heavy
     (simple-service
      'common-heavy
      home-heavy-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 40-servers
     (simple-service
      'common-servers
      home-servers-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(miniflux
                      matterbridge
                      znc))))))
     ;; 01-games
     (simple-service
      'common-games
      home-games-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-java
     (simple-service
      'common-java
      home-java-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (map symbol->string
                    '(electron
                      chromium-embedded-framework
                      node-tiddlywiki))))))
     ;; 99-tmp
     (simple-service
      'common-tmp
      home-tmp-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 02-test
     (simple-service
      'common-test
      home-test-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))
     ;; 99-failed
     (simple-service
      'common-failed
      home-failed-profile-service-type
      (scoped-profile-config
       (packages
        (apply strings->packages
               (list)))))))

  (feature
   (name 'common-profile)
   (home-services-getter get-home-services)))

