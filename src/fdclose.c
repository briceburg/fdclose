#define _GNU_SOURCE

#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "ptrace_do/libptrace_do.h"

int main(int argc, char **argv){
	int pid;
  int fd;

  struct ptrace_do *target;

  if(argc != 3){
		fprintf(stderr, "usage: %1$s <PID> <FD>\n"
                    " e.g.: close file descriptor 3 from pid 1000 => "
                    "%1$s 1000 3\n", program_invocation_short_name);
		exit(-1);
	}

  pid = strtol(argv[1],NULL,10);
  fd = strtol(argv[2],NULL,10);

  if (kill(pid, 0) != 0) {
    fprintf(stderr, "PID %d is invalid. Has the process stopped?\n", pid);
    exit(-1);
  }

  target = ptrace_do_init(pid);
  ptrace_do_syscall(target, __NR_close, fd, 0, 0, 0, 0, 0);
  ptrace_do_cleanup(target);
  return(0);
}
