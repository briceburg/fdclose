
# fdclose

_fdclose_ intercepts a running process and closes a named file descriptor. It
uses `ptrace` and `close` system calls, and process execution continues normally
after the descriptor is closed.

## usage

* _fdclose_ is x86_64 bit **only** for now.
* depending on the process, you may need superuser or CAP_SYS_PTRACE cababilities.
* processes can be secured from tracing via `kernel.user_ptrace` and `kernel.user_ptrace_self`
* build with `make`, or install with `make install`
  ```sh
  cd /path/to/fdclose.git
  make

  # usage: fdclose <PID> <FD>
  #  e.g.: close file descriptor 3 from pid 1000 =>
  bin/fdclose 1000 3
  ```



## why

A process may hold a descriptor open to a file that has been deleted (unliked) preventing space used by the file from being freed. This becomes problematic when the deleted file is a huge log file and the disk is running out of space -- a situation that is [not uncommon](https://bugs.launchpad.net/oslo.log/+bug/1437444).


#### finding unlinked files

The quickest way to locate files that have been unlinked (deleted), but a process still holds a descriptor to them is via `lsof`. Alternatively you can use the `/proc` filesystem and grep for deleted files.

```
lsof +L1
```

#### alternatives

`gdb` supports executing a system call via `print` or `call`, and is easily installable through your package manager.


### history

I had an interview 'fail' where (amongst other things) I could not explain the mechanism for attaching to a running process and having it run a system call -- so I wrote
_fdclose_ to teach myself the internals...

It turns out `gdb`, `strace`, &c. all use the `ptrace` system call for attaching to and inspecting running processes. The kernel halts execution of the tracee (attached process) at the next system call for inspection by the tracer.

Inspecting the tracee is fairly straightforward, albiet with architectural gotchas. Running arbitrary shell code involves;
* low-level writing of memory containing the shell code
* manipulating registers to point to this
memory so the code is executed next
* restoring registers to their original location
to continue normal process execution

Probably sounds easy to a reverse engineer, but scary for me when having to look up `eax`, `edb`, `edc?`, and the difference between `eip` and `rip` (or x86 and x86_64). After a few tries I thankfully [found a library](https://github.com/emptymonkey/ptrace_do) to help make it happen. All this elicited a new-found and undying respect for `gdb` developers.


## reference

Some fine resources regarding `ptrace`, `gdb`, profiling, &c.

* bcc/BPF - [Give me 15 minutes and I'll change your view of Linux tracing](http://www.brendangregg.com/blog/2016-12-27/linux-tracing-in-15-minutes.html)
* gdb - [gdb Debugging Full Example](http://www.brendangregg.com/blog/2016-08-09/gdb-example-ncurses.html)
* go/ptrace - [ptrace in go - lock your thread!](https://github.com/golang/go/issues/7699#issuecomment-201582185)
* ptrace - [playing with ptrace (32bit)](http://www.linuxjournal.com/article/6210)
* ptrace - [how does strace work](https://blog.packagecloud.io/eng/2016/02/29/how-does-strace-work/)
* ptrace - [tracing tips with ptrace](http://pramode.net/articles/lfy/ptrace/pramode.html)
* pyflame - [uber engineering's ptracing profiler for python](https://eng.uber.com/pyflame/)
* python-ptrace - [high level python binding to ptrace](https://github.com/haypo/python-ptrace)
