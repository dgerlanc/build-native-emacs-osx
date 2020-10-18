# Building emacs native on OS X

This repository provides an `ansible` playbook to install the dependencies
required to compile `gccemacs` (native-compiled `emacs`) on OS X.

You must have `homebrew` and `ansible` installed to run these scripts.

To install the system dependencies, run

```bash
install-deps.sh
```

which, will run an `ansible` `playbook` that installs all of the system
dependencies.

Next, run

```bash
build.sh
```

to compile `gccemacs`.

Running `build.sh` creates `/Applications/Emacs-${TODAY}.app`, where `TODAY` is
an ISO-style date. You may use this application bundle or rename it to
`Emacs.app`. Running `build.sh` more than once per calendar day overwrites the
existing build.
