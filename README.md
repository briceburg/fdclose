


## history

interview fail. (amongst others things) I could not explain the mechanism of
attaching to a running process and having it run a system call.

It turns out `gdb`, `strace`, &c. all use the `ptrace` system call for attaching and inspecting running processes. The kernel halts execution of the tracee (attached process) at the next system call for inspection by the tracer.

While inspecting the tracee is fairly straightforward, it turns out executing
arbitrary shell code is non-trivial. This involves low-level writing of memory
containing the shell code, manipulating the tracee's registers to point to this
memory so the code is executed, and then restoring the tracee's registers to their original location
to continue normal process execution. And you have to account for differences in architectures.
Probably sounds easy to a reverse engineer, but scary while looking up `eax`, `edb`, `edc?`, and the difference between `eip` and `rip`. I have a new-found respect for `gdb` developers and you should too!
