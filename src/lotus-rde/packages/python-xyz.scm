
(define-module (lotus-rde packages python-xyz)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system pyproject)
  #:use-module (guix build-system python)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (gnu packages)
  #:use-module (gnu packages rust-apps)
  #:use-module (gnu packages xorg)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages check)
  #:use-module (gnu packages xml)
  #:use-module (gnu packages tmux)
  #:use-module (gnu packages speech)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages python)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages xiph)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-crypto)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages protobuf)
  #:use-module (gnu packages time))

(define-public python-colorama-043
  (package (inherit python-colorama)
           (version "0.4.3")
           (source
            (origin (method url-fetch)
                    (uri (pypi-uri "colorama" version))
                    (sha256 (base32 "189n8hpijy14jfan4ha9f5n06mnl33cxz7ay92wjqgkr639s0vg9"))))))

;; https://files.pythonhosted.org/packages/source/P/PyYAML/PyYAML-5.2.tar.gz
(define-public python-pyyaml-52
  (package (inherit python-pyyaml)
           (name "python-pyyaml")
           (version "5.2")
           (source (origin (method url-fetch)
                           (uri (pypi-uri "PyYAML" version))
                           (sha256 (base32 "0v1lwxbn0x2s6lbj7iqbn4gpy6rxf17jqvpcqb1jjbaq5k58xvn0"))))))

(define-public python-exifread
  (package
    (name "python-exifread")
    (version "2.1.2")
    (source
     (origin (method url-fetch)
             (uri (pypi-uri "ExifRead" version))
             (sha256 (base32 "1b90jf6m9vxh9nanhpyvqdq7hmfx5iggw1l8kq10jrs6xgr49qkr"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (home-page "https://github.com/ianare/exif-py")
    (synopsis
     "Read Exif metadata from tiff and jpeg files.")
    (description
     "Read Exif metadata from tiff and jpeg files.")
    (license license:bsd-3)))

(define-public python-organize-tool
  (package
    (name "python-organize-tool")
    (version "1.7.0")
    (source (origin (method url-fetch)
                    (uri (pypi-uri "organize-tool" version))
                    (sha256 (base32 "15yyh3ycb1f7q5ig7gq5ppwaf1wpx5dr906w80rfzlkh0z8byvh3"))))
    (build-system python-build-system)
    (arguments
     `(#:phases
       (modify-phases %standard-phases
         (delete 'check))))
    (inputs
     `(("python-exifread"     ,python-exifread)
       ("python-docopt"       ,python-docopt)
       ("python-appdirs"      ,python-appdirs)
       ("python-send2trash"   ,python-send2trash)
       ("python-pyyaml"       ,python-pyyaml-52)
       ("python-colorama"     ,python-colorama-043)))
    (home-page
     "https://github.com/tfeldmann/organize")
    (synopsis "The file management automation tool")
    (description
     "The file management automation tool")
    (license license:expat)))

;; (define-public python-simplematch
;;   (package
;;     (name "python-simplematch")
;;     (version "1.4")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/tfeldmann/simplematch")
;;              (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0g55xgzlxz03r0qdx158a9gfpvjw3agf21yfpw72s0syk8dpml1q"))))
;;     (build-system pyproject-build-system)
;;     (native-inputs (list python-poetry-core))
;;     (home-page "https://github.com/tfeldmann/simplematch")
;;     (synopsis "Minimal, super readable string pattern matching.")
;;     (description "Minimal, super readable string pattern matching.")
;;     (license license:expat)))

;; (define-public python-pytkdocs
;;   (package
;;     (name "python-pytkdocs")
;;     (version "0.16.5")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "pytkdocs" version))
;;        (sha256
;;         (base32 "19sgvy6rf600vmh5dimfw8x1cnv8v1yams8a6jy95hwq08zxng0h"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-astunparse python-cached-property
;;                              python-docstring-parser python-typing-extensions))
;;     (native-inputs (list python-pdm-backend))
;;     (home-page "https://mkdocstrings.github.io/pytkdocs")
;;     (synopsis "Load Python objects documentation.")
;;     (description "Load Python objects documentation.")
;;     (license #f)))

;; (define-public python-mkdocstrings-python-legacy
;;   (package
;;     (name "python-mkdocstrings-python-legacy")
;;     (version "0.2.7")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "mkdocstrings_python_legacy" version))
;;        (sha256
;;         (base32 "18gq3wxdql6mm1miyqcd5rwxixwal4zxx1ippr4hvyrjldvs5a0s"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-mkdocs-autorefs python-mkdocstrings
;;                              python-pytkdocs))
;;     (native-inputs (list python-pdm-backend))
;;     (home-page "https://mkdocstrings.github.io/python-legacy")
;;     (synopsis "A legacy Python handler for mkdocstrings.")
;;     (description
;;      "This package provides a legacy Python handler for mkdocstrings.")
;;     (license #f)))

;; (define-public python-uv-dynamic-versioning
;;   (package
;;     (name "python-uv-dynamic-versioning")
;;     (version "0.14.0")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/ninoseki/uv-dynamic-versioning/")
;;              (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0zb13ylzi6cp4dyv54xahbjh6sadm57fbnzbh6y27fhr1vsf85z2"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-dunamai python-hatchling python-jinja2
;;                              python-tomlkit))
;;     (native-inputs (list python-hatchling python-uv-dynamic-versioning))
;;     (home-page "https://github.com/ninoseki/uv-dynamic-versioning/")
;;     (synopsis "Dynamic versioning based on VCS tags for uv/hatch project")
;;     (description "Dynamic versioning based on VCS tags for uv/hatch project.")
;;     (license #f)))

;; (define-public python-griffelib
;;   (package
;;     (name "python-griffelib")
;;     (version "2.0.2")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "griffelib" version))
;;        (sha256
;;         (base32 "0zkhvvr40ij9mwyy2zf63fn1n8difq06w8xzzxikgs3hqhxhpwiw"))))
;;     (build-system pyproject-build-system)
;;     (native-inputs (list python-hatchling python-pdm-backend
;;                          python-uv-dynamic-versioning))
;;     (home-page #f)
;;     (synopsis
;;      "Signatures for entire Python programs. Extract the structure, the frame, the skeleton of your project, to generate API documentation or find breaking changes in your API.")
;;     (description
;;      "Signatures for entire Python programs.  Extract the structure, the frame, the
;; skeleton of your project, to generate API documentation or find breaking changes
;; in your API.")
;;     (license #f)))

;; (define-public python-mkdocstrings
;;   (package
;;     (name "python-mkdocstrings")
;;     (version "2.0.3")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "mkdocstrings_python" version))
;;        (sha256
;;         (base32 "1f0k5k4qzmkajmivhy8vqajvzllacxvk378wncwr91nca4kn6665"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-griffelib python-mkdocs-autorefs
;;                              python-mkdocstrings python-typing-extensions))
;;     (native-inputs (list python-pdm-backend))
;;     (home-page "https://mkdocstrings.github.io/python")
;;     (synopsis "A Python handler for mkdocstrings.")
;;     (description "This package provides a Python handler for mkdocstrings.")
;;     (license #f)))

;; (define-public python-markdown-callouts
;;   (package
;;     (name "python-markdown-callouts")
;;     (version "0.4.0")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/oprypin/markdown-callouts")
;;              (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0hiywx8h043jkvbv25qr5s5pnq94h5q6g2a65ajcfa3jxgyjz5bj"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-markdown python-markdown))
;;     (native-inputs (list python-hatchling))
;;     (home-page "https://github.com/oprypin/markdown-callouts")
;;     (synopsis "Markdown extension: a classier syntax for admonitions")
;;     (description "Markdown extension: a classier syntax for admonitions.")
;;     (license license:expat)))

;; (define-public python-mkdocstrings-crystal
;;   (package
;;     (name "python-mkdocstrings-crystal")
;;     (version "0.3.9")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/mkdocstrings/crystal")
;;              (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0mrcn3zjh23kfdppybmzag9l5k79ppcvbgsliql3rr2v4v6nbp9i"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-jinja2
;;                              python-jinja2
;;                              python-markdown-callouts
;;                              python-markupsafe
;;                              python-mkdocs-autorefs
;;                              python-mkdocstrings))
;;     (native-inputs (list python-hatchling))
;;     (home-page "https://github.com/mkdocstrings/crystal")
;;     (synopsis "Crystal language doc generator for MkDocs, via mkdocstrings")
;;     (description
;;      "Crystal language doc generator for @code{MkDocs}, via mkdocstrings.")
;;     (license license:expat)))

;; (define-public python-mkdocs-autorefs
;;   (package
;;     (name "python-mkdocs-autorefs")
;;     (version "1.4.4")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "mkdocs_autorefs" version))
;;        (sha256
;;         (base32 "15x1dpy5bym02v4fsrlfa3d25hj0g4bm5y7i72f6nd574x7jhjnm"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-markdown python-markupsafe python-mkdocs))
;;     (native-inputs (list python-pdm-backend))
;;     (home-page "https://mkdocstrings.github.io/autorefs")
;;     (synopsis "Automatically link across pages in MkDocs.")
;;     (description "Automatically link across pages in @code{MkDocs}.")
;;     (license #f)))

;; (define-public python-mkdocstrings
;;   (package
;;     (name "python-mkdocstrings")
;;     (version "1.0.4")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "mkdocstrings" version))
;;        (sha256
;;         (base32 "0wkidm2075g8lfk65vm2f6yl1s2amavw2lvv17ynbnvpbd8scs9r"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-jinja2
;;                              python-markdown
;;                              python-markupsafe
;;                              python-mkdocs
;;                              python-mkdocs-autorefs
;;                              python-mkdocstrings-crystal
;;                              python-mkdocstrings
;;                              python-mkdocstrings-python-legacy
;;                              python-pymdown-extensions))
;;     (native-inputs (list python-pdm-backend))
;;     (home-page "https://mkdocstrings.github.io")
;;     (synopsis "Automatic documentation from sources, for MkDocs.")
;;     (description "Automatic documentation from sources, for @code{MkDocs}.")
;;     (license #f)))


;; (define-public python-bracex
;;   (package
;;     (name "python-bracex")
;;     (version "2.6")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/facelessuser/bracex")
;;              (commit version)))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "1j717bsjr3ms4snzrbv4izbblcwgdk1lzxzi2cjhr9365zgz4kdk"))))
;;     (build-system pyproject-build-system)
;;     (native-inputs (list python-hatchling))
;;     (home-page "https://github.com/facelessuser/bracex")
;;     (synopsis "Bash style brace expander.")
;;     (description "Bash style brace expander.")
;;     (license license:expat)))

;; (define-public python-wcmatch
;;   (package
;;     (name "python-wcmatch")
;;     (version "10.1")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/facelessuser/wcmatch")
;;              (commit version)))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "1pz6wyz2hlckl88y6z7v32sm5mfp2mqgar4z5f1kz7mixsdpmh41"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-bracex))
;;     (native-inputs (list python-hatchling))
;;     (home-page "https://github.com/facelessuser/wcmatch")
;;     (synopsis "Wildcard/glob file name matcher.")
;;     (description "Wildcard/glob file name matcher.")
;;     (license license:expat)))

;; (define-public python-mkdocs-include-markdown-plugin
;;   (package
;;     (name "python-mkdocs-include-markdown-plugin")
;;     (version "7.3.0")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/mondeja/mkdocs-include-markdown-plugin")
;;              (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0afpmqijv8rybzhj7363a70gkjfiq8jg9f474fwxfmy6zda6h992"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-mkdocs python-wcmatch))
;;     (native-inputs (list python-hatchling))
;;     (home-page "https://github.com/mondeja/mkdocs-include-markdown-plugin")
;;     (synopsis "Mkdocs Markdown includer plugin.")
;;     (description "Mkdocs Markdown includer plugin.")
;;     (license #f)))



;; (define-public python-mkdocs-autorefs
;;   (package
;;     (name "python-mkdocs-autorefs")
;;     (version "1.4.4")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "mkdocs_autorefs" version))
;;        (sha256
;;         (base32 "15x1dpy5bym02v4fsrlfa3d25hj0g4bm5y7i72f6nd574x7jhjnm"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-markdown python-markupsafe python-mkdocs))
;;     (native-inputs (list python-pdm-backend))
;;     (home-page "https://mkdocstrings.github.io/autorefs")
;;     (synopsis "Automatically link across pages in MkDocs.")
;;     (description "Automatically link across pages in @code{MkDocs}.")
;;     (license #f)))



;; (define-public python-uv
;;   (package
;;     (name "python-uv")
;;     (version "0.11.16")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "uv" version))
;;        (sha256
;;         (base32 "0f0j4bpiv1x2c0hmql8dzmz46miq4a53m461vhrliwzq1b5myhsb"))))
;;     (build-system pyproject-build-system)
;;     (native-inputs (list maturin))
;;     (home-page "https://pypi.org/project/uv/")
;;     (synopsis
;;      "An extremely fast Python package and project manager, written in Rust.")
;;     (description
;;      "An extremely fast Python package and project manager, written in Rust.")
;;     (license #f)))

;; (define-public python-build
;;   (package
;;     (name "python-build")
;;     (version "1.5.0")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "build" version))
;;        (sha256
;;         (base32 "0ivnzhd0py11sidw3pnbfrhqkczb849na60rj7rxa3rapb1j4b1h"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-colorama
;;                              python-keyring
;;                              python-packaging
;;                              python-pyproject-hooks
;;                              python-tomli
;;                              python-uv
;;                              python-virtualenv))
;;     (native-inputs (list python-flit-core))
;;     (home-page #f)
;;     (synopsis "A simple, correct Python build frontend")
;;     (description
;;      "This package provides a simple, correct Python build frontend.")
;;     (license #f)))

;; (define-public python-poetry
;;   (package
;;     (name "python-poetry")
;;     (version "2.4.1")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "poetry" version))
;;        (sha256
;;         (base32 "1b0cxhplfjpri1420apyl67n8ayrn6kn89ab4h4gkv270fw9k4qq"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-build
;;                              python-cachecontrol
;;                              python-cleo
;;                              python-dulwich
;;                              python-fastjsonschema
;;                              python-findpython
;;                              python-installer
;;                              python-keyring
;;                              python-packaging
;;                              python-pbs-installer
;;                              python-pendulum
;;                              python-pkginfo
;;                              python-platformdirs
;;                              python-poetry-core
;;                              python-pyproject-hooks
;;                              python-requests
;;                              python-requests-toolbelt
;;                              python-shellingham
;;                              python-tomli
;;                              python-tomlkit
;;                              python-trove-classifiers
;;                              python-virtualenv
;;                              python-xattr))
;;     (native-inputs (list python-poetry-core))
;;     (home-page "https://python-poetry.org/")
;;     (synopsis "Python dependency management and packaging made easy.")
;;     (description "Python dependency management and packaging made easy.")
;;     (license #f)))

;; (define-public python-mdfind-wrapper
;;   (package
;;     (name "python-mdfind-wrapper")
;;     (version "0.1.5")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/dmkskn/mdfind-wrapper")
;;              (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "19dyrwhgfk2w6rfis634yzyi35aaganaw8illglkxk6imngbf3m0"))))
;;     (build-system pyproject-build-system)
;;     (home-page "https://github.com/dmkskn/mdfind-wrapper")
;;     (synopsis "A python library that wraps the mdfind.")
;;     (description
;;      "This package provides a python library that wraps the mdfind.")
;;     (license #f)))

;; (define-public python-macos-tags
;;   (package
;;     (name "python-macos-tags")
;;     (version "1.5.1")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "macos-tags" version))
;;        (sha256
;;         (base32 "1rqjhyiqdq46fybfjcjvdavj0nrlrf1j9jladnb765fh0nycai7i"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-mdfind-wrapper python-xattr))
;;     (native-inputs (list python-poetry))
;;     (home-page "https://macos-tags.dmkskn.com")
;;     (synopsis "Use tags to organize files on Mac from Python")
;;     (description "Use tags to organize files on Mac from Python.")
;;     (license license:expat)))



;; (define-public python-docx2txt
;;   (package
;;     (name "python-docx2txt")
;;     (version "0.9")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/ankushshah89/python-docx2txt")
;;              (commit version)))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0bbvqsrjs3jx0cs9az72kshaiblqqmkzv917aj0zwgkr4zjimdin"))))
;;     (build-system pyproject-build-system)
;;     (native-inputs (list python-setuptools))
;;     (home-page "https://github.com/ankushshah89/python-docx2txt")
;;     (synopsis
;;      "A pure python-based utility to extract text and images from docx files.")
;;     (description
;;      "This package provides a pure python-based utility to extract text and images
;; from docx files.")
;;     (license #f)))


;; (define-public python-docopt-ng
;;   (package
;;     (name "python-docopt-ng")
;;     (version "0.9.0")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/jazzband/docopt-ng")
;;              (commit version)))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "1vdh1amh8jkhll0ym1r72q1ddg8ds3pyx37kyw9abg1w3abh6ih8"))))
;;     (build-system pyproject-build-system)
;;     (native-inputs (list python-pdm-backend))
;;     (home-page "https://github.com/jazzband/docopt-ng")
;;     (synopsis
;;      "Jazzband-maintained fork of docopt, the humane command line arguments parser.")
;;     (description
;;      "Jazzband-maintained fork of docopt, the humane command line arguments parser.")
;;     (license license:expat)))

;; (define-public python-organize-tool
;;   (package
;;     (name "python-organize-tool")
;;     (version "3.3.0")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/tfeldmann/organize")
;;              (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0p1rb5050y7wrpb8f2qg8j5nhi89kxrm7ci35nnfmvlgy8bx7vlr"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-arrow
;;                              python-docopt-ng
;;                              python-docx2txt
;;                              python-exifread
;;                              python-jinja2
;;                              python-macos-tags
;;                              python-markupsafe
;;                              python-mkdocs
;;                              python-mkdocs-autorefs
;;                              python-mkdocs-include-markdown-plugin
;;                              python-mkdocstrings
;;                              python-natsort
;;                              python-pdfminer-six
;;                              python-platformdirs
;;                              python-pydantic
;;                              python-pyyaml
;;                              python-rich
;;                              python-send2trash
;;                              python-simplematch))
;;     (native-inputs (list python-poetry-core))
;;     (home-page "https://github.com/tfeldmann/organize")
;;     (synopsis "The file management automation tool")
;;     (description "The file management automation tool.")
;;     (license license:expat)))


(define-public python-xq
  (package
    (name "python-xq")
    (version "0.0.4")
    (source (origin (method url-fetch)
                    (uri (pypi-uri "xq" version))
                    (sha256 (base32 "0xr9v3nn4hhkldx6r2hxkyfddx0j6z2v220fmnl14h2dc5f4smr8"))))
    (build-system python-build-system)
    (propagated-inputs
      `(("python-lxml" ,python-lxml)
        ("python-pygments" ,python-pygments)))
    (arguments '(#:phases
                 (modify-phases %standard-phases
                                (delete 'check))))
    (home-page "https://github.com/jeffbr13/xq")
    (synopsis "Like jq but for XML and XPath.")
    (description "Like jq but for XML and XPath.")
    (license #f)))

(define-public python-pdfminer
  (package
    (name "python-pdfminer")
    (version "20191125")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "pdfminer" version))
        (sha256
          (base32
            "00fwankn96xms8fyjm4f36282qr98pfw2hv3jg4da3ih673hnw4y"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (propagated-inputs
      `(("python-pycryptodome" ,python-pycryptodome)))
    (home-page "http://github.com/euske/pdfminer")
    (synopsis "PDF parser and analyzer")
    (description "PDF parser and analyzer")
    (license license:expat)))

(define-public python-ordereddict
  (package
    (name "python-ordereddict")
    (version "1.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "ordereddict" version))
        (sha256
          (base32
            "07qvy11nvgxpzarrni3wrww3vpc9yafgi2bch4j2vvvc42nb8d8w"))))
    (build-system python-build-system)
    (arguments '(#:tests? #f
                 #:phases
                 (modify-phases %standard-phases
                   (delete 'sanity-check))))
    (home-page "UNKNOWN")
    (synopsis
      "A drop-in substitute for Py2.7's new collections.OrderedDict that works in Python 2.4-2.6.")
    (description
      "A drop-in substitute for Py2.7's new collections.OrderedDict that works in Python 2.4-2.6.")
    (license #f)))

(define-public python-xmlplain
  (package
    (name "python-xmlplain")
    (version "1.6.0")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "xmlplain" version))
        (sha256
          (base32
            "1qyqfpbsl961p30zri6kp8jpdbmp04jk2n04b2qg2kbfnf5gmk59"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (propagated-inputs
                        `(("python-ordereddict" ,python-ordereddict)
                          ("python-pyyaml" ,python-pyyaml)))
    (home-page "https://github.com/guillon/xmlplain")
    (synopsis "XML as plain object module")
    (description "XML as plain object module")
    (license #f)))


(define-public python-i3ipc
  (package
    (name "python-i3ipc")
    (version "2.2.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "i3ipc" version))
        (sha256
          (base32
            "1s6crkdn7q8wmzl5d0pb6rdkhhbvp444yxilrgaylnbr2kbxg078"))))
    (build-system python-build-system)
    (propagated-inputs
     `(("python-six"  ,python-six)
       ("python-xlib" ,python-xlib)))
    (arguments
     '(#:tests? #f))
    (home-page
      "https://github.com/altdesktop/i3ipc-python")
    (synopsis
      "An improved Python library to control i3wm and sway")
    (description
      "An improved Python library to control i3wm and sway")
    (license license:bsd-3)))

(define-public python-rofi
  (package
    (name "python-rofi")
    (version "1.0.1")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "python-rofi" version))
        (sha256
          (base32
            "0qbsg7x7qcqrm2b771z8r6f86v3zkafk49yg35xq1lgwl73vimpj"))))
    (build-system python-build-system)
    (native-inputs (list python-setuptools))
    (arguments
     '(#:tests? #f))
    (home-page
     "https://github.com/bcbnz/python-rofi")
    (synopsis
      "Create simple GUIs using the Rofi application")
    (description
      "Create simple GUIs using the Rofi application")
    (license license:expat)))


;; (define-public python-rofi
;;   (package
;;     (name "python-rofi")
;;     (version "1.0.1")
;;     (source
;;      (origin
;;        (method git-fetch)
;;        (uri (git-reference
;;              (url "https://github.com/bcbnz/python-rofi")
;;              (commit version)))
;;        (file-name (git-file-name name version))
;;        (sha256
;;         (base32 "0l3njiqx1cfq9bddjmngckw53p9i51vx8v33cf3k11cd093rgmjl"))))
;;     (build-system pyproject-build-system)
;;     (native-inputs (list python-setuptools))
;;     (home-page "https://github.com/bcbnz/python-rofi")
;;     (synopsis "Create simple GUIs using the Rofi application")
;;     (description "Create simple GUIs using the Rofi application.")
;;     (license license:expat)))



(define-public python-rofi-menu
  (package
    (name "python-rofi-menu")
    (version "0.2.2")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "rofi-menu" version))
       (sha256
        (base32
         "102iblj3niqv0l9mq5lb0masph9jgjkygf2dg6skldq4a6b7wwdb"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (home-page
     "https://github.com/miphreal/python-rofi-menu")
    (synopsis "Create rofi menus via python")
    (description "Create rofi menus via python")
    (license license:expat)))

(define-public python-rofi-tmux
  (package
    (name "python-rofi-tmux")
    (version "0.3")
    (source
      (origin
        (method url-fetch)
        (uri (pypi-uri "rofi-tmux" version))
        (sha256
          (base32 "19k8dhnzyvdb6maqyb6bx611kf6h8q2n25zjyr59sgnmi7v8y423"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (propagated-inputs
     `(("python-click"   ,python-click)
       ("python-i3ipc"   ,python-i3ipc)
       ("python-libtmux" ,python-libtmux)
       ("python-rofi"    ,python-rofi)))
    (home-page
      "http://github.com/viniarck/rofi-tmux")
    (synopsis
      "Quickly manages tmux sessions, windows and tmuxinator projects on Rofi")
    (description
      "Quickly manages tmux sessions, windows and tmuxinator projects on Rofi")
    (license license:expat)))

;; (define-public python-tinydb
;;   (package
;;    (name "python-tinydb")
;;    (version "4.1.1")
;;    (source
;;     (origin
;;      (method url-fetch)
;;      (uri (pypi-uri "tinydb" version))
;;      (sha256
;;       (base32
;;        "00m2cq2ra58ygdwd3f3sky9m6c01c8yg6sdfqs1dbrigp847738v"))))
;;    (build-system python-build-system)
;;    (home-page "https://github.com/msiemens/tinydb")
;;    (synopsis
;;     "TinyDB is a tiny, document oriented database optimized for your happiness :)")
;;    (description
;;     "TinyDB is a tiny, document oriented database optimized for your happiness :)")
;;    (license license:expat)))


(define-public python-attnmgr
  (package
    (name "python-attnmgr")
    (version "0.5")
    (source (origin (method git-fetch)
                    (uri (git-reference
                          (url "https://github.com/sharad/attnmgr")
                          (commit (string-append "v" version))))
                    (file-name (git-file-name name version))
                    (sha256 (base32 "1pqq7gqj5y76c1fwpx3hswva4j79h3gqqvkpgxni7rw3jix0a7ck"))))
    (arguments
     '(#:tests? #f))
    (build-system python-build-system)
    ;; (build-system pyproject-build-system)
    (inputs  (list python-rofi
                   python-tinydb
                   xprop
                   wmctrl))
    (propagated-inputs (list python-tinydb))
    (home-page "https://github.com/sharad/attnmgr")
    (synopsis "attnmgr")
    (description "attnmgr")
    (license license:gpl3)))

;; https://files.pythonhosted.org/packages/source/c/camelot-py/camelot-py-0.7.3.tar.gz
;; https://files.pythonhosted.org/packages/source/c/camelot-py/camelot_py-0.7.3-py3-none-any.whl
;; https://files.pythonhosted.org/packages/source/c/camelot-py/camelot_py-0.7.3.whl
;; (define-public python-camelot-py
;;   (package
;;     (name "python-camelot-py")
;;     (version "0.7.3")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri
;;         (string-append "https://files.pythonhosted.org/packages/70/d6/a47894242a6fba58a2332489358afedc6209da43942ab7f850b932019101/camelot_py-" version "-py3-none-any.whl"))
;;        (sha256
;;         (base32
;;          "11jd3m11k2vppgvrs6x55c6p2k57jrdxkyzwl6c209s8i74jisj9"))))
;;     (build-system python-build-system)
;;     (home-page "https://pypi.org/project/camelot-py/#files")
;;     (synopsis
;;      "Read Exif metadata from tiff and jpeg files.")
;;     (description
;;      "Read Exif metadata from tiff and jpeg files.")
;;     (license license:bsd-3)))


(define-public python-speechrecognition
  (package
    (name "python-speechrecognition")
    (version "3.10.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "SpeechRecognition" version))
       (sha256
        (base32 "10lzmlmv4c6i3ldszdhvjwqf3a8jrv5cd8mr0q5f4dkqdf4331vi"))))
    (build-system python-build-system)
    ;; (build-system pyproject-build-system)
    (arguments
     '(#:tests? #f
       #:phases
       (modify-phases %standard-phases
         (add-after  'unpack 'compatibility
           (lambda* (#:key inputs outputs #:allow-other-keys)
             (delete-file "speech_recognition/flac-linux-x86")
             (delete-file "speech_recognition/flac-linux-x86_64")
             (delete-file "speech_recognition/flac-mac")
             (delete-file "speech_recognition/flac-win32.exe")
             (substitute* "speech_recognition/audio.py"
               (("os\\.path\\.join.+$")
                (string-append "\"" (assoc-ref inputs "flac") "/bin/flac" "\"\n")))
             #t)))))
    (inputs  (list python-pyaudio
                   flac))
    (propagated-inputs (list python-pyaudio
                             python-requests
                             python-typing-extensions))
    (home-page "https://github.com/Uberi/speech_recognition#readme")
    (synopsis
     "Library for performing speech recognition, with support for several engines and APIs, online and offline.")
    (description
     "Library for performing speech recognition, with support for several engines and
APIs, online and offline.")
    (license license:bsd-3)))

(define-public python-pyttsx3
  (package
   (name "python-pyttsx3")
   (home-page "https://github.com/nateshmbhat/pyttsx3")
   (version "2.90")
   (source (origin (method git-fetch)
                   (uri (git-reference
                         (url home-page)
                         (commit (string-append "v." version))))
                   (file-name (git-file-name name version))
                   (sha256 (base32 "1g0yhf2ph32if0187aj67qvpdpx4gkw8kmmg47c16plg8ihv4r88"))))
   (inputs (list espeak-ng
                 espeak))
   (arguments
    '(#:tests? #f))
   (build-system python-build-system)
   ;; (build-system pyproject-build-system)
   (synopsis "Offline Text To Speech (TTS) converter for Python ")
   (description "pyttsx3 is a text-to-speech conversion library in Python. Unlike alternative libraries, it works offline.")
   (license license:gpl3)))

(define-public python-playsound
  (package
   (name "python-playsound")
   (home-page "https://github.com/TaylorSMarks/playsound")
   (version "1.3.0")
   (source (origin
            (method url-fetch)
            (uri (pypi-uri "playsound" version))
            (sha256 (base32 "1vbw54iv92gvib9yd7552j26pdzla2zv8ssfcbpv0d1hfwfx2vnc"))))
   (inputs (list gst123
                 python-pygobject
                 python-gst
                 python))
   (propagated-inputs (list gst123
                            python-pygobject
                            python-gst))
   (build-system python-build-system)
   (arguments
    '(#:tests? #f
      #:phases
      (modify-phases %standard-phases
                     (add-after  'unpack 'compatibility
                                 (lambda* (#:key inputs outputs #:allow-other-keys)
                                   (substitute* "playsound.py"
                                                (("/usr/bin/python3")
                                                 (string-append "\"" (assoc-ref inputs "python") "/bin/python3" "\"")))
                                   #t)))))
   (synopsis
    "Pure Python, cross platform, single function module with no dependencies for playing sounds.")
   (description
    "Pure Python, cross platform, single function module with no dependencies for
playing sounds.")
   (license license:expat)))



;; (define-public python-google-ai-generativelanguage
;;   (package
;;     (name "python-google-ai-generativelanguage")
;;     (version "0.6.15")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "google_ai_generativelanguage" version))
;;        (sha256
;;         (base32 "1hwy2lg85wqjzv7122rdpwz1i9ff38bjd418s3i5y1ibq729svcg"))))
;;     (build-system pyproject-build-system)
;;     (arguments
;;      `(#:tests? #f
;;        #:phases (modify-phases %standard-phases
;;                                (delete 'check))))
;;     (propagated-inputs (list python-google-api-core python-google-auth
;;                              python-proto-plus python-protobuf))
;;     (native-inputs (list python-setuptools python-wheel))
;;     (home-page
;;      "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-ai-generativelanguage")
;;     (synopsis "Google Ai Generativelanguage API client library")
;;     (description "Google Ai Generativelanguage API client library.")
;;     (license license:asl2.0)))


;; (define-public python-google-ai-generativelanguage7
;;   (package
;;     (name "python-google-ai-generativelanguage")
;;     (version "0.7.0")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "google_ai_generativelanguage" version))
;;        (sha256
;;         (base32 "15s2ppkgzpf377rg5a55vymjnpzas3i17mfbyycjx7lli4qfszr0"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-google-api-core python-google-auth
;;                              python-proto-plus python-protobuf))
;;     (native-inputs (list python-setuptools python-wheel))
;;     (home-page
;;      "https://github.com/googleapis/google-cloud-python/tree/main/packages/google-ai-generativelanguage")
;;     (synopsis "Google Ai Generativelanguage API client library")
;;     (description "Google Ai Generativelanguage API client library.")
;;     (license license:asl2.0)))

;; (define-public python-google-api-python-client
;;   (package
;;     (name "python-google-api-python-client")
;;     (version "2.181.0")
;;     (source
;;      (origin
;;        (method url-fetch)
;;        (uri (pypi-uri "google_api_python_client" version))
;;        (sha256
;;         (base32 "07166bfx3sl81c2ypa5wpw8zznr4jdbb3d4gdwn6m8bll9i0j1np"))))
;;     (build-system pyproject-build-system)
;;     (propagated-inputs (list python-google-api-core python-google-auth
;;                              python-google-auth-httplib2 python-httplib2
;;                              python-uritemplate))
;;     (native-inputs (list python-setuptools python-wheel))
;;     (home-page "https://github.com/googleapis/google-api-python-client/")
;;     (synopsis "Google API Client Library for Python")
;;     (description "Google API Client Library for Python.")
;;     (license license:asl2.0)))

;; (define-public python-google-generativeai
;;   (package
;;     (name "python-google-generativeai")
;;     (version "0.8.5")
;;     (source
;;      (origin
;;        ;; Upstream repo: using GitHub or similar
;;        ;; If there is a tag "v0.8.5", use that; else pick a commit matching that release.
;;        (method git-fetch)
;;        (uri (git-reference
;;               (url "https://github.com/google/generative-ai-python.git")
;;               (commit (string-append "v" version))))
;;        (file-name (git-file-name name version))
;;        (sha256 (base32 "0hzd0xbmjs5cx6yscb6ngvr9r7s8cgpabilflkg1pwrx4wjzkkf1"))))

;;     (build-system pyproject-build-system)
;;     (arguments
;;      '(#:tests? #f))

;;     ;; Runtime / propagated inputs: fill in dependencies based on upstream's pyproject.toml / setup
;;     (propagated-inputs
;;      (list
;;        python-google-ai-generativelanguage
;;        python-requests           ;; for HTTP requests
;;        python-protobuf           ;; if they use protobuf
;;        python-google-auth        ;; for authentication
;;        python-google-api-core))    ;; core google api utilities
;;        ;; etc: add others upstream requires

;;     (native-inputs
;;      (list python-setuptools
;;            python-wheel
;;            python-pip))  ;; possibly needed for building wheels / tests

;;     (home-page "https://github.com/google/generative-ai-python")
;;     (synopsis "Legacy Google Generative AI (Gemini) Python SDK (google.generativeai)")
;;     (description
;;      "python-google-generativeai is Google's legacy Python SDK for the Gemini API. \
;; It provides utilities to call text / content generation, chat, etc, using the google.generativeai API. \
;; Note: this package is deprecated in favor of `google-genai` in many places. Data / model compatibility may vary.")
;;     (license license:asl2.0)))


;; python-google-generativeai



(define-public python-types-docopt
  (package
    (name "python-types-docopt")
    (version "0.6.11.20241107")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "types-docopt" version))
       (sha256
        (base32 "19zpxplvb54ycqaasxv7sz9n6ap51k45rfj0inzbb5a8mh1lvi31"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (native-inputs (list python-setuptools python-wheel))
    (home-page "https://github.com/python/typeshed")
    (synopsis "Typing stubs for docopt")
    (description "Typing stubs for docopt.")
    (license #f)))

(define-public python-pyfzf
  (package
    (name "python-pyfzf")
    (version "0.3.1")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "pyfzf" version))
       (sha256
        (base32 "1lkbnhjf92063gg9snxskcx4n2yj7mck2qgrh8q9rjpyrws2x46x"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f))
    (native-inputs (list python-setuptools python-wheel))
    (home-page "https://github.com/nk412/pyfzf")
    (synopsis "Python wrapper for junegunn's fuzzyfinder (fzf)")
    (description "Python wrapper for junegunn's fuzzyfinder (fzf).")
    (license license:expat)))

(define-public python-catcli
  (package
    (name "python-catcli")
    (version "1.0")
    (source
     (origin
       (method url-fetch)
       (uri (pypi-uri "catcli" version))
       (sha256
        (base32 "1rx524agzqy0q137m23lcsq8fdfkk9fd2vm091bn60z0bklk8f91"))))
    (build-system python-build-system)
    (arguments
     '(#:tests? #f
       #:phases (modify-phases %standard-phases
                  (delete 'sanity-check))))
    (propagated-inputs (list python-anytree
                             python-cmd2
                             python-docopt
                             python-fusepy
                             ;; python-gnureadline
                             python-natsort
                             python-pyfzf
                             python-types-docopt))
    (native-inputs (list python-check-manifest
                         python-coverage
                         python-pytest
                         python-pytest-cov
                         python-setuptools
                         python-wheel))
    (home-page "https://github.com/deadc0de6/catcli")
    (synopsis "The command line catalog tool for your offline data")
    (description "The command line catalog tool for your offline data.")
    (license #f)))


