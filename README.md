# redmine_issue_notes_auto_collapse



## Overview

チケットへのコメントのメールの引用部分を自動的に折り畳んだ状態で初期表示するRedmineプラグイン。

## Description

Redmineのデフォルト動作としてチケットへのコメントへは、行頭に

`>`

の記載があると

`<blockquote>`というタグに置換して引用として表示されるが、

本プラグインでは、ひとつめの`>`を`<blockquote>`ではなく、

`{{collapse }}`
で囲むことで

初期表示時には引用部分を折り畳み表示する。

２つ目以降については、`<blockquote>`に置換する。


表示時のみ変換を行うため、DBの書き換えなどは発生しない。

またチケットの詳細画面表示のみ変換を行うため、コメントのプレビュー画面や

プロジェクトのactivityページなどは非対応。（そのまま表示される）

## Install

redmineのインストールパスの下のpluginsディレクトリに
redmine_issue_notes_auto_collapseという名前でコピーする。


## 参考情報

Redmine 2.2新機能紹介: チケットやWikiでテキスト折り畳み
[http://blog.redmine.jp/articles/2_2/collapsed-text/](http://)

本プラグインは、Redmine 2.5.3(Ruby 2.1.6/1.9.3)にて動作確認済み。
