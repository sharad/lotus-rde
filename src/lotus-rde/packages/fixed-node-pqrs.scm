(define-module (lotus-rde packages fixed-node-pqrs)
  #:use-module (guix download)
  #:use-module (guix gexp)
  ;; #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix build utils)
  #:use-module (guix build-system node)
  #:use-module ((guix licenses)
                #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages python)
  #:use-module (myguix packages)
  #:use-module (myguix packages node-pqrs)
  #:use-module (myguix home services openclaw))





(define-public node-modelcontextprotocol-sdk-1.29.0-fixed
  (package
    (inherit node-modelcontextprotocol-sdk-1.29.0)
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'build)
          (add-after 'patch-dependencies 'patch-overrides
            (lambda* (#:key inputs #:allow-other-keys)
              (let ((qs (string-append (assoc-ref inputs "node-qs")
                                       "/lib/node_modules/qs")))
                (modify-json
                 (lambda (pkg-meta)
                   (assoc-set! pkg-meta "overrides"
                               (assoc-set! (assoc-ref pkg-meta "overrides")
                                           "qs" qs)))))))
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dependencies '("@cfworker/json-schema"
                                                  "@eslint/js"
                                                  "@modelcontextprotocol/conformance"
                                                  "@types/content-type"
                                                  "@types/cors"
                                                  "@types/cross-spawn"
                                                  "@types/eventsource"
                                                  "@types/express"
                                                  "@types/express-serve-static-core"
                                                  "@types/node"
                                                  "@types/supertest"
                                                  "@types/ws"
                                                  "@typescript/native-preview"
                                                  "eslint"
                                                  "eslint-config-prettier"
                                                  "eslint-plugin-n"
                                                  "prettier"
                                                  "supertest"
                                                  "tsx"
                                                  "typescript"
                                                  "typescript-eslint"
                                                  "vitest"
                                                  "ws"))))))))
    (inputs (list node-zod-to-json-schema-3.25.2
                  node-zod-4.4.3
                  node-raw-body-3.0.2
                  node-qs-6.14.1
                  node-pkce-challenge-5.0.1
                  node-json-schema-typed-8.0.2
                  node-jose-6.2.3
                  node-hono-4.12.22
                  node-express-rate-limit-8.5.2
                  node-express-5.2.1
                  node-eventsource-parser-3.0.8
                  node-eventsource-3.0.7
                  node-cross-spawn-7.0.6
                  node-cors-2.8.6
                  node-content-type
                  node-ajv-formats-3.0.1
                  node-ajv-8.20.0
                  node-hono-node-server-1.19.14
                  node-cfworker-json-schema-4.1.1))))

(define-public node-openclaw-proxyline-0.3.3-fixed
  (package
    (inherit node-openclaw-proxyline-0.3.3)
    (inputs
     (list node-undici-8.3.0))
    (arguments
     (list
      #:tests? #f
      #:phases
      #~(modify-phases %standard-phases
          (delete 'build)
          (add-after 'patch-dependencies 'delete-scripts
            (lambda _
              (modify-json
               (lambda (pkg-meta)
                 (filter (lambda (field)
                           (not (equal? (car field) "scripts")))
                         pkg-meta)))))
          (add-after 'patch-dependencies 'delete-dev-dependencies
            (lambda _
              (modify-json (delete-dependencies '("@types/node" "@types/ws"
                                                  "tsx" "typescript"
                                                  "ws"))))))))))

(define-public node-openclaw-fixed
  (package
    (inherit node-openclaw)
    (inputs (list node-grammyjs-transformer-throttler-1.2.1
                  node-earendil-works-pi-coding-agent-0.75.4
                  node-earendil-works-pi-agent-core-0.75.4
                  node-modelcontextprotocol-sdk-1.29.0-fixed
                  node-agentclientprotocol-sdk-0.22.1
                  node-earendil-works-pi-tui-0.75.4
                  node-earendil-works-pi-ai-0.75.4
                  node-mozilla-readability-0.6.0
                  node-openclaw-proxyline-0.3.3-fixed
                  node-openclaw-fs-safe-0.2.7
                  node-tree-sitter-bash-0.25.1
                  node-lydell-node-pty-1.2.0-beta.12
                  node-homebridge-ciao-1.3.8
                  node-grammyjs-runner-2.0.3
                  node-web-tree-sitter-0.26.9
                  node-playwright-core-1.60.0
                  node-clack-prompts-1.4.0
                  node-node-edge-tts-1.2.10
                  node-google-genai-2.5.0
                  node-quickjs-wasi-2.2.0
                  node-markdown-it-14.1.1
                  node-clack-core-1.3.1
                  node-typescript-6.0.3
                  node-tokenjuice-0.7.1
                  node-pdfjs-dist-5.7.284
                  node-ipaddr-js-2.4.0
                  node-file-type-22.0.1
                  node-commander-14.0.3
                  node-web-push-3.6.7
                  node-linkedom-0.18.12
                  node-chokidar-5.0.0
                  node-typebox-1.1.38
                  node-express-5.2.1
                  node-undici-8.3.0
                  node-qrcode-1.5.4
                  node-openai-6.38.0
                  node-kysely-0.29.2
                  node-grammy-1.43.0
                  node-dotenv-17.4.2
                  node-croner-10.0.1
                  node-tslog-4.10.2
                  node-jszip-3.10.1
                  node-json5-2.2.3
                  node-chalk-5.6.2
                  node-yaml-2.9.0
                  node-jiti-2.7.0
                  node-zod-4.4.3
                  node-tar-7.5.15
                  node-fast-uri-3.1.2
                  node-ajv-8.20.0
                  node-ip-address-10.2.0
                  node-node-domexception-1.0.0
                  node-ws-8.20.1))))


