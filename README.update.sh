#!/usr/bin/env bash
set -eou pipefail
cd "$(dirname "$0")"

cat > README.adoc <<EOF
= Git labs
:icons: font
:toc:
:toc-placement!:
ifdef::env-github,env-browser[:outfilesuffix: .adoc]

ifdef::env-github[]
Please read this link:README.adoc[] through the https://gitlab.com/paulojeronimo/git-labs[GitLab mirror of this project^]. +
This is because https://github.com/github/markup/issues/1095[GitHub does not render \`includes\` in Asciidoc documents correctly^]. 😒
endif::[]

ifndef::env-github[]
// AsciiDoc URIs and Attributes (a shared project)
include::asciidoc-una/uris.adoc[]
include::asciidoc-una/attributes.adoc[]

// Local attributes
:Base58: <<base58,Base58>>

Some labs to test {Git} features or solutions.

toc::[]

<<contribution-guidelines,Contributions>> are welcome! 😃 +
Fell free fork {uri-paulojeronimo-git-labs}[this repo^], add your lab, and {uri-github-creating-a-pull-request-from-a-fork}[make a pull request^] to add it.
Currently, these scripts only use {Bash}, and tools available in macOS and Linux distros like {sed} and {awk}.

WARNING: The file link:README.adoc[] is generated by link:README.update.sh[] script.
So, do not edit it directly because it will be overwritten!

ifdef::env-gitlab[]
WARNING: This repo is a mirror of {uri-paulojeronimo-git-labs}.
So, it is not maintained directly here, in GitLab.
All changes to this repo occur firstly in GitHub.
Why we have this mirror in GitLab?
Well, GitHub does not render Asciidoc documents correctly as Gitlab does.
You can note, for example, that the clause \`includes\` in Asciidoc does not work in GitHub.
endif::[]

== Labs

$(for f in `ls lab???.sh | sort -r`
  do
    d=$(git log --diff-filter=A --follow --format=%aI -1 -- $f)
    sed -n '2p' $f | sed "s/^# Purpose: \(.*\)/* link:$f[] (created in $d): \1/"
  done)

:leveloffset: +1

include::docs/contribution-guidelines.adoc[]

include::docs/utilities.adoc[]

:leveloffset: -1
endif::[]
EOF

adoc_args="-o index.html"
while [ "${1:-}" ]
do
  case "${1:-}" in
    --github)
      # Simulates the GitHub generated README.adoc
      adoc_args="-a env-github $adoc_args"
      ;;
    --gitlab)
      # Simulates the GitLab generated README.adoc
      adoc_args="-a env-gitlab $adoc_args"
      ;;
    --html)
      asciidoctor README.adoc $adoc_args
      for f in docs/lab???.adoc; do asciidoctor $f; done
      ;;
    --serve)
      ruby -run -e httpd . -p 8000 &> httpd.log &
      ;;
    *)
      echo "Invalid argument: \"${1:-}\""
      exit 1
      ;;
  esac
  shift || :
done
