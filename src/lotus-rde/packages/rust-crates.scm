;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2025 Hilton Chain <hako@ultrarare.space>
;;; Copyright © 2026 Daniel Khodabakhsh <d@niel.khodabakh.sh>
;;;
;;; This file is part of GNU Guix.
;;;
;;; GNU Guix is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; GNU Guix is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Guix.  If not, see <http://www.gnu.org/licenses/>.

(define-module (lotus-rde packages rust-crates)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module ((gnu packages rust-sources) #:prefix package:)
  #:export (lookup-cargo-inputs))



(let ((src (resolve-module '(gnu packages rust-crates)))
      (dst (current-module)))
  (module-for-each
   (lambda (sym var)
     (module-define! dst sym (variable-ref var))
     (module-export! dst (list sym)))
   src))


(define rust-adler2-2.0.1
  (crate-source "adler2" "2.0.1"
                "1ymy18s9hs7ya1pjc9864l30wk8p2qfqdi7mhhcc5nfakxbij09j"))

(define rust-ahash-0.8.12
  (crate-source "ahash" "0.8.12"
                "0xbsp9rlm5ki017c0w6ay8kjwinwm8knjncci95mii30rmwz25as"))

(define rust-aho-corasick-1.1.4
  (crate-source "aho-corasick" "1.1.4"
                "00a32wb2h07im3skkikc495jvncf62jl6s96vwc7bhi70h9imlyx"))

(define rust-aligned-0.4.3
  (crate-source "aligned" "0.4.3"
                "1186lhb3gb4x6spzw7ff0zcraa8cr9zqk4ldpm5g1vb2ijc0higf"))

(define rust-aligned-vec-0.6.4
  (crate-source "aligned-vec" "0.6.4"
                "16vnf78hvfix5cwzd5xs5a2g6afmgb4h7n6yfsc36bv0r22072fw"))

(define rust-allocator-api2-0.2.21
  (crate-source "allocator-api2" "0.2.21"
                "08zrzs022xwndihvzdn78yqarv2b9696y67i6h78nla3ww87jgb8"))

(define rust-android-system-properties-0.1.5
  (crate-source "android_system_properties" "0.1.5"
                "04b3wrz12837j7mdczqd95b732gw5q7q66cv4yn4646lvccp57l1"))

(define rust-annotate-snippets-0.11.5
  (crate-source "annotate-snippets" "0.11.5"
                "1i1bmr5vy957l8fvivj9x1xs24np0k56rdgwj0bxqk45b2p8w3ki"))

(define rust-anstyle-1.0.14
  (crate-source "anstyle" "1.0.14"
                "0030szmgj51fxkic1hpakxxgappxzwm6m154a3gfml83lq63l2wl"))

(define rust-anyhow-1.0.104
  (crate-source "anyhow" "1.0.104"
                "0w34jjcm02p5g9kvsjr1dvpw0zs2fi7igi6nr414fkm5gz85w2ik"))

(define rust-arbitrary-1.4.2
  (crate-source "arbitrary" "1.4.2"
                "1wcbi4x7i3lzcrkjda4810nqv03lpmvfhb0a85xrq1mbqjikdl63"))

(define rust-arg-enum-proc-macro-0.3.4
  (crate-source "arg_enum_proc_macro" "0.3.4"
                "1sjdfd5a8j6r99cf0bpqrd6b160x9vz97y5rysycsjda358jms8a"))

(define rust-arrayvec-0.7.8
  (crate-source "arrayvec" "0.7.8"
                "0mmd8lrijbvg1qp4c5zis5dq41a3mjv2rb6bxkyj9kwaw2k6gyyk"))

(define rust-as-slice-0.2.1
  (crate-source "as-slice" "0.2.1"
                "05j52y1ws8kir5zjxnl48ann0if79sb56p9nm76hvma01r7nnssi"))

(define rust-ashpd-0.10.3
  (crate-source "ashpd" "0.10.3"
                "145j9pa0ni1bizy8r6p7s9c11qxlw644f3q3fwh8rlx1w6z60gfy"))

(define rust-async-broadcast-0.7.2
  (crate-source "async-broadcast" "0.7.2"
                "0ckmqcwyqwbl2cijk1y4r0vy60i89gqc86ijrxzz5f2m4yjqfnj3"))

(define rust-async-channel-2.5.0
  (crate-source "async-channel" "2.5.0"
                "1ljq24ig8lgs2555myrrjighycpx2mbjgrm3q7lpa6rdsmnxjklj"))

(define rust-async-executor-1.14.0
  (crate-source "async-executor" "1.14.0"
                "0al1rmxjy7p7r6h50z698q5lwssqs5a2vzmqbazm1z2sv1rgjsy9"))

(define rust-async-fs-2.2.0
  (crate-source "async-fs" "2.2.0"
                "1iclw9970mh4ndb0bd68a6901kqy81rf9yypvf78pvaavy0scd40"))

(define rust-async-io-2.6.0
  (crate-source "async-io" "2.6.0"
                "1z16s18bm4jxlmp6rif38mvn55442yd3wjvdfhvx4hkgxf7qlss5"))

(define rust-async-lock-3.4.2
  (crate-source "async-lock" "3.4.2"
                "04c3xrrdrfrvh9v0ajxrangpy38qi76qq268zslphnxxjqjpy3r9"))

(define rust-async-process-2.5.0
  (crate-source "async-process" "2.5.0"
                "0xfswxmng6835hjlfhv7k0jrfp7czqxpfj6y2s5dsp05q0g94l7w"))

(define rust-async-recursion-1.1.1
  (crate-source "async-recursion" "1.1.1"
                "04ac4zh8qz2xjc79lmfi4jlqj5f92xjvfaqvbzwkizyqd4pl4hrv"))

(define rust-async-signal-0.2.14
  (crate-source "async-signal" "0.2.14"
                "11dlpb15la279r5cazppy18gbk2xzzl60ahzl19m1kr0l2psmdaj"))

(define rust-async-task-4.7.1
  (crate-source "async-task" "4.7.1"
                "1pp3avr4ri2nbh7s6y9ws0397nkx1zymmcr14sq761ljarh3axcb"))

(define rust-async-trait-0.1.91
  (crate-source "async-trait" "0.1.91"
                "1v3cm8mzg66037wm392p1vsdx0lq8bid6y2ivr7z03lpfx0xqdmf"))

(define rust-asyncified-0.6.2
  (crate-source "asyncified" "0.6.2"
                "1bncns9168firr5sdm7cy4q9kj3qqj12saqsg5z8ncz74k2z7g6x"))

(define rust-atomic-waker-1.1.2
  (crate-source "atomic-waker" "1.1.2"
                "1h5av1lw56m0jf0fd3bchxq8a30xv0b4wv8s4zkp4s0i7mfvs18m"))

(define rust-auto-palette-0.6.0
  (crate-source "auto-palette" "0.6.0"
                "06rxp92y934aki9kdz37m91dsk11ql27g90aisrkaij8w8gsv5pn"))

(define rust-autocfg-1.5.1
  (crate-source "autocfg" "1.5.1"
                "0lqasy5i30flcgih1b50kvsk6z32g09r1q4ql7q81pj6228jy0zj"))

(define rust-av-scenechange-0.14.1
  (crate-source "av-scenechange" "0.14.1"
                "1543y7riwcy4mmsgcalxcm3bnb41hvwiqiz774nbj68fq9vischg"))

(define rust-av1-grain-0.2.5
  (crate-source "av1-grain" "0.2.5"
                "1y3p43i5xncbny0pfh8kw09am3l3mgyg82ln65r3f434443xpzcc"))

(define rust-avif-serialize-0.8.9
  (crate-source "avif-serialize" "0.8.9"
                "0f3z55fma6xmdj0a0x15vz91cqisiardrfgbjlwb2q6lyzjqy5z7"))

(define rust-base64-0.22.1
  (crate-source "base64" "0.22.1"
                "1imqzgh7bxcikp5vx3shqvw9j09g9ly0xr0jma0q66i52r7jbcvj"))

(define rust-bindgen-0.72.1
  (crate-source "bindgen" "0.72.1"
                "15bq73y3wd3x3vxh3z3g72hy08zs8rxg1f0i1xsrrd6g16spcdwr"))

(define rust-bit-field-0.10.3
  (crate-source "bit_field" "0.10.3"
                "1ikhbph4ap4w692c33r8bbv6yd2qxm1q3f64845grp1s6b3l0jqy"))

(define rust-bitflags-2.13.1
  (crate-source "bitflags" "2.13.1"
                "1nl76mpykmwmb8rq1l5vw1azdh1wvxdrnsk4sy3rdrzx01nvg25m"))

(define rust-bitstream-io-4.10.0
  (crate-source "bitstream-io" "4.10.0"
                "07zxcy47l51k6vsxphzhgcnqyzl21pprs7212687c64s56z01zvy"))

(define rust-bitvec-1.1.1
  (crate-source "bitvec" "1.1.1"
                "0dqq44v9877q0xbl4g6aaaf3xhh3m1ca7ag0iy4l17ap5k8w7knx"))

(define rust-block-0.1.6
  (crate-source "block" "0.1.6"
                "16k9jgll25pzsq14f244q22cdv0zb4bqacldg3kx6h89d7piz30d"))

(define rust-block-buffer-0.10.4
  (crate-source "block-buffer" "0.10.4"
                "0w9sa2ypmrsqqvc20nhwr75wbb5cjr4kkyhpjm1z1lv2kdicfy1h"))

(define rust-blocking-1.6.2
  (crate-source "blocking" "1.6.2"
                "08bz3f9agqlp3102snkvsll6wc9ag7x5m1xy45ak2rv9pq18sgz8"))

(define rust-bson-3.1.0
  (crate-source "bson" "3.1.0"
                "132iga3bjdfiyibn8jbf5lpghmx0v2bvz5mgf8wkaiag9ilhkwdk"))

(define rust-bufstream-0.1.4
  (crate-source "bufstream" "0.1.4"
                "1j7f52rv73hd1crzrrfb9dr50ccmi3hb1ybd6s5dyg6jmllqkqs0"))

(define rust-built-0.8.1
  (crate-source "built" "0.8.1"
                "1saq332pd6g3svvc9ah8myjpfvgqlzl2ksb1ypp3976kjcfm63jw"))

(define rust-bumpalo-3.20.3
  (crate-source "bumpalo" "3.20.3"
                "0jc6va3nwcqikm7chnpdv1s87my3gs2j7g1sc7g3k91brg3arxbj"))

(define rust-bytemuck-1.25.2
  (crate-source "bytemuck" "1.25.2"
                "15rp2m7j7kq22s76cbjwmrkd5r8lvacnm0mnrj013cnzka22x0wm"))

(define rust-byteorder-1.5.0
  (crate-source "byteorder" "1.5.0"
                "0jzncxyf404mwqdbspihyzpkndfgda450l0893pz5xj685cg5l0z"))

(define rust-byteorder-lite-0.1.0
  (crate-source "byteorder-lite" "0.1.0"
                "15alafmz4b9az56z6x7glcbcb6a8bfgyd109qc3bvx07zx4fj7wg"))

(define rust-bytes-1.12.1
  (crate-source "bytes" "1.12.1"
                "017z19dpg4f942h051m7bpnzcgng042hhcpd7bmg7bjjqd42lrgw"))

(define rust-cairo-rs-0.22.0
  (crate-source "cairo-rs" "0.22.0"
                "15fb1m9vlsni37g9qwqgmag7s69f3bplylm0v567901lg6mdkj2w"))

(define rust-cairo-sys-rs-0.22.0
  (crate-source "cairo-sys-rs" "0.22.0"
                "0m3dnyax3l8nwypc2lzzd41bbfrjxykbd39bw2p5yzq42dbrid7q"))

(define rust-cc-1.4.0
  (crate-source "cc" "1.4.0"
                "1fc26n76n7gr37m2q0xw5l8jpn4sd33hvyppmwhv6v4fcyxq3pas"))

(define rust-cexpr-0.6.0
  (crate-source "cexpr" "0.6.0"
                "0rl77bwhs5p979ih4r0202cn5jrfsrbgrksp40lkfz5vk1x3ib3g"))

(define rust-cfg-aliases-0.2.2
  (crate-source "cfg_aliases" "0.2.2"
                "09rm3dv28gbsal7w6q76lg2nfyn8wp789ska9b8vr1w750xfhygh"))

(define rust-cfg-expr-0.20.8
  (crate-source "cfg-expr" "0.20.8"
                "0z4r6l4936g1c1s27ryvjdy5pjij6sfvs3myk3hji9dgpi13asgv"))

(define rust-cfg-if-1.0.4
  (crate-source "cfg-if" "1.0.4"
                "008q28ajc546z5p2hcwdnckmg0hia7rnx52fni04bwqkzyrghc4k"))

(define rust-chacha20-0.10.1
  (crate-source "chacha20" "0.10.1"
                "108aajbvs3rwl4d0pdvq3p8ydy4pwh0rxy2z265ynwkflrmla96m"))

(define rust-chrono-0.4.45
  (crate-source "chrono" "0.4.45"
                "09rkcgk6is2sdhqs9142zv8xqnj8ryx8m9hknllqwyv9wxi9x9qs"))

(define rust-clang-sys-1.8.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "clang-sys" "1.8.1"
                "1x1r9yqss76z8xwpdanw313ss6fniwc1r7dzb5ycjn0ph53kj0hb"))

(define rust-color-quant-1.1.0
  (crate-source "color_quant" "1.1.0"
                "12q1n427h2bbmmm1mnglr57jaz2dj9apk0plcxw7nwqiai7qjyrx"))

(define rust-colorutils-rs-0.7.6
  (crate-source "colorutils-rs" "0.7.6"
                "1cajfbgh7kzy0a4fvyd3l8jgnyqfbci89bjwvri3clpsaxcc4bvf"))

(define rust-concurrent-queue-2.5.0
  (crate-source "concurrent-queue" "2.5.0"
                "0wrr3mzq2ijdkxwndhf79k952cp4zkz35ray8hvsxl96xrx1k82c"))

(define rust-cookie-factory-0.3.3
  (crate-source "cookie-factory" "0.3.3"
                "18mka6fk3843qq3jw1fdfvzyv05kx7kcmirfbs2vg2kbw9qzm1cq"))

(define rust-core-foundation-0.10.1
  (crate-source "core-foundation" "0.10.1"
                "1xjns6dqf36rni2x9f47b65grxwdm20kwdg9lhmzdrrkwadcv9mj"))

(define rust-core-foundation-0.9.4
  (crate-source "core-foundation" "0.9.4"
                "13zvbbj07yk3b61b8fhwfzhy35535a583irf23vlcg59j7h9bqci"))

(define rust-core-foundation-sys-0.8.7
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "core-foundation-sys" "0.8.7"
                "12w8j73lazxmr1z0h98hf3z623kl8ms7g07jch7n4p8f9nwlhdkp"))

(define rust-cpufeatures-0.2.17
  (crate-source "cpufeatures" "0.2.17"
                "10023dnnaghhdl70xcds12fsx2b966sxbxjq5sxs49mvxqw5ivar"))

(define rust-cpufeatures-0.3.0
  (crate-source "cpufeatures" "0.3.0"
                "00fjhygsqmh4kbxxlb99mcsbspxcai6hjydv4c46pwb67wwl2alb"))

(define rust-crc32fast-1.5.0
  (crate-source "crc32fast" "1.5.0"
                "04d51liy8rbssra92p0qnwjw8i9rm9c4m3bwy19wjamz1k4w30cl"))

(define rust-crossbeam-deque-0.8.7
  (crate-source "crossbeam-deque" "0.8.7"
                "1sqcxia1mmz2fw8ba1v72jjrvbkvg7c6sz9l3sl07sv1gggf10ai"))

(define rust-crossbeam-epoch-0.9.20
  (crate-source "crossbeam-epoch" "0.9.20"
                "0gzg0v8in20iajikalg5i5qgpp0m26r426f0fs8nwk953w218s9d"))

(define rust-crossbeam-utils-0.8.22
  (crate-source "crossbeam-utils" "0.8.22"
                "05vwf7pmjq8c8f3fp5qqdm0z3cnk4p62wi8spf0jms5yjnh3v031"))

(define rust-crunchy-0.2.4
  (crate-source "crunchy" "0.2.4"
                "1mbp5navim2qr3x48lyvadqblcxc1dm0lqr0swrkkwy2qblvw3s6"))

(define rust-crypto-common-0.1.7
  (crate-source "crypto-common" "0.1.7"
                "02nn2rhfy7kvdkdjl457q2z0mklcvj9h662xrq6dzhfialh2kj3q"))

(define rust-deranged-0.5.8
  (crate-source "deranged" "0.5.8"
                "0711df3w16vx80k55ivkwzwswziinj4dz05xci3rvmn15g615n3w"))

(define rust-derivative-2.2.0
  (crate-source "derivative" "2.2.0"
                "02vpb81wisk2zh1d5f44szzxamzinqgq2k8ydrfjj2wwkrgdvhzw"))

(define rust-digest-0.10.7
  (crate-source "digest" "0.10.7"
                "14p2n6ih29x81akj097lvz7wi9b6b9hvls0lwrv7b6xwyy0s5ncy"))

(define rust-dirs-4.0.0
  (crate-source "dirs" "4.0.0"
                "0n8020zl4f0frfnzvgb9agvk4a14i1kjz4daqnxkgslndwmaffna"))

(define rust-dirs-sys-0.3.7
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "dirs-sys" "0.3.7"
                "19md1cnkazham8a6kh22v12d8hh3raqahfk6yb043vrjr68is78v"))

(define rust-displaydoc-0.2.6
  (crate-source "displaydoc" "0.2.6"
                "0kyxwfbdmagd8afzb2pzja7wj8dhah7smxdsgw00iq8pa2jhmiqs"))

(define rust-duplicate-2.0.1
  (crate-source "duplicate" "2.0.1"
                "091cfk8krd3k31pc50qaz2h1xnsi3nhzmazdrbxbyv0p945g34lf"))

(define rust-either-1.17.0
  (crate-source "either" "1.17.0"
                "07dagpwcfdzpkb1n7fxkx0q3nv80rnf81v7gwlz9ljx22mn8yply"))

(define rust-encoding-rs-0.8.35
  (crate-source "encoding_rs" "0.8.35"
                "1wv64xdrr9v37rqqdjsyb8l8wzlcbab80ryxhrszvnj59wy0y0vm"))

(define rust-endi-1.1.1
  (crate-source "endi" "1.1.1"
                "16a0076dx41vgrzzimm9clcym77h732czqjiajanmzvd1i1y5dv6"))

(define rust-enumflags2-0.7.12
  (crate-source "enumflags2" "0.7.12"
                "1vzcskg4dca2jiflsfx1p9yw1fvgzcakcs7cpip0agl51ilgf9qh"))

(define rust-enumflags2-derive-0.7.12
  (crate-source "enumflags2_derive" "0.7.12"
                "09rqffacafl1b83ir55hrah9gza0x7pzjn6lr6jm76fzix6qmiv7"))

(define rust-equator-0.4.2
  (crate-source "equator" "0.4.2"
                "1z760z5r0haxjyakbqxvswrz9mq7c29arrivgq8y1zldhc9v44a7"))

(define rust-equator-macro-0.4.2
  (crate-source "equator-macro" "0.4.2"
                "1cqzx3cqn9rxln3a607xr54wippzff56zs5chqdf3z2bnks3rwj4"))

(define rust-equivalent-1.0.2
  (crate-source "equivalent" "1.0.2"
                "03swzqznragy8n0x31lqc78g2af054jwivp7lkrbrc0khz74lyl7"))

(define rust-errno-0.3.14
  (crate-source "errno" "0.3.14"
                "1szgccmh8vgryqyadg8xd58mnwwicf39zmin3bsn63df2wbbgjir"))

(define rust-erydanos-0.2.18
  (crate-source "erydanos" "0.2.18"
                "1cczx18693ymk7blhfgvrd63lssracnkqfa593kfrsfqgscc9gcc"))

(define rust-event-listener-5.4.1
  (crate-source "event-listener" "5.4.1"
                "1asnp3agbr8shcl001yd935m167ammyi8hnvl0q1ycajryn6cfz1"))

(define rust-event-listener-strategy-0.5.4
  (crate-source "event-listener-strategy" "0.5.4"
                "14rv18av8s7n8yixg38bxp5vg2qs394rl1w052by5npzmbgz7scb"))

(define rust-exr-1.74.2
  (crate-source "exr" "1.74.2"
                "1wxd45pcgcc1zs7dcl39i2c4plp1w2gkzfizxq0mwab4k4nf87vi"))

(define rust-fallible-iterator-0.3.0
  (crate-source "fallible-iterator" "0.3.0"
                "0ja6l56yka5vn4y4pk6hn88z0bpny7a8k1919aqjzp0j1yhy9k1a"))

(define rust-fallible-streaming-iterator-0.1.9
  (crate-source "fallible-streaming-iterator" "0.1.9"
                "0nj6j26p71bjy8h42x6jahx1hn0ng6mc2miwpgwnp8vnwqf4jq3k"))

(define rust-fastrand-2.5.0
  (crate-source "fastrand" "2.5.0"
                "08q2r30y62winysimnlpbvw9kiwn0rmdlidqlmzd6z90mv764z6s"))

(define rust-fax-0.2.7
  (crate-source "fax" "0.2.7"
                "0nmc65jjdym0f7lr4qm2q7awz1p5arm8i19wv1cmsg92cfahgwfa"))

(define rust-fdeflate-0.3.7
  (crate-source "fdeflate" "0.3.7"
                "130ga18vyxbb5idbgi07njymdaavvk6j08yh1dfarm294ssm6s0y"))

(define rust-field-offset-0.3.6
  (crate-source "field-offset" "0.3.6"
                "0zq5sssaa2ckmcmxxbly8qgz3sxpb8g1lwv90sdh1z74qif2gqiq"))

(define rust-find-msvc-tools-0.1.9
  (crate-source "find-msvc-tools" "0.1.9"
                "10nmi0qdskq6l7zwxw5g56xny7hb624iki1c39d907qmfh3vrbjv"))

(define rust-flate2-1.1.9
  (crate-source "flate2" "1.1.9"
                "0g2pb7cxnzcbzrj8bw4v6gpqqp21aycmf6d84rzb6j748qkvlgw4"))

(define rust-float-cmp-0.8.0
  (crate-source "float-cmp" "0.8.0"
                "1i56hnzjn5pmrcm47fwkmfxiihk7wz5vvcgpb0kpfhzkqi57y9p1"))

(define rust-fnv-1.0.7
  (crate-source "fnv" "1.0.7"
                "1hc2mcqha06aibcaza94vbi81j6pr9a1bbxrxjfhc91zin8yr7iz"))

(define rust-foldhash-0.1.5
  (crate-source "foldhash" "0.1.5"
                "1wisr1xlc2bj7hk4rgkcjkz3j2x4dhd1h9lwk7mj8p71qpdgbi6r"))

(define rust-foldhash-0.2.0
  (crate-source "foldhash" "0.2.0"
                "1nvgylb099s11xpfm1kn2wcsql080nqmnhj1l25bp3r2b35j9kkp"))

(define rust-foreign-types-0.3.2
  (crate-source "foreign-types" "0.3.2"
                "1cgk0vyd7r45cj769jym4a6s7vwshvd0z4bqrb92q1fwibmkkwzn"))

(define rust-foreign-types-shared-0.1.1
  (crate-source "foreign-types-shared" "0.1.1"
                "0jxgzd04ra4imjv8jgkmdq59kj8fsz6w4zxsbmlai34h26225c00"))

(define rust-form-urlencoded-1.2.2
  (crate-source "form_urlencoded" "1.2.2"
                "1kqzb2qn608rxl3dws04zahcklpplkd5r1vpabwga5l50d2v4k6b"))

(define rust-funty-2.0.0
  (crate-source "funty" "2.0.0"
                "177w048bm0046qlzvp33ag3ghqkqw4ncpzcm5lq36gxf2lla7mg6"))

(define rust-futures-0.3.33
  (crate-source "futures" "0.3.33"
                "066j5aqz8an05xh4hn5ljdnjn80z3g335v4grx4gaifr57wg3358"))

(define rust-futures-channel-0.3.33
  (crate-source "futures-channel" "0.3.33"
                "1bn5hlhfkl1sgypmiachaqcgwmr6wmjal7dyhfyb1zkazvs90996"))

(define rust-futures-core-0.3.33
  (crate-source "futures-core" "0.3.33"
                "1iqdbvcdlplfr2g43h7xrfkv2sg5p1a26x8acz1xgxl07i3hrm9c"))

(define rust-futures-executor-0.3.33
  (crate-source "futures-executor" "0.3.33"
                "0n3lpkmcfrsnh40i4armn040gnqbpd257hz5qs46zipjr6f8fm37"))

(define rust-futures-io-0.3.33
  (crate-source "futures-io" "0.3.33"
                "0yjx13qdm9b2p4w00ddw85k6yccnnmqrlrrz8yfmi5jg7jmfqxs5"))

(define rust-futures-lite-2.6.1
  (crate-source "futures-lite" "2.6.1"
                "1ba4dg26sc168vf60b1a23dv1d8rcf3v3ykz2psb7q70kxh113pp"))

(define rust-futures-macro-0.3.33
  (crate-source "futures-macro" "0.3.33"
                "02xiyd5y1nk9b805aympj4wq2czgvxnhcml9w9xkc665d3g3qv9d"))

(define rust-futures-sink-0.3.33
  (crate-source "futures-sink" "0.3.33"
                "01z38z344hpryw84b6r0rbwcb669d8pyvl2szg10aqwx96n1hi73"))

(define rust-futures-task-0.3.33
  (crate-source "futures-task" "0.3.33"
                "02f1y1yvjg1cv998zkgl1706pi9y4fyc9045l1hlmyqyhclfscdj"))

(define rust-futures-util-0.3.33
  (crate-source "futures-util" "0.3.33"
                "1anyg40j5www5l22r2jbn1birsafz4q1w9qmcjk4vqzwasi90ym7"))

(define rust-fxhash-0.2.1
  (crate-source "fxhash" "0.2.1"
                "037mb9ichariqi45xm6mz0b11pa92gj38ba0409z3iz239sns6y3"))

(define rust-gdk-pixbuf-0.22.0
  (crate-source "gdk-pixbuf" "0.22.0"
                "0imnx7m6f3agw91hqv1zpci658wj71by8k1pvfr43q5ydlvj1x15"))

(define rust-gdk-pixbuf-sys-0.22.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdk-pixbuf-sys" "0.22.0"
                "1ywipm5pg65rsyfkb62xb2s013n10kpvg4bb9yslhjzwn4vipws8"))

(define rust-gdk4-0.11.4
  (crate-source "gdk4" "0.11.4"
                "0f8f3zvwq6vwqbnhb0ffzl5zl0wbhvqqva9k0svam8nbdrn2l7nq"))

(define rust-gdk4-sys-0.11.4
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdk4-sys" "0.11.4"
                "04wdqzz40653n1i54g5bvp29h587sgsjdl6hqisrj8kxin6n13rx"))

(define rust-generic-array-0.14.7
  (crate-source "generic-array" "0.14.7"
                "16lyyrzrljfq424c3n8kfwkqihlimmsg5nhshbbp48np3yjrqr45"))

(define rust-getrandom-0.2.17
  (crate-source "getrandom" "0.2.17"
                "1l2ac6jfj9xhpjjgmcx6s1x89bbnw9x6j9258yy6xjkzpq0bqapz"))

(define rust-getrandom-0.3.4
  (crate-source "getrandom" "0.3.4"
                "1zbpvpicry9lrbjmkd4msgj3ihff1q92i334chk7pzf46xffz7c9"))

(define rust-getrandom-0.4.3
  (crate-source "getrandom" "0.4.3"
                "16b0202fkdwz3p2cyll82dv24ljbn0wiyy829v4lwbkbflyqh3ih"))

(define rust-gettext-rs-0.7.7
  (crate-source "gettext-rs" "0.7.7"
                "1prb49j0d33kam9ww0pi5bbr95726ks37s0xjs3fw3vz3gf5fn2x"))

(define rust-gettext-sys-0.26.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gettext-sys" "0.26.0"
                "1scfknchxmmdfl3w3ik8bnb9rlq3gl3kwaq34gw0zryp1nmmka2f"))

(define rust-gif-0.14.2
  (crate-source "gif" "0.14.2"
                "0n81js7vlb9bwrjb765sicza3k0vrihjddrgm2mvpbfr272gr37f"))

(define rust-gio-0.22.8
  (crate-source "gio" "0.22.8"
                "1vcxfs28jrhkvck57x3qgl5ckf4p41s5mpiv86wjdhq9k5k1yglb"))

(define rust-gio-sys-0.22.8
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gio-sys" "0.22.8"
                "1mdhnh532ridfi6hv8mar34hwf6ywzjf1c84c68xl5ndlxyxqgrm"))

(define rust-glib-0.22.8
  (crate-source "glib" "0.22.8"
                "0041i04ba9r8sicbvpff7gdg8wr8x2s54khfjqdzr08qplagbg6x"))

(define rust-glib-macros-0.22.6
  (crate-source "glib-macros" "0.22.6"
                "06bgdnz54l50vxkcp8iraab1v1x3v7l5g5s2k0l19iq7jx4j6vah"))

(define rust-glib-sys-0.22.8
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "glib-sys" "0.22.8"
                "0cr2jp2z0g3k9iap56zccbacc9bqxanh8qrchx8nhrwzkx2nf283"))

(define rust-glob-0.3.4
  (crate-source "glob" "0.3.4"
                "02zby4rsidb2ksrnysyrsaap7rk6wpp7vl5chflndafhl5gaisz4"))

(define rust-gobject-sys-0.22.6
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gobject-sys" "0.22.6"
                "0b57dwgs2yp56892kp990bxxhmvsr69c2n8k8v7pjyl8kf2n3a12"))

(define rust-graphene-rs-0.22.8
  (crate-source "graphene-rs" "0.22.8"
                "1zvx1l25phywms3y191jd420nwfs4s4kb4mn7bqw6wc9anf6p1gb"))

(define rust-graphene-sys-0.22.8
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "graphene-sys" "0.22.8"
                "017xd7svbz7a8yzhp4zjl63x6dp06cj8l3ayf39p0dcgx3yzszsw"))

(define rust-gsk4-0.11.4
  (crate-source "gsk4" "0.11.4"
                "1zsj97c8kj337by8wgll8f5mznmim7lzdvy0absvip0lbwfbwrxq"))

(define rust-gsk4-sys-0.11.4
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gsk4-sys" "0.11.4"
                "123hf2kcl44vkll874msafgx090z8cmqgf6g8rk8kvl1wsr7wz2v"))

(define rust-gtk4-0.11.4
  (crate-source "gtk4" "0.11.4"
                "1nbn1dvivwws2x7aw14f1gmpigj6z91ls65qnl3lpxl4ci3a184q"))

(define rust-gtk4-macros-0.11.4
  (crate-source "gtk4-macros" "0.11.4"
                "03nh83f5p3gf4cxv81xrj9lmkia1p1mj094w0gg08sm302a1giss"))

(define rust-gtk4-sys-0.11.4
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gtk4-sys" "0.11.4"
                "00bg3jmwll7qwdmk30b16ja6bzzmfxml9i158jcb3w3ag1agkf42"))

(define rust-h2-0.4.15
  (crate-source "h2" "0.4.15"
                "0mgilh1g8gydcchqi6acs5l6j0gwg5jwpa64sj4b3ncb9v497c3c"))

(define rust-half-2.7.1
  (crate-source "half" "2.7.1"
                "0jyq42xfa6sghc397mx84av7fayd4xfxr4jahsqv90lmjr5xi8kf"))

(define rust-hashbrown-0.15.5
  (crate-source "hashbrown" "0.15.5"
                "189qaczmjxnikm9db748xyhiw04kpmhm9xj9k9hg0sgx7pjwyacj"))

(define rust-hashbrown-0.16.1
  (crate-source "hashbrown" "0.16.1"
                "004i3njw38ji3bzdp9z178ba9x3k0c1pgy8x69pj7yfppv4iq7c4"))

(define rust-hashbrown-0.17.1
  (crate-source "hashbrown" "0.17.1"
                "0jmqz7i4yl6cm7rbn0i2ffkfrmwi6xkmzkaldr2v8bcsx2v0jngd"))

(define rust-hashlink-0.10.0
  (crate-source "hashlink" "0.10.0"
                "1h8lzvnl9qxi3zyagivzz2p1hp6shgddfmccyf6jv7s1cdicz0kk"))

(define rust-heck-0.5.0
  (crate-source "heck" "0.5.0"
                "1sjmpsdl8czyh9ywl3qcsfsq9a307dg4ni2vnlwgnzzqhc4y0113"))

(define rust-hermit-abi-0.5.2
  (crate-source "hermit-abi" "0.5.2"
                "1744vaqkczpwncfy960j2hxrbjl1q01csm84jpd9dajbdr2yy3zw"))

(define rust-hex-0.4.3
  (crate-source "hex" "0.4.3"
                "0w1a4davm1lgzpamwnba907aysmlrnygbqmfis2mqjx5m552a93z"))

(define rust-hsl-0.1.1
  (crate-source "hsl" "0.1.1"
                "0w69w7g522d5qrjkkany3x361i4aj4afp42yhbnqhfvz2vqvfpsp"))

(define rust-http-1.4.2
  (crate-source "http" "1.4.2"
                "09b4p8fiivkg7wm0b59fyrn1jkm7px298ci7zb9igz6n647gaw39"))

(define rust-http-body-1.1.0
  (crate-source "http-body" "1.1.0"
                "0b5wj0rdj8p03k20q8x0jy249amg2db919fnmh7zcrgf2clqyana"))

(define rust-http-body-util-0.1.4
  (crate-source "http-body-util" "0.1.4"
                "1wizkqx9a75x8v5lm7cawpammz8sfvd7cngnkp34wkcfl3b1zx79"))

(define rust-httparse-1.10.1
  (crate-source "httparse" "1.10.1"
                "11ycd554bw2dkgw0q61xsa7a4jn1wb1xbfacmf3dbwsikvkkvgvd"))

(define rust-hyper-1.11.0
  (crate-source "hyper" "1.11.0"
                "0wha96biivgpj0fpf80a2aar5dfbff1lk62i9x9i2bl53wl5686j"))

(define rust-hyper-rustls-0.27.9
  (crate-source "hyper-rustls" "0.27.9"
                "03vfnsm873wsp1dk0q85nxvk7w6syp8c2m5bcdjcyfgg4786ijik"))

(define rust-hyper-tls-0.6.0
  (crate-source "hyper-tls" "0.6.0"
                "1q36x2yps6hhvxq5r7mc8ph9zz6xlb573gx0x3yskb0fi736y83h"))

(define rust-hyper-util-0.1.20
  (crate-source "hyper-util" "0.1.20"
                "186zdc58hmm663csmjvrzgkr6jdh93sfmi3q2pxi57gcaqjpqm4n"))

(define rust-iana-time-zone-0.1.65
  (crate-source "iana-time-zone" "0.1.65"
                "0w64khw5p8s4nzwcf36bwnsmqzf61vpwk9ca1920x82bk6nwj6z3"))

(define rust-iana-time-zone-haiku-0.1.2
  (crate-source "iana-time-zone-haiku" "0.1.2"
                "17r6jmj31chn7xs9698r122mapq85mfnv98bb4pg6spm0si2f67k"))

(define rust-icu-collections-2.2.0
  (crate-source "icu_collections" "2.2.0"
                "070r7xd0pynm0hnc1v2jzlbxka6wf50f81wybf9xg0y82v6x3119"))

(define rust-icu-locale-core-2.2.0
  (crate-source "icu_locale_core" "2.2.0"
                "0a9cmin5w1x3bg941dlmgszn33qgq428k7qiqn5did72ndi9n8cj"))

(define rust-icu-normalizer-2.2.0
  (crate-source "icu_normalizer" "2.2.0"
                "1d7krxr0xpc4x9635k1100a24nh0nrc59n65j6yk6gbfkplmwvn5"))

(define rust-icu-normalizer-data-2.2.0
  (crate-source "icu_normalizer_data" "2.2.0"
                "0f5d5d5fhhr9937m2z6z38fzh6agf14z24kwlr6lyczafypf0fys"))

(define rust-icu-properties-2.2.0
  (crate-source "icu_properties" "2.2.0"
                "1pkh3s837808cbwxvfagwc28cvwrz2d9h5rl02jwrhm51ryvdqxy"))

(define rust-icu-properties-data-2.2.0
  (crate-source "icu_properties_data" "2.2.0"
                "052awny0qwkbcbpd5jg2cd7vl5ry26pq4hz1nfsgf10c3qhbnawf"))

(define rust-icu-provider-2.2.0
  (crate-source "icu_provider" "2.2.0"
                "08dl8pxbwr8zsz4c5vphqb7xw0hykkznwi4rw7bk6pwb3krlr70k"))

(define rust-idna-1.1.0
  (crate-source "idna" "1.1.0"
                "1pp4n7hppm480zcx411dsv9wfibai00wbpgnjj4qj0xa7kr7a21v"))

(define rust-idna-adapter-1.2.2
  (crate-source "idna_adapter" "1.2.2"
                "0557p76l8hj35r9zn1yv7c6x1c0qbrsffmg80n0yy8361ly3fs6b"))

(define rust-image-0.25.10
  (crate-source "image" "0.25.10"
                "0131b9fsd5grxf3lchfs2ci0rg8ga2mh1ygai7k2zh1k8cwq1aw5"))

(define rust-image-webp-0.2.4
  (crate-source "image-webp" "0.2.4"
                "1hz814csyi9283vinzlkix6qpnd6hs3fkw7xl6z2zgm4w7rrypjj"))

(define rust-imgref-1.12.2
  (crate-source "imgref" "1.12.2"
                "1msc8g8x8a9dy3l85ila4sijvnhr1rxrxsbjhqk1bawkm64lc6c9"))

(define rust-indexmap-2.14.0
  (crate-source "indexmap" "2.14.0"
                "1na9z6f0d5pkjr1lgsni470v98gv2r7c41j8w48skr089x2yjrnl"))

(define rust-interpolate-name-0.2.4
  (crate-source "interpolate_name" "0.2.4"
                "0q7s5mrfkx4p56dl8q9zq71y1ysdj4shh6f28qf9gly35l21jj63"))

(define rust-ipnet-2.12.0
  (crate-source "ipnet" "2.12.0"
                "1qpq2y0asyv0jppw7zww9y96fpnpinwap8a0phhqqgyy3znnz3yr"))

(define rust-is-docker-0.2.0
  (crate-source "is-docker" "0.2.0"
                "1cyibrv6817cqcpf391m327ss40xlbik8wxcv5h9pj9byhksx2wj"))

(define rust-is-wsl-0.4.0
  (crate-source "is-wsl" "0.4.0"
                "19bs5pq221d4bknnwiqqkqrnsx2in0fsk8fylxm1747iim4hjdhp"))

(define rust-itertools-0.13.0
  (crate-source "itertools" "0.13.0"
                "11hiy3qzl643zcigknclh446qb9zlg4dpdzfkjaa9q9fqpgyfgj1"))

(define rust-itertools-0.14.0
  (crate-source "itertools" "0.14.0"
                "118j6l1vs2mx65dqhwyssbrxpawa90886m3mzafdvyip41w2q69b"))

(define rust-itoa-1.0.18
  (crate-source "itoa" "1.0.18"
                "10jnd1vpfkb8kj38rlkn2a6k02afvj3qmw054dfpzagrpl6achlg"))

(define rust-jobserver-0.1.35
  (crate-source "jobserver" "0.1.35"
                "1crwgbb0wjph42ni4hqryjxlv4vlr0hyk81g76id9fpa56ysq00w"))

(define rust-js-sys-0.3.103
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.103"
                "00lib0b6hqmw56r2hjp7xrv730qacslirbkdlhvmi39zvgy4pd2k"))

(define rust-lazy-static-1.5.0
  (crate-source "lazy_static" "1.5.0"
                "1zk6dqqni0193xg6iijh7i3i44sryglwgvx20spdvwk3r6sbrlmv"))

(define rust-lebe-0.5.3
  (crate-source "lebe" "0.5.3"
                "1f459clndzzm35nyd15vj5dlasyagfasp7hcgl6lh2b658rs6ybs"))

(define rust-libadwaita-0.9.2
  (crate-source "libadwaita" "0.9.2"
                "1yivylbik000y0ff5k3hjy5mqwghjj6l8yqm3xdlnahqcw791fc5"))

(define rust-libadwaita-sys-0.9.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libadwaita-sys" "0.9.2"
                "1kcw0yc235d1bdzxvsv35f56zv0r9i5bshckm4m8b2dk89vc5lr8"))

(define rust-libblur-0.14.10
  (crate-source "libblur" "0.14.10"
                "1694hr7ansinlk5n83kchx3h23x5svxq0j316g2r8g7rmxaxfiqm"))

(define rust-libc-0.2.189
  (crate-source "libc" "0.2.189"
                "1whjfs375vlng2q6yrbzs73cvp5lm3w1n2gfqajb2vgf7zg3xbry"))

(define rust-libfuzzer-sys-0.4.13
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libfuzzer-sys" "0.4.13"
                "1li9z5q55wi81zzyifm7a4rw1xvcclsnqsqbkbvrk86bl50jzzd9"))

(define rust-libloading-0.8.9
  (crate-source "libloading" "0.8.9"
                "0mfwxwjwi2cf0plxcd685yxzavlslz7xirss3b9cbrzyk4hv1i6p"))

(define rust-libm-0.2.16
  (crate-source "libm" "0.2.16"
                "10brh0a3qjmbzkr5mf5xqi887nhs5y9layvnki89ykz9xb1wxlmn"))

(define rust-libredox-0.1.18
  (crate-source "libredox" "0.1.18"
                "0lj6dqz0pzwm32zqss320bhjryg7vymkxa575pzhc7ig6jg2ahy9"))

(define rust-libsecret-0.9.0
  (crate-source "libsecret" "0.9.0"
                "0d93inf4yf39drr3qhc6m19n19ax3rj3w10lsbvf00xkhhigncdm"))

(define rust-libsecret-sys-0.9.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libsecret-sys" "0.9.0"
                "16l5lbzhkiv6lynm2xbq0bgj4h82zi46vfwwamqp2lc1mc8p8iw0"))

(define rust-libspa-0.10.0
  (crate-source "libspa" "0.10.0"
                "0kkx5wb1s2wwl65ql76n9hyb06xy3f6z3bq40vqyfx6n56zg6299"))

(define rust-libspa-sys-0.10.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libspa-sys" "0.10.0"
                "1nkx02mv2haxwb74vhk82ld1ykc4xjppbkzkhs282m6a9xv55bb9"))

(define rust-libsqlite3-sys-0.35.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libsqlite3-sys" "0.35.0"
                "0gy1m6j1l94fxsirzp4h4rkrksf78rz7jy3px57qd1rcd8m1hg0k"))

(define rust-libwebp-sys-0.9.6
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libwebp-sys" "0.9.6"
                "0cv7hxzh9p66q5c4ay30bvffh0y66abwmr2nliscwrbigkgk1kal"))

(define rust-linux-raw-sys-0.12.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.12.1"
                "0lwasljrqxjjfk9l2j8lyib1babh2qjlnhylqzl01nihw14nk9ij"))

(define rust-litemap-0.8.2
  (crate-source "litemap" "0.8.2"
                "1w7628bc7wwcxc4n4s5kw0610xk06710nh2hn5kwwk2wa91z9nlj"))

(define rust-locale-config-0.3.0
  (crate-source "locale_config" "0.3.0"
                "0d399alr1i7h7yji4vydbdbzd8hp0xaykr7h4rn3yj7l2rdw7lh8"))

(define rust-lock-api-0.4.14
  (crate-source "lock_api" "0.4.14"
                "0rg9mhx7vdpajfxvdjmgmlyrn20ligzqvn8ifmaz7dc79gkrjhr2"))

(define rust-log-0.4.33
  (crate-source "log" "0.4.33"
                "1bd9dmk22pxgnf0h0slba6rz99zb0a0b2mdhpk8p92bp26ycbvhc"))

(define rust-loop9-0.1.5
  (crate-source "loop9" "0.1.5"
                "0qphc1c0cbbx43pwm6isnwzwbg6nsxjh7jah04n1sg5h4p0qgbhg"))

(define rust-lru-0.16.4
  (crate-source "lru" "0.16.4"
                "0fgg35wrpfdrkv9hcabkg92g3sv4867g1rir7ay9lq1zs3ayhrkz"))

(define rust-lucene-query-builder-0.3.0
  (crate-source "lucene_query_builder" "0.3.0"
                "073jx1djvg4aazx8hd5hf7glmvjfd2jjmgp2b6m54y49hk8518h6"))

(define rust-lucene-query-builder-rs-derive-0.3.0
  (crate-source "lucene_query_builder_rs_derive" "0.3.0"
                "1rnk37ywq8dkyh31azra6pl3ba3rli8dxqawghc8rhfv92rbpslp"))

(define rust-malloc-buf-0.0.6
  (crate-source "malloc_buf" "0.0.6"
                "1jqr77j89pwszv51fmnknzvd53i1nkmcr8rjrvcxhm4dx1zr1fv2"))

(define rust-maybe-async-0.2.11
  (crate-source "maybe-async" "0.2.11"
                "036anp4dzz7sjgdq3zfwzf52ggblpbx1sivlvg2ssq5dhjip6s3l"))

(define rust-maybe-rayon-0.1.1
  (crate-source "maybe-rayon" "0.1.1"
                "06cmvhj4n36459g327ng5dnj8d58qs472pv5ahlhm7ynxl6g78cf"))

(define rust-memchr-2.8.3
  (crate-source "memchr" "2.8.3"
                "161xa63ipfanf8v3nb82xd5hqgydv55nzw59wyngqbz6alfaz2yg"))

(define rust-memoffset-0.9.1
  (crate-source "memoffset" "0.9.1"
                "12i17wh9a9plx869g7j4whf62xw68k5zd4k0k5nh6ys5mszid028"))

(define rust-microfft-0.4.0
  (crate-source "microfft" "0.4.0"
                "0dvnq3mwdqia3kccd1b1k0cggbflpxvm30s3acc16mfsfhpgqkxh"))

(define rust-mime-0.3.17
  (crate-source "mime" "0.3.17"
                "16hkibgvb9klh0w0jk5crr5xv90l3wlf77ggymzjmvl1818vnxv8"))

(define rust-minimal-lexical-0.2.1
  (crate-source "minimal-lexical" "0.2.1"
                "16ppc5g84aijpri4jzv14rvcnslvlpphbszc7zzp6vfkddf4qdb8"))

(define rust-miniz-oxide-0.8.9
  (crate-source "miniz_oxide" "0.8.9"
                "05k3pdg8bjjzayq3rf0qhpirq9k37pxnasfn4arbs17phqn6m9qz"))

(define rust-mio-1.2.2
  (crate-source "mio" "1.2.2"
                "09y4b7gc42ymgssshh8sz6gs3y5r8bbigqaw2c4snh6fy5qmrmih"))

(define rust-moxcms-0.8.1
  (crate-source "moxcms" "0.8.1"
                "0jz4fd5f7pdn1rngqc96lxriqjkym1lswdhdbjr037s8p9ac31dv"))

(define rust-mpd-0.1.0.218e1af
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/htkhiem/rust-mpd.git")
          (commit "218e1af6c44e08101b3c99f0df0fe1d10c3702b4")))
    (file-name (git-file-name "rust-mpd" "0.1.0.218e1af"))
    (sha256 (base32 "1z9sslnd06xhw9kyvfn17n48rkn2bis6hxlyihx6b0j5iimciwrc"))))

(define rust-mpris-server-0.8.1
  (crate-source "mpris-server" "0.8.1"
                "1bjh0xk74j3mbz9ib4zk134g5v5f6qzdllda6i7kkbr7fwic52q5"))

(define rust-musicbrainz-rs-0.12.0
  (crate-source "musicbrainz_rs" "0.12.0"
                "1wwx1zg1cjs7dn7c7m8gg8drpvaryyzi6fbqjb6xf3gnw3bkqmlm"))

(define rust-native-tls-0.2.18
  (crate-source "native-tls" "0.2.18"
                "1wmv0g5p6jwyyslyw88w5fv9kc9qvjd1hi2d4sfl4qm19vhh0ma6"))

(define rust-new-debug-unreachable-1.0.6
  (crate-source "new_debug_unreachable" "1.0.6"
                "11phpf1mjxq6khk91yzcbd3ympm78m3ivl7xg6lg2c0lf66fy3k5"))

(define rust-nix-0.29.0
  (crate-source "nix" "0.29.0"
                "0ikvn7s9r2lrfdm3mx1h7nbfjvcc6s9vxdzw7j5xfkd2qdnp9qki"))

(define rust-no-std-io2-0.9.4
  (crate-source "no_std_io2" "0.9.4"
                "00w0ggkaaacbwiv4qw188ih5llmhf53qgp20wk5gdyrldldvv2j1"))

(define rust-nohash-hasher-0.2.0
  (crate-source "nohash-hasher" "0.2.0"
                "0lf4p6k01w4wm7zn4grnihzj8s7zd5qczjmzng7wviwxawih5x9b"))

(define rust-nom-7.1.3
  (crate-source "nom" "7.1.3"
                "0jha9901wxam390jcf5pfa0qqfrgh8li787jx2ip0yk5b8y9hwyj"))

(define rust-nom-8.0.0
  (crate-source "nom" "8.0.0"
                "01cl5xng9d0gxf26h39m0l8lprgpa00fcc75ps1yzgbib1vn35yz"))

(define rust-noop-proc-macro-0.3.0
  (crate-source "noop_proc_macro" "0.3.0"
                "1j2v1c6ric4w9v12h34jghzmngcwmn0hll1ywly4h6lcm4rbnxh6"))

(define rust-num-bigint-0.4.8
  (crate-source "num-bigint" "0.4.8"
                "0ry3xjal8f5xhdinani268ci13h14mf7j4w0y1gflfzhw3knk7n8"))

(define rust-num-complex-0.4.6
  (crate-source "num-complex" "0.4.6"
                "15cla16mnw12xzf5g041nxbjjm9m85hdgadd5dl5d0b30w9qmy3k"))

(define rust-num-conv-0.2.2
  (crate-source "num-conv" "0.2.2"
                "0hg4f9bwmy7cwpxdkm165dmkfc8jhkkayci234jsmi5ssb33j5sj"))

(define rust-num-derive-0.4.2
  (crate-source "num-derive" "0.4.2"
                "00p2am9ma8jgd2v6xpsz621wc7wbn1yqi71g15gc3h67m7qmafgd"))

(define rust-num-integer-0.1.46
  (crate-source "num-integer" "0.1.46"
                "13w5g54a9184cqlbsq80rnxw4jj4s0d8wv75jsq5r2lms8gncsbr"))

(define rust-num-rational-0.4.2
  (crate-source "num-rational" "0.4.2"
                "093qndy02817vpgcqjnj139im3jl7vkq4h68kykdqqh577d18ggq"))

(define rust-num-threads-0.1.7
  (crate-source "num_threads" "0.1.7"
                "1ngajbmhrgyhzrlc4d5ga9ych1vrfcvfsiqz6zv0h2dpr2wrhwsw"))

(define rust-num-traits-0.2.19
  (crate-source "num-traits" "0.2.19"
                "0h984rhdkkqd4ny9cif7y2azl3xdfb7768hb9irhpsch4q3gq787"))

(define rust-objc-0.2.7
  (crate-source "objc" "0.2.7"
                "1cbpf6kz8a244nn1qzl3xyhmp05gsg4n313c9m3567625d3innwi"))

(define rust-objc-foundation-0.1.1
  (crate-source "objc-foundation" "0.1.1"
                "1y9bwb3m5fdq7w7i4bnds067dhm4qxv4m1mbg9y61j9nkrjipp8s"))

(define rust-objc-id-0.1.1
  (crate-source "objc_id" "0.1.1"
                "0fq71hnp2sdblaighjc82yrac3adfmqzhpr11irhvdfp9gdlsbf9"))

(define rust-once-cell-1.21.4
  (crate-source "once_cell" "1.21.4"
                "0l1v676wf71kjg2khch4dphwh1jp3291ffiymr2mvy1kxd5kwz4z"))

(define rust-oneshot-0.1.13
  (crate-source "oneshot" "0.1.13"
                "01x1rp6s5hxx87n2pc5101lxgdrj0gnxj45zss2qb8li4m6cm6r6"))

(define rust-open-5.4.0
  (crate-source "open" "5.4.0"
                "1m8ya7x1yf8lm9j8acwv6nf4vp8fc9c5dx7yfa52pmcmwxcx1cx0"))

(define rust-openssl-0.10.81
  (crate-source "openssl" "0.10.81"
                "0ibsv2ppsjrp62jqyzprhay9vczk1bw9xvdr3h4h7fxsy0kkm0kp"))

(define rust-openssl-macros-0.1.1
  (crate-source "openssl-macros" "0.1.1"
                "173xxvfc63rr5ybwqwylsir0vq6xsj4kxiv4hmg4c3vscdmncj59"))

(define rust-openssl-probe-0.2.1
  (crate-source "openssl-probe" "0.2.1"
                "1gpwpb7smfhkscwvbri8xzbab39wcnby1jgz1s49vf1aqgsdx1vw"))

(define rust-openssl-sys-0.9.117
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "openssl-sys" "0.9.117"
                "159nf6jsqnmsynkh6gjzx088q1ifll7v88sss8qdk363n9mpwzml"))

(define rust-ordered-stream-0.2.0
  (crate-source "ordered-stream" "0.2.0"
                "0l0xxp697q7wiix1gnfn66xsss7fdhfivl2k7bvpjs4i3lgb18ls"))

(define rust-pango-0.22.8
  (crate-source "pango" "0.22.8"
                "0v1ix8skv2c53p17rlixrw1s055sp96k9xa6n07mvbg21n6hv02x"))

(define rust-pango-sys-0.22.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "pango-sys" "0.22.0"
                "1mnm14vf7xcrag51qjfqy400kh3rqs1rgi897vqfs3x91ji13ldv"))

(define rust-parking-2.2.1
  (crate-source "parking" "2.2.1"
                "1fnfgmzkfpjd69v4j9x737b1k8pnn054bvzcn5dm3pkgq595d3gk"))

(define rust-parking-lot-0.12.5
  (crate-source "parking_lot" "0.12.5"
                "06jsqh9aqmc94j2rlm8gpccilqm6bskbd67zf6ypfc0f4m9p91ck"))

(define rust-parking-lot-core-0.9.12
  (crate-source "parking_lot_core" "0.9.12"
                "1hb4rggy70fwa1w9nb0svbyflzdc69h047482v2z3sx2hmcnh896"))

(define rust-paste-1.0.15
  (crate-source "paste" "1.0.15"
                "02pxffpdqkapy292harq6asfjvadgp1s005fip9ljfsn9fvxgh2p"))

(define rust-pastey-0.1.1
  (crate-source "pastey" "0.1.1"
                "1v389jkifv757903flrrps67dvc6q6giwlyx3xi33hcfjmgjxyrm"))

(define rust-percent-encoding-2.3.2
  (crate-source "percent-encoding" "2.3.2"
                "083jv1ai930azvawz2khv7w73xh8mnylk7i578cifndjn5y64kwv"))

(define rust-pin-project-lite-0.2.17
  (crate-source "pin-project-lite" "0.2.17"
                "1kfmwvs271si96zay4mm8887v5khw0c27jc9srw1a75ykvgj54x8"))

(define rust-piper-0.2.5
  (crate-source "piper" "0.2.5"
                "1hd3j94mw5dwc457gs9ssb2r5b9iipywndf5srqx7pj38jd4fdf8"))

(define rust-pipewire-0.10.0
  (crate-source "pipewire" "0.10.0"
                "0f2zd3b4zwrkan90nlaxpmv7j9y43ly2k3ivcg64rmralnlap1c5"))

(define rust-pipewire-sys-0.10.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "pipewire-sys" "0.10.0"
                "1p3af1addl3c4hdr9skr5hvs5dw6ylkkqxr50gk271slbcj9y27j"))

(define rust-pkg-config-0.3.33
  (crate-source "pkg-config" "0.3.33"
                "17jnqmcbxsnwhg9gjf0nh6dj5k0x3hgwi3mb9krjnmfa9v435w8r"))

(define rust-png-0.18.1
  (crate-source "png" "0.18.1"
                "0qca282xp8a6d7mikxrwji3f52mjn4vnqxz2v9iz5adj665rnxk0"))

(define rust-polling-3.11.0
  (crate-source "polling" "3.11.0"
                "0622qfbxi3gb0ly2c99n3xawp878fkrd1sl83hjdhisx11cly3jx"))

(define rust-potential-utf-0.1.5
  (crate-source "potential_utf" "0.1.5"
                "0r0518fr32xbkgzqap509s3r60cr0iancsg9j1jgf37cyz7b20q1"))

(define rust-powerfmt-0.2.0
  (crate-source "powerfmt" "0.2.0"
                "14ckj2xdpkhv3h6l5sdmb9f1d57z8hbfpdldjc2vl5givq2y77j3"))

(define rust-ppv-lite86-0.2.21
  (crate-source "ppv-lite86" "0.2.21"
                "1abxx6qz5qnd43br1dd9b2savpihzjza8gb4fbzdql1gxp2f7sl5"))

(define rust-proc-macro-crate-3.5.0
  (crate-source "proc-macro-crate" "3.5.0"
                "0kv1g1d1zjwxlgcaba2qlshzyy32j03xic8rskqlcr5mnblsfyz6"))

(define rust-proc-macro2-1.0.107
  (crate-source "proc-macro2" "1.0.107"
                "1nb6ly8kp65f724kj73ippc7lvydss24sm2vagk6qpklpg4pwplq"))

(define rust-proc-macro2-diagnostics-0.10.1
  (crate-source "proc-macro2-diagnostics" "0.10.1"
                "1j48ipc80pykvhx6yhndfa774s58ax1h6sm6mlhf09ls76f6l1mg"))

(define rust-profiling-1.0.18
  (crate-source "profiling" "1.0.18"
                "1xdwlvxlgy99nn1dra7arzinkc8lbqljvcwpq70m7g16lda5wn9x"))

(define rust-profiling-procmacros-1.0.18
  (crate-source "profiling-procmacros" "1.0.18"
                "1jxvqff6j1z7ph3qghw2xhv18z7pf6cs6cja6fwscjwsdfis9224"))

(define rust-pulp-0.22.3
  (crate-source "pulp" "0.22.3"
                "0sj9294yb8yr6z7vdlx467cfs4vvcwnygj0p8wpfqhlnk1ds8sh4"))

(define rust-pulp-wasm-simd-flag-0.1.1
  (crate-source "pulp-wasm-simd-flag" "0.1.1"
                "0h67yf9psibw4768lihrcidsdfqiqnhrrrblbaa64fcwggh713qx"))

(define rust-pxfm-0.1.30
  (crate-source "pxfm" "0.1.30"
                "1slrnbxd0nc96sny6x50ss1sm9ci0gig0fp1w8mw0pkgm5prapfm"))

(define rust-qoi-0.4.1
  (crate-source "qoi" "0.4.1"
                "00c0wkb112annn2wl72ixyd78mf56p4lxkhlmsggx65l3v3n8vbz"))

(define rust-quick-error-2.0.1
  (crate-source "quick-error" "2.0.1"
                "18z6r2rcjvvf8cn92xjhm2qc3jpd1ljvcbf12zv0k9p565gmb4x9"))

(define rust-quick-xml-0.41.0
  (crate-source "quick-xml" "0.41.0"
                "1h9y8zry34r3mxfd5vqfj50vvvzvri4kzbx5d657jkqjalg4aq76"))

(define rust-quote-1.0.47
  (crate-source "quote" "1.0.47"
                "00ch0yyzvv6s671ik0kcsbw8nigdaj2g3fr61kcahwx48aqlvgqz"))

(define rust-r-efi-5.3.0
  (crate-source "r-efi" "5.3.0"
                "03sbfm3g7myvzyylff6qaxk4z6fy76yv860yy66jiswc2m6b7kb9"))

(define rust-r-efi-6.0.0
  (crate-source "r-efi" "6.0.0"
                "1gyrl2k5fyzj9k7kchg2n296z5881lg7070msabid09asp3wkp7q"))

(define rust-r2d2-0.8.10
  (crate-source "r2d2" "0.8.10"
                "14qw32y4m564xb1f5ya8ii7dwqyknvk8bsx2r0lljlmn7zxqbpji"))

(define rust-r2d2-sqlite-0.31.0
  (crate-source "r2d2_sqlite" "0.31.0"
                "030v27fk8h6iyjx2ivynl2ya8vcqlm99ydxdlgp9f5w9vj1pwhb3"))

(define rust-radium-0.7.0
  (crate-source "radium" "0.7.0"
                "02cxfi3ky3c4yhyqx9axqwhyaca804ws46nn4gc1imbk94nzycyw"))

(define rust-rand-0.10.2
  (crate-source "rand" "0.10.2"
                "105yqkdzqbgggd3r1yjm9jg0zvibfdsmxylvxxkmblwc0lxgmxf7"))

(define rust-rand-0.8.7
  (crate-source "rand" "0.8.7"
                "06iaf16fr0z8zly7anmn8ky0p80xnx9yv0gdcm30fwn9vqmigxi2"))

(define rust-rand-0.9.5
  (crate-source "rand" "0.9.5"
                "0hbvllk8g28mqjld6hqmckk69w296qpzg95whm3didsyg46ivvxr"))

(define rust-rand-chacha-0.3.1
  (crate-source "rand_chacha" "0.3.1"
                "123x2adin558xbhvqb8w4f6syjsdkmqff8cxwhmjacpsl1ihmhg6"))

(define rust-rand-chacha-0.9.0
  (crate-source "rand_chacha" "0.9.0"
                "1jr5ygix7r60pz0s1cv3ms1f6pd1i9pcdmnxzzhjc3zn3mgjn0nk"))

(define rust-rand-core-0.10.1
  (crate-source "rand_core" "0.10.1"
                "0s9wiacxrr100icl7i41308gcj85nlcclrc5jx1jd6p10dhigf33"))

(define rust-rand-core-0.6.4
  (crate-source "rand_core" "0.6.4"
                "0b4j2v4cb5krak1pv6kakv4sz6xcwbrmy2zckc32hsigbrwy82zc"))

(define rust-rand-core-0.9.5
  (crate-source "rand_core" "0.9.5"
                "0g6qc5r3f0hdmz9b11nripyp9qqrzb0xqk9piip8w8qlvqkcibvn"))

(define rust-rand-distr-0.5.1
  (crate-source "rand_distr" "0.5.1"
                "0qvlzxq4a2rvrf3wq0xq1bfw8iy9zqm6jlmbywqzld6g1paib1ka"))

(define rust-rav1e-0.8.1
  (crate-source "rav1e" "0.8.1"
                "0axk3ji3jmlr81svmsy5zvj8shmhpp8lz5nyghkq752xx1bdvdj3"))

(define rust-ravif-0.13.0
  (crate-source "ravif" "0.13.0"
                "0ifcpczxf6kcsqlky08vbjrvw9yd1m9mfszywxdhy6wpglci08z5"))

(define rust-raw-cpuid-11.6.0
  (crate-source "raw-cpuid" "11.6.0"
                "11j1lmrjqqnc43bxkrz0xai1g9piw3z9aap53qsj8cnpb7fd1329"))

(define rust-rayon-1.12.0
  (crate-source "rayon" "1.12.0"
                "0vcj63xgnk72c30vdrak7dhl53snnaqv9x2faf1d94hzg1kb2fgv"))

(define rust-rayon-core-1.13.0
  (crate-source "rayon-core" "1.13.0"
                "14dbr0sq83a6lf1rfjq5xdpk5r6zgzvmzs5j6110vlv2007qpq92"))

(define rust-reborrow-0.5.5
  (crate-source "reborrow" "0.5.5"
                "0c14ccj3fdf47a1ya21bkxqv7s2hxrcfhaw98aqd6jqg029i2983"))

(define rust-redox-syscall-0.5.18
  (crate-source "redox_syscall" "0.5.18"
                "0b9n38zsxylql36vybw18if68yc9jczxmbyzdwyhb9sifmag4azd"))

(define rust-redox-users-0.4.6
  (crate-source "redox_users" "0.4.6"
                "0hya2cxx6hxmjfxzv9n8rjl5igpychav7zfi1f81pz6i4krry05s"))

(define rust-regex-1.13.1
  (crate-source "regex" "1.13.1"
                "1391a0a4100ik8cp7l577p3ip3haqq03rd9c5vdr7vcfdixj687h"))

(define rust-regex-automata-0.4.16
  (crate-source "regex-automata" "0.4.16"
                "1b8ihxq99g3hr8mr37bvhib4bfn8rlmpmp0wjg2q1j50plvdpkwg"))

(define rust-regex-syntax-0.8.11
  (crate-source "regex-syntax" "0.8.11"
                "1m25h5q2wp976fb9gc3dsc9l99svcvd5cri8lncb51c46ydgzxnn"))

(define rust-reqwest-0.12.28
  (crate-source "reqwest" "0.12.28"
                "0iqidijghgqbzl3bjg5hb4zmigwa4r612bgi0yiq0c90b6jkrpgd"))

(define rust-resolve-path-0.1.0
  (crate-source "resolve-path" "0.1.0"
                "1dbvi31ffhwgiskhd2g6qnwb9236rgm9snz7y6vdm4mind0mw7ij"))

(define rust-rgb-0.8.53
  (crate-source "rgb" "0.8.53"
                "1i0c55whln68zs6f5qqrkbg1mzai0p3qk1mwkwzdgr9i3dw4pcs7"))

(define rust-ring-0.17.14
  (crate-source "ring" "0.17.14"
                "1dw32gv19ccq4hsx3ribhpdzri1vnrlcfqb2vj41xn4l49n9ws54"))

(define rust-ringbuffer-0.15.0
  (crate-source "ringbuffer" "0.15.0"
                "0lzd15aplym0rb037iv1h67gdssnvmqd2xn06ffgy1gjf67kdxix"))

(define rust-rusqlite-0.37.0
  (crate-source "rusqlite" "0.37.0"
                "0gqzwykyfaaddq5rg1jk0940wby6ifarnwp3fcakbq90ggjscp0n"))

(define rust-rustc-hash-2.1.3
  (crate-source "rustc-hash" "2.1.3"
                "0bbla578m87qmf3yr55q49l97gxn7z0ha1dwqlnvwwc58ad7y7kb"))

(define rust-rustc-version-0.4.1
  (crate-source "rustc_version" "0.4.1"
                "14lvdsmr5si5qbqzrajgb6vfn69k0sfygrvfvr2mps26xwi3mjyg"))

(define rust-rustix-1.1.4
  (crate-source "rustix" "1.1.4"
                "14511f9yjqh0ix07xjrjpllah3325774gfwi9zpq72sip5jlbzmn"))

(define rust-rustls-0.23.42
  (crate-source "rustls" "0.23.42"
                "0f619dq1izpl40glcqgfjbqzpmwg8g5iffjx4429sh4v06mzqm1w"))

(define rust-rustls-pki-types-1.15.1
  (crate-source "rustls-pki-types" "1.15.1"
                "15hakk4pcvr5278cazgw9qf2r7gdg09rg5pivbyd3dbyih12aj9g"))

(define rust-rustls-webpki-0.103.13
  (crate-source "rustls-webpki" "0.103.13"
                "0vkm7z9pnxz5qz66p2kmyy2pwx0g4jnsbqk5xzfhs4czcjl2ki31"))

(define rust-rustversion-1.0.23
  (crate-source "rustversion" "1.0.23"
                "07z2a843fs80fawwflj9jwn49k9b0bd0dhhbvy0ar69vaxd72m6g"))

(define rust-ryu-1.0.23
  (crate-source "ryu" "1.0.23"
                "0zs70sg00l2fb9jwrf6cbkdyscjs53anrvai2hf7npyyfi5blx4p"))

(define rust-schannel-0.1.29
  (crate-source "schannel" "0.1.29"
                "0ffrzz5vf2s3gnzvphgb5gg8fqifvryl07qcf7q3x1scj3jbghci"))

(define rust-scheduled-thread-pool-0.2.7
  (crate-source "scheduled-thread-pool" "0.2.7"
                "068s77f9xcpvzl70nsxk8750dzzc6f9pixajhd979815cj0ndg1w"))

(define rust-scopeguard-1.2.0
  (crate-source "scopeguard" "1.2.0"
                "0jcz9sd47zlsgcnm1hdw0664krxwb5gczlif4qngj2aif8vky54l"))

(define rust-security-framework-3.7.0
  (crate-source "security-framework" "3.7.0"
                "07fd0j29j8yczb3hd430vwz784lx9knb5xwbvqna1nbkbivvrx5p"))

(define rust-security-framework-sys-2.17.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "security-framework-sys" "2.17.0"
                "1qr0w0y9iwvmv3hwg653q1igngnc5b74xcf0679cbv23z0fnkqkc"))

(define rust-semver-1.0.28
  (crate-source "semver" "1.0.28"
                "1kaimrpy876bcgi8bfj0qqfxk77zm9iz2zhn1hp9hj685z854y4a"))

(define rust-serde-1.0.229
  (crate-source "serde" "1.0.229"
                "1fp04fq4a79bpm61xz1zy0pbz4kpc7d771zii1k3inmszq55jj21"))

(define rust-serde-bytes-0.11.19
  (crate-source "serde_bytes" "0.11.19"
                "1a1y1v0r9akqyvprxnmpgc0i8wybqqpvgi01mi8qxn3rkrq41m55"))

(define rust-serde-core-1.0.229
  (crate-source "serde_core" "1.0.229"
                "0j1ajiha76h3nmd976il9li6975k121xa7jb39ws8n0yqp4s5p37"))

(define rust-serde-derive-1.0.229
  (crate-source "serde_derive" "1.0.229"
                "0j4k63i7h1bikxwz2c89ig0hrwbnl9mz1czn85xx99x5cc9dg9g7"))

(define rust-serde-json-1.0.151
  (crate-source "serde_json" "1.0.151"
                "051zww7lvpw147vvwss1ng6w587qyrkzg75fvj08q2dfrmgbahf8"))

(define rust-serde-repr-0.1.21
  (crate-source "serde_repr" "0.1.21"
                "01l987ghc17h1y9cf9xbzmcs77575mbrjf4ca2h70g15vqlicfwd"))

(define rust-serde-spanned-1.1.1
  (crate-source "serde_spanned" "1.1.1"
                "09jzk7i6wihn3d8i3wi4j4n98ghi93c3b8m8k64nxq0ijn3vaqk6"))

(define rust-serde-urlencoded-0.7.1
  (crate-source "serde_urlencoded" "0.7.1"
                "1zgklbdaysj3230xivihs30qi5vkhigg323a9m62k8jwf4a1qjfk"))

(define rust-sha1-0.10.7
  (crate-source "sha1" "0.10.7"
                "1f632d529qzz95yrprr632w1fxqkrv6b6jksjc11vnzl049lay59"))

(define rust-shlex-1.3.0
  (crate-source "shlex" "1.3.0"
                "0r1y6bv26c1scpxvhg2cabimrmwgbp4p3wy6syj9n0c4s3q2znhg"))

(define rust-shlex-2.0.1
  (crate-source "shlex" "2.0.1"
                "1fjsll1cd7d2bcpdij9kd6w62rpbc7qqzvydvs021vsmr1cxvypq"))

(define rust-signal-hook-registry-1.4.8
  (crate-source "signal-hook-registry" "1.4.8"
                "06vc7pmnki6lmxar3z31gkyg9cw7py5x9g7px70gy2hil75nkny4"))

(define rust-simd-adler32-0.3.10
  (crate-source "simd-adler32" "0.3.10"
                "1sny4y2qa5mwyxx5x59ln2p02vsdh92004njlslnx98imjc9489s"))

(define rust-simd-helpers-0.1.0
  (crate-source "simd_helpers" "0.1.0"
                "19idqicn9k4vhd04ifh2ff41wvna79zphdf2c81rlmpc7f3hz2cm"))

(define rust-simdutf8-0.1.5
  (crate-source "simdutf8" "0.1.5"
                "0vmpf7xaa0dnaikib5jlx6y4dxd3hxqz6l830qb079g7wcsgxag3"))

(define rust-slab-0.4.12
  (crate-source "slab" "0.4.12"
                "1xcwik6s6zbd3lf51kkrcicdq2j4c1fw0yjdai2apy9467i0sy8c"))

(define rust-smallvec-1.15.2
  (crate-source "smallvec" "1.15.2"
                "143wzbqf6vgapdp2z4qpl0yvlqcn17s8cnk8m28rqly808zsdmlf"))

(define rust-socket2-0.6.5
  (crate-source "socket2" "0.6.5"
                "1m7diygswpvlpvrxd6ap169nxgax014jr8220nqlr3bzyb3y5lf3"))

(define rust-spectrum-analyzer-0.5.2
  (crate-source "spectrum-analyzer" "0.5.2"
                "1233mvm03m57vc5qafr244dh6bga9083hns30zmias59kg7mag2b"))

(define rust-stable-deref-trait-1.2.1
  (crate-source "stable_deref_trait" "1.2.1"
                "15h5h73ppqyhdhx6ywxfj88azmrpml9gl6zp3pwy2malqa6vxqkc"))

(define rust-static-assertions-1.1.0
  (crate-source "static_assertions" "1.1.0"
                "0gsl6xmw10gvn3zs1rv99laj5ig7ylffnh71f9l34js4nr4r7sx2"))

(define rust-strum-0.27.2
  (crate-source "strum" "0.27.2"
                "1ksb9jssw4bg9kmv9nlgp2jqa4vnsa3y4q9zkppvl952q7vdc8xg"))

(define rust-strum-macros-0.27.2
  (crate-source "strum_macros" "0.27.2"
                "19xwikxma0yi70fxkcy1yxcv0ica8gf3jnh5gj936jza8lwcx5bn"))

(define rust-subtle-2.6.1
  (crate-source "subtle" "2.6.1"
                "14ijxaymghbl1p0wql9cib5zlwiina7kall6w7g89csprkgbvhhk"))

(define rust-syn-1.0.109
  (crate-source "syn" "1.0.109"
                "0ds2if4600bd59wsv7jjgfkayfzy3hnazs394kz6zdkmna8l3dkj"))

(define rust-syn-2.0.119
  (crate-source "syn" "2.0.119"
                "15vjy620l91a3q4n4f4gzhnflmdr6pnm38v2m6cpk86i8av32a47"))

(define rust-syn-3.0.3
  (crate-source "syn" "3.0.3"
                "18srnql3cd39j9q6hf1az02p67rlr1rf6njx9zx4vxj9i3jvmsak"))

(define rust-sync-wrapper-1.0.2
  (crate-source "sync_wrapper" "1.0.2"
                "0qvjyasd6w18mjg5xlaq5jgy84jsjfsvmnn12c13gypxbv75dwhb"))

(define rust-synstructure-0.13.2
  (crate-source "synstructure" "0.13.2"
                "1lh9lx3r3jb18f8sbj29am5hm9jymvbwh6jb1izsnnxgvgrp12kj"))

(define rust-system-configuration-0.7.0
  (crate-source "system-configuration" "0.7.0"
                "12rwilylzc625qnxl30h5kf8wj5ka61zjrwpmb034cd0mc6ksgx1"))

(define rust-system-configuration-sys-0.6.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "system-configuration-sys" "0.6.0"
                "1i5sqrmgy58l4704hibjbl36hclddglh73fb3wx95jnmrq81n7cf"))

(define rust-system-deps-7.0.8
  (crate-source "system-deps" "7.0.8"
                "1rwnfw9dm6ck65a7lfjfpn2c91gwj88brz2i09z3fdbknvz3asir"))

(define rust-tap-1.0.1
  (crate-source "tap" "1.0.1"
                "0sc3gl4nldqpvyhqi3bbd0l9k7fngrcl4zs47n314nqqk4bpx4sm"))

(define rust-target-lexicon-0.13.5
  (crate-source "target-lexicon" "0.13.5"
                "1jm6lmf9hsn7ri2d6v9gg6fy24lylhskh6pbxh71f82wdxd97dmd"))

(define rust-temp-dir-0.1.16
  (crate-source "temp-dir" "0.1.16"
                "0r09qwiiqm8pk6inaqmmp0h6zjg9py6m1dkcwqgghv21x5cnf5w3"))

(define rust-tempfile-3.27.0
  (crate-source "tempfile" "3.27.0"
                "1gblhnyfjsbg9wjg194n89wrzah7jy3yzgnyzhp56f3v9jd7wj9j"))

(define rust-thiserror-1.0.69
  (crate-source "thiserror" "1.0.69"
                "0lizjay08agcr5hs9yfzzj6axs53a2rgx070a1dsi3jpkcrzbamn"))

(define rust-thiserror-2.0.19
  (crate-source "thiserror" "2.0.19"
                "1ngwxsjsa64v1n7vb90h2b0i3fqk1piwaf0z6fqdacqfhjc3b909"))

(define rust-thiserror-impl-1.0.69
  (crate-source "thiserror-impl" "1.0.69"
                "1h84fmn2nai41cxbhk6pqf46bxqq1b344v8yz089w1chzi76rvjg"))

(define rust-thiserror-impl-2.0.19
  (crate-source "thiserror-impl" "2.0.19"
                "1ka10pqy1g8zy5al9m8yadg30jp8hx0q80j8awmd8131yw6gxjs3"))

(define rust-tiff-0.11.3
  (crate-source "tiff" "0.11.3"
                "0lmw68ic77sixk17r4rl2vsv00rqhja3yj2h9p5bcd9x6krylgxn"))

(define rust-time-0.3.54
  (crate-source "time" "0.3.54"
                "0i12170vw516jprmbv385krw75nyn7kwfp48nqybgfpnkximw79y"))

(define rust-time-core-0.1.9
  (crate-source "time-core" "0.1.9"
                "028ix0ax7ixp1h1k5zsqwgw85w6y1q32irslma7ci6ddd5kr074y"))

(define rust-time-macros-0.2.32
  (crate-source "time-macros" "0.2.32"
                "11gdd3b81mj8i0h114qfjjzm8j2rz2mhr9byr0ksjbldli196s3y"))

(define rust-tinystr-0.8.3
  (crate-source "tinystr" "0.8.3"
                "0vfr8x285w6zsqhna0a9jyhylwiafb2kc8pj2qaqaahw48236cn8"))

(define rust-tokio-1.53.1
  (crate-source "tokio" "1.53.1"
                "1v8b3b45pkpbibls75yniqbvx5dlks2708141ljni5mnf6lawb10"))

(define rust-tokio-native-tls-0.3.1
  (crate-source "tokio-native-tls" "0.3.1"
                "1wkfg6zn85zckmv4im7mv20ca6b1vmlib5xwz9p7g19wjfmpdbmv"))

(define rust-tokio-rustls-0.26.4
  (crate-source "tokio-rustls" "0.26.4"
                "0qggwknz9w4bbsv1z158hlnpkm97j3w8v31586jipn99byaala8p"))

(define rust-tokio-util-0.7.19
  (crate-source "tokio-util" "0.7.19"
                "0licqrhrawysjrsr0qw3cgzkkjph7090hlcqcm45aazmkg81aj29"))

(define rust-toml-1.1.3+spec-1.1.0
  (crate-source "toml" "1.1.3+spec-1.1.0"
                "0g2c3lqf61ss14ak0lzg5r8fvsx8mnclzldfzk28y74lzb6nxjak"))

(define rust-toml-datetime-1.1.1+spec-1.1.0
  (crate-source "toml_datetime" "1.1.1+spec-1.1.0"
                "1mws2mkkf46l7inn77azhm0vdwxngv9vsbhbl0ah33p2c9gzcr9i"))

(define rust-toml-edit-0.25.13+spec-1.1.0
  (crate-source "toml_edit" "0.25.13+spec-1.1.0"
                "16xgmjdnxssdpj7rjyimsk4fqbv29g8zl7zhdbc6dxrf9mz3cxb9"))

(define rust-toml-parser-1.1.2+spec-1.1.0
  (crate-source "toml_parser" "1.1.2+spec-1.1.0"
                "09kmzc55a0j21whm290wlf5a8b18a0qc87a1s8sncrckc6wfkax2"))

(define rust-toml-writer-1.1.2+spec-1.1.0
  (crate-source "toml_writer" "1.1.2+spec-1.1.0"
                "1lk6pqf9mac3v1x6282n6a66qx5b18c8f4a23bsd0nk658x3amkx"))

(define rust-tower-0.5.3
  (crate-source "tower" "0.5.3"
                "1m5i3a2z1sgs8nnz1hgfq2nr4clpdmizlp1d9qsg358ma5iyzrgb"))

(define rust-tower-http-0.6.11
  (crate-source "tower-http" "0.6.11"
                "0h08wjgs3hwnq11iwwzlmnabn1h4cl0fzd48svaccvqffkiggz2c"))

(define rust-tower-layer-0.3.3
  (crate-source "tower-layer" "0.3.3"
                "03kq92fdzxin51w8iqix06dcfgydyvx7yr6izjq0p626v9n2l70j"))

(define rust-tower-service-0.3.3
  (crate-source "tower-service" "0.3.3"
                "1hzfkvkci33ra94xjx64vv3pp0sq346w06fpkcdwjcid7zhvdycd"))

(define rust-tracing-0.1.44
  (crate-source "tracing" "0.1.44"
                "006ilqkg1lmfdh3xhg3z762izfwmxcvz0w7m4qx2qajbz9i1drv3"))

(define rust-tracing-attributes-0.1.31
  (crate-source "tracing-attributes" "0.1.31"
                "1np8d77shfvz0n7camx2bsf1qw0zg331lra0hxb4cdwnxjjwz43l"))

(define rust-tracing-core-0.1.36
  (crate-source "tracing-core" "0.1.36"
                "16mpbz6p8vd6j7sf925k9k8wzvm9vdfsjbynbmaxxyq6v7wwm5yv"))

(define rust-trait-variant-0.1.3
  (crate-source "trait-variant" "0.1.3"
                "1lyrcbi8xv83dgr45rphpb07j62bh1av9wl3qb2fvxkhm1kli6mi"))

(define rust-try-lock-0.2.5
  (crate-source "try-lock" "0.2.5"
                "0jqijrrvm1pyq34zn1jmy2vihd4jcrjlvsh4alkjahhssjnsn8g4"))

(define rust-typenum-1.20.1
  (crate-source "typenum" "1.20.1"
                "086s9ly0906kw5yw41249fba97w5zfxf03pyfwdkffvcprqfixdn"))

(define rust-uds-windows-1.2.1
  (crate-source "uds_windows" "1.2.1"
                "0vidqwwfgn8wyzvbxiqil787b4wyqjia50zpdbbjqx7n8wlgpxpj"))

(define rust-unicode-ident-1.0.24
  (crate-source "unicode-ident" "1.0.24"
                "0xfs8y1g7syl2iykji8zk5hgfi5jw819f5zsrbaxmlzwsly33r76"))

(define rust-unicode-width-0.2.2
  (crate-source "unicode-width" "0.2.2"
                "0m7jjzlcccw716dy9423xxh0clys8pfpllc5smvfxrzdf66h9b5l"))

(define rust-untrusted-0.9.0
  (crate-source "untrusted" "0.9.0"
                "1ha7ib98vkc538x0z60gfn0fc5whqdd85mb87dvisdcaifi6vjwf"))

(define rust-url-2.5.8
  (crate-source "url" "2.5.8"
                "1v8f7nx3hpr1qh76if0a04sj08k86amsq4h8cvpw6wvk76jahrzz"))

(define rust-urlencoding-2.1.3
  (crate-source "urlencoding" "2.1.3"
                "1nj99jp37k47n0hvaz5fvz7z6jd0sb4ppvfy3nphr1zbnyixpy6s"))

(define rust-utf8-iter-1.0.4
  (crate-source "utf8_iter" "1.0.4"
                "1gmna9flnj8dbyd8ba17zigrp9c4c3zclngf5lnb5yvz1ri41hdn"))

(define rust-uuid-1.24.0
  (crate-source "uuid" "1.24.0"
                "0faj5x0zgri8m3i8dv9qgyhiwqwdyhbl2g351cp3iin4ynk26fdz"))

(define rust-v-frame-0.3.9
  (crate-source "v_frame" "0.3.9"
                "1qkvb4ks33zck931vzqckjn36hkngj6l2cwmvfsnlpc7r0kpfsv6"))

(define rust-vcpkg-0.2.15
  (crate-source "vcpkg" "0.2.15"
                "09i4nf5y8lig6xgj3f7fyrvzd3nlaw4znrihw8psidvv5yk4xkdc"))

(define rust-version-check-0.9.5
  (crate-source "version_check" "0.9.5"
                "0nhhi4i5x89gm911azqbn7avs9mdacw2i3vcz3cnmz3mv4rqz4hb"))

(define rust-version-compare-0.2.1
  (crate-source "version-compare" "0.2.1"
                "03nziqxwnxlizl42cwsx33vi5xd2cf2jnszhh9rzay7g6xl8bhh3"))

(define rust-want-0.3.1
  (crate-source "want" "0.3.1"
                "03hbfrnvqqdchb5kgxyavb9jabwza0dmh2vw5kg0dq8rxl57d9xz"))

(define rust-wasi-0.11.1+wasi-snapshot-preview1
  (crate-source "wasi" "0.11.1+wasi-snapshot-preview1"
                "0jx49r7nbkbhyfrfyhz0bm4817yrnxgd3jiwwwfv0zl439jyrwyc"))

(define rust-wasip2-1.0.4+wasi-0.2.12
  (crate-source "wasip2" "1.0.4+wasi-0.2.12"
                "11wl7lqwq4pbmlmzr6n7bwz0hzy1z6sxc4554bkmrr86w4vznzmn"))

(define rust-wasm-bindgen-0.2.126
  (crate-source "wasm-bindgen" "0.2.126"
                "197rma4qg1kb8l4bl7857pgszzval8s1w740g9myyjh92467q1jb"))

(define rust-wasm-bindgen-futures-0.4.76
  (crate-source "wasm-bindgen-futures" "0.4.76"
                "0799v92cpaprapnmpaflc51sdnz362q2fsjdqnwiq8ij1wsg2bf6"))

(define rust-wasm-bindgen-macro-0.2.126
  (crate-source "wasm-bindgen-macro" "0.2.126"
                "1cda6wl5zyiy7777cfgrix7fhpaqba55l5zpqj4zig7ng7jyaz0n"))

(define rust-wasm-bindgen-macro-support-0.2.126
  (crate-source "wasm-bindgen-macro-support" "0.2.126"
                "03iq412frl2py55skwb3ya08xha0cf6q22zr5kqlwbr675w7r6gk"))

(define rust-wasm-bindgen-shared-0.2.126
  (crate-source "wasm-bindgen-shared" "0.2.126"
                "097a3kbjls447s1lwr41l21x5crrh5vq3h6zsxccz7slrjq4q6yw"))

(define rust-web-sys-0.3.103
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "web-sys" "0.3.103"
                "0hb1zdnrp99p5r5q66jagsddmwha460yv2wklvzrzk0b3jvdq8l6"))

(define rust-webp-0.3.1
  (crate-source "webp" "0.3.1"
                "1qbwyf404ac1x9y39z2qyysb0ppzj1mw90x5ysdsbb7lvrm4awf0"))

(define rust-weezl-0.1.12
  (crate-source "weezl" "0.1.12"
                "122a1dhha6cib5az4ihcqlh60ns2bi6rskdv875p94lbvj6wk2m2"))

(define rust-winapi-0.3.9
  (crate-source "winapi" "0.3.9"
                "06gl025x418lchw1wxj64ycr7gha83m44cjr5sarhynd9xkrm0sw"))

(define rust-winapi-i686-pc-windows-gnu-0.4.0
  (crate-source "winapi-i686-pc-windows-gnu" "0.4.0"
                "1dmpa6mvcvzz16zg6d5vrfy4bxgg541wxrcip7cnshi06v38ffxc"))

(define rust-winapi-x86-64-pc-windows-gnu-0.4.0
  (crate-source "winapi-x86_64-pc-windows-gnu" "0.4.0"
                "0gqq64czqb64kskjryj8isp62m2sgvx25yyj3kpc2myh85w24bki"))

(define rust-windows-aarch64-gnullvm-0.52.6
  (crate-source "windows_aarch64_gnullvm" "0.52.6"
                "1lrcq38cr2arvmz19v32qaggvj8bh1640mdm9c2fr877h0hn591j"))

(define rust-windows-aarch64-msvc-0.52.6
  (crate-source "windows_aarch64_msvc" "0.52.6"
                "0sfl0nysnz32yyfh773hpi49b1q700ah6y7sacmjbqjjn5xjmv09"))

(define rust-windows-core-0.62.2
  (crate-source "windows-core" "0.62.2"
                "1swxpv1a8qvn3bkxv8cn663238h2jccq35ff3nsj61jdsca3ms5q"))

(define rust-windows-i686-gnu-0.52.6
  (crate-source "windows_i686_gnu" "0.52.6"
                "02zspglbykh1jh9pi7gn8g1f97jh1rrccni9ivmrfbl0mgamm6wf"))

(define rust-windows-i686-gnullvm-0.52.6
  (crate-source "windows_i686_gnullvm" "0.52.6"
                "0rpdx1537mw6slcpqa0rm3qixmsb79nbhqy5fsm3q2q9ik9m5vhf"))

(define rust-windows-i686-msvc-0.52.6
  (crate-source "windows_i686_msvc" "0.52.6"
                "0rkcqmp4zzmfvrrrx01260q3xkpzi6fzi2x2pgdcdry50ny4h294"))

(define rust-windows-implement-0.60.2
  (crate-source "windows-implement" "0.60.2"
                "1psxhmklzcf3wjs4b8qb42qb6znvc142cb5pa74rsyxm1822wgh5"))

(define rust-windows-interface-0.59.3
  (crate-source "windows-interface" "0.59.3"
                "0n73cwrn4247d0axrk7gjp08p34x1723483jxjxjdfkh4m56qc9z"))

(define rust-windows-link-0.2.1
  (crate-source "windows-link" "0.2.1"
                "1rag186yfr3xx7piv5rg8b6im2dwcf8zldiflvb22xbzwli5507h"))

(define rust-windows-registry-0.6.1
  (crate-source "windows-registry" "0.6.1"
                "082p7l615qk8a4g8g15yipc5lghga6cgfhm74wm7zknwzgvjnx82"))

(define rust-windows-result-0.4.1
  (crate-source "windows-result" "0.4.1"
                "1d9yhmrmmfqh56zlj751s5wfm9a2aa7az9rd7nn5027nxa4zm0bp"))

(define rust-windows-strings-0.5.1
  (crate-source "windows-strings" "0.5.1"
                "14bhng9jqv4fyl7lqjz3az7vzh8pw0w4am49fsqgcz67d67x0dvq"))

(define rust-windows-sys-0.52.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.52.0"
                "0gd3v4ji88490zgb6b5mq5zgbvwv7zx1ibn8v3x83rwcdbryaar8"))

(define rust-windows-sys-0.59.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.59.0"
                "0fw5672ziw8b3zpmnbp9pdv1famk74f1l9fcbc3zsrzdg56vqf0y"))

(define rust-windows-sys-0.61.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.61.2"
                "1z7k3y9b6b5h52kid57lvmvm05362zv1v8w0gc7xyv5xphlp44xf"))

(define rust-windows-targets-0.52.6
  (crate-source "windows-targets" "0.52.6"
                "0wwrx625nwlfp7k93r2rra568gad1mwd888h1jwnl0vfg5r4ywlv"))

(define rust-windows-x86-64-gnu-0.52.6
  (crate-source "windows_x86_64_gnu" "0.52.6"
                "0y0sifqcb56a56mvn7xjgs8g43p33mfqkd8wj1yhrgxzma05qyhl"))

(define rust-windows-x86-64-gnullvm-0.52.6
  (crate-source "windows_x86_64_gnullvm" "0.52.6"
                "03gda7zjx1qh8k9nnlgb7m3w3s1xkysg55hkd1wjch8pqhyv5m94"))

(define rust-windows-x86-64-msvc-0.52.6
  (crate-source "windows_x86_64_msvc" "0.52.6"
                "1v7rb5cibyzx8vak29pdrk8nx9hycsjs4w0jgms08qk49jl6v7sq"))

(define rust-winnow-1.0.4
  (crate-source "winnow" "1.0.4"
                "10fzxipa7lx16172p3aca9j60hzbqgjki2f95kqksd5qywcp7f93"))

(define rust-wit-bindgen-0.57.1
  (crate-source "wit-bindgen" "0.57.1"
                "0vjk2jb593ri9k1aq4iqs2si9mrw5q46wxnn78im7hm7hx799gqy"))

(define rust-writeable-0.6.3
  (crate-source "writeable" "0.6.3"
                "1i54d13h9bpap2hf13xcry1s4lxh7ap3923g8f3c0grd7c9fbyhz"))

(define rust-wyz-0.5.1
  (crate-source "wyz" "0.5.1"
                "1vdrfy7i2bznnzjdl9vvrzljvs4s3qm8bnlgqwln6a941gy61wq5"))

(define rust-xdg-home-1.3.0
  (crate-source "xdg-home" "1.3.0"
                "1xm122zz0wjc8p8cmchij0j9nw34hwncb39jc7dc0mgvb2rdl77c"))

(define rust-y4m-0.8.0
  (crate-source "y4m" "0.8.0"
                "0j24y2zf60lpxwd7kyg737hqfyqx16y32s0fjyi6fax6w4hlnnks"))

(define rust-yoke-0.8.3
  (crate-source "yoke" "0.8.3"
                "1xgyj6c2lxj2bp891ynmhws87c6z7yyv2li1v0ss9di40hxf57vh"))

(define rust-yoke-derive-0.8.2
  (crate-source "yoke-derive" "0.8.2"
                "13l5y5sz4lqm7rmyakjbh6vwgikxiql51xfff9hq2j485hk4r16y"))

(define rust-zbus-4.4.0
  (crate-source "zbus" "4.4.0"
                "09f7916lp7haxv1y5zgcg99ny15whi6dn3waf1afcafxx8mh35xv"))

(define rust-zbus-5.18.0
  (crate-source "zbus" "5.18.0"
                "12p9swv45ja31c18a65vkd4a9rr1xbm7cyvi73kkjq39vihgn67y"))

(define rust-zbus-macros-4.4.0
  (crate-source "zbus_macros" "4.4.0"
                "0glqn6ddgv4ra734p343a41rrxb0phy1v13dljzhpsc1f10bjz96"))

(define rust-zbus-macros-5.18.0
  (crate-source "zbus_macros" "5.18.0"
                "068ix4mznsnwp3r63c5f0gnqxl0j9qvdyc0s5922ppwjxl5li5py"))

(define rust-zbus-names-3.0.0
  (crate-source "zbus_names" "3.0.0"
                "0v1f0ajwafj47bf11yp0xdgp26r93lslr9nb2v6624h2gppiz6sb"))

(define rust-zbus-names-4.3.4
  (crate-source "zbus_names" "4.3.4"
                "0kk250s3x1fxpz9fvhdr64ydbacpn8ah23hy021yhlzzlfs8igyq"))

(define rust-zerocopy-0.8.55
  (crate-source "zerocopy" "0.8.55"
                "1swncvj53zi9yr08b9ddhfrcmlrmh6ijxzxcr3p6w3qlgg6hb8dm"))

(define rust-zerocopy-derive-0.8.55
  (crate-source "zerocopy-derive" "0.8.55"
                "1sr8w9zc62lxmw7v6n89nxvqlki48b0nyfpyri6dd367f3xpds8g"))

(define rust-zerofrom-0.1.8
  (crate-source "zerofrom" "0.1.8"
                "0wjjdj7gdmd0iq91gzkxl7dlv0nhkk80l4bmdpzh3a1yh48mmh0f"))

(define rust-zerofrom-derive-0.1.7
  (crate-source "zerofrom-derive" "0.1.7"
                "18c4wsnznhdxx6m80piil1lbyszdiwsshgjrybqcm4b6qic22lqi"))

(define rust-zeroize-1.9.0
  (crate-source "zeroize" "1.9.0"
                "0kpnij2v1ig6g2mhc0bnci0lrdfdhiq40afbc0fahajqc9jiag71"))

(define rust-zerotrie-0.2.4
  (crate-source "zerotrie" "0.2.4"
                "1gr0pkcn3qsr6in6iixqyp0vbzwf2j1jzyvh7yl2yydh3p9m548g"))

(define rust-zerovec-0.11.6
  (crate-source "zerovec" "0.11.6"
                "0fdjsy6b31q9i0d73sl7xjd12xadbwi45lkpfgqnmasrqg5i3ych"))

(define rust-zerovec-derive-0.11.3
  (crate-source "zerovec-derive" "0.11.3"
                "0m85qj92mmfvhjra6ziqky5b1p4kcmp5069k7kfadp5hr8jw8pb2"))

(define rust-zmij-1.0.23
  (crate-source "zmij" "1.0.23"
                "06zwri21nnrl34rwinmvbciap8yk1mrl8qfg9pff7lgspc56sri9"))

(define rust-zune-core-0.5.1
  (crate-source "zune-core" "0.5.1"
                "1ya0zdqxlr5v57791j7bvm408ri2cfx81a4v6z85f560yw3hi2nb"))

(define rust-zune-inflate-0.2.54
  (crate-source "zune-inflate" "0.2.54"
                "00kg24jh3zqa3i6rg6yksnb71bch9yi1casqydl00s7nw8pk7avk"))

(define rust-zune-jpeg-0.5.15
  (crate-source "zune-jpeg" "0.5.15"
                "15kjpn6pywxlwb8w5irfd68x31wi3mb4y1da8bqh7havh5drvg17"))

(define rust-zvariant-4.2.0
  (crate-source "zvariant" "4.2.0"
                "1zl1ika7zd9bxkd0bqc78h9bykvk6xc98965iz1p3i51p452k110"))

(define rust-zvariant-5.13.1
  (crate-source "zvariant" "5.13.1"
                "04a9r40d5vd4q6gaww8bynjrnk7mmam4bzvg8mm7h1x9saya1qmy"))

(define rust-zvariant-derive-4.2.0
  (crate-source "zvariant_derive" "4.2.0"
                "0jf408h0s83krxwm7wl62fnssin1kcklmb1bcn83ls6sddabmqkk"))

(define rust-zvariant-derive-5.13.1
  (crate-source "zvariant_derive" "5.13.1"
                "04iywbj0dg5v6iapb6vqiwz3mj67753kzzhbfyb0fy0qd8hhi9rq"))

(define rust-zvariant-utils-2.1.0
  (crate-source "zvariant_utils" "2.1.0"
                "0h43h3jcw8rmjr390rdqnhkb9nn3913pgkvb75am1frxrkvwy6y5"))

(define rust-zvariant-utils-3.5.0
  (crate-source "zvariant_utils" "3.5.0"
                "1iy79yppaqsw0pjb8q7b36vivw7qsc1b4n0jg9090lmlz61r7jwh"))


(define-cargo-inputs lookup-cargo-inputs
                     (euphonica =>
                                (list rust-adler2-2.0.1
                                 rust-ahash-0.8.12
                                 rust-aho-corasick-1.1.4
                                 rust-aligned-0.4.3
                                 rust-aligned-vec-0.6.4
                                 rust-allocator-api2-0.2.21
                                 rust-android-system-properties-0.1.5
                                 rust-annotate-snippets-0.11.5
                                 rust-anstyle-1.0.14
                                 rust-anyhow-1.0.104
                                 rust-arbitrary-1.4.2
                                 rust-arg-enum-proc-macro-0.3.4
                                 rust-arrayvec-0.7.8
                                 rust-as-slice-0.2.1
                                 rust-ashpd-0.10.3
                                 rust-async-broadcast-0.7.2
                                 rust-async-channel-2.5.0
                                 rust-async-executor-1.14.0
                                 rust-async-fs-2.2.0
                                 rust-async-io-2.6.0
                                 rust-async-lock-3.4.2
                                 rust-async-process-2.5.0
                                 rust-async-recursion-1.1.1
                                 rust-async-signal-0.2.14
                                 rust-async-task-4.7.1
                                 rust-async-trait-0.1.91
                                 rust-asyncified-0.6.2
                                 rust-atomic-waker-1.1.2
                                 rust-auto-palette-0.6.0
                                 rust-autocfg-1.5.1
                                 rust-av-scenechange-0.14.1
                                 rust-av1-grain-0.2.5
                                 rust-avif-serialize-0.8.9
                                 rust-base64-0.22.1
                                 rust-bindgen-0.72.1
                                 rust-bit-field-0.10.3
                                 rust-bitflags-2.13.1
                                 rust-bitstream-io-4.10.0
                                 rust-bitvec-1.1.1
                                 rust-block-0.1.6
                                 rust-block-buffer-0.10.4
                                 rust-blocking-1.6.2
                                 rust-bson-3.1.0
                                 rust-bufstream-0.1.4
                                 rust-built-0.8.1
                                 rust-bumpalo-3.20.3
                                 rust-bytemuck-1.25.2
                                 rust-byteorder-1.5.0
                                 rust-byteorder-lite-0.1.0
                                 rust-bytes-1.12.1
                                 rust-cairo-rs-0.22.0
                                 rust-cairo-sys-rs-0.22.0
                                 rust-cc-1.4.0
                                 rust-cexpr-0.6.0
                                 rust-cfg-expr-0.20.8
                                 rust-cfg-if-1.0.4
                                 rust-cfg-aliases-0.2.2
                                 rust-chacha20-0.10.1
                                 rust-chrono-0.4.45
                                 rust-clang-sys-1.8.1
                                 rust-color-quant-1.1.0
                                 rust-colorutils-rs-0.7.6
                                 rust-concurrent-queue-2.5.0
                                 rust-cookie-factory-0.3.3
                                 rust-core-foundation-0.9.4
                                 rust-core-foundation-0.10.1
                                 rust-core-foundation-sys-0.8.7
                                 rust-cpufeatures-0.2.17
                                 rust-cpufeatures-0.3.0
                                 rust-crc32fast-1.5.0
                                 rust-crossbeam-deque-0.8.7
                                 rust-crossbeam-epoch-0.9.20
                                 rust-crossbeam-utils-0.8.22
                                 rust-crunchy-0.2.4
                                 rust-crypto-common-0.1.7
                                 rust-deranged-0.5.8
                                 rust-derivative-2.2.0
                                 rust-digest-0.10.7
                                 rust-dirs-4.0.0
                                 rust-dirs-sys-0.3.7
                                 rust-displaydoc-0.2.6
                                 rust-duplicate-2.0.1
                                 rust-either-1.17.0
                                 rust-encoding-rs-0.8.35
                                 rust-endi-1.1.1
                                 rust-enumflags2-0.7.12
                                 rust-enumflags2-derive-0.7.12
                                 rust-equator-0.4.2
                                 rust-equator-macro-0.4.2
                                 rust-equivalent-1.0.2
                                 rust-errno-0.3.14
                                 rust-erydanos-0.2.18
                                 rust-event-listener-5.4.1
                                 rust-event-listener-strategy-0.5.4
                                 rust-exr-1.74.2
                                 rust-fallible-iterator-0.3.0
                                 rust-fallible-streaming-iterator-0.1.9
                                 rust-fastrand-2.5.0
                                 rust-fax-0.2.7
                                 rust-fdeflate-0.3.7
                                 rust-field-offset-0.3.6
                                 rust-find-msvc-tools-0.1.9
                                 rust-flate2-1.1.9
                                 rust-float-cmp-0.8.0
                                 rust-fnv-1.0.7
                                 rust-foldhash-0.1.5
                                 rust-foldhash-0.2.0
                                 rust-foreign-types-0.3.2
                                 rust-foreign-types-shared-0.1.1
                                 rust-form-urlencoded-1.2.2
                                 rust-funty-2.0.0
                                 rust-futures-0.3.33
                                 rust-futures-channel-0.3.33
                                 rust-futures-core-0.3.33
                                 rust-futures-executor-0.3.33
                                 rust-futures-io-0.3.33
                                 rust-futures-lite-2.6.1
                                 rust-futures-macro-0.3.33
                                 rust-futures-sink-0.3.33
                                 rust-futures-task-0.3.33
                                 rust-futures-util-0.3.33
                                 rust-fxhash-0.2.1
                                 rust-gdk-pixbuf-0.22.0
                                 rust-gdk-pixbuf-sys-0.22.0
                                 rust-gdk4-0.11.4
                                 rust-gdk4-sys-0.11.4
                                 rust-generic-array-0.14.7
                                 rust-getrandom-0.2.17
                                 rust-getrandom-0.3.4
                                 rust-getrandom-0.4.3
                                 rust-gettext-rs-0.7.7
                                 rust-gettext-sys-0.26.0
                                 rust-gif-0.14.2
                                 rust-gio-0.22.8
                                 rust-gio-sys-0.22.8
                                 rust-glib-0.22.8
                                 rust-glib-macros-0.22.6
                                 rust-glib-sys-0.22.8
                                 rust-glob-0.3.4
                                 rust-gobject-sys-0.22.6
                                 rust-graphene-rs-0.22.8
                                 rust-graphene-sys-0.22.8
                                 rust-gsk4-0.11.4
                                 rust-gsk4-sys-0.11.4
                                 rust-gtk4-0.11.4
                                 rust-gtk4-macros-0.11.4
                                 rust-gtk4-sys-0.11.4
                                 rust-h2-0.4.15
                                 rust-half-2.7.1
                                 rust-hashbrown-0.15.5
                                 rust-hashbrown-0.16.1
                                 rust-hashbrown-0.17.1
                                 rust-hashlink-0.10.0
                                 rust-heck-0.5.0
                                 rust-hermit-abi-0.5.2
                                 rust-hex-0.4.3
                                 rust-hsl-0.1.1
                                 rust-http-1.4.2
                                 rust-http-body-1.1.0
                                 rust-http-body-util-0.1.4
                                 rust-httparse-1.10.1
                                 rust-hyper-1.11.0
                                 rust-hyper-rustls-0.27.9
                                 rust-hyper-tls-0.6.0
                                 rust-hyper-util-0.1.20
                                 rust-iana-time-zone-0.1.65
                                 rust-iana-time-zone-haiku-0.1.2
                                 rust-icu-collections-2.2.0
                                 rust-icu-locale-core-2.2.0
                                 rust-icu-normalizer-2.2.0
                                 rust-icu-normalizer-data-2.2.0
                                 rust-icu-properties-2.2.0
                                 rust-icu-properties-data-2.2.0
                                 rust-icu-provider-2.2.0
                                 rust-idna-1.1.0
                                 rust-idna-adapter-1.2.2
                                 rust-image-0.25.10
                                 rust-image-webp-0.2.4
                                 rust-imgref-1.12.2
                                 rust-indexmap-2.14.0
                                 rust-interpolate-name-0.2.4
                                 rust-ipnet-2.12.0
                                 rust-is-docker-0.2.0
                                 rust-is-wsl-0.4.0
                                 rust-itertools-0.13.0
                                 rust-itertools-0.14.0
                                 rust-itoa-1.0.18
                                 rust-jobserver-0.1.35
                                 rust-js-sys-0.3.103
                                 rust-lazy-static-1.5.0
                                 rust-lebe-0.5.3
                                 rust-libadwaita-0.9.2
                                 rust-libadwaita-sys-0.9.2
                                 rust-libblur-0.14.10
                                 rust-libc-0.2.189
                                 rust-libfuzzer-sys-0.4.13
                                 rust-libloading-0.8.9
                                 rust-libm-0.2.16
                                 rust-libredox-0.1.18
                                 rust-libsecret-0.9.0
                                 rust-libsecret-sys-0.9.0
                                 rust-libspa-0.10.0
                                 rust-libspa-sys-0.10.0
                                 rust-libsqlite3-sys-0.35.0
                                 rust-libwebp-sys-0.9.6
                                 rust-linux-raw-sys-0.12.1
                                 rust-litemap-0.8.2
                                 rust-locale-config-0.3.0
                                 rust-lock-api-0.4.14
                                 rust-log-0.4.33
                                 rust-loop9-0.1.5
                                 rust-lru-0.16.4
                                 rust-lucene-query-builder-0.3.0
                                 rust-lucene-query-builder-rs-derive-0.3.0
                                 rust-malloc-buf-0.0.6
                                 rust-maybe-async-0.2.11
                                 rust-maybe-rayon-0.1.1
                                 rust-memchr-2.8.3
                                 rust-memoffset-0.9.1
                                 rust-microfft-0.4.0
                                 rust-mime-0.3.17
                                 rust-minimal-lexical-0.2.1
                                 rust-miniz-oxide-0.8.9
                                 rust-mio-1.2.2
                                 rust-moxcms-0.8.1
                                 rust-mpd-0.1.0.218e1af
                                 rust-mpris-server-0.8.1
                                 rust-musicbrainz-rs-0.12.0
                                 rust-native-tls-0.2.18
                                 rust-new-debug-unreachable-1.0.6
                                 rust-nix-0.29.0
                                 rust-no-std-io2-0.9.4
                                 rust-nohash-hasher-0.2.0
                                 rust-nom-7.1.3
                                 rust-nom-8.0.0
                                 rust-noop-proc-macro-0.3.0
                                 rust-num-bigint-0.4.8
                                 rust-num-complex-0.4.6
                                 rust-num-conv-0.2.2
                                 rust-num-derive-0.4.2
                                 rust-num-integer-0.1.46
                                 rust-num-rational-0.4.2
                                 rust-num-traits-0.2.19
                                 rust-num-threads-0.1.7
                                 rust-objc-0.2.7
                                 rust-objc-foundation-0.1.1
                                 rust-objc-id-0.1.1
                                 rust-once-cell-1.21.4
                                 rust-oneshot-0.1.13
                                 rust-open-5.4.0
                                 rust-openssl-0.10.81
                                 rust-openssl-macros-0.1.1
                                 rust-openssl-probe-0.2.1
                                 rust-openssl-sys-0.9.117
                                 rust-ordered-stream-0.2.0
                                 rust-pango-0.22.8
                                 rust-pango-sys-0.22.0
                                 rust-parking-2.2.1
                                 rust-parking-lot-0.12.5
                                 rust-parking-lot-core-0.9.12
                                 rust-paste-1.0.15
                                 rust-pastey-0.1.1
                                 rust-percent-encoding-2.3.2
                                 rust-pin-project-lite-0.2.17
                                 rust-piper-0.2.5
                                 rust-pipewire-0.10.0
                                 rust-pipewire-sys-0.10.0
                                 rust-pkg-config-0.3.33
                                 rust-png-0.18.1
                                 rust-polling-3.11.0
                                 rust-potential-utf-0.1.5
                                 rust-powerfmt-0.2.0
                                 rust-ppv-lite86-0.2.21
                                 rust-proc-macro-crate-3.5.0
                                 rust-proc-macro2-1.0.107
                                 rust-proc-macro2-diagnostics-0.10.1
                                 rust-profiling-1.0.18
                                 rust-profiling-procmacros-1.0.18
                                 rust-pulp-0.22.3
                                 rust-pulp-wasm-simd-flag-0.1.1
                                 rust-pxfm-0.1.30
                                 rust-qoi-0.4.1
                                 rust-quick-error-2.0.1
                                 rust-quick-xml-0.41.0
                                 rust-quote-1.0.47
                                 rust-r-efi-5.3.0
                                 rust-r-efi-6.0.0
                                 rust-r2d2-0.8.10
                                 rust-r2d2-sqlite-0.31.0
                                 rust-radium-0.7.0
                                 rust-rand-0.8.7
                                 rust-rand-0.9.5
                                 rust-rand-0.10.2
                                 rust-rand-chacha-0.3.1
                                 rust-rand-chacha-0.9.0
                                 rust-rand-core-0.6.4
                                 rust-rand-core-0.9.5
                                 rust-rand-core-0.10.1
                                 rust-rand-distr-0.5.1
                                 rust-rav1e-0.8.1
                                 rust-ravif-0.13.0
                                 rust-raw-cpuid-11.6.0
                                 rust-rayon-1.12.0
                                 rust-rayon-core-1.13.0
                                 rust-reborrow-0.5.5
                                 rust-redox-syscall-0.5.18
                                 rust-redox-users-0.4.6
                                 rust-regex-1.13.1
                                 rust-regex-automata-0.4.16
                                 rust-regex-syntax-0.8.11
                                 rust-reqwest-0.12.28
                                 rust-resolve-path-0.1.0
                                 rust-rgb-0.8.53
                                 rust-ring-0.17.14
                                 rust-ringbuffer-0.15.0
                                 rust-rusqlite-0.37.0
                                 rust-rustc-hash-2.1.3
                                 rust-rustc-version-0.4.1
                                 rust-rustix-1.1.4
                                 rust-rustls-0.23.42
                                 rust-rustls-pki-types-1.15.1
                                 rust-rustls-webpki-0.103.13
                                 rust-rustversion-1.0.23
                                 rust-ryu-1.0.23
                                 rust-schannel-0.1.29
                                 rust-scheduled-thread-pool-0.2.7
                                 rust-scopeguard-1.2.0
                                 rust-security-framework-3.7.0
                                 rust-security-framework-sys-2.17.0
                                 rust-semver-1.0.28
                                 rust-serde-1.0.229
                                 rust-serde-bytes-0.11.19
                                 rust-serde-core-1.0.229
                                 rust-serde-derive-1.0.229
                                 rust-serde-json-1.0.151
                                 rust-serde-repr-0.1.21
                                 rust-serde-spanned-1.1.1
                                 rust-serde-urlencoded-0.7.1
                                 rust-sha1-0.10.7
                                 rust-shlex-1.3.0
                                 rust-shlex-2.0.1
                                 rust-signal-hook-registry-1.4.8
                                 rust-simd-adler32-0.3.10
                                 rust-simd-helpers-0.1.0
                                 rust-simdutf8-0.1.5
                                 rust-slab-0.4.12
                                 rust-smallvec-1.15.2
                                 rust-socket2-0.6.5
                                 rust-spectrum-analyzer-0.5.2
                                 rust-stable-deref-trait-1.2.1
                                 rust-static-assertions-1.1.0
                                 rust-strum-0.27.2
                                 rust-strum-macros-0.27.2
                                 rust-subtle-2.6.1
                                 rust-syn-1.0.109
                                 rust-syn-2.0.119
                                 rust-syn-3.0.3
                                 rust-sync-wrapper-1.0.2
                                 rust-synstructure-0.13.2
                                 rust-system-configuration-0.7.0
                                 rust-system-configuration-sys-0.6.0
                                 rust-system-deps-7.0.8
                                 rust-tap-1.0.1
                                 rust-target-lexicon-0.13.5
                                 rust-temp-dir-0.1.16
                                 rust-tempfile-3.27.0
                                 rust-thiserror-1.0.69
                                 rust-thiserror-2.0.19
                                 rust-thiserror-impl-1.0.69
                                 rust-thiserror-impl-2.0.19
                                 rust-tiff-0.11.3
                                 rust-time-0.3.54
                                 rust-time-core-0.1.9
                                 rust-time-macros-0.2.32
                                 rust-tinystr-0.8.3
                                 rust-tokio-1.53.1
                                 rust-tokio-native-tls-0.3.1
                                 rust-tokio-rustls-0.26.4
                                 rust-tokio-util-0.7.19
                                 rust-toml-1.1.3+spec-1.1.0
                                 rust-toml-datetime-1.1.1+spec-1.1.0
                                 rust-toml-edit-0.25.13+spec-1.1.0
                                 rust-toml-parser-1.1.2+spec-1.1.0
                                 rust-toml-writer-1.1.2+spec-1.1.0
                                 rust-tower-0.5.3
                                 rust-tower-http-0.6.11
                                 rust-tower-layer-0.3.3
                                 rust-tower-service-0.3.3
                                 rust-tracing-0.1.44
                                 rust-tracing-attributes-0.1.31
                                 rust-tracing-core-0.1.36
                                 rust-trait-variant-0.1.3
                                 rust-try-lock-0.2.5
                                 rust-typenum-1.20.1
                                 rust-uds-windows-1.2.1
                                 rust-unicode-ident-1.0.24
                                 rust-unicode-width-0.2.2
                                 rust-untrusted-0.9.0
                                 rust-url-2.5.8
                                 rust-urlencoding-2.1.3
                                 rust-utf8-iter-1.0.4
                                 rust-uuid-1.24.0
                                 rust-v-frame-0.3.9
                                 rust-vcpkg-0.2.15
                                 rust-version-compare-0.2.1
                                 rust-version-check-0.9.5
                                 rust-want-0.3.1
                                 rust-wasi-0.11.1+wasi-snapshot-preview1
                                 rust-wasip2-1.0.4+wasi-0.2.12
                                 rust-wasm-bindgen-0.2.126
                                 rust-wasm-bindgen-futures-0.4.76
                                 rust-wasm-bindgen-macro-0.2.126
                                 rust-wasm-bindgen-macro-support-0.2.126
                                 rust-wasm-bindgen-shared-0.2.126
                                 rust-web-sys-0.3.103
                                 rust-webp-0.3.1
                                 rust-weezl-0.1.12
                                 rust-winapi-0.3.9
                                 rust-winapi-i686-pc-windows-gnu-0.4.0
                                 rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                 rust-windows-core-0.62.2
                                 rust-windows-implement-0.60.2
                                 rust-windows-interface-0.59.3
                                 rust-windows-link-0.2.1
                                 rust-windows-registry-0.6.1
                                 rust-windows-result-0.4.1
                                 rust-windows-strings-0.5.1
                                 rust-windows-sys-0.52.0
                                 rust-windows-sys-0.59.0
                                 rust-windows-sys-0.61.2
                                 rust-windows-targets-0.52.6
                                 rust-windows-aarch64-gnullvm-0.52.6
                                 rust-windows-aarch64-msvc-0.52.6
                                 rust-windows-i686-gnu-0.52.6
                                 rust-windows-i686-gnullvm-0.52.6
                                 rust-windows-i686-msvc-0.52.6
                                 rust-windows-x86-64-gnu-0.52.6
                                 rust-windows-x86-64-gnullvm-0.52.6
                                 rust-windows-x86-64-msvc-0.52.6
                                 rust-winnow-1.0.4
                                 rust-wit-bindgen-0.57.1
                                 rust-writeable-0.6.3
                                 rust-wyz-0.5.1
                                 rust-xdg-home-1.3.0
                                 rust-y4m-0.8.0
                                 rust-yoke-0.8.3
                                 rust-yoke-derive-0.8.2
                                 rust-zbus-4.4.0
                                 rust-zbus-5.18.0
                                 rust-zbus-macros-4.4.0
                                 rust-zbus-macros-5.18.0
                                 rust-zbus-names-3.0.0
                                 rust-zbus-names-4.3.4
                                 rust-zerocopy-0.8.55
                                 rust-zerocopy-derive-0.8.55
                                 rust-zerofrom-0.1.8
                                 rust-zerofrom-derive-0.1.7
                                 rust-zeroize-1.9.0
                                 rust-zerotrie-0.2.4
                                 rust-zerovec-0.11.6
                                 rust-zerovec-derive-0.11.3
                                 rust-zmij-1.0.23
                                 rust-zune-core-0.5.1
                                 rust-zune-inflate-0.2.54
                                 rust-zune-jpeg-0.5.15
                                 rust-zvariant-4.2.0
                                 rust-zvariant-5.13.1
                                 rust-zvariant-derive-4.2.0
                                 rust-zvariant-derive-5.13.1
                                 rust-zvariant-utils-2.1.0
                                 rust-zvariant-utils-3.5.0))
                     (rust-usrhttpd-v0.1.0 =>
                                           (list rust-adler2-2.0.1
                                            rust-aho-corasick-1.1.4
                                            rust-android-system-properties-0.1.5
                                            rust-anstream-0.6.21
                                            rust-anstyle-1.0.13
                                            rust-anstyle-parse-0.2.7
                                            rust-anstyle-query-1.1.5
                                            rust-anstyle-wincon-3.0.11
                                            rust-anyhow-1.0.102
                                            rust-atomic-waker-1.1.2
                                            rust-autocfg-1.5.0
                                            rust-base64-0.22.1
                                            rust-bitflags-2.11.0
                                            rust-block-buffer-0.10.4
                                            rust-bumpalo-3.20.2
                                            rust-bytes-1.11.1
                                            rust-cc-1.2.56
                                            rust-cfg-if-1.0.4
                                            rust-chrono-0.4.43
                                            rust-clap-4.5.60
                                            rust-clap-builder-4.5.60
                                            rust-clap-derive-4.5.55
                                            rust-clap-lex-1.0.0
                                            rust-colorchoice-1.0.4
                                            rust-core-foundation-sys-0.8.7
                                            rust-cpufeatures-0.2.17
                                            rust-crc32fast-1.5.0
                                            rust-crypto-common-0.1.7
                                            rust-digest-0.10.7
                                            rust-dirs-6.0.0
                                            rust-dirs-sys-0.5.0
                                            rust-equivalent-1.0.2
                                            rust-errno-0.3.14
                                            rust-find-msvc-tools-0.1.9
                                            rust-flate2-1.1.9
                                            rust-fnv-1.0.7
                                            rust-form-urlencoded-1.2.2
                                            rust-futures-channel-0.3.32
                                            rust-futures-core-0.3.32
                                            rust-futures-sink-0.3.32
                                            rust-futures-task-0.3.32
                                            rust-futures-util-0.3.32
                                            rust-futures-macro-0.3.32
                                            rust-generic-array-0.14.7
                                            rust-getopts-0.2.24
                                            rust-getrandom-0.2.17
                                            rust-h2-0.4.13
                                            rust-hashbrown-0.16.1
                                            rust-heck-0.5.0
                                            rust-hex-0.4.3
                                            rust-http-1.4.0
                                            rust-http-body-1.0.1
                                            rust-http-body-util-0.1.3
                                            rust-httparse-1.10.1
                                            rust-httpdate-1.0.3
                                            rust-hyper-1.8.1
                                            rust-hyper-util-0.1.20
                                            rust-iana-time-zone-0.1.65
                                            rust-iana-time-zone-haiku-0.1.2
                                            rust-idna-1.1.0
                                            rust-idna-adapter-1.1.0
                                            rust-idna-mapping-1.0.0
                                            rust-indexmap-2.13.0
                                            rust-is-terminal-polyfill-1.70.2
                                            rust-itoa-1.0.17
                                            rust-js-sys-0.3.88
                                            rust-lazy-static-1.5.0
                                            rust-libc-0.2.182
                                            rust-libredox-0.1.9
                                            rust-lock-api-0.4.14
                                            rust-log-0.4.29
                                            rust-memchr-2.8.0
                                            rust-mime-0.3.17
                                            rust-mime-guess-2.0.5
                                            rust-miniz-oxide-0.8.9
                                            rust-mio-1.1.1
                                            rust-nu-ansi-term-0.50.3
                                            rust-num-traits-0.2.19
                                            rust-once-cell-1.21.3
                                            rust-once-cell-polyfill-1.70.2
                                            rust-option-ext-0.2.0
                                            rust-parking-lot-0.12.5
                                            rust-parking-lot-core-0.9.12
                                            rust-percent-encoding-2.3.2
                                            rust-pin-project-lite-0.2.16
                                            rust-pin-utils-0.1.0
                                            rust-proc-macro2-1.0.106
                                            rust-pulldown-cmark-0.9.6
                                            rust-quote-1.0.44
                                            rust-redox-syscall-0.5.18
                                            rust-redox-users-0.5.2
                                            rust-regex-1.12.3
                                            rust-regex-automata-0.4.14
                                            rust-regex-syntax-0.8.9
                                            rust-ring-0.17.14
                                            rust-rustls-0.22.4
                                            rust-rustls-pemfile-2.2.0
                                            rust-rustls-pki-types-1.14.0
                                            rust-rustls-webpki-0.102.8
                                            rust-rustversion-1.0.22
                                            rust-ryu-1.0.23
                                            rust-serde-1.0.228
                                            rust-serde-core-1.0.228
                                            rust-serde-derive-1.0.228
                                            rust-serde-json-1.0.99
                                            rust-serde-spanned-1.0.4
                                            rust-scopeguard-1.2.0
                                            rust-sha1-0.10.6
                                            rust-sharded-slab-0.1.7
                                            rust-shell-words-1.1.1
                                            rust-shellexpand-3.1.2
                                            rust-shlex-1.3.0
                                            rust-signal-hook-registry-1.4.8
                                            rust-simd-adler32-0.3.8
                                            rust-slab-0.4.12
                                            rust-smallvec-1.15.1
                                            rust-socket2-0.6.2
                                            rust-strsim-0.11.1
                                            rust-subtle-2.6.1
                                            rust-syn-2.0.117
                                            rust-thiserror-2.0.17
                                            rust-thiserror-impl-2.0.17
                                            rust-thread-local-1.1.9
                                            rust-tinyvec-1.10.0
                                            rust-tinyvec-macros-0.1.1
                                            rust-tokio-1.49.0
                                            rust-tokio-macros-2.6.0
                                            rust-tokio-rustls-0.25.0
                                            rust-tokio-util-0.7.18
                                            rust-toml-0.9.8
                                            rust-toml-datetime-0.7.5+spec-1.1.0
                                            rust-toml-parser-1.0.8+spec-1.1.0
                                            rust-toml-writer-1.0.6+spec-1.1.0
                                            rust-tower-service-0.3.3
                                            rust-tracing-0.1.44
                                            rust-tracing-core-0.1.36
                                            rust-tracing-log-0.2.0
                                            rust-tracing-attributes-0.1.31
                                            rust-tracing-subscriber-0.3.22
                                            rust-try-lock-0.2.5
                                            rust-typenum-1.19.0
                                            rust-urlencoding-2.1.3
                                            rust-unicase-2.9.0
                                            rust-unicode-bidi-0.3.18
                                            rust-unicode-ident-1.0.24
                                            rust-unicode-joining-type-0.7.0
                                            rust-unicode-normalization-0.1.25
                                            rust-unicode-width-0.2.2
                                            rust-untrusted-0.9.0
                                            rust-url-2.5.8
                                            rust-utf8parse-0.2.2
                                            rust-valuable-0.1.1
                                            rust-version-check-0.9.5
                                            rust-want-0.3.1
                                            rust-wasi-0.11.1+wasi-snapshot-preview1
                                            rust-wasm-bindgen-0.2.111
                                            rust-wasm-bindgen-macro-0.2.111
                                            rust-wasm-bindgen-macro-support-0.2.111
                                            rust-wasm-bindgen-shared-0.2.111
                                            rust-windows-core-0.62.2
                                            rust-windows-implement-0.60.2
                                            rust-windows-interface-0.59.3
                                            rust-windows-link-0.2.1
                                            rust-windows-result-0.4.1
                                            rust-windows-strings-0.5.1
                                            rust-windows-sys-0.48.0
                                            rust-windows-sys-0.52.0
                                            rust-windows-sys-0.60.2
                                            rust-windows-sys-0.61.2
                                            rust-windows-targets-0.52.6
                                            rust-windows-targets-0.53.5
                                            rust-windows-aarch64-gnullvm-0.48.5
                                            rust-windows-aarch64-gnullvm-0.52.6
                                            rust-windows-aarch64-gnullvm-0.53.1
                                            rust-windows-aarch64-msvc-0.48.5
                                            rust-windows-aarch64-msvc-0.52.6
                                            rust-windows-aarch64-msvc-0.53.1
                                            rust-windows-i686-gnu-0.48.5
                                            rust-windows-i686-gnu-0.52.6
                                            rust-windows-i686-gnu-0.53.1
                                            rust-windows-i686-gnullvm-0.52.6
                                            rust-windows-i686-gnullvm-0.53.1
                                            rust-windows-i686-msvc-0.48.5
                                            rust-windows-i686-msvc-0.52.6
                                            rust-windows-i686-msvc-0.53.1
                                            rust-windows-x86-64-gnu-0.48.5
                                            rust-windows-x86-64-gnu-0.52.6
                                            rust-windows-x86-64-gnu-0.53.1
                                            rust-windows-x86-64-gnullvm-0.48.5
                                            rust-windows-x86-64-gnullvm-0.52.6
                                            rust-windows-x86-64-gnullvm-0.53.1
                                            rust-windows-x86-64-msvc-0.48.5
                                            rust-windows-x86-64-msvc-0.52.6
                                            rust-windows-x86-64-msvc-0.53.1
                                            rust-winnow-0.7.13
                                            rust-utf8-iter-1.0.4
                                            rust-zeroize-1.8.2)))

