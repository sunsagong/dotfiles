;; WEB+DB PRESS plusシリーズ
;; ［改訂新版］Emacs実践入門――思考を直感的にコード化し，開発を加速する
;; サンプルinit.el

;;; 注意事項 - まずはこちらをお読みください

;; このサンプルコードは、書籍『［改訂新版］Emacs実践入門』に登場する
;; 設定コードをまとめたものです。一部の設定では、拡張機能のインストー
;; ルが必須となっているため、このファイルに書かれている内容の一部は
;; そのまま利用することはできません。本書を読み進めながら、必要な設
;; 定をあなたのinit.elへコピーしてご利用ください。なお、拡張機能のイ
;; ンストールが必要な設定については、自動的に拡張をインストールする
;; 設定にしています。必要に応じてコメントアウトしてください。


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 3.2 Emacsの起動と終了                                  ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P30 デバッグモードでの起動
;; cl-libパッケージを読み込む
(require 'cl-lib)
;; スタートアップメッセージを非表示
(setq inhibit-startup-screen t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.1 効率的な設定ファイルの作り方と管理方法             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P61 Elisp配置用のディレクトリを作成
;; load-pathを追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
;; (add-to-load-path "elisp" "conf" "public_repos")

;;; P63 Emacsが自動的に書き込む設定をcustom.elに保存する
;; カスタムファイルを別ファイルにする
(setq custom-file (locate-user-emacs-file "custom.el"))
;; (カスタムファイルが存在しない場合は作成する
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
;; カスタムファイルを読み込む
(load custom-file)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 4.2 環境に応じた設定の分岐                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P65 OSの違いによる分岐
;; Macだけに読み込ませる内容を書く
(when (eq system-type 'darwin)
  ;; MacのEmacsでファイル名を正しく扱うための設定
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;;; P65-66 CUIとGUIによる分岐
;; ターミナル以外はツールバー、スクロールバーを非表示
(when window-system
  ;; tool-barを非表示
  (tool-bar-mode 0)
  ;; scroll-barを非表示
  (scroll-bar-mode 0))

;; CocoaEmacs以外はメニューバーを非表示
(unless (eq window-system 'ns)
  ;; menu-barを非表示
  (menu-bar-mode 0))

;;; P66 Emacsのバージョンによる分岐
;; Emacs 23より前のバージョンを利用している方は
;; user-emacs-directory変数が未定義のため次の設定を追加
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.2 キーバインドの設定                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P80 C-hをバックスペースにする
;; 入力されるキーシーケンスを置き換える
;; ?\C-?はDELのキーシケンス
;; (keyboard-translate ?\C-h ?\C-?)

;;; P79-81 お勧めのキー操作
;; C-mにnewline-and-indentを割り当てる。
;; 先ほどとは異なりglobal-set-keyを利用
(global-set-key (kbd "C-m") 'newline-and-indent)
;; 折り返しトグルコマンド
(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)
;; "C-t" でウィンドウを切り替える。初期値はtranspose-chars
(define-key global-map (kbd "C-t") 'other-window)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.3 環境変数の設定                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P83 パスの設定
(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")

;;; P85 文字コードを指定する
(set-language-environment "Japanese")
(prefer-coding-system 'utf-8)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.4 フレームに関する設定                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P87-90 モードラインに関する設定
;; カラム番号も表示
(column-number-mode t)

;; 行番号を表示させない
(line-number-mode 0)

;; ファイルサイズを表示
(size-indication-mode t)
;; 時計を表示（好みに応じてフォーマットを変更可能）
;; (setq display-time-day-and-date t) ; 曜日・月・日を表示
;; (setq display-time-24hr-format t) ; 24時表示
(display-time-mode t)
;; バッテリー残量を表示
(display-battery-mode t)

;; リージョン内の行数と文字数をモードラインに表示する（範囲指定時のみ）
(defun count-lines-and-chars ()
  (if mark-active
      (format "(%dlines,%dchars) "
              (count-lines (region-beginning) (region-end))
              (- (region-end) (region-beginning)))
    ""))

(add-to-list 'default-mode-line-format
             '(:eval (count-lines-and-chars)))

;; タイトルバーにファイルのフルパスを表示
(setq frame-title-format "%f")

;; 行番号を常に表示する
(global-linum-mode t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.5インデントの設定                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P91-92 タブ文字の表示幅
;; TABの表示幅。初期値は8
(setq-default tab-width 4)

;; インデントにタブ文字を使用しない
(setq-default indent-tabs-mode nil)

;; php-modeのみタブを利用しない
;; (add-hook 'php-mode-hook
;;           '(lambda ()
;;             (setq indent-tabs-mode nil)))

;; C、C++、JAVA、PHPなどのインデント
(add-hook 'c-mode-common-hook
          '(lambda ()
             (c-set-style "bsd")))


;; php-modeのswitch文のインデント
(add-hook 'php-mode-hook
          (lambda ()
            (c-set-offset 'case-label '+)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.6 表示・装飾に関する設定                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P95 フェイス
;; リージョンの背景色を変更
;; (set-face-background 'region "darkgreen")

;;; P96-97 フォントの設定
;; AsciiフォントをMenloに
(set-face-attribute 'default nil
                    :family "Menlo"
                    :height 120)

;; 日本語フォントをNoto Serif CJK JPに
(set-fontset-font
 nil 'japanese-jisx0208
 (font-spec :family "Noto Serif CJK JP"))

;; ひらがなとカタカナをNoto Sans CJK JPに
;; U+3000-303F	CJKの記号および句読点
;; U+3040-309F	ひらがな
;; U+30A0-30FF	カタカナ
(set-fontset-font
 nil '(#x3040 . #x30ff)
 (font-spec :family "Noto Sans CJK JP"))

;; Notoフォントの横幅を調整
(add-to-list 'face-font-rescale-alist '(".*Noto.*" . 1.2))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.7 ハイライトの設定                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P98 現在行のハイライト
(defface my-hl-line-face
  ;; 背景がdarkならば背景色を紺に
  '((((class color) (background dark))
     (:background "NavyBlue" t))
    ;; 背景がlightならば背景色を青に
    (((class color) (background light))
     (:background "LightSkyBlue" t))
    (t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)

;; P99 括弧の対応関係のハイライト
;; paren-mode：対応する括弧を強調して表示する
(setq show-paren-delay 0) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expressionは括弧内も強調表示
(setq show-paren-style 'expression)
;; フェイスを変更する
(set-face-background 'show-paren-match-face nil)
(set-face-underline-p 'show-paren-match-face "darkgreen")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.8 バックアップとオートセーブ                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P100-101 バックアップとオートセーブの設定
;; バックアップファイルを作成しない
;; (setq make-backup-files nil) ; 初期値はt
;; オートセーブファイルを作らない
;; (setq auto-save-default nil) ; 初期値はt

;; バックアップファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq backup-directory-alist
;;       `((".*" . ,temporary-file-directory)))
;; オートセーブファイルの作成場所をシステムのTempディレクトリに変更する
;; (setq auto-save-file-name-transforms
;;       `((".*" ,temporary-file-directory t)))

;; バックアップとオートセーブファイルを~/.emacs.d/backups/へ集める
(add-to-list 'backup-directory-alist
             (cons "." "~/.emacs.d/backups/"))
(setq auto-save-file-name-transforms
      `((".*" ,(expand-file-name "~/.emacs.d/backups/") t)))

;; オートセーブファイル作成までの秒間隔
(setq auto-save-timeout 15)
;; オートセーブファイル作成までのタイプ間隔
(setq auto-save-interval 60)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.9 変更されたファイルの自動更新                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P102 ファイルの自動更新
;; 更新されたファイルを自動的に読み込み直す
(global-auto-revert-mode t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 5.10 フック                                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P103 自動化のしくみ
;; ファイルが #! から始まる場合、+xを付けて保存する
(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

;;; P104-105 関数を定義する場合
;; emacs-lisp-mode-hook用の関数を定義
(defun elisp-mode-hooks ()
  "lisp-mode-hooks"
  (when (require 'eldoc nil t)
    (setq eldoc-idle-delay 0.2)
    (setq eldoc-echo-area-use-multiline-p t)
    (turn-on-eldoc-mode)))

;; emacs-lisp-modeのフックをセット
(add-hook 'emacs-lisp-mode-hook 'elisp-mode-hooks)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.1 Elispをインストールしよう                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P112-113 ELPAリポジトリを追加する
(require 'package) ; package.elを有効化
;; パッケージリポジトリにMarmaladeとMELPAを追加
(add-to-list
 'package-archives
 '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/"))
(package-initialize) ; インストール済みのElispを読み込む
;; 最新のpackageリストを読み込む
(when (not package-archive-contents)
  (package-refresh-contents))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.2 テーマ                                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P119-121 テーマの変更
(package-install 'zenburn-theme)
;; zenburnテーマを利用する
(load-theme 'zenburn t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.3 統一したインタフェースでの操作                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P122-123 候補選択型インタフェース Helm
(package-install 'helm)

;; Helm
(require 'helm-config)


;;; P125 過去の履歴からペーストする──helm-show-kill-ring
;; M-yにhelm-show-kill-ringを割り当てる
(define-key global-map (kbd "M-y") 'helm-show-kill-ring)

;;; P126 moccurを利用する──helm-c-moccur
(package-install 'helm-c-moccur)
(when (require 'helm-c-moccur nil t)
  (setq
   ;; 執筆時点でエラーが出たため定義しているが、
   ;; 将来的には不要になる可能性が高い
   helm-idle-delay 0.1
   ;; helm-c-moccur用 `helm-idle-delay'
   helm-c-moccur-helm-idle-delay 0.1
   ;; バッファの情報をハイライトする
   helm-c-moccur-higligt-info-line-flag t
   ;; 現在選択中の候補の位置をほかのwindowに表示する
   helm-c-moccur-enable-auto-look-flag t
   ;; 起動時にポイントの位置の単語を初期パターンにする
   helm-c-moccur-enable-initial-pattern t)
  ;; C-M-oにhelm-c-moccur-occur-by-moccurを割り当てる
  (global-set-key (kbd "C-M-o") 'helm-c-moccur-occur-by-moccur))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.4 入力の効率化                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P128 補完入力の強化 Auto Complete Mode
(package-install 'auto-complete)
;; auto-completeの設定
(when (require 'auto-complete-config nil t)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
  (ac-config-default)
  (setq ac-use-menu-map t)
  (setq ac-ignore-case nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.5 検索と置換の拡張                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P129-130 検索結果をリストアップする color-moccur
;; color-moccurの設定
(when (require 'color-moccur nil t)
  ;; M-oにoccur-by-moccurを割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スペース区切りでAND検索
  (setq moccur-split-word t)
  ;; ディレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$"))

;;; P131-132 moccurの結果を直接編集 moccur-edit
(package-install 'moccur-edit)
;; moccur-editの設定
(require 'moccur-edit nil t)
;; moccur-edit-finish-editと同時にファイルを保存する
(defadvice moccur-edit-change-file
  (after save-after-moccur-edit-buffer activate)
  (save-buffer))

;;; P133 grepの結果を直接編集 wgrep
(package-install 'wgrep)
;; wgrepの設定
(require 'wgrep nil t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.6 さまざまな履歴管理                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P135 編集履歴の記憶 undohist
(package-install 'undohist)
;; undohistの設定
(when (require 'undohist nil t)
  (undohist-initialize))


;;; P136 アンドゥの分岐履歴 undo-tree
(package-install 'undo-tree)
;; undo-treeの設定
(when (require 'undo-tree nil t)
  ;; C-'にリドゥを割り当てる
  ;; (define-key global-map (kbd "C-'") 'undo-tree-redo)
  (global-undo-tree-mode))

;;; P137 カーソルの移動履歴 point-undo
(package-install 'point-undo)
;; point-undoの設定
(when (require 'point-undo nil t)
  (define-key global-map [f5] 'point-undo)
  (define-key global-map [f6] 'point-redo)
  ;; 筆者のお勧めキーバインド
  ;; (define-key global-map (kbd "M-[") 'point-undo)
  ;; (define-key global-map (kbd "M-]") 'point-redo)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.7 ウィンドウ管理                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P139 ウィンドウの分割状態を管理──ElScreen
(package-install 'elscreen)
;; ElScreenのプレフィックスキーを変更する（初期値はC-z）
;; (setq elscreen-prefix-key (kbd "C-t"))
(when (require 'elscreen nil t)
  (elscreen-start)
  ;; C-z C-zをタイプした場合にデフォルトのC-zを利用する
  (if window-system
      (define-key elscreen-map (kbd "C-z") 'iconify-or-deiconify-frame)
    (define-key elscreen-map (kbd "C-z") 'suspend-emacs)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.8 メモ・情報整理                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P141-144 メモ書き・ToDo管理 howm
(package-install 'howm)
;; howmメモ保存の場所
(setq howm-directory (concat user-emacs-directory "howm"))
;; howm-menuの言語を日本語に
(setq howm-menu-lang 'ja)
;; howmメモを1日1ファイルにする
; (setq howm-file-name-format "%Y/%m/%Y-%m-%d.howm")
;; howm-modeを読み込む
(when (require 'howm-mode nil t)
  ;; C-c,,でhowm-menuを起動
  (define-key global-map (kbd "C-c ,,") 'howm-menu))

;; howmメモを保存と同時に閉じる
(defun howm-save-buffer-and-kill ()
  "howmメモを保存と同時に閉じます。"
  (interactive)
  (when (and (buffer-file-name)
             (howm-buffer-p))
    (save-buffer)
,    (kill-buffer nil)))

;; C-c C-cでメモの保存と同時にバッファを閉じる
(define-key howm-mode-map (kbd "C-c C-c") 'howm-save-buffer-and-kill)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 6.9 特殊な範囲の編集                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; P147 矩形編集──cua-mode
;; cua-modeの設定
(cua-mode t) ; cua-modeをオン
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効にする


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.1 各種言語の開発環境                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; P153-154 web-mode
(package-install 'web-mode)
(when (require 'web-mode nil t)
  ;; 自動的にweb-modeを起動したい拡張子を追加する
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  ;;; web-modeのインデント設定用フック
  ;; (defun web-mode-hook ()
  ;;   "Hooks for Web mode."
  ;;   (setq web-mode-markup-indent-offset 2) ; HTMLのインデイント
  ;;   (setq web-mode-css-indent-offset 2) ; CSSのインデント
  ;;   (setq web-mode-code-indent-offset 2) ; JS, PHP, Rubyなどのインデント
  ;;   (setq web-mode-comment-style 2) ; web-mode内のコメントのインデント
  ;;   (setq web-mode-style-padding 1) ; <style>内のインデント開始レベル
  ;;   (setq web-mode-script-padding 1) ; <script>内のインデント開始レベル
  ;;   )
  ;; (add-hook 'web-mode-hook  'web-mode-hook)
  )


;;; P156 nxml-modeをHTML編集のデフォルトモードに
;; HTML編集のデフォルトモードをnxml-modeにする
;; (add-to-list 'auto-mode-alist '("\\.[sx]?html?\\(\\.[a-zA-Z_]+\\)?\\'" . nxml-mode))

;;; P157 HTML5をnxml-modeで編集する
(package-install 'html5-schema)

;;; P158 nxml-modeの基本設定
;; </を入力すると自動的にタグを閉じる
(setq nxml-slash-auto-complete-flag t)
;; M-TABでタグを補完する
(setq nxml-bind-meta-tab-to-complete-flag t)
;; nxml-modeでauto-complete-modeを利用する
(add-to-list 'ac-modes 'nxml-mode)

;; 子要素のインデント幅を設定する。初期値は2
(setq nxml-child-indent 0)
;; 属性値のインデント幅を設定する。初期値は4
(setq nxml-attribute-indent 0)

;;; P159 less-css-mode
(package-install 'less-css-mode)


;;; P159 sass-mode
(package-install 'sass-mode)


;;; P160 標準のjs-mode
(defun js-indent-hook ()
  ;; インデント幅を4にする
  (setq js-indent-level 2
        js-expr-indent-offset 2
        indent-tabs-mode nil)
  ;; switch文のcaseラベルをインデントする関数を定義する
  (defun my-js-indent-line () ←(d1)
    (interactive)
    (let* ((parse-status (save-excursion (syntax-ppss (point-at-bol))))
           (offset (- (current-column) (current-indentation)))
           (indentation (js--proper-indentation parse-status)))
      (back-to-indentation)
      (if (looking-at "case\\s-")
          (indent-line-to (+ indentation 2))
        (js-indent-line))
      (when (> offset 0) (forward-char offset))))
  ;; caseラベルのインデント処理をセットする
  (set (make-local-variable 'indent-line-function) 'my-js-indent-line)
  ;; ここまでcaseラベルを調整する設定
  )

;; js-modeの起動時にhookを追加
(add-hook 'js-mode-hook 'js-indent-hook)


;;; P161 構文チェック機能を備えたjs2-mode
(package-install 'js2-mode)
;; (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
;; React（JSX）を使う場合はこちら
(add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-jsx-mode))


;;; P162 php-mode
(package-install 'php-mode)
;; 日本語ドキュメントを利用するための設定
(when (require 'php-mode nil t)
  (setq php-site-url "https://secure.php.net/"
        php-manual-url 'ja))

;; php-modeのインデント設定
(defun php-indent-hook ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  ;; (c-set-offset 'case-label '+) ; switch文のcaseラベル
  (c-set-offset 'arglist-intro '+) ; 配列の最初の要素が改行した場合
  (c-set-offset 'arglist-close 0)) ; 配列の閉じ括弧

(add-hook 'php-mode-hook 'php-indent-hook)


;;; P164-165 cperl-mode
;; perl-modeをcperl-modeのエイリアスにする
(defalias 'perl-mode 'cperl-mode)

;; cperl-modeのインデント設定
(setq cperl-indent-level 4 ; インデント幅を4にする
      cperl-continued-statement-offset 4 ; 継続する文のオフセット※
      cperl-brace-offset -4 ; ブレースのオフセット
      cperl-label-offset -4 ; labelのオフセット
      cperl-indent-parens-as-block t ; 括弧もブロックとしてインデント
      cperl-close-paren-offset -4 ; 閉じ括弧のオフセット
      cperl-tab-always-indent t ; <kbd>Tab</kbd>をインデントにする
      cperl-highlight-variables-indiscriminately t) ; スカラを常にハイライト

;;; P164 コラム：便利なエイリアス
;; dtwをdelete-trailing-whitespaceのエイリアスにする
(defalias 'dtw 'delete-trailing-whitespace)



;;; P165 yaml-mode
(package-install 'yaml-mode)


;;; P166 ruby-modeのインデントを調整する
;; ruby-modeのインデント設定
(setq ruby-indent-level 3 ; インデント幅を3に。初期値は2
      ruby-deep-indent-paren-style nil ; 改行時のインデントを調整する
      ;; ruby-mode実行時にindent-tabs-modeを設定値に変更
      ruby-indent-tabs-mode t) ; タブ文字を使用する。初期値はnil

;;; P166 Ruby編集用の便利なマイナーモードを利用する
(package-install 'ruby-electric)
(package-install 'inf-ruby)
;; ruby-mode-hookにruby-electric-modeを追加
(add-hook 'ruby-mode-hook #'ruby-electric-mode)


;;; P168 python-mode
(setq python-check-command "flake8")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.2 Flycheckによる文法チェック                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P172-173 Flycheckの利用
(package-install 'flycheck)

;; 文法チェックを実行する
(add-hook 'after-init-hook #'global-flycheck-mode)

;;; 機能を追加する
(package-install 'flycheck-pos-tip)
(with-eval-after-load 'flycheck
  (flycheck-pos-tip-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.3 コードの実行                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P174 quickrunによるコード実行
(package-install 'quickrun)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.4 タグによるコードリーディング                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P177-178 gtagsとEmacsの連携
;; (package-install-file "/usr/local/share/gtags/gtags.el")

;; gtags-modeのキーバインドを有効化する
(setq gtags-suggested-key-mapping t) ; 無効化する場合はコメントアウト
;; ファイル保存時に自動的にタグをアップデートする
(setq gtags-auto-update t) ; 無効化する場合はコメントアウト


;;; P179 Helmとgtagsの連携
(package-install 'helm-gtags)
(custom-set-variables
 '(helm-gtags-suggested-key-mapping t)
 '(helm-gtags-auto-update t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.5 プロジェクトベースの編集──projectile               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P180 projectileによるプロジェクト管理
(package-install 'projectile)
;; projectile
(when (require 'projectile nil t)
  ;;自動的にプロジェクト管理を開始
  (projectile-mode)
  ;; プロジェクト管理から除外するディレクトリを追加
  (add-to-list
    'projectile-globally-ignored-directories
    "node_modules")
  ;; プロジェクト情報をキャッシュする
  (setq projectile-enable-caching t))

;; projectileのプレフィックスキーをs-pに変更
(define-key projectile-mode-map
  (kbd "s-p") 'projectile-command-map)


;;; P182-183 Helmを使って利用する
(package-install 'helm-projectile)
;; Fuzzyマッチを無効にする。
;; (setq helm-projectile-fuzzy-match nil)
(when (require 'helm-projectile nil t)
  (setq projectile-completion-system 'helm))


;;; P183-184 Railsサポートを利用して編集するファイルを切り替える
(package-install 'projectile-rails)
;; projectile-railsのプレフィックスキーをs-rに変更
;; (setq projectile-rails-keymap-prefix (kbd "s-r"))
(when (require 'projectile-rails nil t)
  (projectile-rails-global-mode))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.6 特殊な文字の入力補助                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; P185-186 絵文字の入力補助 ac-emoji
(package-install 'ac-emoji)
(when (require 'ac-emoji nil t)
  ;; text-modeとmarkdown-modeでauto-completeを有効にする
  (add-to-list 'ac-modes 'text-mode)
  (add-to-list 'ac-modes 'markdown-mode)
  ;; text-modeとmarkdown-modeでac-emojiを有効にする
  (add-hook 'text-mode-hook 'ac-emoji-setup)
  (add-hook 'markdown-mode-hook 'ac-emoji-setup))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.7 差分とマージ                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P189 同一フレーム内にコントロールパネルを表示する
;; ediffコントロールパネルを別フレームにしない
(setq ediff-window-setup-function 'ediff-setup-windows-plain)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.8 Emacsからデータベースを操作                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P193 MySQLへ接続する──sql-interactive-mode
;; SQLサーバへ接続するためのデフォルト情報
;; (setq sql-user "root" ; デフォルトユーザー名
;;       sql-database "database_name" ;  データベース名
;;       sql-server "localhost" ; ホスト名
;;       sql-product 'mysql) ; データベースの種類


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.9 バージョン管理                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; P198 Subversionフロントエンド psvn
(package-install 'psvn)

;;; P200 Gitフロントエンド Magit
(package-install 'magit)

;;; P204 差分の表示──git-gutter
(package-install 'git-gutter)
(when (require 'git-gutter nil t)
  (global-git-gutter-mode t)
  ;; linum-modeを利用している場合は次の設定も追加
  ;; (git-gutter:linum-setup)
  )

;; (custom-set-variables
;;  '(git-gutter:modified-sign "*")
;;  '(git-gutter:added-sign ">")
;;  '(git-gutter:deleted-sign "x"))

(global-set-key (kbd "C-x p") 'git-gutter:previous-hunk)
(global-set-key (kbd "C-x n") 'git-gutter:next-hunk)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.10 シェルの利用                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P208 ターミナルの利用 multi-term
(package-install 'multi-term)
;; multi-termの設定
;; (when (require 'multi-term nil t)
;;   ;; 使用するシェルを指定
;;   (setq multi-term-program "/usr/local/bin/zsh"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.11 TRAMPによるサーバ接続                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P210 バックアップファイルを作成しない
;; TRAMPでバックアップファイルを作成しない
(add-to-list 'backup-directory-alist
             (cons tramp-file-name-regexp nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.12 ドキュメント閲覧・検索                            ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P211-212 Emacs版manビューア（WoMan）の利用
;; キャッシュを作成
(setq woman-cache-filename "~/.emacs.d/.wmncach.el")
;; manパスを設定
(setq woman-manpath '("/usr/share/man"
                      "/usr/local/share/man"
                      "/usr/local/share/man/ja"))

;;; P212 Helmによるman検索
;; 既存のソースを読み込む
(require 'helm-elisp)
(require 'helm-man)
;; 基本となるソースを定義
(setq helm-for-document-sources
      '(helm-source-info-elisp
        helm-source-info-cl
        helm-source-info-pages
        helm-source-man-pages))
;; helm-for-documentコマンドを定義
(defun helm-for-document ()
  "Preconfigured `helm' for helm-for-document."
  (interactive)
  (let ((default (thing-at-point 'symbol)))
    (helm :sources
          (nconc
           (mapcar (lambda (func)
                     (funcall func default))
                   helm-apropos-function-list)
           helm-for-document-sources)
          :buffer "*helm for docuemont*")))

;; s-dにhelm-for-documentを割り当て
(define-key global-map (kbd "s-d") 'helm-for-document)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 7.13 テスティングフレームワークとの連携                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; P214-215 phpunit.el
(package-install 'phpunit)
;; php-modeにキーバインドを追加する
(define-key php-mode-map (kbd "C-t t") 'phpunit-current-test)
(define-key php-mode-map (kbd "C-t c") 'phpunit-current-class)
(define-key php-mode-map (kbd "C-t p") 'phpunit-current-project)

;;; P216 rspec-mode
(package-install 'rspec-mode)
(package-install 'direnv)

;; direnv
(when (require 'direnv nil t)
  (setq direnv-always-show-summary t)
  (direnv-mode))

;; rspec-modeのプレフィックスキーをs-rに変更
;; (setq rspec-key-command-prefix (kbd "s-s"))
;; rakeコマンドを利用する
;; (setq rspec-use-rake-when-possible t)
;; bundle execコマンドを利用しない
;; (setq rspec-use-bundler-when-possible nil)
;; springを利用しない
(setq rspec-use-spring-when-possible nil)
;; Dockerを利用する
;; (setq rspec-use-docker-when-possible t)
;; (setq rspec-docker-container "api")
;; (setq rspec-docker-cwd "/api/")
;; Vagrantを利用する
;; (setq rspec-use-vagrant-when-possible t)
;; (setq rspec-vagrant-cwd "/vagrant/")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; オマケ                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; symlink をフォローしない
(setq-default find-file-visit-truename t)

;;; exec-path に PATH を追加する
(cl-loop for x in (reverse
                (split-string (substring (shell-command-to-string "echo $PATH") 0 -1) ":"))
      do (add-to-list 'exec-path x))

;;; recentf の履歴を増やして自動保存する
(when (require 'recentf nil 'noerror)
  (setq recentf-max-saved-items 100000)
  (setq recentf-exclude '("recentf"))
  (setq recentf-auto-save-timer
        (run-with-idle-timer 30 t 'recentf-save-list))
  (recentf-mode 1))

;;; 全角スペースや改行などを可視化する
(setq whitespace-display-mappings
      '(
        (space-mark ?\x3000 [?\□]) ; zenkaku space
        (newline-mark 10 [182 10]) ; ¶
        (tab-mark 9 [187 9] [92 9]) ; tab » 187
        ))

(setq whitespace-style
      '(
        spaces
        trailing
        newline
        space-mark
        tab-mark
        newline-mark))

;; display zenkaku space
(setq whitespace-space-regexp "\\(\u3000+\\)")

(global-whitespace-mode t)
(define-key global-map (kbd "<f5>") 'global-whitespace-mode)
(set-face-foreground 'whitespace-newline "Gray")

;;; 保存時に末尾空白を削除する
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;; Mac でファイルを開いたときに、新たなフレームを作らない
(setq ns-pop-up-frames nil)
