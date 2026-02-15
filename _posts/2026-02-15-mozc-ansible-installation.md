---
layout: post
title: "Japanese input method configuration via ansible"
author: "Daniil"
tags: japan language ansible gnome fedora
excerpt_separator: <!--more-->
---

Hello there! I broke the OS during the last update and hence lost all my
configs. It was time I realized that IaC (aka. Infrastructure as Code) actually
makes sense. Apart from other configs I had Japanese input method I had been
struggling to configure before. So for the sake of all who like the Japanese
language I have decided to share ansible tasks for configuring it automatically.

<!--more-->

The requirements for the tasks:

* Fedora (I used Fedora 43).
* IBus input method framework.
* GNOME.

Here are the tasks:

```yaml
---
- name: Install mozc
  become: true
  dnf:
    name:
      - mozc
      - ibus-mozc
    state: present
- name: Restart ibus to make it recognize mozc
  shell: |
    ibus restart
- name: Add japanese input method
  shell: |
    current=$(gsettings get org.gnome.desktop.input-sources sources)
    echo $current | grep -q mozc-jp || \
    gsettings set org.gnome.desktop.input-sources sources \
    "${current%]}, ('ibus', 'mozc-jp')]"
    current=$(gsettings get org.gnome.desktop.input-sources mru-sources)
    echo $current | grep -q mozc-jp || \
    gsettings set org.gnome.desktop.input-sources mru-sources \
    "${current%]}, ('ibus', 'mozc-jp')]"
```

After running the tasks you should have `mozc` appended to your input methods,
e.g.:

![some-img]({{ site.baseurl }}/assets/images/2026-02-15-mozc-ansible-installation/input-methods.png)

じゃあ、また。
