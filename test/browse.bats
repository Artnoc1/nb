#!/usr/bin/env bats

load test_helper

export NB_SERVER_PORT=6789

# non-breaking space
export _S=" "

# title #######################################################################

@test "'browse' sets HTML title." {
  {
    "${_NB}" init
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[    "${status}"  -eq 0                    ]]

  [[    "${output}"  =~  '<title>nb</title>'  ]]
  [[ !  "${output}"  =~  'h1 class="title"'   ]]
  [[ !  "${output}"  =~  'title-block-header' ]]
}

# css / styles ################################################################

@test "'browse' includes application styles." {
  {
    "${_NB}" init
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  -eq 0         ]]

  [[ "${output}"  =~  'html {'  ]]
}

# conflicting folder id / name ################################################

@test "'browse <folder>/' with conflicting id / folder name renders links to ids and labels to names." {
  {
    "${_NB}" init

    "${_NB}" add "Example Folder" --type folder
    "${_NB}" add "Sample Folder/File One.md" --content "Example content."

    "${_NB}" move "Sample Folder" "1" --force

    [[ -d "${NB_DIR}/home/Example Folder" ]]
    [[ -f "${NB_DIR}/home/1/File One.md"  ]]
  }

  run "${_NB}" browse 1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>        ]]
  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>           ]]
  [[ "${output}"  =~  \
      .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ .*:.*\              ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1/\"\>Example\ Folder\</a\>\ .*/.*\</h1\>  ]]

  [[ "${output}"  =~  0\ items. ]]

  run "${_NB}" browse 2/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\  ]]
  [[ "${output}"  =~  \
      \<span\ class=\"dim\"\>❯\</span\>nb\</a\>                                       ]]
  [[ "${output}"  =~  \
      .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ .*:.*\            ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:2/\"\>1\</a\>\ .*/.*\</h1\>              ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/home:2/1\"\ class=\"list-item\"\>.*\[.*1/1.*\].*   ]]
  [[ "${output}"  =~  \
      class=\"list-item\"\>.*\[.*1/1.*\].*${_S}File${_S}One.md\</a\>\<br\>\</p\>                ]]
}

# header crumbs ###############################################################

@test "'browse <notebook>:<folder-id>/<folder-id>/<file-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
  [[ "${output}"    =~ \ .*/.*\ \[Sample\ Folder\]\(http://localhost:6789/home:1/1/\?--page=.*\)\ .*/.* ]]
}

@test "'browse <notebook>:<folder-id>/<file-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse home:1/1 --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
}

@test "'browse <notebook>:<folder-id>/<folder-id>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/Sample Folder/File One.md"  \
      --title     "Example Title"                             \
      --content   "Example content."

    "${_NB}" notebooks add "Example Notebook"
    "${_NB}" use "Example Notebook"
  }

  run "${_NB}" browse home:1/1/ --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
  [[ "${output}"    =~ \ .*/.*\ \[Sample\ Folder\]\(http://localhost:6789/home:1/1/\?--page=.*\)\ .*/.* ]]

  run "${_NB}" browse home:1/1/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0                                ]]

  [[ "${output}"    =~ \<h1\ class=\"header-crumbs\"\>  ]]
}

@test "'browse <notebook-path>/<folder>/file>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder/File One.md" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0  ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
}

@test "'browse <notebook-path>/<folder>' displays header crumbs with folder." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse "${NB_DIR}/home/Example Folder" --header

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    == 0 ]]

  [[ "${output}"    =~ \
        \<h1\ class=\"header-crumbs\"\>\[\<span\ class=\"dim\"\>❯\</span\>nb\]\(http://localhost:6789/\)\ .*·.*\  ]]
  [[ "${output}"    =~ \ .*·.*\ \[home\]\(http://localhost:6789/home:\?--page=.*\)\ .*:.*\              ]]
  [[ "${output}"    =~ \ .*:.*\ \[Example\ Folder\]\(http://localhost:6789/home:1/\?--page=.*\)\ .*/.*  ]]
}

# headers #######################################################################

@test "'browse <selector> --print --headers' prints response headers." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."
  }

  run "${_NB}" browse 1 --print --headers

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                         ]]
  [[ "${#lines[@]}" ==  5                         ]]

  [[ "${lines[0]}"  =~  HTTP/1.0\ 200\ OK         ]]
  [[ "${lines[1]}"  =~  Date:\ .*                 ]]
  [[ "${lines[2]}"  =~  Expires:\ .*              ]]
  [[ "${lines[3]}"  =~  Server:\ nb               ]]
  [[ "${lines[4]}"  =~  Content-Type:\ text/html  ]]
}

# items #######################################################################

@test "'browse <folder-id>/<id>' serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" browse 2/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                 ]]

  [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>           ]]

  [[ "${output}"    =~  \
      \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/home:1\"\>  ]]
  [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                  ]]
}

@test "'browse <folder-name>/<id>' serves the rendered HTML page with wiki-style links resolved to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example File.md"             \
      --title     "Example Title"               \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content. [[Example Title]]"
  }

  run "${_NB}" browse Example\ Folder/1 --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"    ==  0                                                   ]]
  [[ "${output}"    =~  \<\!DOCTYPE\ html\>                                 ]]

  [[ "${output}"    =~  \<h1\ id=\"title-one\"\>Title\ One\</h1\>           ]]

  [[ "${output}"    =~  \
      \<p\>Example\ content.\ \<a\ href=\"http://localhost:6789/home:1\"\>  ]]
  [[ "${output}"    =~  \[\[Example\ Title\]\]\</a\>\</p\>                  ]]
}

# empty #######################################################################

@test "'browse <folder-selector>/' (slash) with empty folder prints message and header." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder" --type "folder"
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
      .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ .*:.*\              ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1/\"\>Example\ Folder\</a\>\ .*/.*\</h1\>  ]]

  [[ "${output}"  =~  0\ items. ]]
}

@test "'browse <notebook>:' with empty notebook prints message and header." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"
  }

  run "${_NB}" browse Example\ Notebook: --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
      .*·.*\ \<a\ href=\"http://localhost:6789/Example%20Notebook:\"\>Example\ Notebook\</a\>.*\</h1\>  ]]

  [[ "${output}"  =~  0\ items. ]]
}

# notebooks and folder (containers) ###########################################

@test "'browse --notebooks'  serves the list of unarchived notebooks as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "One"
    "${_NB}" notebooks add "Two"
    "${_NB}" notebooks add "Three"
  }

  run "${_NB}" browse --notebooks --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0                   ]]
  [[ "${output}"  =~  \<\!DOCTYPE\ html\> ]]

  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\  ]]
  [[ "${output}"  =~  \
      \<span\ class=\"dim\"\>❯\</span\>nb\</a\>\ .*·.*\ \<span\ class=\"dim\"\>notebooks\</span\>.*\</h1\>  ]]


  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/One:\"\>One\</a\>\ .*·.*\  ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Two:\"\>Two\</a\>\ .*·.*\       ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Three:\"\>Three\</a\>\ .*·.*\   ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\</p\>       ]]
}

@test "'browse' with no arguments serves the current notebook contents as a rendered HTML page with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "File One.md"       \
      --title     "Title One"         \
      --content   "Example content."

    "${_NB}" add  "File Two.md"       \
      --title     "Title Two"         \
      --content   "Example content."

    "${_NB}" add  "Example Folder"    \
      --type      "folder"
  }

  run "${_NB}" browse --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  == 0                                              ]]
  [[ "${output}"  =~ \<\!DOCTYPE\ html\>                            ]]

  [[ "${output}"  =~  \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>     ]]
  [[ "${output}"  =~  href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~ .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>.*\</h1\>        ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/home:3\"\ class=\"list-item\"\>        ]]
  [[ "${output}"  =~  .*\[.*home:3.*\].*${_S}📂${_S}Example${_S}Folder\</a\>\<br\>  ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:2\"\ class=\"list-item\"\>             ]]
  [[ "${output}"  =~  .*\[.*home:2.*\].*${_S}Title${_S}Two\</a\>\<br\>              ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1\"\ class=\"list-item\"\>             ]]
  [[ "${output}"  =~  .*\[.*home:1.*\].*${_S}Title${_S}One\</a\>\<br\>              ]]
}

@test "'browse <folder-selector>/' (slash) serves the list as rendered HTML with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File Two.md"  \
      --title     "Title Two"                   \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Folder/ --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\> ]]
  [[ "${output}"  =~  \
      .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ .*:.*\                ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1/\"\>Example\ Folder\</a\>\ .*/.*\</h1\>    ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/home:1/2\"\ class=\"list-item\"\>            ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/2.*\].*${_S}Title${_S}Two\</a\>\<br\>      ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1/1\"\ class=\"list-item\"\>                 ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/1.*\].*${_S}Title${_S}One\</a\>\<br\>      ]]
}

@test "'browse <folder-selector>' (no slash) serves the list as rendered HTML with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" add  "Example Folder/File One.md"  \
      --title     "Title One"                   \
      --content   "Example content."

    "${_NB}" add  "Example Folder/File Two.md"  \
      --title     "Title Two"                   \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Folder --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
      .*·.*\ \<a\ href=\"http://localhost:6789/home:\"\>home\</a\>\ .*:.*\              ]]
  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1/\"\>Example\ Folder\</a\>\ .*/.*\</h1\>  ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/home:1/2\"\ class=\"list-item\"\>          ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/2.*\].*${_S}Title${_S}Two\</a\>\<br\>    ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/home:1/1\"\ class=\"list-item\"\>               ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Folder/1.*\].*${_S}Title${_S}One\</a\>\<br\>    ]]
}

@test "'browse <notebook>:' serves the notebook contents as rendered HTML with links to internal web server URLs." {
  {
    "${_NB}" init

    "${_NB}" notebooks add "Example Notebook"

    "${_NB}" add  "Example Notebook:File One.md"  \
      --title     "Title One"                     \
      --content   "Example content."

    "${_NB}" add  "Example Notebook:File Two.md"  \
      --title     "Title Two"                     \
      --content   "Example content."
  }

  run "${_NB}" browse Example\ Notebook: --print

  printf "\${status}: '%s'\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ "${status}"  ==  0 ]]

  [[ "${output}"  =~  \
      \<h1\ class=\"header-crumbs\"\>.*\<a\ href=\"http://localhost:6789/\"\>\<span\ class=\"dim\"\>❯\</span\>nb\</a\>  ]]
  [[ "${output}"  =~  \
      .*·.*\ \<a\ href=\"http://localhost:6789/Example%20Notebook:\"\>Example\ Notebook\</a\>.*\</h1\>  ]]

  [[ "${output}"  =~  \
      \<p\>\<a\ href=\"http://localhost:6789/Example%20Notebook:2\"\ class=\"list-item\"\>  ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Notebook:2.*\].*${_S}Title${_S}Two\</a\>\<br\>      ]]

  [[ "${output}"  =~  \
      \<a\ href=\"http://localhost:6789/Example%20Notebook:1\"\ class=\"list-item\"\>       ]]
  [[ "${output}"  =~  .*\[.*Example${_S}Notebook:1.*\].*${_S}Title${_S}One\</a\>\<br\>      ]]
}
