---
layout: post
title: How to use Mibottle Blog
date: 2019-09-19
categories: Markdown
tags: [A kubernetes, group, team, role, rolebinding]
author: himang10
description: The read me page of jekyll-xixia.
---

## mibottle.github.io
[mibottle.github.io](https://mibottle.github.io/)을 사용하기 위해 [repository](https://github.com/mibottle/mibottle.github.io.git)를 clone 하면 됩니다.
`https://github.com/mibottle/mibottle.github.io/tree/master`로 연결하여 URL을 Clone하세요
```cli
$mkdir ~/GitHub
$cd ~/GitHub
$git clone [https://github.com/mibottle/mibottle.github.io/tree/master, Clone URL]
```
이 후 `mibottle.io/_post`아래에 작성하고자 하는 markdown file을 생성하면 됩니다.
markdown 작성법은 [markdown](https://mibottle.github.io/other/2019/09/12/markdown-writing-metho.html)을 참조하면 됩니다.

단 작성 시 아래의 header를 필이 작성해야 합니다.

```markdown
---
layout: post
title: github team으로 k8s group 설정하기
date: 2019-09-19
categories: kubernetes
tags: [A kubernetes, group, team, role, rolebinding]
author: himang10
description: The read me page of jekyll-xixia.
---
```
header 이후에 작성하고자 하는 설명을 정리한후 파일 명은 다음과 같이 작성하여 저장한다.

```filename
YYYY-MM-DD-filename.markdown
```

### 작성된 문서는 github에 add, commit push 실행
```
$git add YYYY-DD-MM-filename.markdown
$git commit -m "write first"
$git push -u origin master
```

### Markdown 전용 edit 사용
전용 Editor는 [MOU](http://25.io/mou/) 또는 한국사람이 만든 [Haroopad](http://pad.haroopress.com/)등이 있다. 
이중 하나를 골라서 사용하면 된다.


## git 사용법
```
# command line에서 최초 repository를 생성하고자 하는 경우
echo "# test.github.io" >> README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/mibottle/test.github.io.git
git push -u origin master

# 존재하는 repository에 add하고자 할 경우
git clone https://github.com/mibottle/test.github.io.git
git add README.md
git commit -m "second commit"
git push -u origin master

# 단수 업데이트
git commit README.md -m "TEST"
git push -u origin master
```
